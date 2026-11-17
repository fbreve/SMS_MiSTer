`timescale 1ns/1ps
module mapped_tb;
reg clk=0,we=0,out_en=1;reg[3:0]wa=0,ra=0;reg[9:0]data=0;wire[9:0]q;
mapped_feedback_cut dut(clk,we,out_en,wa,ra,data,q);
reg[9:0]model[0:8],expected;reg[8:0]valid=0;reg v=0;reg[31:0]rng=32'hfb241309;
integer cycles=0,checks=0,collisions=0,held=0,negativezero=0,i,a,b,pattern;
task check;begin if(v)begin if(q!==expected)$fatal(1,"OLD_DATA mismatch cycle=%0d q=%h expected=%h",cycles,q,expected);checks=checks+1;if(q==10'h200)negativezero=negativezero+1;end end endtask
task step(input integer address,readaddr,input[9:0]value,input writing,enabling);
begin clk=0;wa=address;ra=readaddr;data=value;we=writing;out_en=enabling;#3;check;
if(enabling)begin expected=model[readaddr];v=valid[readaddr];end
clk=1;if(writing)begin model[address]=value;valid[address]=1;if(address==readaddr)collisions=collisions+1;end
if(!enabling)held=held+1;#2;check;clk=0;#3;check;cycles=cycles+1;end endtask
initial begin
for(i=0;i<9;i=i+1)model[i]=10'hxxx;
for(i=0;i<9;i=i+1)step(i,i,10'h155^i,1,1);
for(pattern=0;pattern<6;pattern=pattern+1)for(a=0;a<9;a=a+1)for(b=0;b<9;b=b+1)begin
case(pattern)0:step(a,b,0,1,1);1:step(a,b,511,1,1);2:step(a,b,512,1,1);3:step(a,b,1023,1,1);4:step(a,b,341,1,1);5:step(a,b,682,1,1);endcase
step(a,b,0,0,1);end
for(i=0;i<9;i=i+1)begin step(i,i,512,1,1);step(i,i,0,0,1);end
for(i=0;i<100;i=i+1)step(i%9,(i/9)%9,i,1,0);
for(i=0;i<9;i=i+1)step(0,i,0,0,1);
for(i=0;i<10000;i=i+1)begin rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);step(i%9,(i/9)%9,rng[9:0],rng[10],1);end
if(collisions==0||held==0||negativezero==0)$fatal(1,"coverage missing");
$display("PASS ACTUAL FEEDBACK cells cycles=%0d checks=%0d collisions=%0d held=%0d negativezero=%0d",cycles,checks,collisions,held,negativezero);$finish;end
initial begin #1000000;$fatal(1,"VENDOR TIMEOUT");end
endmodule
