`timescale 1ns/1ps
module mapped_tb;
reg clk=0,we=0,out_en=1;reg[4:0]wa=0,ra0=0,ra1=0;reg[9:0]data=0;wire[9:0]q0,q1;
mapped_output_cut dut(clk,we,out_en,wa,ra0,ra1,data,q0,q1);
reg[9:0]model[0:18],expected0,expected1;reg[18:0]valid=0;reg v0=0,v1=0;
integer cycles=0,checks=0,collision0=0,collision1=0,both=0,distinct=0,held=0,i,a,b,w,pattern;
task check;
begin
 if(v0)begin if(q0!==expected0)$fatal(1,"mapped read0 mismatch cycle=%0d q=%h expected=%h",cycles,q0,expected0);checks=checks+1;end
 if(v1)begin if(q1!==expected1)$fatal(1,"mapped read1 mismatch cycle=%0d q=%h expected=%h",cycles,q1,expected1);checks=checks+1;end
end endtask
task step(input integer address,read0,read1,input[9:0]value,input writing,enabling);
begin
 clk=0;wa=address;ra0=read0;ra1=read1;data=value;we=writing;out_en=enabling;#3;
 check;
 if(enabling)begin expected0=model[read0];expected1=model[read1];v0=valid[read0];v1=valid[read1];end
 clk=1;
 if(writing)begin
  model[address]=value;valid[address]=1;
  if(address==read0)collision0=collision0+1;
  if(address==read1)collision1=collision1+1;
  if(address==read0&&address==read1)both=both+1;
  if(address!=read0&&address!=read1&&read0!=read1)distinct=distinct+1;
 end
 if(!enabling)held=held+1;
 #2;check;clk=0;#3;check;cycles=cycles+1;
end endtask
initial begin
 for(i=0;i<19;i=i+1)model[i]=10'hxxx;
 for(i=0;i<19;i=i+1)step(i,i,i,(10'h155^i),1,1);
 // Complete independent write/read0/read1 address cross product, all 19 entries.
 for(pattern=0;pattern<6;pattern=pattern+1)for(w=0;w<19;w=w+1)for(a=0;a<19;a=a+1)for(b=0;b<19;b=b+1)begin
  case(pattern)
   0:step(w,a,b,0,1,1);1:step(w,a,b,511,1,1);2:step(w,a,b,512,1,1);
   3:step(w,a,b,1023,1,1);4:step(w,a,b,10'h155,1,1);5:step(w,a,b,10'h2aa,1,1);
  endcase
  step(w,a,b,0,0,1);
 end
 // Output FFs hold during reset; storage and entry18 are not asynchronously cleared.
 step(18,18,18,10'h355,1,1);step(18,18,18,0,0,1);
 for(i=0;i<100;i=i+1)step(i%19,(i+1)%19,(i+2)%19,0,0,0);
 for(i=0;i<18;i=i+1)step(i,18,18,0,1,1);
 step(18,18,18,0,0,1);if(q0!==10'h355||q1!==10'h355)$fatal(1,"mapped entry18 reset preservation");
 // Long raw-clock writes/reads without an FM clock-enable.
 for(i=0;i<4000;i=i+1)step(7,i%19,(i/19)%19,10'h3ff,1,1);
 for(i=0;i<19;i=i+1)step(i,i,18-i,0,0,1);
 if(both<100||collision0<1000||collision1<1000||distinct<1000)$fatal(1,"mapped coverage missing");
 $display("PASS ACTUAL MAPPED OUTPUT cycles=%0d checks=%0d collision0=%0d collision1=%0d both=%0d distinct=%0d held=%0d",cycles,checks,collision0,collision1,both,distinct,held);$finish;
end
initial begin #2000000;$fatal(1,"mapped probe timeout");end
endmodule
