const fs=require('fs'),path=require('path'),d=__dirname;
let tb=fs.readFileSync(path.join(d,'history_tb.sv'),'utf8').split('reg[63:0]saved;')[0].replace('module history_tb;','module boundary_fixed_tb;\ninteger phase=0;').replace('cpu_ce=cycle%15==0','cpu_ce=(cycle+phase)%15==0');
tb+=`integer start,kind,accepted=0;
initial begin
 reset_n=0;repeat(4)tick;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'hf1300020;
 download(4,0);
 for(phase=0;phase<15;phase=phase+1)for(kind=0;kind<3;kind=kind+1)for(start=65515;start<=65535;start=start+5)begin
  reset_n=0;mrst=0;boot=0;ss_save=0;holdref=0;wr=1;mreq=1;repeat(4)tick;
  reset_n=1;mrst=1;repeat(3)tick;boot=1;bootcycle=cycle;repeat(3)tick;
  if(kind==1)put(16'hfffd,0,30);if(kind==2)put(16'h4000,0,30);
  repeat(start-(cycle-bootcycle))tick;mreq=0;addr=0;ss_save=1;tick;ss_save=0;
  wait(dut.state==66);tick;
  if(dut.mapper_snap!==mapper_out||dut.mapper_history_snap!==mapper_history_out)$fatal(1,"incoherent final mapper capture");
  if(sg0!==(kind==1))$fatal(1,"Sega evidence changed on SAVE");
  accepted=accepted+1;$display("BOUNDARY phase%0d kind%0d request%0d mapper%h history%h",phase,kind,start,mapper_out,mapper_history_out);
 end
 $display("PASS FIXED F13 phased boundary captures%0d coherent mapper/history",accepted);$finish;
end
initial begin repeat(18000000)tick;$fatal(1,"boundary watchdog");end
endmodule
`;
fs.writeFileSync(path.join(d,'boundary_fixed_tb.sv'),tb);
let script=fs.readFileSync(path.join(d,'run.do'),'utf8').replaceAll('work','boundary_fixed_work').replace('vcom -2008','vcom -work boundary_fixed_work -2008').replace('vlog -sv','vlog -work boundary_fixed_work -sv').replace('history_tb.sv','boundary_fixed_tb.sv').replace('boundary_fixed_work.history_tb -gCASE=$env(F13_CASE)','boundary_fixed_work.boundary_fixed_tb');
fs.writeFileSync(path.join(d,'boundary_fixed.do'),script);
