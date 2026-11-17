`timescale 1ns/1ps
module native_tb;
reg clk=0;always #5 clk=~clk;reg rst=1,ce=0,freeze=0,wr1=1,wr2=1,detwr=1,balwr=1;reg[7:0]din=0;
reg [31:0]rng=32'h187cda39;integer cycles=0,checks=0,nonzero=0,stereo=0,control_changes=0,reset_cases=0;reg[10:0]prevcontrols=0;
wire[10:0] A_control;wire[55:0]A_cfg1,A_cfg2;wire signed[10:0]A_l1,A_r1,A_l2,A_r2;wire signed[15:0]A_al,A_ar;
A_jt89 A1(.clk(clk),.rst(rst),.clk_en(ce&&!freeze),.wr_n(wr1),.din(din),.mux(A_control[7:0]),.soundL(A_l1),.soundR(A_r1),.ready(),.ss_out(A_cfg1),.ss_in(56'd0),.ss_set(1'b0),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_in(4'd0),.ss_ext_out(),.ss_div_out(),.ss_quiescent());
A_jt89 A2(.clk(clk),.rst(rst),.clk_en(ce&&!freeze),.wr_n(wr2),.din(din),.mux(8'hff),.soundL(A_l2),.soundR(A_r2),.ready(),.ss_out(A_cfg2),.ss_in(56'd0),.ss_set(1'b0),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_in(4'd0),.ss_ext_out(),.ss_div_out(),.ss_quiescent());
A_controls Actl(.clk_sys(clk),.RESET_n(!rst),.ss_freeze(freeze),.psg_set(1'b0),.audio_ext_set(1'b0),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(11'd0),.audio_control_out(A_control));
A_AudioMix Amix(.clk(clk),.audio_in_l1({A_l1,5'd0}),.audio_in_r1({A_r1,5'd0}),.audio_in_l2({A_l2,5'd0}),.audio_in_r2({A_r2,5'd0}),.audio_l(A_al),.audio_r(A_ar),.ss_phase_out(),.ss_phase_in(1'b0),.ss_phase_set(1'b0));
wire[10:0] B_control;wire[55:0]B_cfg1,B_cfg2;wire signed[10:0]B_l1,B_r1,B_l2,B_r2;wire signed[15:0]B_al,B_ar;
B_jt89 B1(.clk(clk),.rst(rst),.clk_en(ce&&!freeze),.wr_n(wr1),.din(din),.mux(B_control[7:0]),.soundL(B_l1),.soundR(B_r1),.ready(),.ss_out(B_cfg1),.ss_in(56'd0),.ss_set(1'b0));
B_jt89 B2(.clk(clk),.rst(rst),.clk_en(ce&&!freeze),.wr_n(wr2),.din(din),.mux(8'hff),.soundL(B_l2),.soundR(B_r2),.ready(),.ss_out(B_cfg2),.ss_in(56'd0),.ss_set(1'b0));
B_controls Bctl(.clk_sys(clk),.RESET_n(!rst),.ss_freeze(freeze),.psg_set(1'b0),.audio_ext_set(1'b0),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(11'd0),.audio_control_out(B_control));
B_AudioMix Bmix(.clk(clk),.audio_in_l1({B_l1,5'd0}),.audio_in_r1({B_r1,5'd0}),.audio_in_l2({B_l2,5'd0}),.audio_in_r2({B_r2,5'd0}),.audio_l(B_al),.audio_r(B_ar));
wire[10:0] C_control;wire[55:0]C_cfg1,C_cfg2;wire signed[10:0]C_l1,C_r1,C_l2,C_r2;wire signed[15:0]C_al,C_ar;
C_jt89 C1(.clk(clk),.rst(rst),.clk_en(ce&&!freeze),.wr_n(wr1),.din(din),.mux(C_control[7:0]),.soundL(C_l1),.soundR(C_r1),.ready(),.ss_out(C_cfg1),.ss_in(56'd0),.ss_set(1'b0));
C_jt89 C2(.clk(clk),.rst(rst),.clk_en(ce&&!freeze),.wr_n(wr2),.din(din),.mux(8'hff),.soundL(C_l2),.soundR(C_r2),.ready(),.ss_out(C_cfg2),.ss_in(56'd0),.ss_set(1'b0));
C_controls Cctl(.clk_sys(clk),.RESET_n(!rst),.ss_freeze(freeze),.psg_set(1'b0),.audio_ext_set(1'b0),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(11'd0),.audio_control_out(C_control));
C_AudioMix Cmix(.clk(clk),.audio_in_l1({C_l1,5'd0}),.audio_in_r1({C_r1,5'd0}),.audio_in_l2({C_l2,5'd0}),.audio_in_r2({C_r2,5'd0}),.audio_l(C_al),.audio_r(C_ar));
task tick;begin @(negedge clk);#1;cycles=cycles+1;end endtask
task put(input integer chip,input[7:0]b);begin din=b;wr1=chip==1?0:1;wr2=chip==2?0:1;repeat(2)tick;wr1=1;wr2=1;repeat(2)tick;end endtask
always @(posedge clk)begin #1;
 if(!rst&&cycles>10)begin
 if({A_cfg1,A_cfg2,A_control,A_l1,A_r1,A_l2,A_r2,A_al,A_ar}!=={B_cfg1,B_cfg2,B_control,B_l1,B_r1,B_l2,B_r2,B_al,B_ar})$fatal(1,"B native operation mismatch cycle=%0d",cycles);
 if({A_cfg1,A_cfg2,A_control,A_l1,A_r1,A_l2,A_r2,A_al,A_ar}!=={C_cfg1,C_cfg2,C_control,C_l1,C_r1,C_l2,C_r2,C_al,C_ar})$fatal(1,"C native operation mismatch cycle=%0d",cycles);
 if(^({A_l1,A_r1,A_l2,A_r2,A_al,A_ar})===1'bx)$fatal(1,"unknown audio");
 checks=checks+1;if(A_al!=0||A_ar!=0)nonzero=nonzero+1;if(A_al!=A_ar)stereo=stereo+1;if(A_control!=prevcontrols)control_changes=control_changes+1;prevcontrols=A_control;
 end
end
initial begin
 repeat(5)tick;rst=0;ce=1;
 // Tone periods include the sample-playback boundary and the largest reload.
 for(integer tone=0;tone<9;tone=tone+1)begin
  put(1,8'h80|(tone==8?15:tone));put(1,tone==8?8'h3f:0);put(1,8'h91);put(1,8'he0|(tone%8));put(1,8'hf2);
  put(2,8'haf);put(2,8'h17);put(2,8'hb3);put(2,8'he0|(tone%8));put(2,8'hf1);
  repeat(22000)begin
   rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};ce=cycles%3==0;freeze=cycles%997<37;
   if(cycles%131==0)begin din=rng[7:0];detwr=0;end else detwr=1;
   if(cycles%137==0)begin din=rng[15:8];balwr=0;end else balwr=1;
   tick;
  end
  freeze=0;detwr=1;balwr=1;rst=1;repeat(3)tick;rst=0;reset_cases=reset_cases+1;
 end
 if(checks<190000||nonzero<1000||stereo<1000||control_changes<100)$fatal(1,"native coverage");
 $display("PASS native A/B/C: cycles=%0d checks=%0d nonzero=%0d stereo=%0d control_changes=%0d resets=%0d dual_PSG exact config/sample/mixer/control equivalence",cycles,checks,nonzero,stereo,control_changes,reset_cases);$finish;
end
endmodule
