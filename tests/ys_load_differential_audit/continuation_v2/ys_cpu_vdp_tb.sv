`timescale 1ns/1ps
module ys_cpu_vdp_tb;
parameter VARIANT=1,PROGRAM=0,INTCASE=0,PERIOD=15;
reg clk=0,reset_n=0,restore=0,cen0=0,cen1=0,hold1=0;
reg int_n=1,nmi_n=1;
wire [15:0] a[2];wire [7:0] dout[2];reg [7:0] din[2];
wire [229:0] regs[2];wire [1:0] iset[2];wire [2:0] ctx[2],nmistate[2],mc[2],ts[2];wire [7:0] ir[2];
wire [1:0] m1,mreq,iorq,rd,wr,halt,replay;
reg run_vdp=1;reg [4:0] vp=0;
 wire [8:0] xx[2],yy[2];wire [7:0] vc[2];wire [1:0] vb,vidirq;wire [3:0] sm[2];
 reg [7:0] cart[0:1048575];integer cart_bytes,cart_file;string cart_path;
 reg [7:0] bank[2][4];reg [7:0] saved_bank[4];reg [7:0] sram[2][32768],saved_sram[32768];integer ordinal=0;

 wire [127:0] vdpr[2];wire [383:0] cr[2];wire [7:0] vdpd[2],vwd[2];wire [14:0] vwa[2];wire [1:0] vwe;
 reg [127:0] vdpsnap;reg vset=0,initVDP=0;
 reg [22:0] vram_events[2][512];integer vram_count[2];
 always @(negedge clk) vp=(vp+1)%30;
 for(genvar v=0;v<2;v++)begin:video_access
 video video_unit(.clk(clk),.ce_pix(run_vdp&&vp%10==0),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(sm[v][0]),.smode_M2(sm[v][1]),.smode_M3(sm[v][2]),.smode_M4(sm[v][3]),.video_state_out(),.video_state_in(22'd0),.video_state_set(1'b0),.x(xx[v]),.y(yy[v]),.vcounter_cpu(vc[v]),.hsync(),.vsync(),.hblank(),.vblank(vb[v]));
 vdp vdp_unit(.clk_sys(clk),.ce_vdp(run_vdp&&vp%5==0&&!vset),.ce_pix(run_vdp&&vp%10==0),.ce_sp(run_vdp&&vp[0]),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(rd[v]|iorq[v]|(a[v][7:6]!=2'b10)),.WR_n(wr[v]|iorq[v]|(a[v][7:6]!=2'b10)),.IRQ_n(vidirq[v]),.WR_direct(1'b0),.A_direct(6'd0),.A(a[v][7:0]),.D_in(dout[v]),.D_out(vdpd[v]),.x(xx[v]),.y(yy[v]),.vcounter_cpu(vc[v]),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(sm[v][0]),.smode_M2(sm[v][1]),.smode_M3(sm[v][2]),.smode_M4(sm[v][3]),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdpr[v]),.ss_regs_in(vdpsnap),.ss_regs_set(vset&&(v==1||initVDP)),.ss_cram_out(cr[v]),.ss_cram_wr(1'b0),.ss_cram_A(5'd0),.ss_cram_D(12'd0),.ss_vram_en(1'b0),.ss_vram_A(15'd0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'd0),.ss_vram_WD(8'd0),.TestWE(vwe[v]),.TestWA(vwa[v]),.TestWD(vwd[v]));
 always @(posedge clk)if(reset_n&&vwe[v]&&vram_count[v]<512)begin vram_events[v][vram_count[v]]<={vwa[v],vwd[v]};vram_count[v]<=vram_count[v]+1;end
 end
 reg [1:0] previous_wr=2'b11;
reg [229:0] snapshot;reg [2:0] context_saved,nmi_saved;
reg [7:0] mem[2][65536],saved_mem[65536];
 function [7:0] readmem(input integer i,input [15:0] addr);integer off;begin
  if(addr>=16'hc000&&bank[i][0][4])readmem=sram[i][addr&16'h3fff];
  else if(addr>=16'hc000)readmem=mem[i][16'hc000+(addr&16'h1fff)];
  else if(addr>=16'h8000&&bank[i][0][3])readmem=sram[i][(bank[i][0][2]?16384:0)+(addr&16'h3fff)];
  else begin
   if(addr<16'h0400)off=addr;
   else off=bank[i][1+(addr>>14)]*16384+(addr&16'h3fff);
   readmem=cart[off%cart_bytes];
  end
 end endfunction
integer capture_addr,body,loopaddr,first_div=-1,arch_div=-1,bus_div=-1,io_count[2],write_count[2];
integer events=0,checks=0,io_first_bad=-1;reg failed=0;
reg [23:0] io_events[2][512];
always #5 clk=~clk;
for(genvar i=0;i<2;i++)begin:g
 if(i==0||VARIANT>=2)begin:hist
 T80s_historical cpu(.RESET_n(reset_n),.CLK(clk),.CEN(i==0?cen0:cen1),.WAIT_n(1'b1),.INT_n(vidirq[i]),.NMI_n(nmi_n),.BUSRQ_n(1'b1),.M1_n(m1[i]),.MREQ_n(mreq[i]),.IORQ_n(iorq[i]),.RD_n(rd[i]),.WR_n(wr[i]),.RFSH_n(),.HALT_n(halt[i]),.BUSAK_n(),.OUT0(1'b0),.A(a[i]),.DI(din[i]),.DO(dout[i]),.REG(regs[i]),.DIRSet(restore&&i==1),.DIR(snapshot),.ISet_out(iset[i]),.RestartContext(ctx[i]),.RestartDIR(context_saved),.RestartValid(i==1&&VARIANT!=3),.NMIState(nmistate[i]),.NMIDIR(nmi_saved),.NMIValid(1'b1),.NMIEnable(i==1),.NMIHold(1'b0),.RestoreHold(i==1&&hold1),.ReplayT2(1'b1),.NMIReplay(replay[i]),.TestIR(ir[i]),.TestMC(mc[i]),.TestTS(ts[i]));
 end else begin:context_cpu
 T80s_context cpu(.RESET_n(reset_n),.CLK(clk),.CEN(cen1),.WAIT_n(1'b1),.INT_n(vidirq[i]),.NMI_n(nmi_n),.BUSRQ_n(1'b1),.M1_n(m1[i]),.MREQ_n(mreq[i]),.IORQ_n(iorq[i]),.RD_n(rd[i]),.WR_n(wr[i]),.RFSH_n(),.HALT_n(halt[i]),.BUSAK_n(),.OUT0(1'b0),.A(a[i]),.DI(din[i]),.DO(dout[i]),.REG(regs[i]),.DIRSet(restore),.DIR(snapshot),.ISet_out(iset[i]),.RestartContext(ctx[i]),.RestartDIR(context_saved),.RestartValid(VARIANT==1),.NMIState(nmistate[i]),.NMIDIR(nmi_saved),.NMIValid(1'b0),.NMIEnable(1'b0),.NMIHold(1'b0),.RestoreHold(hold1),.ReplayT2(1'b1),.NMIReplay(replay[i]),.TestIR(ir[i]),.TestMC(mc[i]),.TestTS(ts[i]));
 end
 always @* din[i]=!iorq[i]?(a[i][7:6]==2'b10 ? vdpd[i]:8'hff):readmem(i,a[i]);
 always @(posedge clk)if(reset_n&&(i==0?cen0:cen1))begin
  if(!mreq[i]&&!wr[i])begin
 if(a[i]>=16'hc000)begin
 if(bank[i][0][4])sram[i][a[i]&16'h3fff]<=dout[i];else mem[i][16'hc000+(a[i]&16'h1fff)]<=dout[i];
 if(a[i]>=16'hfffc)bank[i][a[i]&3]<=dout[i];end
 else if(a[i]>=16'h8000&&bank[i][0][3])sram[i][(bank[i][0][2]?16384:0)+(a[i]&16'h3fff)]<=dout[i];end
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
 repeat(PERIOD-2)@(negedge clk);
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
 io_count[0]=0;io_count[1]=0;vram_count[0]=0;vram_count[1]=0;
 for(integer j=0;j<65536;j++)begin mem[0][j]=0;mem[1][j]=0;end
 for(integer i=0;i<2;i++)begin bank[i][0]=0;bank[i][1]=0;bank[i][2]=1;bank[i][3]=2;end
 if(!$value$plusargs("ROM=%s",cart_path))$fatal(1,"external ROM path required");
 cart_file=$fopen(cart_path,"rb");if(!cart_file)$fatal(1,"cannot open external ROM");cart_bytes=$fread(cart,cart_file);$fclose(cart_file);
 if(cart_bytes<32768)$fatal(1,"invalid ROM size");
 $display("LOCAL_ROM bytes=%0d (read in place; no ROM output)",cart_bytes);
 for(integer j=0;j<32768;j++)begin sram[0][j]=8'hff;sram[1][j]=8'hff;end
 repeat(8)@(negedge clk);reset_n=1;vdpsnap=0;initVDP=1;vset=1;repeat(2)@(negedge clk);vset=0;initVDP=0;
 begin:find_capture
 for(integer k=0;k<200000;k++)begin
  if(!m1[0]&&!mreq[0]&&iset[0]==0&&ctx[0]==2&&vb[0]&&xx[0]<256&&(din[0]==8'hb0||din[0]==8'hb3))begin
   if(INTCASE==1)int_n=0;
   if(INTCASE==2||INTCASE==3)nmi_n=0;
   #1;snapshot=regs[0];context_saved=ctx[0];nmi_saved=nmistate[0];
   for(integer b=0;b<4;b++)saved_bank[b]=bank[0][b];
   for(integer b=0;b<32768;b++)saved_sram[b]=sram[0][b];
   $display("YS_ACCEPT tick=%0d beam=%0d,%0d PC=%h context=%0d BC=%h HL=%h DE=%h ctrl=%h bank=%h/%h/%h",k,xx[0],yy[0],a[0],ctx[0],regs[0][95:80],regs[0][127:112],regs[0][111:96],bank[0][0],bank[0][1],bank[0][2],bank[0][3]);
   for(integer j=0;j<65536;j++)saved_mem[j]=mem[0][j];
   tick(1,1);disable find_capture;
  end
  tick(1,1);
 end
 $fatal(1,"capture not reached");
 end
 $display("CAPTURE VARIANT=%0d PROGRAM=%0d INTCASE=%0d PC=%h context=%0d NMI=%b",VARIANT,PROGRAM,INTCASE,snapshot[79:64],context_saved,nmi_saved);
 hold1=1;run_vdp=0;vdpsnap=vdpr[0];
 for(integer b=0;b<4;b++)bank[1][b]=saved_bank[b];
 // Reference now represents post-accepted T. LOAD architectural pre-T state.
 @(negedge clk);restore=1;vset=1;@(posedge clk);#1;@(negedge clk);restore=0;vset=0;
 for(integer j=0;j<65536;j++)mem[1][j]=saved_mem[j];
 for(integer b=0;b<32768;b++)sram[1][b]=saved_sram[b];
 io_count[0]=0;io_count[1]=0;vram_count[0]=0;vram_count[1]=0;
 repeat(40)@(negedge clk);
 if(VARIANT>=2)begin // historical metadata installation is a separate stopped edge
  hold1=0;repeat(3)@(negedge clk);
 end
 // Historical T1/T2: reference/VDP guest time stays held.
 tick(0,1);tick(0,1);hold1=0;
 compare(0);run_vdp=1;
 for(integer k=1;k<=700;k++)begin
  if(INTCASE==2&&k==1)nmi_n=1;
  if(INTCASE==4&&k==20)nmi_n=0;
  if(INTCASE==4&&k==22)nmi_n=1;
  if(INTCASE==5&&k==20)int_n=0;
  tick(1,1);compare(k);
 end
 for(integer j='hc000;j<65536;j++)if(mem[0][j]!==mem[1][j])failed=1;
 if(io_count[0]!=io_count[1])io_first_bad=io_count[0]<io_count[1]?io_count[0]:io_count[1];
 for(integer j=0;j<io_count[0]&&j<io_count[1];j++)if(io_events[0][j]!==io_events[1][j]&&io_first_bad<0)io_first_bad=j;
 if(io_first_bad>=0)failed=1;
 begin:memory_scan integer wc,sc;wc=0;sc=0;
 for(integer b=0;b<32768;b++)if(sram[0][b]!==sram[1][b])sc++;
 for(integer b=16'hc000;b<16'he000;b++)if(mem[0][b]!==mem[1][b])wc++;
 if(wc||sc)failed=1;$display("YS_MEMORY WRAM_different_bytes=%0d SRAM_different_bytes=%0d mapper_equal=%0d",wc,sc,{bank[0][0],bank[0][1],bank[0][2],bank[0][3]}==={bank[1][0],bank[1][1],bank[1][2],bank[1][3]});end
 if(vram_count[0]!=vram_count[1])failed=1;
 for(integer j=0;j<vram_count[0]&&j<vram_count[1];j++)begin if($isunknown(vram_events[0][j])||$isunknown(vram_events[1][j]))$fatal(1,"unknown VRAM transaction"); if(vram_events[0][j]!==vram_events[1][j])failed=1;end
 $display("VRAM actual_writes=%0d/%0d first=%h/%h second=%h/%h",vram_count[0],vram_count[1],vram_events[0][0],vram_events[1][0],vram_events[0][1],vram_events[1][1]);
 $display("RESULT failed=%0d arch_first=%0d bus_first=%0d IO=%0d/%0d IO_first_bad=%0d handlerINT=%0d/%0d handlerNMI=%0d/%0d checks=%0d",failed,arch_div,bus_div,io_count[0],io_count[1],io_first_bad,mem[0]['hc510],mem[1]['hc510],mem[0]['hc511],mem[1]['hc511],checks);
 $display("COMPLETE VARIANT=%0d PROGRAM=%0d INTCASE=%0d",VARIANT,PROGRAM,INTCASE);$finish;
end
initial begin #100000000;$fatal(1,"timeout");end
endmodule
