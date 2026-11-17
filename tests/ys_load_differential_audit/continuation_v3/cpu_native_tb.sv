`timescale 1ns/1ps
module cpu_native_tb;
parameter VARIANT=1,PROGRAM=0,INTCASE=0,PERIOD=15,PRELOAD=0;
reg clk=0,reset_n=0,restore=0,cen0=0,cen1=0,hold1=0;
reg reset_dut=0;
reg int_n=1,nmi_n=1;
wire [15:0] a[2];wire [7:0] dout[2];reg [7:0] din[2];
wire [229:0] regs[2];wire [1:0] iset[2];wire [2:0] ctx[2],nmistate[2],mc[2],ts[2];wire [7:0] ir[2];
wire [1:0] m1,mreq,iorq,rd,wr,halt,replay;
reg [1:0] previous_wr=2'b11;
reg [229:0] snapshot;reg [2:0] context_saved,nmi_saved;
reg [7:0] mem[2][65536],saved_mem[65536];
integer capture_addr,body,loopaddr,first_div=-1,arch_div=-1,bus_div=-1,io_count[2],write_count[2];
integer events=0,checks=0,io_first_bad=-1;reg failed=0;
reg [23:0] io_events[2][512];
always #5 clk=~clk;
for(genvar i=0;i<2;i++)begin:g
 if(i==0||VARIANT>=2)begin:hist
 T80s_context #(.Mode(0),.T2Write(0)) cpu(.RESET_n(reset_n&&(i==0||!reset_dut)),.CLK(clk),.CEN(i==0?cen0:cen1),.WAIT_n(1'b1),.INT_n(int_n),.NMI_n(nmi_n),.BUSRQ_n(1'b1),.M1_n(m1[i]),.MREQ_n(mreq[i]),.IORQ_n(iorq[i]),.RD_n(rd[i]),.WR_n(wr[i]),.RFSH_n(),.HALT_n(halt[i]),.BUSAK_n(),.OUT0(1'b0),.A(a[i]),.DI(din[i]),.DO(dout[i]),.REG(regs[i]),.DIRSet(restore&&i==1),.DIR(snapshot),.ISet_out(iset[i]),.RestartContext(ctx[i]),.RestartDIR(context_saved),.RestartValid(i==1&&VARIANT!=3),.NMIState(nmistate[i]),.NMIDIR(nmi_saved),.NMIValid(1'b1),.NMIEnable(i==1),.NMIHold(1'b0),.RestoreHold(i==1&&hold1),.ReplayT2(1'b1),.NMIReplay(replay[i]),.TestIR(ir[i]),.TestMC(mc[i]),.TestTS(ts[i]));
 end else begin:context_cpu
 T80s_context #(.Mode(0),.T2Write(0)) cpu(.RESET_n(reset_n&&(i==0||!reset_dut)),.CLK(clk),.CEN(cen1),.WAIT_n(1'b1),.INT_n(int_n),.NMI_n(nmi_n),.BUSRQ_n(1'b1),.M1_n(m1[i]),.MREQ_n(mreq[i]),.IORQ_n(iorq[i]),.RD_n(rd[i]),.WR_n(wr[i]),.RFSH_n(),.HALT_n(halt[i]),.BUSAK_n(),.OUT0(1'b0),.A(a[i]),.DI(din[i]),.DO(dout[i]),.REG(regs[i]),.DIRSet(restore),.DIR(snapshot),.ISet_out(iset[i]),.RestartContext(ctx[i]),.RestartDIR(context_saved),.RestartValid(VARIANT==1),.NMIState(nmistate[i]),.NMIDIR(nmi_saved),.NMIValid(1'b0),.NMIEnable(1'b0),.NMIHold(1'b0),.RestoreHold(hold1),.ReplayT2(1'b1),.NMIReplay(replay[i]),.TestIR(ir[i]),.TestMC(mc[i]),.TestTS(ts[i]));
 end
 always @* din[i]=!iorq[i]?8'hff:mem[i][a[i]];
 always @(posedge clk)if(reset_n&&(i==0?cen0:cen1))begin
  if(!mreq[i]&&!wr[i])mem[i][a[i]]<=dout[i];
 end
 always @(posedge clk)begin
  previous_wr[i]<=wr[i];
  if(reset_n&&!iorq[i]&&!wr[i]&&previous_wr[i]&&io_count[i]<512)begin io_events[i][io_count[i]]<={a[i],dout[i]};io_count[i]<=io_count[i]+1;end
 end
end
task tick(input bit r,input bit d);begin
 @(negedge clk);cen0=r;cen1=d;
 @(posedge clk);#1;
 @(negedge clk);cen0=0;cen1=0;
 repeat(PERIOD-1)@(negedge clk);
end endtask
task bytecode(input integer v);begin mem[0][body]=v;mem[1][body]=v;body++;end endtask
task compare(input integer k);begin
 checks++;
 if({regs[0],iset[0],ir[0],mc[0],ts[0]}!=={regs[1],iset[1],ir[1],mc[1],ts[1]})begin if(arch_div<0)arch_div=k;failed=1;end
 // DO is don't-care on reads; DI is compared only on active reads.
 if({m1[0],mreq[0],iorq[0],rd[0],wr[0],halt[0]}!=={m1[1],mreq[1],iorq[1],rd[1],wr[1],halt[1]} ||
 ((!mreq[0]||!iorq[0]||!mreq[1]||!iorq[1])&&a[0]!==a[1]) ||
 ((!wr[0]||!wr[1])&&dout[0]!==dout[1]) || ((!rd[0]||!rd[1])&&din[0]!==din[1]))begin if(bus_div<0)bus_div=k;failed=1;end
 if(failed&&first_div<0)begin first_div=k;$display("FIRST k=%0d PC=%h/%h IR=%h/%h ISet=%h/%h BC=%h/%h busA=%h/%h",k,regs[0][79:64],regs[1][79:64],ir[0],ir[1],iset[0],iset[1],regs[0][95:80],regs[1][95:80],a[0],a[1]);end
end endtask
initial begin
 io_count[0]=0;io_count[1]=0;
 for(integer j=0;j<65536;j++)begin mem[0][j]=0;mem[1][j]=0;end
 // Fully initialize architectural banks with guest code, and leave SP in RAM.
 body=0;bytecode('hf3);bytecode('h31);bytecode('hf0);bytecode('hdf);
 bytecode('h01);bytecode(2);bytecode(0);bytecode('h11);bytecode(0);bytecode('hc1);bytecode('h21);bytecode(0);bytecode('hc2);
 bytecode('haf);bytecode('h08);bytecode('haf);bytecode('h08);bytecode('hd9);
 bytecode('h01);bytecode(0);bytecode(0);bytecode('h11);bytecode(0);bytecode(0);bytecode('h21);bytecode(0);bytecode(0);bytecode('hd9);
 bytecode('hdd);bytecode('h21);bytecode(0);bytecode('hc3);bytecode('hfd);bytecode('h21);bytecode(0);bytecode('hc4);
 bytecode('hc3);bytecode(0);bytecode(1);
 // IM1 handler increments a RAM counter then EI/RETI; NMI handler RETN.
 body='h38;bytecode('h3a);bytecode('h10);bytecode('hc5);bytecode('h3c);bytecode('h32);bytecode('h10);bytecode('hc5);bytecode('hfb);bytecode('hed);bytecode('h4d);
 body='h66;bytecode('h3a);bytecode('h11);bytecode('hc5);bytecode('h3c);bytecode('h32);bytecode('h11);bytecode('hc5);bytecode('hed);bytecode('h45);
 body='h100;bytecode('hed);bytecode('h56); // IM 1
 case(PROGRAM)
 0:begin bytecode('h00);capture_addr=body;bytecode('h00);end
 1:begin bytecode('h06);bytecode('h81);bytecode('hcb);capture_addr=body;bytecode('h00);end
 2:begin bytecode('h3e);bytecode('h35);bytecode('hed);capture_addr=body;bytecode('h44);end
 3:begin bytecode('hdd);capture_addr=body;bytecode('h24);end
 4:begin bytecode('hfd);capture_addr=body;bytecode('h2c);end
 5:begin bytecode('hfb);capture_addr=body;bytecode('h00);end
 6:begin bytecode('hdd);bytecode('hcb);capture_addr=body-1;bytecode(0);bytecode('h06);end
 7:begin bytecode('hfd);bytecode('hcb);capture_addr=body-1;bytecode(0);bytecode('hc6);end
 8:begin bytecode('hdd);bytecode('hfd);bytecode('hdd);capture_addr=body;bytecode('h24);end
 9:begin bytecode('h21);bytecode(0);bytecode('hc2);bytecode('h11);bytecode(0);bytecode('hc1);bytecode('h01);bytecode(3);bytecode(0);bytecode('hed);capture_addr=body;bytecode('hb0);end
 10:begin bytecode('h21);bytecode(0);bytecode('hc2);bytecode('h01);bytecode('hbe);bytecode(3);bytecode('hed);capture_addr=body;bytecode('hb3);end
 11:begin bytecode('hfb);capture_addr=body;bytecode('h76);end
 default:$fatal(1,"unknown program");
 endcase
 // Every future ends in real VDP control/data writes, then a quiet RAM loop.
 bytecode('h3e);bytecode(0);bytecode('hd3);bytecode('hbf);bytecode('h3e);bytecode('h40);bytecode('hd3);bytecode('hbf);
 bytecode('h3e);bytecode('ha5);bytecode('hd3);bytecode('hbe);bytecode('h3e);bytecode('h5a);bytecode('hd3);bytecode('hbe);
 bytecode('h32);bytecode('h20);bytecode('hc5);loopaddr=body;bytecode('hc3);bytecode(loopaddr&255);bytecode(loopaddr>>8);
 for(integer j=0;j<2;j++)begin mem[j]['hc200]='h81;mem[j]['hc201]='h5a;mem[j]['hc202]='hc3;end
 repeat(8)@(negedge clk);reset_n=1;
 begin:find_capture
 for(integer k=0;k<4000;k++)begin
  if(!m1[0]&&!mreq[0]&&iset[0]==0&&a[0]==capture_addr)begin
   if(INTCASE==1)int_n=0;
   if(INTCASE==2||INTCASE==3)nmi_n=0;
   #1;snapshot=regs[0];context_saved=ctx[0];nmi_saved=nmistate[0];
   for(integer j=0;j<65536;j++)saved_mem[j]=mem[0][j];
   tick(1,1);disable find_capture;
  end
  tick(1,1);
 end
 $fatal(1,"capture not reached");
 end
 $display("CAPTURE VARIANT=%0d PROGRAM=%0d INTCASE=%0d PC=%h context=%0d NMI=%b",VARIANT,PROGRAM,INTCASE,snapshot[79:64],context_saved,nmi_saved);
 if(PRELOAD==2)for(integer dirty=0;dirty<700;dirty++)tick(0,1);
 if(PRELOAD==1)begin @(negedge clk);reset_dut=1;repeat(8)@(negedge clk);reset_dut=0;end
 hold1=1;
 // Reference now represents post-accepted T. LOAD architectural pre-T state.
 @(negedge clk);restore=1;@(posedge clk);#1;@(negedge clk);restore=0;
 for(integer j=0;j<65536;j++)mem[1][j]=saved_mem[j];
 io_count[0]=0;io_count[1]=0;
 repeat(40)@(negedge clk);
 if(VARIANT>=2)begin // historical metadata installation is a separate stopped edge
  hold1=0;repeat(3)@(negedge clk);
 end
 // Historical T1/T2: reference/VDP guest time stays held.
 tick(0,1);tick(0,1);hold1=0;
 compare(0);
 for(integer k=1;k<=700;k++)begin
  if(INTCASE==2&&k==1)nmi_n=1;
  if(INTCASE==4&&k==20)nmi_n=0;
  if(INTCASE==4&&k==22)nmi_n=1;
  if(INTCASE==5&&k==20)int_n=0;
  tick(1,1);compare(k);
 end
 for(integer j='hc000;j<65536;j++)if(mem[0][j]!==mem[1][j])failed=1;
 if(io_count[0]!=io_count[1])io_first_bad=io_count[0]<io_count[1]?io_count[0]:io_count[1];
 for(integer j=0;j<io_count[0]&&j<io_count[1];j++)if(io_events[0][j]!==io_events[1][j]&&(io_first_bad<0||j<io_first_bad))io_first_bad=j;
 if(io_first_bad>=0)failed=1;
 $display("RESULT failed=%0d arch_first=%0d bus_first=%0d IO=%0d/%0d IO_first_bad=%0d handlerINT=%0d/%0d handlerNMI=%0d/%0d checks=%0d",failed,arch_div,bus_div,io_count[0],io_count[1],io_first_bad,mem[0]['hc510],mem[1]['hc510],mem[0]['hc511],mem[1]['hc511],checks);
 $display("COMPLETE VARIANT=%0d PROGRAM=%0d INTCASE=%0d",VARIANT,PROGRAM,INTCASE);$finish;
end
initial begin #10000000;$fatal(1,"timeout");end
endmodule
