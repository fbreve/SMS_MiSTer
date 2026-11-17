`timescale 1ns/1ps
module ordering_tb;
stress_tb #(.CUT(0),.STALL(1)) test();
reg mapper_seen=0,cpu_seen=0;integer observed_sram_writes=0;
always @(posedge test.clk)begin
 if(!test.reset_n)begin mapper_seen=0;cpu_seen=0;observed_sram_writes=0;end
 else begin
  if(test.mapper_set)mapper_seen=1;
  if(test.nvram_WE)begin
   if(!mapper_seen||cpu_seen||!test.ss_freeze)$fatal(1,"SRAM restore ordering violated");
   observed_sram_writes++;
  end
  if(test.z80_set)begin
   if(observed_sram_writes!=32768)$fatal(1,"CPU resumed before complete SRAM restore");
   cpu_seen=1;$display("PASS ORDER mapper before SRAM, all32768 SRAM bytes before CPU, freeze held");
  end
 end
end
endmodule
