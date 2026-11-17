`timescale 1ns/1ps
module psg_replay_tb;
reg clk=0; always #5 clk=~clk;
reg rst=1,wr=1,ce=0,perturb=0,load=0;
reg [7:0] din=0;
wire [55:0] cfg,rcfg; wire [95:0] ext,rext; wire [3:0] div,rdiv;
reg [55:0] saved_cfg; reg [95:0] saved_ext; reg [3:0] saved_div;
wire signed [10:0] l,r,rl,rr; wire quiet,rquiet;
jt89 dut(.clk(clk),.clk_en(ce|perturb),.rst(rst),.wr_n(wr),.din(din),.mux(8'hA5),.soundL(l),.soundR(r),.ready(),.ss_out(cfg),.ss_set(1'b0),.ss_in(saved_cfg),.ss_ext_out(ext),.ss_ext_in(saved_ext),.ss_ext_set(load),.ss_div_out(div),.ss_div_in(saved_div),.ss_quiescent(quiet));
jt89 reference(.clk(clk),.clk_en(ce),.rst(rst),.wr_n(wr),.din(din),.mux(8'hA5),.soundL(rl),.soundR(rr),.ready(),.ss_out(rcfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(rext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(rdiv),.ss_div_in(4'd0),.ss_quiescent(rquiet));
task tick; begin @(posedge clk); #1; @(negedge clk); #1; end endtask
task put(input [7:0] b); begin din=b;wr=0;tick;wr=1;tick;tick;end endtask
integer mode,phase,i,n=0;
initial begin
for(mode=0;mode<8;mode=mode+1) for(phase=0;phase<16;phase=phase+1) begin
 rst=1;ce=0;perturb=0;load=0;repeat(3) tick;rst=0;tick;
 put(8'h8D);put(8'h02);put(8'hA7);put(8'h01);put(8'hC9);put(8'h03);
 put(8'h91);put(8'hB3);put(8'hD5);put(8'hF2);put(8'hE0|mode);
 for(i=0;i<40000;i=i+1) begin ce=1;tick;end
 ce=0;repeat(4) tick;
 while(div!=phase) begin ce=1;tick;ce=0;repeat(3) tick;end
 ce=0;repeat(4) tick;
 if(!quiet||!rquiet) $fatal(1,"not quiescent");
 saved_cfg=cfg;saved_ext=ext;saved_div=div;
 perturb=1;repeat(4099) tick;perturb=0;repeat(4) tick;
 load=1;tick;load=0;repeat(4) tick;
 if(cfg!==rcfg||ext!==rext||div!==rdiv) $fatal(1,"restore mismatch mode=%0d phase=%0d",mode,phase);
 for(i=0;i<20000;i=i+1) begin
  ce=(i%7==0);tick;
  if(cfg!==rcfg||ext!==rext||div!==rdiv||l!==rl||r!==rr) $fatal(1,"replay mismatch mode=%0d phase=%0d cycle=%0d",mode,phase,i);
 end
 n=n+1;
end
$display("PASS PSG replay: %0d cases, 8 noise controls, all 16 divider phases, 20000 compared cycles/case",n);$finish;
end endmodule
