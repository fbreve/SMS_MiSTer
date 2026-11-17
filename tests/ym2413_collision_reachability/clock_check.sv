module clock_check;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg[4:0]clkd=0;
reg ce_cpu;
reg ce_snd;
reg ce_vdp;
reg ce_pix;
reg ce_sp;
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


integer arm=0,checks=0,release_phase,k,delta,pulse_phase,mode,seed,steps;reg boundary;
initial begin
for(mode=0;mode<2;mode=mode+1)for(seed=0;seed<30;seed=seed+1)begin
 @(posedge clk_sys);#1;clkd=seed;arm=0;
 for(steps=0;steps<90;steps=steps+1)begin
 @(posedge clk_sys);
 if(arm)begin if(ce_cpu)$fatal(1,"FM enabled on ARM_FREEZE edge");checks=checks+1;end
 arm=mode?ce_pix:ce_cpu;
 end
end
// Check the exact divider phases admitted by production ST_UNFREEZE's
// !cpu_ce && !vdp_ce && !pix_ce && !sp_ce condition.
for(release_phase=0;release_phase<30;release_phase=release_phase+1)begin
 @(posedge clk_sys);#1;clkd=release_phase;
 @(posedge clk_sys);#1;
 if(!ce_cpu&&!ce_vdp&&!ce_pix&&!ce_sp)begin
 delta=0;
 do begin @(posedge clk_sys);#1;delta=delta+1;end while(!ce_cpu);
 $display("QUIET_RELEASE phase=%0d first_FM_edge=%0d raw_CE_low_gap=%0d",release_phase,delta,delta-1);
 if(release_phase==22 && delta!=2)$fatal(1,"directed E1/E2 counterexample phase not reachable");
 end
end
$display("PASS production divider ARM checks=%0d modes=2 initial_phases=30",checks);$finish;
end endmodule
