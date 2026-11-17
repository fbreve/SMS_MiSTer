`timescale 1ns/1ps
module pin_model #(parameter TAC=1,SYSTEME=0,CACHEHISTORY=0)(input clk,input [12:0]a,input[1:0]ba,input cs,ras,cas,we,inout[15:0]dq);
reg[12:0]row[0:3];reg[15:0]out=0;reg drive=0;reg[24:0]pending_addr;integer latency=0,reads=0,refreshes=0;
reg[7:0]program_bytes[0:65535];initial begin $readmemh("rom.hex",program_bytes);if(CACHEHISTORY)begin program_bytes[46]=8'hc3;program_bytes[47]=0;program_bytes[48]=8'hc0;end end
function[7:0]byte_at(input[24:0]addr);reg[31:0]h;begin
 if((!SYSTEME&&addr<256)||(SYSTEME&&addr>=25'h40000&&addr<25'h40100))byte_at=program_bytes[addr[7:0]];
 else begin h=(addr^32'hb7a49163)*32'h45d9f3b;h=(h^(h>>16))*32'h45d9f3b;byte_at=h^(h>>8)^(h>>16)^(h>>24);end
end endfunction
always@(negedge clk)begin
 drive<=0;
 if(latency>0)begin latency=latency-1;if(latency==0)begin out<={byte_at(pending_addr|25'd1),byte_at(pending_addr&~25'd1)};drive<=#(TAC)1;end end
 if({cs,ras,cas,we}==4'b0011)row[ba]<=a;
 if({cs,ras,cas,we}==4'b0101)begin
  if(latency!=0)$fatal(1,"overlapping physical reads");
  pending_addr={ba,a[8],row[ba],a[7:0],1'b0};latency=2;reads++;
 end
 if({cs,ras,cas,we}==4'b0001)refreshes++;
end
assign dq=drive?out:16'hzzzz;
endmodule
