const fs=require('fs'),path=require('path'),d=__dirname;
let prefix=fs.readFileSync(path.join(d,'history_tb.sv'),'utf8').split('reg mrst=')[0].replace('module history_tb;','module boundary_tb;');
let scenario=fs.readFileSync(path.join(d,'scenario.sv.in'),'utf8').split('reg[63:0]saved;')[0];
fs.writeFileSync(path.join(d,'boundary_tb.sv'),prefix+scenario+`
integer start,kind;integer accepted=0;
initial begin
 reset_n=0;repeat(4)tick;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'hf1300002;
 download(4,0);
 for(kind=0;kind<3;kind=kind+1)begin
  for(start=65480;start<=65540;start=start+1)begin
   reset_n=0;mrst=0;boot=0;ss_save=0;holdref=0;wr=1;mreq=1;
   repeat(4)tick;reset_n=1;mrst=1;repeat(3)tick;boot=1;bootcycle=cycle;repeat(3)tick;
   if(kind==1)put(16'hfffd,0,30);
   if(kind==2)put(16'h4000,0,30);
   repeat(start-(cycle-bootcycle))tick;
   mreq=0;addr=0;ss_save=1;tick;ss_save=0;
   wait(ss_freeze);tick;
   if(dut.mapper_snap!==mapper_out)$fatal(1,"capture payload differs from live mapper");
   if(sg0!==(kind==1))$fatal(1,"Sega history unexpectedly changed");
   accepted=accepted+1;
   $display("BOUNDARY kind%0d request_age%0d capture_age%0d mapper%h sega%0d",kind,start,cycle-bootcycle,mapper_out,sg0);
  end
 end
 $display("PASS F13 boundary sweep %0d accepted captures",accepted);$finish;
end
initial begin repeat(15000000)tick;$fatal(1,"boundary watchdog");end
endmodule
`);
let script=fs.readFileSync(path.join(d,'run.do'),'utf8').replaceAll('work','boundary_work').replace('vcom -2008','vcom -work boundary_work -2008').replace('vlog -sv','vlog -work boundary_work -sv').replace('history_tb.sv','boundary_tb.sv').replace('boundary_work.history_tb -gCASE=$env(F13_CASE)','boundary_work.boundary_tb');
script=script.replace('run -all',`when {/boundary_tb/ss_freeze == 1} {echo "HISTORY ticks=[examine -radix unsigned /boundary_tb/loaded_machine/mapper_detect_inst/mapper_detect_ticks] bank=[examine /boundary_tb/loaded_machine/mapper_detect_inst/bank_write_seen] sega=[examine /boundary_tb/loaded_machine/mapper_detect_inst/sega_mapper_write_seen] wonderkid_count=[examine -radix unsigned /boundary_tb/loaded_machine/mapper_detect_inst/wonderkid_write_count]"}\nrun -all`);
fs.writeFileSync(path.join(d,'boundary.do'),script);
