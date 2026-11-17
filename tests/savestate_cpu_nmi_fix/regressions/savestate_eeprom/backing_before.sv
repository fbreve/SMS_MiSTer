`timescale 1ns/1ps
module backing_before;
reg clk=0;always #5 clk=~clk;
reg reset_n=0,wr=1;reg [15:0]addr=16'h8000;reg[7:0]din=0;
wire[7:0]dout,wd;wire[6:0]a;wire we;reg[7:0]q;reg[7:0]mem[0:127];
wire[63:0]state;reg[63:0]saved;reg load=0;
cart_eeprom dut(.clk_sys(clk),.ce_cpu(1'b1),.reset_n(reset_n),.soft_reset(1'b0),.A(addr),.D_in(din),.D_out(dout),.WR_n(wr),.MREQ_n(1'b0),.enabled(1'b1),.mapper_eeprom(1'b1),.bus_active(),.nvram_a(a),.nvram_di(wd),.nvram_do(q),.nvram_we(we),.ss_out(state),.ss_in(saved),.ss_set(load));
always @(posedge clk)begin q<=mem[a];if(we)mem[a]<=wd;end
task tick;begin @(negedge clk);#1;end endtask
task put(input[7:0]d);begin din=d;wr=0;tick;wr=1;repeat(2)tick;end endtask
task bitin(input bit b);begin put(4|b);put(6|b);put(4|b);end endtask
task command(input[7:0]op);begin put(0);bitin(1);for(integer i=7;i>=0;i=i-1)bitin(op[i]);end endtask
task writeword(input[5:0]w,input[15:0]data);begin command({2'b01,w});for(integer i=15;i>=0;i=i-1)bitin(data[i]);repeat(5)tick;put(0);end endtask
initial begin
for(integer i=0;i<128;i=i+1)mem[i]=8'hff;
repeat(3)tick;reset_n=1;command(8'h30);writeword(0,16'ha55a);writeword(63,16'h3cc3);
if(mem[0]!=8'ha5||mem[127]!=8'hc3)$fatal(1,"setup writes failed");
saved=state;writeword(0,16'h1234);writeword(63,16'h5678);
load=1;tick;load=0;repeat(4)tick;
if(mem[0]!=8'h12||mem[127]!=8'h78)$fatal(1,"expected missing contents restore absent");
$display("CONFIRMED F04: saved byte0=A5 byte127=C3; after writes and protocol load byte0=%h byte127=%h",mem[0],mem[127]);
$display("PASS backing_before (expected F04 defect through production cart/serial/write pipeline)");$finish;
end
endmodule
