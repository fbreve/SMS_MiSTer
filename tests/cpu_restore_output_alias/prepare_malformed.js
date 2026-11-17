const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,src=p.join(d,'format'),dst=p.join(d,'malformed');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(src,'format_tb.sv'),'utf8'),start=s.indexOf('initial begin\n for(integer i=0;i<12288;i++)'),mon=s.indexOf('// Complete controller outputs:');assert(start>0&&mon>start);
s=s.slice(0,start)+`
initial begin
 for(integer i=0;i<12288;i++)mem[i]=0;
 bg_live=0;bg2_live=0;repeat(4)tick;reset_n=1;transfer(1);transfer(0);
 if(!guest_writes)$fatal(1,"valid initial LOAD");
 // Each rejection occurs after CPU words have already changed private S.
 // Keep NMI/restart/padding valid; change the architectural CPU payload only.
 mem[2]=64'h0123456789abcdef;mem[3]=64'hfedcba9876543210;mem[4]=64'h554433221100ffee;
 mem[5][37:0]=38'h2a5a5a5a5a;
 for(integer b=0;b<64;b++)reject_bit('h2997,b);
 for(integer b=0;b<64;b++)reject_bit('h32,b);
 for(integer b=11;b<64;b++)reject_bit('h35,b);
 for(integer b=48;b<64;b++)reject_bit('h22,b);
 // Late semantic invalid positions, owner/phase flags, and descriptor bits.
 for(integer b=4;b<64;b++)reject_bit('h2f,b);
 for(integer b=0;b<64;b++)reject_bit('h2e,b);
 transfer(0);if(!guest_writes)$fatal(1,"recovery after late malformed private CPU data");
 for(integer rep=0;rep<3;rep++)begin transfer(0);if(!guest_writes)$fatal(1,"repeated LOAD after late rejection");end
 $display("PASS ALIAS MALFORMED rejected%0d recoveryLoads4",rejections);$finish;
end
initial begin #1000000000;$fatal(1,"malformed watchdog");end
`+s.slice(mon);
fs.writeFileSync(p.join(dst,'format_tb.sv'),s);
// A production-rate /15 enable for the attached consumer; controller inputs,
// every-edge comparisons, all rejection oracles and case count are unchanged.
s=s.replace('always #5 clk=~clk;',`reg[3:0]observe_phase=0;wire observe_tick=observe_phase==0;always@(posedge clk)begin if(!reset_n||observe_phase==14)observe_phase<=0;else observe_phase<=observe_phase+1'b1;end\nalways #5 clk=~clk;`);
for(const[n,ct]of[['b','dut'],['a','alias_ctl']])s=s.replace(`.CEN(!${ct}.ss_freeze||(${ct}.ss_cpu_prepare&&${n}_replay))`,`.CEN(observe_tick&&(!${ct}.ss_freeze||(${ct}.ss_cpu_prepare&&${n}_replay)))`);
fs.writeFileSync(p.join(dst,'format_tb.sv'),s);
for(const f of['savestates_sim.sv','candidate_sim.sv','T80_sim.vhd','T80s_sim.vhd','run.do'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
console.log('Prepared 321 focused late-metadata rejection cases with changed private CPU data; existing exhaustive BG regression preserved.');
