`timescale 1ns/1ps
module cpu_tb;
reg clk=0,reset_n=0,restore=0;
reg [2:0] run_cpu=3'b001;
reg [229:0] snapshot=0;
wire [15:0] a[3]; wire [7:0] dout[3]; reg [7:0] din[3];
wire [229:0] regs[3]; wire [1:0] iset[3];
wire [2:0] m1,mreq,rd,wr,halt;
reg [7:0] ram[3][65536];
integer phase=0;
wire ce=phase==0;
always #5 clk=~clk;
always @(negedge clk) phase=(phase+1)%15;
for(genvar i=0;i<3;i++)begin:g
 if(i==2)begin:probe
 T80s_ed dut(.RESET_n(reset_n),.CLK(clk),.CEN(ce&&run_cpu[i]),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(m1[i]),.MREQ_n(mreq[i]),.IORQ_n(),.RD_n(rd[i]),.WR_n(wr[i]),.RFSH_n(),.HALT_n(halt[i]),.BUSAK_n(),.OUT0(1'b0),.A(a[i]),.DI(din[i]),.DO(dout[i]),.REG(regs[i]),.DIRSet(restore&&i!=0),.DIR(snapshot),.ISet_out(iset[i]));
 end else begin:original
 T80s dut(.RESET_n(reset_n),.CLK(clk),.CEN(ce&&run_cpu[i]),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(m1[i]),.MREQ_n(mreq[i]),.IORQ_n(),.RD_n(rd[i]),.WR_n(wr[i]),.RFSH_n(),.HALT_n(halt[i]),.BUSAK_n(),.OUT0(1'b0),.A(a[i]),.DI(din[i]),.DO(dout[i]),.REG(regs[i]),.DIRSet(restore&&i!=0),.DIR(snapshot),.ISet_out(iset[i]));
 end
 always @* din[i]=ram[i][a[i]];
 always @(posedge clk) if(reset_n&&run_cpu[i]&&!mreq[i]&&!wr[i])ram[i][a[i]]<=dout[i];
end
initial begin
 for(integer i=0;i<3;i++)begin
  for(integer j=0;j<65536;j++)ram[i][j]=0;
  // LD BC,2; LD HL,4000; LD DE,C000; LDIR; HALT
  ram[i][0]='h01;ram[i][1]=2;ram[i][2]=0;
  ram[i][3]='h21;ram[i][4]=0;ram[i][5]='h40;
  ram[i][6]='h11;ram[i][7]=0;ram[i][8]='hc0;
  ram[i][9]='hed;ram[i][10]='hb0;ram[i][11]='h76;
  ram[i]['h4000]='ha5;ram[i]['h4001]='h5a;
 end
 repeat(8)@(negedge clk);reset_n=1;
 // Exactly the production acceptance predicate's fetch, at the CPU tick.
 do begin @(posedge clk);end while(!(ce&&!m1[0]&&!mreq[0]&&iset[0]==0&&a[0]==10));
 snapshot=regs[0];
 $display("CAPTURE PC=%h ISet=%h (natural ED predecessor)",snapshot[79:64],iset[0]);
 @(negedge clk);restore=1;
 @(negedge clk);restore=0;run_cpu=3'b111;
 wait(halt==0);repeat(5)@(negedge clk);
 $display("RESULT uninterrupted=%h,%h current_LOAD=%h,%h ED_probe=%h,%h",ram[0]['hc000],ram[0]['hc001],ram[1]['hc000],ram[1]['hc001],ram[2]['hc000],ram[2]['hc001]);
 if(ram[0]['hc000]!==8'ha5||ram[0]['hc001]!==8'h5a)$fatal(1,"reference copy failed");
 if(ram[1]['hc000]!==0||ram[1]['hc001]!==0)$fatal(1,"expected current defect absent");
 if(ram[2]['hc000]!==ram[0]['hc000]||ram[2]['hc001]!==ram[0]['hc001])$fatal(1,"ED intervention failed");
 $display("PASS: current CPU loses pending ED; test-only predecessor restoration recovers both guest writes. Not an Ys reproduction.");$finish;
end
initial begin #5000000;$fatal(1,"timeout");end
endmodule
