const fs=require('fs'),path=require('path'),dir=__dirname;
let tb=fs.readFileSync(path.join(dir,'integration_tb.sv'),'utf8').split('initial begin\nreset_n')[0];
tb=tb.replace('module md_integration;','module before_integration;');
for(const n of ['md_out','md_in','md_set','md_valid'])tb=tb.replace(`.${n}(${n}),`,'');
for(const i of [1,2]){
 tb=tb.replace('sega_controller pad'+i+'(', 'legacy_pad pad'+i+'(');
 tb=tb.replace('sega_controller pad'+i+'ref(', 'legacy_pad #(.HOLD_FREEZE(1)) pad'+i+'ref(');
}
tb+=`initial begin
 reset_n=0;repeat(4)tick;reset_n=1;iorst=1;padreset=0;refreset=0;
 vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;video_state_out=22'h12345;
 padreset=1;refreset=1;put(8'hff);padreset=0;refreset=0;put(8'h55);
 repeat(2)begin put(8'hff);put(8'h55);end
 put(8'h77);repeat(37)tick;
 operation(1);saved=refstate;
 if(saved[19:17]!=3||saved[42:40]!=2)$fatal(1,"baseline phase setup");
 if(mem['h1a][63:38]!=={24'h484302,2'd2})$fatal(1,"not committed F02 format");
 put(8'h55);repeat(80545)tick;put(8'hff);operation(0);
 if(freeze_length<=80540)$fatal(1,"real transaction too short");
 if(md_out[19:17]!=0||md_out[42:40]!=0||pins1!==6'h3f||refpins1!==6'h30)$fatal(1,"baseline divergence missing");
 $display("CONFIRMED real DDRAM F08 T=80540: load freeze=%0d clocks; P1 DUT=%b reference=%b; saved P1 phase3 P2 phase2 both lost",freeze_length,pins1,refpins1);
 $display("PASS before integration (expected pre-fix defect)");$finish;
end
initial begin #50000000;$fatal(1,"watchdog");end
endmodule

// Observe original registers without driving them. Only the reference's clock
// is held to represent the uninterrupted logical save point. DUT uses the
// completely unmodified pre-F08 module and ignores the new interface signals.
module legacy_pad #(parameter HOLD_FREEZE=0)(input clk,reset,input[1:0]controller_type,input[5:0]sms_pins,input th,input md_a,md_start,md_x,md_y,md_z,md_mode,output[5:0]pins,input ss_freeze,ss_set,ss_valid,input[22:0]ss_in,output[22:0]ss_out);
 wire localclk=HOLD_FREEZE?(clk&&!ss_freeze):clk;
 sega_controller original(.clk(localclk),.reset(reset),.controller_type(controller_type),.sms_pins(sms_pins),.th(th),.md_a(md_a),.md_start(md_start),.md_x(md_x),.md_y(md_y),.md_z(md_z),.md_mode(md_mode),.pins(pins));
 assign ss_out={original.type_prev,original.th_prev,original.rises,original.timer};
endmodule
`;
fs.writeFileSync(path.join(dir,'before_integration_tb.sv'),tb);
let sim=fs.readFileSync(path.join(dir,'baseline/rtl/savestates.sv'),'utf8');
for(const name of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+name+';\\r?\\n','m'),d=sim.match(re)[0];sim=sim.replace(re,'').replace('// NVRAM size calculation helpers',d+'// NVRAM size calculation helpers');}
fs.writeFileSync(path.join(dir,'baseline_savestates_sim.sv'),sim);
fs.writeFileSync(path.join(dir,'before.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib before_work
vcom -work before_work -2008 -quiet baseline/rtl/io.vhd
vlog -work before_work -sv -quiet baseline_savestates_sim.sv baseline/rtl/sega_controller.sv before_integration_tb.sv
vsim -c -t 1ps before_work.before_integration
run -all
quit -code 0
`);
