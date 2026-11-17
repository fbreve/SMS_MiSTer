`timescale 1ns/1ps
module memory_tb;
reg clk=0;always #5 clk=~clk;
reg reset_n=0,capture=0,apply_state=0,legacy=0,bulk_read=0,bulk_write=0;
reg[6:0]bulk_addr=0;reg[63:0]bulk_wdata=0;
wire[63:0]bulk_rdata;wire done,busy;wire[7:0]state_addr;wire state_read,state_write;
wire[31:0]state_wdata;reg[31:0]state_rdata=0;
integer reads=0,writes=0,passes=0;
reg[103:0]read_seen=0,write_seen=0;
function[31:0]pattern(input[7:0]a);pattern=32'h9e3779b9 ^ (32'h01020408*a);endfunction
opll_snapshot dut(.clk(clk),.reset_n(reset_n),.capture(capture),.apply_state(apply_state),.legacy(legacy),.initialized(1'b1),.legacy_reset(),.initialization_run(),.bulk_read(bulk_read),.bulk_write(bulk_write),.bulk_addr(bulk_addr),.bulk_wdata(bulk_wdata),.bulk_rdata(bulk_rdata),.done(done),.busy(busy),.state_addr(state_addr),.state_read(state_read),.state_write(state_write),.state_wdata(state_wdata),.state_rdata(state_rdata));
always@(posedge clk)begin
 if(state_read)begin
  if(state_addr>=104||read_seen[state_addr])$fatal(1,"capture alias/duplicate");
  read_seen[state_addr]=1;reads++;state_rdata<=pattern(state_addr);
 end
 if(state_write)begin
  if(state_addr>=104||write_seen[state_addr]||state_wdata!==pattern(state_addr))$fatal(1,"restore coverage/data word%0d",state_addr);
  write_seen[state_addr]=1;writes++;
 end
end
task tick;begin @(negedge clk);#1;end endtask
task finish_op;begin wait(done);tick;if(busy)$fatal(1,"done busy");end endtask
initial begin
 repeat(3)tick;reset_n=1;tick;capture=1;tick;capture=0;finish_op;
 if(reads!=104||read_seen!=={104{1'b1}})$fatal(1,"capture incomplete");
 for(integer i=0;i<52;i++)begin
  bulk_addr=i;bulk_read=1;tick;bulk_read=0;finish_op;
  if(bulk_rdata!=={pattern(2*i+1),pattern(2*i)})$fatal(1,"bulk read alias/stale %0d",i);
  repeat((i*7)%13)tick;
 end
 // Overwrite all scratch rows, not only the first104, checking every physical
 // address and both halves under varying idle gaps. This does not mutate OPLL.
 for(integer i=0;i<128;i++)begin
  bulk_addr=i;bulk_wdata={pattern(2*i+1),pattern(2*i)};bulk_write=1;tick;bulk_write=0;finish_op;
  repeat((i*3)%7)tick;
 end
 for(integer i=127;i>=0;i--)begin
  bulk_addr=i;bulk_read=1;tick;bulk_read=0;finish_op;
  if(bulk_rdata!=={pattern(2*i+1),pattern(2*i)})$fatal(1,"full memory alias/truncation %0d",i);
 end
 for(integer pass=0;pass<3;pass++)begin
  write_seen=0;writes=0;apply_state=1;tick;apply_state=0;finish_op;
  if(writes!=104||write_seen!=={104{1'b1}})$fatal(1,"apply incomplete");
  passes++;repeat(17*pass)tick;
 end
 $display("PASS MEMORY capture104 physical256 restore%0d",passes*104);$finish;
end
initial begin #1000000;$fatal(1,"memory watchdog");end
endmodule
