const fs=require('fs'),path=require('path'),d=__dirname;
require('./prepare_cpu.js');
let s=fs.readFileSync(path.join(d,'cpu_reach_tb.sv'),'utf8').replace(/(machine mapped\([^;]+?)\.mapper_in\(mapper_in\),/,'$1.mapper_in(mapper_in),.mapper_history_in(mapper_history_in),.mapper_history_out(mapper_history_out),');
s=s.replace('assign di=rom(physical);',"reg command=0;reg[7:0]guest_data=0;integer guest_reads=0;\nassign di=!iq?{7'd0,command}:rom(physical);\nalways @(posedge clk)if(!iq&&!wr&&addr[7:0]==8'h20&&!ss_freeze)begin guest_data<=data;guest_reads=guest_reads+1;end\n");
s=s.replace('12:rom=8\'hc3;13:rom=12;14:rom=0;',`12:rom=8'h3a;13:rom=8'h23;14:rom=8'h81;15:rom=8'hd3;16:rom=8'h20;17:rom=8'hdb;18:rom=0;19:rom=8'hb7;20:rom=8'h28;21:rom=8'hf6;22:rom=8'h3e;23:rom=7;24:rom=8'h32;25:rom=8'hff;26:rom=8'hff;27:rom=8'hc3;28:rom=12;29:rom=0;`);
s=s.replace('default:rom=0;',"default:rom=a[21:14];");
s=s.replace(".DIRSet(1'b0)",'.DIRSet(z80_set)').replace(".DIR(230'd0)",'.DIR(z80_dir)');
s=s.replace('wait(sega&&mapper_out[23:16]==3);repeat(100)tick;','wait(sega&&mapper_out[23:16]==3&&guest_data==3);repeat(100)tick;');
s=s.replace('$finish;\nend\ninitial begin repeat(2500000)',`wait(!ss_freeze);repeat(20)tick;
 command=1;wait(guest_data==7&&mapper_out[23:16]==7);command=0;repeat(100)tick;
 force dut.op_cooldown=0;tick;ss_load=1;tick;ss_load=0;wait(ss_freeze);wait(!ss_freeze);release dut.op_cooldown;
 guest_data=8'hff;wait(guest_data==3);repeat(100)tick;
 if(mapper_out[23:16]!==3||accepts!=2)$fatal(1,"real CPU mapped execution did not restore");
 $display("PASS FIXED F13 real T80/video EARLY%0d guest OUT data before03 perturbed07 restored03 reads%0d mapper%h history%h",EARLY,guest_reads,mapper_out,mapper_history_out);$finish;
end
initial begin repeat(6500000)`);
fs.writeFileSync(path.join(d,'cpu_fixed_tb.sv'),s);
fs.writeFileSync(path.join(d,'cpu_fixed.do'),fs.readFileSync(path.join(d,'cpu.do'),'utf8').replace('cpu_reach_tb.sv','cpu_fixed_tb.sv'));
