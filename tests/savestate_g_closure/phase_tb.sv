`timescale 1ns/1ps
module phase_tb;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg[4:0]clkd=0;reg ce_cpu,ce_snd,ce_vdp,ce_pix,ce_sp;
always @(negedge clk_sys) begin
	ce_sp <= clkd[0];
	ce_vdp <= 0;//div5
	ce_pix <= 0;//div10
	ce_cpu <= 0;//div15
	clkd <= clkd + 1'd1;
	if (clkd==29) begin
		clkd <= 0;
		ce_vdp <= 1;
		ce_pix <= 1;
	end else if (clkd==24) begin
		ce_cpu <= 1;  //-- changed cpu phase to please VDPTEST HCounter test;
		ce_vdp <= 1;
	end else if (clkd==19) begin
		ce_vdp <= 1;
		ce_pix <= 1;
	end else if (clkd==14) begin
		ce_vdp <= 1;
	end else if (clkd==9) begin
		ce_cpu <= 1;
		ce_vdp <= 1;
		ce_pix <= 1;
	end else if (clkd==4) begin
		ce_vdp <= 1;
	end
end

integer quiet=0,patterns=0;reg[31:0] seen=0;integer first_cpu,first_vdp,first_pix;
initial begin
 repeat(31)@(posedge clk_sys);
 for(integer k=0;k<30;k=k+1)begin
  @(posedge clk_sys);#1;
  if(!ce_cpu&&!ce_vdp&&!ce_pix&&!ce_sp)begin
   quiet=quiet+1;seen[clkd]=1;
   $display("QUIET phase=%0d",clkd);
  end
 end
 for(integer i=0;i<30;i=i+1)if(seen[i])patterns=patterns+1;
 if(patterns<2)$fatal(1,"quiet phase unexpectedly unique");
 $display("PASS G10 quiet_phases=%0d mask=%h; phase multiplicity only, no guest divergence proof",patterns,seen);
 $finish;
end
endmodule
