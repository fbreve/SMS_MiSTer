`timescale 1ns/1ps
module interface_tb;
reg clk=0;always #5 clk=~clk;
tri[45:0]bus;tri[35:0]ext;
reg strobe=0,io=0,fp=0;reg[15:0]din=0;
assign bus[35:33]={fp,io,strobe};assign bus[31:16]=din;assign bus[45:38]=0;assign ext[32]=0;
wire downloading,wr;wire[15:0]index;wire[26:0]addr;wire[7:0]data;wire[31:0]extension;
wire mounted,readonly;wire[63:0]size;
fio_decoder dut(.clk_sys(clk),.HPS_BUS(bus),.ioctl_download(downloading),.ioctl_index(index),.ioctl_addr(addr),.ioctl_dout(data),.ioctl_wr(wr),.ioctl_file_ext(extension));
task tick;begin @(negedge clk);#1;end endtask
task word(input[15:0]v);begin din=v;strobe=1;tick;strobe=0;repeat(2)tick;end endtask
task begin_cmd(input bit f,input[7:0]c);begin io=!f;fp=f;word(c);end endtask
task end_cmd;begin io=0;fp=0;repeat(3)tick;end endtask
task single(input bit f,input[7:0]c,input[15:0]v);begin begin_cmd(f,c);word(v);end_cmd;end endtask
integer count=0,pass=0;reg[50:0]trace[0:31];reg[50:0]observed;
always@(posedge clk)if(wr)begin
 observed={index,addr,data};
 if(pass==0)trace[count]=observed;
 else if(pass==1&&trace[count]!==observed)$fatal(1,"same download differs %d",count);
 else if(pass==2&&data!==(8'h20+count))$fatal(1,"different byte stream missing");
 if(!downloading||addr!==count)$fatal(1,"download address/strobe contract");
 count++;
end
initial begin
 repeat(5)tick;
 for(pass=0;pass<3;pass++)begin
  single(1,8'h55,16'h0041); // extension ordinal1, menu slot1
  begin_cmd(1,8'h56);word(16'h2e53);word(16'h4700);end_cmd;
  if(extension!==32'h2e534700)$fatal(1,"extension metadata");
  count=0;single(1,8'h53,16'h00ff);if(!downloading||addr!==0)$fatal(1,"start");
  begin_cmd(1,8'h54);for(integer j=0;j<32;j++)word((pass==2?8'h20:8'h10)+j);end_cmd;
  begin_cmd(0,8'h1d);word(0);word(0);word(0);word(0);end_cmd;
  single(0,8'h1c,16'h0001);
  single(1,8'h53,0);if(downloading||addr!==32||count!=32)$fatal(1,"end/count");
  $display("PASS WIRE download%0d bytes%0d index%h extension%h final_addr%0d",pass,count,index,extension,addr);
 end
 single(1,8'h55,16'hab41);if(index!==16'hab41)$fatal(1,"full framework index width");
 $display("PASS full16bit framework index; SMS consumes low8 only");
 $display("PASS INTERFACE COMPLETE");$finish;
end
initial begin #100000;$fatal(1,"interface watchdog");end
endmodule
