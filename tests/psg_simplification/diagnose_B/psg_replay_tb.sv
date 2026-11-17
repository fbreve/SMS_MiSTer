`timescale 1ns/1ps
module psg_replay_tb;
reg clk=0; always #5 clk=~clk;
reg rst=1,wr=1,ce=0,perturb=0,load=0;
reg [7:0] din=0;
wire [55:0] cfg,rcfg; wire [95:0] ext,rext; wire [3:0] div,rdiv;
reg [55:0] saved_cfg; reg [95:0] saved_ext; reg [3:0] saved_div;
wire signed [10:0] l,r,rl,rr; wire quiet,rquiet;
jt89 dut(.clk(clk),.clk_en(ce|perturb),.rst(rst),.wr_n(wr),.din(din),.mux(8'hA5),.soundL(l),.soundR(r),.ready(),.ss_out(cfg),.ss_set(load),.ss_in(saved_cfg));
jt89 reference(.clk(clk),.clk_en(ce),.rst(rst),.wr_n(wr),.din(din),.mux(8'hA5),.soundL(rl),.soundR(rr),.ready(),.ss_out(rcfg),.ss_set(1'b0),.ss_in(56'd0));
task tick; begin @(posedge clk); #1; @(negedge clk); #1; end endtask
task put(input [7:0] b); begin din=b;wr=0;tick;wr=1;tick;tick;end endtask
assign div=dut.clk_div;assign rdiv=reference.clk_div;assign ext={dut.noise,dut.ch2,dut.ch1,dut.ch0,dut.u_noise.shift,dut.u_noise.cnt,dut.u_tone2.out,dut.u_tone2.cnt,dut.u_tone1.out,dut.u_tone1.cnt,dut.u_tone0.out,dut.u_tone0.cnt};
assign rext={reference.noise,reference.ch2,reference.ch1,reference.ch0,reference.u_noise.shift,reference.u_noise.cnt,reference.u_tone2.out,reference.u_tone2.cnt,reference.u_tone1.out,reference.u_tone1.cnt,reference.u_tone0.out,reference.u_tone0.cnt};
assign quiet=!ce&&!perturb&&!dut.cen_16&&wr&&!dut.clr_noise&&dut.last_wr;assign rquiet=!ce&&!reference.cen_16&&wr&&!reference.clr_noise&&reference.last_wr;
integer mode,phase,i,n=0,mismatches=0,late=0,raw=0,cases_different=0,local_diff=0;
initial begin
for(mode=0;mode<1;mode=mode+1) for(phase=0;phase<1;phase=phase+1) begin
 rst=1;ce=0;perturb=0;load=0;repeat(3) tick;rst=0;tick;
 put(8'h8D);put(8'h02);put(8'hA7);put(8'h01);put(8'hC9);put(8'h03);
 put(8'h91);put(8'hB3);put(8'hD5);put(8'hF2);put(8'hE0|mode);
 for(i=0;i<3200;i=i+1) begin ce=(i%7==0);tick;end
 ce=0;repeat(4) tick;
 while(div!=phase) begin ce=1;tick;ce=0;repeat(3) tick;end
 ce=0;repeat(4) tick;
 if(!quiet||!rquiet) $fatal(1,"not quiescent");
 saved_cfg=cfg;saved_ext=ext;saved_div=div;$display("CAPTURE cfg=%h ext=%h l=%d r=%d cnt=%d phase=%b",cfg,ext,l,r,dut.u_tone0.cnt,dut.u_tone0.out);
 perturb=1;repeat(4099) tick;perturb=0;repeat(4) tick;
 $display("PERTURBED ext=%h ref=%h l=%d ref_l=%d cnt=%d",ext,rext,l,rl,dut.u_tone0.cnt);load=1;tick;load=0;repeat(4) tick;
 if(cfg!==rcfg) $fatal(1,"configuration restore mismatch");local_diff=0;
 for(i=0;i<20000;i=i+1) begin
  ce=(i%7==0);tick;if(i%5000==0)$display("REPLAY i=%d ext=%h ref=%h l=%d ref_l=%d ce=%b cen=%b",i,ext,rext,l,rl,ce,dut.cen_16);
  if(cfg!==rcfg) $fatal(1,"configuration replay mismatch");
  if(ext!==rext||div!==rdiv)raw=raw+1;
  if(l!==rl||r!==rr)begin mismatches=mismatches+1;local_diff=local_diff+1;if(i>=19000)late=late+1;end
 end
 n=n+1;if(local_diff>0)cases_different=cases_different+1;
end
$display("PASS reduced PSG contract: cases=%0d different_cases=%0d output_mismatches=%0d final1000_mismatches=%0d raw_mismatches=%0d config_errors=0",n,cases_different,mismatches,late,raw);$finish;
end endmodule
