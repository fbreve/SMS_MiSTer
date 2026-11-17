const fs=require('fs'),path=require('path'),d=__dirname;
function adapt(s,name){return s.replace('module lightgun','module '+name).replace('output       SENSOR','output reg   SENSOR').replace('output       TRIGGER','output reg   TRIGGER').replace('assign TARGET  = ~offscreen & draw;','').replace('always @(posedge CLK) begin','always @(posedge CLK) begin : beam').replace('\nendmodule','\nassign TARGET = ~offscreen & draw;\nendmodule');}
fs.writeFileSync(path.join(d,'direct_gun.sv'),adapt(fs.readFileSync(path.join(d,'../../rtl/lightgun.sv'),'utf8'),'direct_gun'));
fs.writeFileSync(path.join(d,'baseline_gun.sv'),adapt(fs.readFileSync(path.join(d,'baseline/rtl/lightgun.sv'),'utf8'),'baseline_gun'));
fs.writeFileSync(path.join(d,'direct.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib direct_work
vlog -work direct_work -sv -quiet direct_gun.sv baseline_gun.sv direct_tb.sv
vsim -c -t 1ps direct_work.direct_tb
run -all
quit -code 0
`);
