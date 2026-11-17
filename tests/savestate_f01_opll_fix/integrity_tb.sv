`timescale 1ns/1ps
module integrity_tb;
reg clk=0;always #5 clk=~clk;
reg apply_state=0,bulk_write=0;reg[63:0]bulk_wdata=0;reg reset_n=0,hold=0,ce=0,legacy=0,capture=0,bulk_read=0;
reg[6:0]bulk_addr=0;wire[63:0]bulk_rdata;
wire[7:0]addr;wire read_en,write_en,initialized,legacy_reset,init_run,done;
wire[31:0]wdata,opll_data,rdata;reg[31:0]wrapper_data=0;
reg a=0,bus_a=0,bus_write=0;reg[7:0]d=0,bus_d=0;
wire[13:0]fm;reg[63:0]image[0:51];reg[13:0]oracle[0:19999];
opll sound(.xin(clk),.xena(ce&&!hold),.d(d),.a(a),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n&&!legacy_reset),.mixout(fm),.ss_hold(hold&&!init_run),.ss_addr(addr),.ss_read(read_en),.ss_write(write_en),.ss_wdata(wdata),.ss_rdata(opll_data),.ss_initialized(initialized));
opll_snapshot store(.clk(clk),.reset_n(reset_n),.capture(capture),.apply_state(apply_state),.legacy(legacy),.initialized(initialized),.legacy_reset(legacy_reset),.initialization_run(init_run),.bulk_read(bulk_read),.bulk_write(bulk_write),.bulk_addr(bulk_addr),.bulk_wdata(bulk_wdata),.bulk_rdata(bulk_rdata),.done(done),.busy(),.state_addr(addr),.state_read(read_en),.state_write(write_en),.state_wdata(wdata),.state_rdata(rdata));
always@(posedge clk)begin
 if(!reset_n||legacy_reset)begin a<=0;d<=0;end
 else if(hold&&write_en&&addr==8'h4c)begin a<=wdata[0];d<=wdata[8:1];end
 else if(!hold&&bus_write)begin a<=bus_a;d<=bus_d;end
 wrapper_data<=0;if(hold&&read_en&&addr==8'h4c)wrapper_data<={23'd0,d,a};
end
assign rdata=opll_data|wrapper_data;
task tick;begin @(negedge clk);#1;end endtask
task ticks(input integer n);begin for(integer i=0;i<n;i++)begin ce=1;tick;ce=0;repeat(14)tick;end end endtask
task wr(input[7:0]r,input[7:0]v);begin bus_a=0;bus_d=r;bus_write=1;ticks(8);bus_write=0;ticks(8);bus_a=1;bus_d=v;bus_write=1;ticks(160);bus_write=0;end endtask
task finish_op;begin wait(done);tick;end endtask
reg[31:0]patterns[0:831];integer writes=0,reads=0;reg[103:0]seen_w=0,seen_r=0;
always@(posedge clk)begin
 if(write_en)begin if(seen_w[addr])$fatal(1,"duplicate restore");seen_w[addr]=1;writes++;end
 if(read_en)begin if(seen_r[addr])$fatal(1,"duplicate capture");seen_r[addr]=1;reads++;end
end
initial begin
 $readmemh("patterns.hex",patterns);repeat(6)tick;reset_n=1;repeat(116)tick;hold=1;
 for(integer pass=0;pass<8;pass++)begin
  seen_w=0;seen_r=0;writes=0;reads=0;
  for(integer i=0;i<52;i++)begin
   bulk_addr=i;bulk_wdata={patterns[pass*104+2*i+1],patterns[pass*104+2*i]};bulk_write=1;tick;bulk_write=0;finish_op;repeat((i*7+pass)%13)tick;
  end
  apply_state=1;tick;apply_state=0;finish_op;
  if(writes!=104||seen_w!=={104{1'b1}})$fatal(1,"restore coverage");
  capture=1;tick;capture=0;finish_op;
  if(reads!=104||seen_r!=={104{1'b1}})$fatal(1,"capture coverage");
  for(integer i=0;i<52;i++)begin
   bulk_addr=i;bulk_read=1;tick;bulk_read=0;finish_op;
   if(bulk_rdata!=={patterns[pass*104+2*i+1],patterns[pass*104+2*i]})$fatal(1,"OPLL map alias/truncation pass%0d word%0d actual%h expected%h",pass,i,bulk_rdata,{patterns[pass*104+2*i+1],patterns[pass*104+2*i]});
  end
  $display("PASS INTEGRITY pass%0d words104",pass);
 end
 $display("PASS INTEGRITY ALL random_words832 exact_once");$finish;
end
initial begin #10000000;$fatal(1,"integrity watchdog");end
endmodule
