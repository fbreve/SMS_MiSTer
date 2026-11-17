`timescale 1ns/1ps
module validator_stream_tb;
`include "ports.svh"
assign fm_initialized=1;assign fm_state_rdata=0;
always #5 clk=~clk;
reg[31:0]words[0:103];integer cycles=0,pending=0,fd,n,k,good=0,bad=0,applied=0;reg[28:0]ra;
always @(negedge clk)begin cycles++;DDRAM_BUSY=cycles%31<5;end
always @(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<={words[2*(ra-29'h07c02998)+1],words[2*(ra-29'h07c02998)]};DDRAM_DOUT_READY<=1;end end
 if(DDRAM_RD&&!DDRAM_BUSY&&DDRAM_ADDR>=29'h07c02998&&DDRAM_ADDR<29'h07c029cc)begin if(pending)$fatal(1,"overlapping read");pending<=2+cycles%5;ra<=DDRAM_ADDR;end
 if(fm_state_write||fm_legacy_reset||dut.fm_apply)$fatal(1,"validation mutated live FM state");
end
task tick;begin @(negedge clk);#2;end endtask
task check_image(input bit want_accept);integer timeout;begin
 reset_n=0;repeat(3)tick;reset_n=1;repeat(3)tick;
 dut.ss_freeze=1;dut.state=dut.ST_FM_LOAD_DESC;dut.dout_latch=dut.FM_DESC;dut.dout_expected=0;dut.base_addr=29'h07c00000;
 timeout=0;
 while(dut.state!=dut.ST_ERROR&&dut.state!=dut.ST_LOAD_EEPROM)begin tick;timeout++;if(timeout>4000)$fatal(1,"validator timeout state=%0d",dut.state);end
 if(want_accept)begin if(dut.state!=dut.ST_LOAD_EEPROM)$fatal(1,"legitimate/guarded image rejected count=%0d stage=%0d mo_wr=%b",good,words[78],words[100][1]);good++;end
 else begin if(dut.state!=dut.ST_ERROR)$fatal(1,"counterexample accepted");bad++;end
end endtask
task stream(input string name,input bit accepted);begin
 fd=$fopen(name,"r");if(!fd)$fatal(1,"missing payload %s",name);n=0;
 while(!$feof(fd))begin k=$fscanf(fd,"%h",words[0]);if(k==1)begin for(integer j=1;j<104;j++)if($fscanf(fd,"%h",words[j])!=1)$fatal(1,"partial image");check_image(accepted);n++;end end
 $fclose(fd);$display("PASS production FSM validation file=%s images=%0d accepted=%b",name,n,accepted);
end endtask
initial begin
 stream("../../payloads/A.hex",0);stream("../../payloads/B.hex",0);
 stream("../../payloads/coherent.hex",1);stream("../../payloads/guarded.hex",1);
 $display("PASS ACTUAL_VALIDATOR accepted=%0d rejected=%0d no_live_FM_writes",good,bad);$finish;
end
initial begin #1000000000;$fatal(1,"validator campaign timeout");end
endmodule
