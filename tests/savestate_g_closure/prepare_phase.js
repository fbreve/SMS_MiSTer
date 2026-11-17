const fs=require('fs');
const path=require('path');
const root=path.resolve(__dirname,'../..');
const source=fs.readFileSync(path.join(root,'SMS.sv'),'utf8');
const start=source.indexOf('always @(negedge clk_sys) begin',source.indexOf('reg ce_sp;'));
const end=source.indexOf('\nwire HS, VS;',start);
if(start<0||end<0)throw Error('CE source boundaries');
const block=source.slice(start,end);
fs.writeFileSync(path.join(__dirname,'phase_tb.sv'),`\`timescale 1ns/1ps
module phase_tb;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg[4:0]clkd=0;reg ce_cpu,ce_snd,ce_vdp,ce_pix,ce_sp;
${block}
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
`);
fs.writeFileSync(path.join(__dirname,'phase.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib phase_work
vlog -work phase_work -sv phase_tb.sv
vsim -c phase_work.phase_tb
run -all
quit -code 0
`);
console.log('Extracted production CE process unchanged; fixture initializes legal power-up phase only.');
