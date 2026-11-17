`timescale 1ns/1ps
module replay;
parameter T=64;
localparam W=((T<2)?1:$clog2(T))+6;
reg clk=0;always #5 clk=~clk;
reg reset=1,refreset=1,freeze=0,holdref=0,set=0,valid=1,th=1;
reg [1:0] kind=2;reg [3:0] buttons=0;reg [5:0] sms=6'h35;
reg [W-1:0] saved=0;wire [W-1:0] state,refstate;wire [5:0] pins,refpins;
sega_controller #(.TIMEOUT_CYCLES(T)) dut(.clk(clk),.reset(reset),.controller_type(kind),.sms_pins(sms),.th(th),.md_a(1'b0),.md_start(1'b1),.md_x(buttons[1]),.md_y(buttons[2]),.md_z(buttons[3]),.md_mode(buttons[0]),.pins(pins),.ss_freeze(freeze),.ss_set(set),.ss_valid(valid),.ss_in(saved),.ss_out(state));
sega_controller #(.TIMEOUT_CYCLES(T)) reference(.clk(clk),.reset(refreset),.controller_type(kind),.sms_pins(sms),.th(th),.md_a(1'b0),.md_start(1'b1),.md_x(buttons[1]),.md_y(buttons[2]),.md_z(buttons[3]),.md_mode(buttons[0]),.pins(refpins),.ss_freeze(holdref),.ss_set(1'b0),.ss_valid(1'b0),.ss_in({W{1'b0}}),.ss_out(refstate));
task tick;begin @(negedge clk);#1;end endtask
task check;begin if(pins!==refpins||state!==refstate)$fatal(1,"replay T=%0d kind=%d phase=%d low=%d near=%d buttons=%h state=%h ref=%h pins=%b/%b",T,kind,phase,low,near,buttons,state,refstate,pins,refpins);end endtask
task roundtrip;begin
 freeze=1;holdref=1;saved=state;
 // Transport must exceed even the real timeout without consuming protocol time.
 repeat(T+5)tick;if(state!==saved)$fatal(1,"freeze advanced timer/history");
 freeze=0;reset=1;tick;reset=0;th=~th;repeat(7)tick;th=~th;
 freeze=1;set=1;tick;set=0;if(state!==saved)$fatal(1,"restore not exact");
 freeze=0;holdref=0;check;
end endtask
integer mode,phase,low,near,b,i,cases=0;
initial begin
 for(mode=0;mode<4;mode=mode+1)
 for(phase=0;phase<=4;phase=phase+1)
 for(low=0;low<2;low=low+1)
 for(near=0;near<4;near=near+1)
 for(b=0;b<(T==64?16:1);b=b+1)begin
 kind=mode;buttons=b;reset=1;refreset=1;th=1;repeat(2)tick;reset=0;refreset=0;tick;
 repeat(phase)begin th=0;tick;th=1;tick;end
 if(low)begin th=0;tick;end
 if(mode==2&&near>0)begin
 while(dut.timer<T-2)tick;
 repeat(near-1)tick;
 end
 roundtrip;
 // Immediate edge, input changes, late timeout, and type transitions.
 for(i=0;i<T+8;i=i+1)begin
 if(i<8||i>T)th=~th;
 buttons=(b+i)%16;sms=i;tick;check;
 end
 roundtrip;th=~th;tick;check;
 kind=1;tick;check;kind=2;tick;check;
 reset=1;refreset=1;tick;check;reset=0;refreset=0;
 cases=cases+1;
 end
 // Capture between an input transition and its sampling clock. Exact edge/type
 // history must survive; reconstructing either from the new input loses a step.
 kind=2;th=0;reset=1;refreset=1;tick;reset=0;refreset=0;tick;
 th=1;roundtrip;tick;check;
 kind=1;roundtrip;tick;check;
 th=0;tick;kind=2;th=1;roundtrip;tick;check;
 // Legacy normalization samples current inputs, ignoring discarded history.
 valid=0;freeze=1;holdref=1;set=1;th=0;kind=2;tick;set=0;
 if(dut.timer!=0||dut.rises!=0||dut.th_prev!=0||dut.type_prev!=2)$fatal(1,"legacy normalization");
 freeze=0;th=1;tick;if(dut.rises!=1)$fatal(1,"legacy first edge");
 $display("PASS replay T=%0d cases=%0d repeated snapshots; all states/pins compared",T,cases);$finish;
end
endmodule
