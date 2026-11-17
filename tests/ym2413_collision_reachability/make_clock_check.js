const fs=require('fs'),p=require('path'),cp=require('child_process'),d=__dirname;
const src=cp.execFileSync('git',['show','9873761503510e4b2c7e06600bf5515344235c2f:SMS.sv'],{cwd:d,encoding:'utf8'});
const a=src.indexOf('reg ce_cpu;'),b=src.indexOf('wire HS, VS;',a),divider=src.slice(a,b);
fs.writeFileSync(p.join(d,'clock_check.sv'),`module clock_check;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg[4:0]clkd=0;
${divider}
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
`);
fs.writeFileSync(p.join(d,'clock_check.do'),'onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlog -sv -work validator_work clock_check.sv\nvsim validator_work.clock_check\nrun -all\nquit -code 0 -force\n');
