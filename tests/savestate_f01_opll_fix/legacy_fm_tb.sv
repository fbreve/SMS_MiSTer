`timescale 1ns/1ps
module legacy_fm_tb;
reg clk=0;always #5 clk=~clk;
reg reset_n=0,hold=0,ce=0,legacy=0,capture=0,bulk_read=0;
reg[6:0]bulk_addr=0;wire[63:0]bulk_rdata;
wire[7:0]addr;wire read_en,write_en,initialized,legacy_reset,init_run,done;
wire[31:0]wdata,opll_data,rdata;reg[31:0]wrapper_data=0;
reg a=0,bus_a=0,bus_write=0;reg[7:0]d=0,bus_d=0;
wire[13:0]fm;reg[63:0]image[0:51];reg[13:0]oracle[0:19999];
opll sound(.xin(clk),.xena(ce&&!hold),.d(d),.a(a),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n&&!legacy_reset),.mixout(fm),.ss_hold(hold&&!init_run),.ss_addr(addr),.ss_read(read_en),.ss_write(write_en),.ss_wdata(wdata),.ss_rdata(opll_data),.ss_initialized(initialized));
opll_snapshot store(.clk(clk),.reset_n(reset_n),.capture(capture),.apply_state(1'b0),.legacy(legacy),.initialized(initialized),.legacy_reset(legacy_reset),.initialization_run(init_run),.bulk_read(bulk_read),.bulk_write(1'b0),.bulk_addr(bulk_addr),.bulk_wdata(64'd0),.bulk_rdata(bulk_rdata),.done(done),.busy(),.state_addr(addr),.state_read(read_en),.state_write(write_en),.state_wdata(wdata),.state_rdata(rdata));
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
initial begin
 repeat(6)tick;reset_n=1;ticks(100);
 for(integer pass=0;pass<3;pass++)begin
  hold=0;wr(8'h30,8'hf0+pass);wr(8'h10,8'h37+pass);wr(8'h20,8'h19);ticks(901+pass*111);
  hold=1;legacy=1;tick;legacy=0;finish_op;
  if(a!==0||d!==0||fm!==0||!initialized)$fatal(1,"legacy deterministic ready/output");
  capture=1;tick;capture=0;finish_op;
  for(integer i=0;i<52;i++)begin
   bulk_addr=i;bulk_read=1;tick;bulk_read=0;finish_op;
   if($isunknown(bulk_rdata))$fatal(1,"legacy unknown word%0d",i);
   if(pass==0)image[i]=bulk_rdata;else if(image[i]!==bulk_rdata)$fatal(1,"legacy Q dependence word%0d",i);
  end
  hold=0;
  for(integer i=0;i<20000;i++)begin
   ce=(i%15==0);tick;
   if(pass==0)oracle[i]=fm;else if(fm!==oracle[i])$fatal(1,"legacy future Q dependence sample%0d",i);
  end
  ce=0;$display("PASS LEGACY FM pass%0d words104 samples20000",pass);
 end
 $display("PASS LEGACY FM ALL");$finish;
end
initial begin #100000000;$fatal(1,"legacy watchdog");end
endmodule
