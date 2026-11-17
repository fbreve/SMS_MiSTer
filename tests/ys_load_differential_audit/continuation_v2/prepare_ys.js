const fs=require('fs'),p=require('path');const d=__dirname;
let tb=fs.readFileSync(p.join(d,'cpu_vdp_tb.sv'),'utf8').replace('module cpu_vdp_tb;','module ys_cpu_vdp_tb;');
tb=tb.replace('parameter VARIANT=1,PROGRAM=0,INTCASE=0,PERIOD=15;','parameter VARIANT=1,PROGRAM=0,INTCASE=0,PERIOD=15;');
tb=tb.replace('reg run_vdp=1;reg [2:0] vp=0;',`reg run_vdp=1;reg [4:0] vp=0;
 wire [8:0] xx[2],yy[2];wire [7:0] vc[2];wire [1:0] vb,vidirq;wire [3:0] sm[2];
 reg [7:0] cart[0:1048575];integer cart_bytes,cart_file;string cart_path;
 reg [7:0] bank[2][4];reg [7:0] saved_bank[4];reg [7:0] sram[2][32768],saved_sram[32768];integer ordinal=0;
 function [7:0] readmem(input integer i,input [15:0] addr);integer off;begin
  if(addr>=16'hc000&&bank[i][0][4])readmem=sram[i][addr&16'h3fff];
  else if(addr>=16'hc000)readmem=mem[i][16'hc000+(addr&16'h1fff)];
  else if(addr>=16'h8000&&bank[i][0][3])readmem=sram[i][(bank[i][0][2]?16384:0)+(addr&16'h3fff)];
  else begin
   if(addr<16'h0400)off=addr;
   else off=bank[i][1+(addr>>14)]*16384+(addr&16'h3fff);
   readmem=cart[off%cart_bytes];
  end
 end endfunction`);
tb=tb.replace('vp=(vp+1)%5','vp=(vp+1)%30');
tb=tb.replace('begin:video_access','begin:video_access\n video video_unit(.clk(clk),.ce_pix(run_vdp&&vp%10==0),.pal(1\'b0),.border(1\'b0),.ggres(1\'b0),.mask_column(1\'b0),.cut_mask(1\'b0),.smode_M1(sm[v][0]),.smode_M2(sm[v][1]),.smode_M3(sm[v][2]),.smode_M4(sm[v][3]),.video_state_out(),.video_state_in(22\'d0),.video_state_set(1\'b0),.x(xx[v]),.y(yy[v]),.vcounter_cpu(vc[v]),.hsync(),.vsync(),.hblank(),.vblank(vb[v]));');
tb=tb.replace('vp==0&&!vset','vp%5==0&&!vset').replace(".ce_pix(1'b0),.ce_sp(1'b0)",".ce_pix(run_vdp&&vp%10==0),.ce_sp(run_vdp&&vp[0])");
tb=tb.replace('.IRQ_n()','.IRQ_n(vidirq[v])').replace(".x(9'd100),.y(9'd240),.vcounter_cpu(8'd240)",'.x(xx[v]),.y(yy[v]),.vcounter_cpu(vc[v])').replace('.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4()','.smode_M1(sm[v][0]),.smode_M2(sm[v][1]),.smode_M3(sm[v][2]),.smode_M4(sm[v][3])');
tb=tb.replaceAll('.INT_n(int_n)','.INT_n(vidirq[i])');
tb=tb.replace("!iorq[i]?(a[i][7:6]==2'b10 ? vdpd[i]:8'hff):mem[i][a[i]]","!iorq[i]?(a[i][7:6]==2'b10 ? vdpd[i]:8'hff):readmem(i,a[i])");
tb=tb.replace('if(!mreq[i]&&!wr[i])mem[i][a[i]]<=dout[i];',`if(!mreq[i]&&!wr[i])begin
 if(a[i]>=16'hc000)begin
 if(bank[i][0][4])sram[i][a[i]&16'h3fff]<=dout[i];else mem[i][16'hc000+(a[i]&16'h1fff)]<=dout[i];
 if(a[i]>=16'hfffc)bank[i][a[i]&3]<=dout[i];end
 else if(a[i]>=16'h8000&&bank[i][0][3])sram[i][(bank[i][0][2]?16384:0)+(a[i]&16'h3fff)]<=dout[i];end`);
