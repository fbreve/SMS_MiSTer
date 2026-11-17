`timescale 1ns/1ps
module map_tb;
reg clk=0,reset_n=0,hold=0;
always #5 clk=~clk;
reg capture=0,apply_state=0,bulk_read=0,bulk_write=0;
reg [6:0] bulk_addr=0;reg [63:0] bulk_wdata=0;
wire [63:0] bulk_rdata;wire done,busy,ready,init_run,legacy_reset;
wire [7:0] addr;wire rd,wr;wire [31:0] wdata,rdata;
wire [13:0] audio;wire [12:0] audible;
opll_snapshot transport(.clk(clk),.reset_n(reset_n),.capture(capture),.apply_state(apply_state),.legacy(1'b0),
 .initialized(ready),.legacy_reset(legacy_reset),.initialization_run(init_run),.bulk_read(bulk_read),.bulk_write(bulk_write),
 .bulk_addr(bulk_addr),.bulk_wdata(bulk_wdata),.bulk_rdata(bulk_rdata),.done(done),.busy(busy),
 .state_addr(addr),.state_read(rd),.state_write(wr),.state_wdata(wdata),.state_rdata(rdata));
candidate_wrapper fm(.clk_sys(clk),.RESET_n(reset_n),.ce_raw(1'b0),.ss_freeze(hold),.fm_initialization_run(init_run),
 .fm_legacy_reset(legacy_reset),.D_in(8'd0),.A(16'd0),.fm_WR_n(1'b1),.fm_state_addr(addr),.fm_state_read(rd),
 .fm_state_write(wr),.fm_state_wdata(wdata),.fm_state_rdata(rdata),.fm_initialized(ready),.FM_out(audio),.fm_ena(1'b1),.audible(audible));
reg [31:0] patterns[0:831];integer pass=0;
task tick;begin @(negedge clk);#1;end endtask
task complete;begin wait(done);tick;end endtask
initial begin
 $readmemh("patterns.hex",patterns);
 repeat(6)tick;reset_n=1;repeat(130)tick;if(!ready)$fatal(1,"map initialization");hold=1;
 for(pass=0;pass<8;pass++)begin
  for(integer i=0;i<52;i++)begin
   bulk_addr=i;bulk_wdata={patterns[pass*104+2*i+1],patterns[pass*104+2*i]};bulk_write=1;tick;bulk_write=0;complete();repeat(i%5)tick;
  end
  apply_state=1;tick;apply_state=0;complete();
  $stop; // Tcl independently reads every live field before any capture.
  capture=1;tick;capture=0;complete();
  for(integer i=0;i<52;i++)begin
   bulk_addr=i;bulk_read=1;tick;bulk_read=0;complete();
   if(bulk_rdata!=={patterns[pass*104+2*i+1],patterns[pass*104+2*i]})$fatal(1,"map capture pass=%0d bulk=%0d",pass,i);
  end
  $display("PASS independent pattern pass=%0d all104 internal apply and capture",pass);
 end
 $display("PASS independent pattern ALL words=832");$finish;
end
initial begin #10000000;$fatal(1,"map TIMEOUT");end
endmodule
