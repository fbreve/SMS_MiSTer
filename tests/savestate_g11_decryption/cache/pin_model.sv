`timescale 1ns/1ps
module pin_model #(parameter MODE=0,PROGRAM=0,TAC=1,SYSTEME=0,CACHEHISTORY=0)(input clk,input [12:0]a,input[1:0]ba,input cs,ras,cas,we,inout[15:0]dq);
reg[12:0]row[0:3];reg[15:0]out=0;reg drive=0;reg[24:0]pending_addr;integer latency=0,reads=0,refreshes=0;
`include "crypto_functions.svh"
reg[7:0]forward[0:131071],inverse[0:131071];reg opmask[0:65535];
initial begin $readmemh("mc_forward.hex",forward);$readmemh("mc_inverse.hex",inverse);$readmemh($sformatf("opmask_%0d.hex",PROGRAM),opmask);end
function[7:0]plain_byte(input[15:0]a,input[24:0]physical,input bit op);reg[7:0]v;begin
 v=byte_at(physical);
 if(MODE==2&&!a[15])plain_byte=swap_bits(v,swap_byte(sega_index(a,op)))^xor_byte(sega_index(a,op));
 else if(((MODE&1)&&!a[15])||(MODE==3&&!a[14]))plain_byte=forward[{op,key_byte(key_address(a,op)),v}];
 else plain_byte=v;
end endfunction
function[7:0]encode(input[15:0]a,input[7:0]v,input bit op);reg[7:0]r;begin
 encode=v;
 if(MODE==2&&!a[15])begin for(integer n=0;n<256;n++)if((swap_bits(n,swap_byte(sega_index(a,op)))^xor_byte(sega_index(a,op)))==v)encode=n;end
 else if(((MODE&1)&&!a[15])||(MODE==3&&!a[14]))encode=inverse[{op,key_byte(key_address(a,op)),v}];
end endfunction
reg[7:0]program_bytes[0:65535];initial begin $readmemh($sformatf("program_%0d.hex",PROGRAM),program_bytes);#0;if(CACHEHISTORY)begin opmask[46]=1;opmask[47]=0;opmask[48]=0;program_bytes[46]=8'hc3;program_bytes[47]=0;program_bytes[48]=8'hc0;end end
function[7:0]byte_at(input[24:0]addr);reg[31:0]h;begin
 if((!SYSTEME&&addr<1024)||(SYSTEME&&addr>=25'h40000&&addr<25'h40400))byte_at=encode({6'd0,addr[9:0]},program_bytes[addr[9:0]],opmask[addr[9:0]]);
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
