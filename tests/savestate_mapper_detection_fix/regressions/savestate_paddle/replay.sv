`timescale 1ns/1ps
module replay;
parameter PHASES=1;
reg clk=0;always #5 clk=~clk;
reg holdref=0,freeze=0,ss_set=0,valid=1,jp=0,joy=0,th0=1,th1=1;
reg[31:0]restore;reg[7:0]p0,p1,x0,x1;wire[31:0]state,refstate;wire[9:0]pins,refpins;
paddle_fixture dut(clk,1'b0,freeze,ss_set,valid,jp,joy,restore,p0,p1,x0,x1,th0,th1,state,pins);
paddle_fixture reference(clk,holdref,1'b0,1'b0,1'b0,jp,joy,32'd0,p0,p1,x0,x1,th0,th1,refstate,refpins);
task tick;begin @(negedge clk);#1;end endtask
task check;begin if(state!==refstate||pins!==refpins)$fatal(1,"case%0d step%0d state%h/%h pins%h/%h",cases,i,state,refstate,pins,refpins);end endtask
integer a,b,c,e,f,g,phase,cases=0,i,j;reg[31:0]saved;reg[7:0]positions[0:6];
task setup(input integer pos,mode,source,half,ths,pending,cp);
begin
holdref=0;freeze=0;ss_set=0;valid=1;jp=0;joy=source;
p0=positions[pos];p1=~positions[pos];x0=p0^8'h80;x1=p1^8'h80;th0=1;th1=1;
// Choose legal power-up divider phase; all nibble/TR/history state established by real TH edges.
dut.cnt_en16khz=13;reference.cnt_en16khz=13;
repeat(2)tick;th0=0;th1=0;tick;th0=1;th1=1;tick;th0=0;th1=0;tick;
jp=mode!=0;
if(mode)begin while(state[31:20]!=0)tick;tick;if(!half)begin while(state[31:20]!=0)tick;tick;end end
else if(half)begin th0=1;th1=1;tick;end
if(mode==2)begin jp=0;th0=~th0;tick;end
th0=ths&1;th1=(ths>>1)&1;tick;
while(state[31:20]!=cp)tick;
// Capture on either side of an unconsumed edge, including independent ports.
th0=th0^(pending&1);th1=th1^((pending>>1)&1);
saved=state;holdref=1;freeze=1;restore=saved;
repeat(19)begin tick;if(state!==saved)$fatal(1,"freeze drift");end
freeze=0;p0=8'h76;p1=8'h29;x0=8'hfa;x1=8'h03;
repeat(11)begin th0=~th0;th1=~th1;tick;end
freeze=1;ss_set=1;tick;ss_set=0;
if(state!==saved)$fatal(1,"restore mismatch");
// Change raw input after capture. Restored sample must remain historical.
p0=8'he1;p1=8'hb4;x0=8'h96;x1=8'h78;
holdref=0;freeze=0;
for(i=0;i<(PHASES?6714:7000);i=i+1)begin
if(i==0||i==1||i==2||i==47)begin th0=~th0;if(i!=1)th1=~th1;end
if(i==333)begin p0=8'hf0;p1=8'h0f;x0=8'h32;x1=8'hba;end
tick;check;
end
// Repeat exact restore at current point with a long frozen idle.
if(!PHASES)begin saved=state;restore=saved;holdref=1;freeze=1;repeat(6800)tick;ss_set=1;tick;ss_set=0;freeze=0;holdref=0;repeat(3)begin tick;check;end end
cases=cases+1;
end endtask
initial begin
positions[0]=0;positions[1]=255;positions[2]=128;positions[3]=8'ha3;positions[4]=8'h5c;positions[5]=8'h01;positions[6]=8'hfe;
if(PHASES==1)begin
for(a=0;a<2;a=a+1)for(phase=0;phase<3356;phase=phase+1)setup(3,1,phase&1,a,phase&3,phase&3,phase);
end else if(PHASES==2)begin
for(a=0;a<7;a=a+1)for(c=0;c<2;c=c+1)for(f=0;f<4;f=f+1)for(g=0;g<4;g=g+1)setup(a,2,c,1,f,g,123);
end else begin
for(a=0;a<7;a=a+1)for(b=0;b<2;b=b+1)for(c=0;c<2;c=c+1)for(e=0;e<2;e=e+1)for(f=0;f<4;f=f+1)for(g=0;g<4;g=g+1)setup(a,b,c,e,f,g,(a*479+f*7)%3356);
// Invalid/legacy normalization uses current sample, current TH, TR=0, divider=0.
freeze=1;valid=0;ss_set=1;jp=0;joy=0;p0=8'hb2;p1=8'h4d;th0=1;th1=0;tick;ss_set=0;
if(state!=={12'd0,2'b01,2'b00,8'h4d,8'hb2})$fatal(1,"legacy physical normalization %h",state);
joy=1;x0=8'h21;x1=8'he4;ss_set=1;tick;ss_set=0;
if(state!=={12'd0,2'b01,2'b00,8'h64,8'ha1})$fatal(1,"legacy joystick normalization %h",state);
end
$display("PASS F10 directed PHASES=%0d cases=%0d complete counter phases=3356 JP halves=2",PHASES,cases);$finish;
end
endmodule
