`timescale 1ns/1ps
module replay;
reg clk=0;always #5 clk=~clk;
integer op,en,wa,target,c,cases=0;reg[7:0]opcode;
reg reset1=0,reset2=0,freeze=0,holdref=0,load=0,refill=0,dmawe=0;
reg [6:0]dmaa=0;reg[7:0]dmad=0;reg wr=1;reg[7:0]din=0;
wire[7:0]out1,out2,wd1,wd2;wire[6:0]a1,a2;wire we1,we2,active1,active2;
reg[7:0]q1,q2;reg[7:0]mem1[0:127],mem2[0:127],savedmem[0:127];
wire[63:0]s1,s2;wire[127:0]x1,x2;reg[63:0]saved;reg[127:0]savedext;
cart_eeprom dut(.clk_sys(clk),.ce_cpu(1'b1),.reset_n(reset1),.soft_reset(1'b0),.A(16'h8000),.D_in(din),.D_out(out1),.WR_n(wr),.MREQ_n(1'b0),.enabled(1'b1),.mapper_eeprom(1'b1),.bus_active(active1),.nvram_a(a1),.nvram_di(wd1),.nvram_do(q1),.nvram_we(we1),.ss_out(s1),.ss_in(saved),.ss_set(load),.ss_ext_out(x1),.ss_ext_in(savedext),.ss_full(1'b1),.ss_freeze(freeze));
cart_eeprom reference(.clk_sys(clk),.ce_cpu(1'b1),.reset_n(reset2),.soft_reset(1'b0),.A(16'h8000),.D_in(din),.D_out(out2),.WR_n(wr),.MREQ_n(1'b0),.enabled(1'b1),.mapper_eeprom(1'b1),.bus_active(active2),.nvram_a(a2),.nvram_di(wd2),.nvram_do(q2),.nvram_we(we2),.ss_out(s2),.ss_in(64'd0),.ss_set(1'b0),.ss_ext_out(x2),.ss_ext_in(128'd0),.ss_full(1'b0),.ss_freeze(holdref));
wire[6:0]ramaddr=freeze?(dmawe?dmaa:(refill?a1:dmaa)):a1;
always @(posedge clk)begin
 q1<=mem1[ramaddr];q2<=mem2[a2];
 if(freeze?dmawe:we1)mem1[ramaddr]<=freeze?dmad:wd1;
 if(!holdref&&we2)mem2[a2]<=wd2;
end
task tick;begin @(negedge clk);#1;end endtask
task check;begin if(out1!==out2||active1!==active2||s1!==s2||x1!==x2)$fatal(1,"replay op=%0d enabled=%0d address=%0d target=%0d clock=%0d state=%h/%h DO=%h/%h",op,en,wa,target,c,x1,x2,out1,out2);end endtask
task put(input[7:0]v);begin din=v;wr=0;tick;wr=1;repeat(2)tick;end endtask
task bitin(input bit b);begin put(4|b);put(6|b);put(4|b);end endtask
task cmd(input[7:0]v);begin put(0);bitin(1);for(integer j=7;j>=0;j=j-1)bitin(v[j]);end endtask
reg[8:0]trace[0:1023];integer n;
task ap(input[7:0]v);begin trace[n]={1'b0,v};trace[n+1]={1'b1,v};trace[n+2]={1'b1,v};n=n+3;end endtask
task ab(input bit b);begin ap(4|b);ap(6|b);ap(4|b);end endtask
task build(input[7:0]v);begin
 n=0;ap(0);ab(1);for(integer j=7;j>=0;j=j-1)ab(v[j]);
 if(op==3)for(integer j=15;j>=0;j=j-1)ab((16'h96a5>>j)&1);
 if(op==2)repeat(40)ab(0); // sequential read, including last-word wrap
 // Expose every automatic read/write phase and write-all byte boundary.
 repeat(140)begin trace[n]={1'b1,8'h04};n=n+1;end
 ap(0);ap(4);ap(0);
end endtask
task roundtrip;begin
 freeze=1;holdref=1;saved=s1;savedext=x1;
 for(integer j=0;j<128;j=j+1)savedmem[j]=mem1[j];
 repeat(200)tick;if(s1!==saved||x1!==savedext)$fatal(1,"protocol advances frozen");
 // Advance/reset the DUT on the discarded timeline, then overwrite every byte
 // through the same physical RAM write interface used for savestate DMA.
 freeze=0;reset1=0;repeat(2)tick;reset1=1;repeat(4)tick;
 freeze=1;refill=0;dmawe=1;
 for(integer j=0;j<128;j=j+1)begin dmaa=j;dmad=~savedmem[j];tick;end
 for(integer j=0;j<128;j=j+1)begin dmaa=j;dmad=savedmem[j];tick;end
 dmawe=0;load=1;tick;load=0;refill=1;repeat(4)tick;
 freeze=0;holdref=0;check;
end endtask
initial begin
 for(op=0;op<7;op=op+1)
 for(en=0;en<2;en=en+1)
 for(wa=0;wa<(op==2?3:1);wa=wa+1)begin
 case(op)
 0:opcode=8'h30;1:opcode=0;2:opcode=8'h80+(wa==0?0:wa==1?31:63);
 3:opcode=8'h7f;4:opcode=8'hff;5:opcode=8'h10;6:opcode=8'h20;
 endcase
 build(opcode);
 for(target=0;target<n;target=target+1)begin
 reset1=0;reset2=0;wr=1;din=0;freeze=0;holdref=0;
 for(integer j=0;j<128;j=j+1)begin mem1[j]=((j*73)^8'ha5);mem2[j]=((j*73)^8'ha5);end
 repeat(3)tick;reset1=1;reset2=1;repeat(2)tick;
 // Seed the existing WRAL data-buffer behavior with a real READ command.
 cmd(8'h80);repeat(6)tick;put(0);
 if(en)cmd(8'h30);else cmd(0);put(0);
 for(c=0;c<n;c=c+1)begin
 wr=trace[c][8];din=trace[c][7:0];tick;
 if(c==target)roundtrip;
 check;
 end
 // Observe the resulting write-enable state through a real subsequent WRITE,
 // without another EWEN/EWDS command masking a restored enable error.
 cmd(8'h4b);for(integer bitpos=15;bitpos>=0;bitpos=bitpos-1)bitin((16'hc39a>>bitpos)&1);
 repeat(5)tick;put(0);check;
 for(integer j=0;j<128;j=j+1)if(mem1[j]!==mem2[j])$fatal(1,"memory byte %0d mismatch op%0d target%0d",j,op,target);
 cases=cases+1;
 end
 $display("PASS opcode=%0d initialWE=%0d readAddressCase=%0d every %0d cycle positions",op,en,wa,n);
 end
 $display("PASS EEPROM replay: %0d cases, all seven encodings, every protocol/pipeline clock, exact pins/state/all128 bytes",cases);$finish;
end
initial begin #200000000;$fatal(1,"watchdog");end
endmodule
