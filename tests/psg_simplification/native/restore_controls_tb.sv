`timescale 1ns/1ps
module restore_controls_tb;
reg clk=0;always #5 clk=~clk;reg reset_n=0,freeze=0,restore=0,detwr=1,balwr=1,gg=0,systeme=0;reg[7:0]din=0;reg[10:0]saved;
integer persistent=0,fm_differences=0,stereo_differences=0,checks=0;
wire[10:0]Actl;wire signed[10:0]Al,Ar;wire[12:0]Afm,Aml,Amr,Am2l,Am2r;wire Adisable;
A_controls Acontrol(.clk_sys(clk),.RESET_n(reset_n),.ss_freeze(freeze),.psg_set(restore),.audio_ext_set(restore),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(saved),.audio_control_out(Actl));
A_jt89 Apsg(.clk(clk),.clk_en(1'b1),.rst(!reset_n),.wr_n(1'b1),.din(8'd0),.mux(Actl[7:0]),.soundL(Al),.soundR(Ar),.ready(),.ss_out(),.ss_in({4'd0,3'd0,3'd4,4'd15,4'd15,4'd15,4'd1,10'd0,10'd0,10'd1}),.ss_set(restore),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_in(4'd0),.ss_ext_out(),.ss_div_out(),.ss_quiescent());
routing Aroute(.fm_ena(1'b1),.mapper_evolution(1'b0),.systeme(systeme),.gg(gg),.det_D(Actl[10:8]),.psg_enables(2'd0),.PSG_outL(Al),.PSG_outR(Ar),.PSG2_outL(11'd111),.PSG2_outR(11'd222),.FM_out(14'd321),.FM_gated(Afm),.mix_inL(Aml),.mix_inR(Amr),.mix2_inL(Am2l),.mix2_inR(Am2r),.PSG_disable(Adisable));
wire[10:0]Bctl;wire signed[10:0]Bl,Br;wire[12:0]Bfm,Bml,Bmr,Bm2l,Bm2r;wire Bdisable;
B_controls Bcontrol(.clk_sys(clk),.RESET_n(reset_n),.ss_freeze(freeze),.psg_set(restore),.audio_ext_set(restore),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(saved),.audio_control_out(Bctl));
B_jt89 Bpsg(.clk(clk),.clk_en(1'b1),.rst(!reset_n),.wr_n(1'b1),.din(8'd0),.mux(Bctl[7:0]),.soundL(Bl),.soundR(Br),.ready(),.ss_out(),.ss_in({4'd0,3'd0,3'd4,4'd15,4'd15,4'd15,4'd1,10'd0,10'd0,10'd1}),.ss_set(restore));
routing Broute(.fm_ena(1'b1),.mapper_evolution(1'b0),.systeme(systeme),.gg(gg),.det_D(Bctl[10:8]),.psg_enables(2'd0),.PSG_outL(Bl),.PSG_outR(Br),.PSG2_outL(11'd111),.PSG2_outR(11'd222),.FM_out(14'd321),.FM_gated(Bfm),.mix_inL(Bml),.mix_inR(Bmr),.mix2_inL(Bm2l),.mix2_inR(Bm2r),.PSG_disable(Bdisable));
wire[10:0]Cctl;wire signed[10:0]Cl,Cr;wire[12:0]Cfm,Cml,Cmr,Cm2l,Cm2r;wire Cdisable;
C_controls Ccontrol(.clk_sys(clk),.RESET_n(reset_n),.ss_freeze(freeze),.psg_set(restore),.audio_ext_set(restore),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(saved),.audio_control_out(Cctl));
C_jt89 Cpsg(.clk(clk),.clk_en(1'b1),.rst(!reset_n),.wr_n(1'b1),.din(8'd0),.mux(Cctl[7:0]),.soundL(Cl),.soundR(Cr),.ready(),.ss_out(),.ss_in({4'd0,3'd0,3'd4,4'd15,4'd15,4'd15,4'd1,10'd0,10'd0,10'd1}),.ss_set(restore));
routing Croute(.fm_ena(1'b1),.mapper_evolution(1'b0),.systeme(systeme),.gg(gg),.det_D(Cctl[10:8]),.psg_enables(2'd0),.PSG_outL(Cl),.PSG_outR(Cr),.PSG2_outL(11'd111),.PSG2_outR(11'd222),.FM_out(14'd321),.FM_gated(Cfm),.mix_inL(Cml),.mix_inR(Cmr),.mix2_inL(Cm2l),.mix2_inR(Cm2r),.PSG_disable(Cdisable));
task tick;begin @(negedge clk);#1;end endtask
task write_controls(input[10:0]v);begin din={5'd0,v[10:8]};detwr=0;tick;detwr=1;din=v[7:0];balwr=0;tick;balwr=1;tick;end endtask
initial begin
 repeat(5)tick;reset_n=1;tick;
 for(integer mode=0;mode<8;mode=mode+1)begin
  saved={3'(mode),8'h01};write_controls({3'(mode^7),8'h10});
  freeze=1;restore=1;tick;restore=0;freeze=0;repeat(50)tick;
  for(integer i=0;i<2000;i=i+1)begin
   gg=mode%2;systeme=(mode/2)%2;tick;
   if({Actl,Afm,Aml,Amr,Am2l,Am2r,Adisable}!=={Cctl,Cfm,Cml,Cmr,Cm2l,Cm2r,Cdisable})$fatal(1,"C control/routing restore");
   if(Bctl===Actl)$fatal(1,"missing intentional B control loss");persistent=persistent+1;
   if(Bfm!==Afm)fm_differences=fm_differences+1;
   if({Bl,Br}!=={Al,Ar})stereo_differences=stereo_differences+1;
   if(Al!==0||Ar!==203||Bl!==203||Br!==0)$fatal(1,"GG stereo side assignment");
   checks=checks+1;
  end
 end
 if(persistent!=16000||fm_differences!=16000||stereo_differences!=16000)$fatal(1,"control coverage");
 $display("PASS control consumers: checks=%0d C_matches_master=%0d B_persistent_control=%0d B_FM_gate=%0d B_swapped_stereo=%0d SMS/GG/SystemE det_values0..7",checks,checks,persistent,fm_differences,stereo_differences);$finish;
end
endmodule
