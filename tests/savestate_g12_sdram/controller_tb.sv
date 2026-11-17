`timescale 1ns/1ps
module controller_tb;
parameter PERIOD=10,TAC=1;
reg clk=0;always #10 clk=~clk;reg clkref=0;integer ticks=0;
always@(negedge clk)begin ticks++;clkref=(ticks%PERIOD)==0;end
tri[15:0]dq;wire[12:0]a;wire[1:0]ba;wire cs,ras,cas,we,ready;wire[7:0]data;reg[24:0]address=0;reg rd=0;
sdram dut(.SDRAM_DQ(dq),.SDRAM_A(a),.SDRAM_BA(ba),.SDRAM_nCS(cs),.SDRAM_nRAS(ras),.SDRAM_nCAS(cas),.SDRAM_nWE(we),.init(1'b0),.clk(clk),.clkref(clkref),.raddr(address),.rd(rd),.rd_rdy(ready),.dout(data),.waddr(25'd0),.din(8'd0),.we(1'b0),.we_ack());
pin_model #(.TAC(TAC)) chip(clk,a,ba,cs,ras,cas,we,dq);
integer checked=0,start_reads;reg[24:0]addresses[0:34];
initial begin
 addresses[0]=0;addresses[1]=1;addresses[2]=25'h3fff;addresses[3]=25'h4000;addresses[4]=25'h3fffff;addresses[5]=25'h7fffff;addresses[6]=25'h800000;addresses[7]=25'hfffffe;addresses[8]=25'hffffff;addresses[9]=25'h1ffffff;
 for(integer b=0;b<25;b++)addresses[10+b]=25'd1<<b;
 repeat(1200)@(negedge clk);wait(dut.mode==0);
 for(integer phase=0;phase<PERIOD;phase++)for(integer n=0;n<35;n++)begin
  rd=0;repeat(PERIOD+1)@(negedge clk);
  wait(dut.q==0);repeat(phase)@(negedge clk);#1;address=addresses[n];start_reads=chip.reads;rd=1;
  wait(!ready);wait(ready);#1;
  if(data!==chip.byte_at(address)||chip.pending_addr!==(address&~25'd1)||chip.reads!=start_reads+1)$fatal(1,"controller phase/address/exactly-once mismatch phase%0d A%h data%h expected%h reads%0d",phase,address,data,chip.byte_at(address),chip.reads-start_reads);
  checked++;rd=0;
 end
 $display("PASS CONTROLLER period%0d TAC%0d cases%0d physicalReads%0d refresh%0d",PERIOD,TAC,checked,chip.reads,chip.refreshes);$finish;
end
initial begin #10000000;$fatal(1,"controller watchdog q%0d",dut.q);end
endmodule
