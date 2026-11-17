const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const src=p.join(d,'format'),dst=p.join(d,'errors');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(src,'format_tb.sv'),'utf8');const start=s.indexOf('initial begin\n for(integer i=0;i<12288;i++)');assert(start>0);
const mon=s.indexOf('// Complete controller outputs:');assert(mon>start);
s=s.slice(0,start)+`
reg drop_response=0;integer before_consumes;
initial begin
 for(integer i=0;i<12288;i++)mem[i]=0;
 bg_live=0;bg2_live=0;repeat(4)tick;reset_n=1;transfer(1);transfer(0);
 for(integer fault=0;fault<2;fault++)begin
  before_consumes=alias_consumes;
  fork
   begin transfer(0);end
   begin
    if(fault==0)wait(dut.dout_expected);
    else begin wait(DDRAM_RD&&DDRAM_ADDR==29'h07c00032&&!DDRAM_BUSY);wait(dut.dout_expected);end
    drop_response=1;force dut.ddram_watchdog=25'h1ffffff;force alias_ctl.ddram_watchdog=25'h1ffffff;
    tick;release dut.ddram_watchdog;release alias_ctl.ddram_watchdog;
   end
  join
  if(alias_consumes!=before_consumes)$fatal(1,"timeout applied CPU state");
  drop_response=0;repeat(10)tick;transfer(0);
  if(alias_consumes!=before_consumes+1)$fatal(1,"timeout recovery did not LOAD");
  $display("PASS ALIAS TIMEOUT location%0d recovery",fault);
 end
 // Asynchronous reset during private parsing, then ordinary successful LOAD.
 before_consumes=alias_consumes;
 force dut.op_cooldown=0;force alias_ctl.op_cooldown=0;ss_load=1;tick;ss_load=0;
 wait(dut.dout_expected);reset_n=0;tick;release dut.op_cooldown;release alias_ctl.op_cooldown;reset_n=1;
 repeat(10)tick;transfer(0);
 if(alias_consumes!=before_consumes+1)$fatal(1,"reset recovery consuming count");
 $display("PASS ALIAS ERRORS ALL timeouts2 recoveries3 reset_private");$finish;
end
initial begin #1000000000;$fatal(1,"error witness watchdog");end
`+s.slice(mon);
s=s.replace('if(pending==1)begin DDRAM_DOUT','if(pending==1&&!drop_response)begin DDRAM_DOUT').replace('if(pending==0&&!DDRAM_RD&&bus_rng','if(!drop_response&&pending==0&&!DDRAM_RD&&bus_rng');
s=s.replace('reg drop_response=0;integer before_consumes;','integer before_consumes;');
const decl=s.match(/integer alias_cycles=[^;]+;/)[0];s=s.replace(decl,'').replace('module vdp_tb;','module vdp_tb;\nreg drop_response=0;\n'+decl);
fs.writeFileSync(p.join(dst,'format_tb.sv'),s);
for(const f of['savestates_sim.sv','candidate_sim.sv','T80_sim.vhd','T80s_sim.vhd','run.do'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
console.log('Prepared explicit header/late-metadata watchdog expiration and private-reset recovery witnesses.');