const start=tb.indexOf(' // Fully initialize'),end=tb.indexOf(' repeat(8)@(negedge clk);',start);
tb=tb.slice(0,start)+` for(integer i=0;i<2;i++)begin bank[i][0]=0;bank[i][1]=0;bank[i][2]=1;bank[i][3]=2;end
 if(!$value$plusargs("ROM=%s",cart_path))$fatal(1,"external ROM path required");
 cart_file=$fopen(cart_path,"rb");if(!cart_file)$fatal(1,"cannot open external ROM");cart_bytes=$fread(cart,cart_file);$fclose(cart_file);
 if(cart_bytes<32768)$fatal(1,"invalid ROM size");
 $display("LOCAL_ROM bytes=%0d (read in place; no ROM output)",cart_bytes);
 for(integer j=0;j<32768;j++)begin sram[0][j]=8'hff;sram[1][j]=8'hff;end
`+tb.slice(end);
tb=tb.replace('k<4000','k<200000');
tb=tb.replace('if(!m1[0]&&!mreq[0]&&iset[0]==0&&a[0]==capture_addr)',"if(!m1[0]&&!mreq[0]&&iset[0]==0&&ctx[0]==2&&vb[0]&&xx[0]<256&&(din[0]==8'hb0||din[0]==8'hb3))");
tb=tb.replace('snapshot=regs[0];context_saved=ctx[0];nmi_saved=nmistate[0];','snapshot=regs[0];context_saved=ctx[0];nmi_saved=nmistate[0];\n   for(integer b=0;b<4;b++)saved_bank[b]=bank[0][b];\n   for(integer b=0;b<32768;b++)saved_sram[b]=sram[0][b];\n   $display("YS_ACCEPT tick=%0d beam=%0d,%0d PC=%h context=%0d BC=%h HL=%h DE=%h ctrl=%h bank=%h/%h/%h",k,xx[0],yy[0],a[0],ctx[0],regs[0][95:80],regs[0][127:112],regs[0][111:96],bank[0][0],bank[0][1],bank[0][2],bank[0][3]);');
tb=tb.replace('hold1=1;run_vdp=0;vdpsnap=vdpr[0];','hold1=1;run_vdp=0;vdpsnap=vdpr[0];\n for(integer b=0;b<4;b++)bank[1][b]=saved_bank[b];');
tb=tb.replace('io_count[0]=0;io_count[1]=0;\n repeat(40)','for(integer b=0;b<32768;b++)sram[1][b]=saved_sram[b];\n io_count[0]=0;io_count[1]=0;\n repeat(40)');
tb=tb.replace('if(io_first_bad>=0)failed=1;',`if(io_first_bad>=0)failed=1;
 begin:memory_scan integer wc,sc;wc=0;sc=0;
 for(integer b=0;b<32768;b++)if(sram[0][b]!==sram[1][b])sc++;
 for(integer b=16'hc000;b<16'he000;b++)if(mem[0][b]!==mem[1][b])wc++;
 if(wc||sc)failed=1;$display("YS_MEMORY WRAM_different_bytes=%0d SRAM_different_bytes=%0d mapper_equal=%0d",wc,sc,{bank[0][0],bank[0][1],bank[0][2],bank[0][3]}==={bank[1][0],bank[1][1],bank[1][2],bank[1][3]});end`);
tb=tb.replace('io_count[0]=0;io_count[1]=0;\n repeat(40)','io_count[0]=0;io_count[1]=0;vram_count[0]=0;vram_count[1]=0;\n repeat(40)');
// Align native 15-host-clock CPU tick spacing for this ROM probe.
tb=tb.replace('repeat(PERIOD-1)@(negedge clk);','repeat(PERIOD-2)@(negedge clk);');
tb=tb.replace('#10000000;','#100000000;');
const func=tb.match(/ function \[7:0\] readmem[\s\S]*?end endfunction/)[0];tb=tb.replace(func,'').replace('reg [7:0] mem[2][65536],saved_mem[65536];','reg [7:0] mem[2][65536],saved_mem[65536];\n'+func);
fs.writeFileSync(p.join(d,'ys_cpu_vdp_tb.sv'),tb);
