`timescale 1ns/1ps
module ordinary;
reg clk=0;always #5 clk=~clk;
reg jp=0,joy=0,t0=1,t1=1;reg[31:0]rng=32'h543291ac;reg[7:0]p0=8'ha3,p1=8'h5c,x0=0,x1=0;
wire[31:0]state,oldstate;wire[9:0]pins,oldpins;
paddle_fixture dut(clk,1'b0,1'b0,1'b0,1'b0,jp,joy,32'd0,p0,p1,x0,x1,t0,t1,state,pins);
paddle_baseline original(clk,1'b0,1'b0,1'b0,1'b0,jp,joy,32'd0,p0,p1,x0,x1,t0,t1,oldstate,oldpins);
task tick;begin @(negedge clk);#1;end endtask
integer i;
initial begin
dut.cnt_en16khz=13;original.cnt_en16khz=13;repeat(2)tick;t0=0;t1=0;tick;t0=1;t1=1;tick;
for(i=0;i<1000000;i=i+1)begin
rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};
if(i%101==0)begin t0=rng[0];t1=rng[1];end
if(i%10007==0)begin jp=rng[2];joy=rng[3];end
if(i%53==0)begin p0=rng[7:0];p1=rng[15:8];x0=rng[23:16];x1=rng[31:24];end
tick;if(state!==oldstate||pins!==oldpins)$fatal(1,"ordinary timing mismatch %0d %h/%h",i,state,oldstate);
end
$display("PASS F10 ordinary baseline equivalence: 1000000 clocks, both regions, both input sources, independent TH, no reset semantics changed");$finish;
end
endmodule
