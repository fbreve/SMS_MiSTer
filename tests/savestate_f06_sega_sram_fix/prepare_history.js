const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'history');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(d,'shared/shared_tb.sv'),'utf8');s=s.slice(0,s.indexOf('reg[7:0]v1['));
s=s.replace('module shared_tb;','module history_tb;');
s=s.replace('savestates #(.TB_FAST(1)) dut(',`reg[2:0]nmi_model=1,saved_nmi;wire[2:0]nmi_restored;wire nmi_valid;
reg[17:0]history_model=18'h0ffff,saved_history;wire[17:0]history_restored;
savestates #(.TB_FAST(1)) dut(.z80_nmi_dir(nmi_restored),.z80_nmi_valid(nmi_valid),`)
 .replace(".z80_nmi(3'b001)",'.z80_nmi(nmi_model)')
 .replace(".mapper_history_out(18'h0ffff)",'.mapper_history_out(history_model)').replace('.mapper_history_in()', '.mapper_history_in(history_restored)');
s+=`integer profile,nmi_sets=0,history_sets=0;
always@(posedge clk)begin
 if(z80_set)begin if(!nmi_valid||nmi_restored!==saved_nmi)$fatal(1,"v18 NMI payload/valid");nmi_sets++;end
 if(mapper_set)begin if(history_restored!==saved_history)$fatal(1,"v18 mapper history");history_sets++;end
end
initial begin
 for(integer j=0;j<12288;j++)mem[j]=0;repeat(4)tick;reset_n=1;
 for(profile=0;profile<8;profile++)begin
  systeme=profile&1;clkd=profile%4==0?0:profile%4==1?10:profile%4==2?20:25;
  nmi_model=profile;history_model=18'h1234+((profile%4)<<16);
  evolution_out=160'h00000000000000000000891234568912e1322468;evolution_out[155:153]=profile;
  saved_nmi=nmi_model;saved_history=history_model;
  transfer(1);repeat(3)transfer(0);
  if(evolution_in!==evolution_out)$fatal(1,"v18 Evolution pending/history");
  $display("PASS HISTORY profile%0d nmi%h mapper%h EvolutionPending%0d SystemE%b",profile,saved_nmi,saved_history,profile,systeme);
 end
 if(nmi_sets!=24||history_sets!=24)$fatal(1,"restore strobe counts");
 $display("PASS HISTORY COMPLETE NMI8 mapper4 EvolutionPending8 loads24");$finish;
end
initial begin #100000000;$fatal(1,"history watchdog");end
endmodule
`;
fs.writeFileSync(p.join(dst,'history_tb.sv'),s);
fs.writeFileSync(p.join(dst,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')('rtl/savestates.sv'));
fs.writeFileSync(p.join(dst,'run.do'),'onerror {quit -code 1}\nvlib work\nvlog -sv -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv history_tb.sv\nvsim -c -t 1ps work.history_tb\nrun -all\nquit -code 0\n');
