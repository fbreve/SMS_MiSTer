`timescale 1ns/1ps
module pause_tb;parameter CASE=0,KEEP=0,FULL=0;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
wire ss_freeze;
wire vblank;
wire [8:0] x;
wire [229:0] z80_reg;
wire [229:0] z80_dir;
wire z80_set;
wire z80_m1_n;
wire z80_mreq_n;
wire [1:0] z80_iset;
wire cpu_ce;
wire vdp_ce;
wire pix_ce;
wire sp_ce;
wire [135:0] vdp_regs;
wire [135:0] vdp_regs_in;
wire vdp_regs_set;
reg [383:0] cram_out = '0;
wire [4:0] cram_A;
wire [11:0] cram_D;
wire cram_wr;
wire vram_en;
wire [14:0] vram_A;
reg [7:0] vram_D = '0;
wire vram_WE;
wire [14:0] vram_WA;
wire [7:0] vram_WD;
wire [55:0] psg_out;
wire [55:0] psg_in;
wire psg_set;
wire [95:0] psg_ext_out;
wire [95:0] psg2_ext_out;
wire [95:0] psg_ext_in;
wire [95:0] psg2_ext_in;
wire [3:0] psg_div_out;
wire [3:0] psg_div_in;
reg [10:0] audio_control_out = '0;
wire [10:0] audio_control_in;
wire audio_quiescent;
reg audio_phase_out = '0;
wire audio_phase_in;
wire audio_ext_set;
wire audio_phase_set;
reg [63:0] mapper_out = '0;
wire [63:0] mapper_in;
wire mapper_set;
reg [95:0] evolution_out = '0;
wire [95:0] evolution_in;
wire evolution_set;
reg storage_busy = '0;
wire ss_busy;
reg eeprom_present = '0;
reg [127:0] eeprom_ext_out = '0;
wire [127:0] eeprom_ext_in;
wire eeprom_full;
wire nvram_refill;
reg [45:0] gun_out = '0;
wire [45:0] gun_in;
wire gun_set;
wire gun_valid;
reg [31:0] paddle_out = '0;
wire [31:0] paddle_in;
wire paddle_set;
wire paddle_valid;
reg [18:0] tap_out = '0;
wire [18:0] tap_in;
wire tap_set;
wire tap_valid;
reg [1:0] sc_ram_size = '0;
wire sc_ram_restored;
reg [63:0] eeprom_out = '0;
wire [63:0] eeprom_in;
wire eeprom_set;
wire [13:0] wram_A;
reg [7:0] wram_D = '0;
wire wram_WE;
wire [13:0] wram_WA;
wire [7:0] wram_WD;
wire [14:0] nvram_A;
reg [7:0] nvram_D = '0;
wire nvram_WE;
wire [14:0] nvram_WA;
wire [7:0] nvram_WD;
reg systeme = '0;
wire [135:0] vdp2_regs;
wire [135:0] vdp2_regs_in;
wire vdp2_regs_set;
reg [383:0] cram2_out = '0;
wire [4:0] cram2_A;
wire [11:0] cram2_D;
wire cram2_wr;
wire vram2_en;
wire [14:0] vram2_A;
reg [7:0] vram2_D = '0;
wire vram2_WE;
wire [14:0] vram2_WA;
wire [7:0] vram2_WD;
wire [55:0] psg2_out;
wire [55:0] psg2_in;
wire psg2_set;
reg [45:0] md_out = '0;
wire [45:0] md_in;
wire md_set;
wire md_valid;
reg [127:0] gg_out = '0;
wire [127:0] gg_in;
wire gg_set;
reg [31:0] io_out = '0;
wire [31:0] io_in;
wire io_set;
wire [21:0] video_state_out;
wire [21:0] video_state_in;
wire video_state_set;
wire [28:0] DDRAM_ADDR;
wire [63:0] DDRAM_DIN;
wire [7:0] DDRAM_BE;
wire DDRAM_WE;
reg [63:0] DDRAM_DOUT = '0;
reg DDRAM_DOUT_READY = '0;
wire DDRAM_RD;
wire [7:0] DDRAM_BURSTCNT;
reg DDRAM_BUSY = '0;
savestates dut(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
reg[4:0]clkd=0;reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
assign cpu_ce=ce_pix;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
always@(negedge clk)begin cycle=cycle+1;ce_cpu<=0;ce_pix<=0;ce_vdp<=0;ce_sp<=clkd[0];clkd<=clkd+1;
case(clkd)4:ce_vdp<=1;9:begin ce_cpu<=1;ce_pix<=1;ce_vdp<=1;end 14:ce_vdp<=1;19:begin ce_pix<=1;ce_vdp<=1;end 24:begin ce_cpu<=1;ce_vdp<=1;end 29:begin ce_pix<=1;ce_vdp<=1;clkd<=0;end endcase end
always @(posedge clk) begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];writes<=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=3;readaddr<=DDRAM_ADDR;reads<=reads+1;end
 if(vdp_regs_set)begin seen1<=vdp_regs_in;restored<=1;end
 if(vdp2_regs_set)seen2<=vdp2_regs_in;
end
task tick;begin @(negedge clk);#1;end endtask
task operation(input bit saving);begin
 force dut.op_cooldown=0; // UI cooldown only; all transfer/restore FSM stages run normally
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg joy=0,holdref=0;wire paused,pp,up,rpaused,rpp,rup;wire[8:0]y,rx,ry;wire vb,hb,rvb,rhb;wire[21:0]rvideo;
pause_fixture p(clk,reset_n,systeme,joy,vb,ss_freeze,KEEP!=0,paused,pp,up);
pause_fixture rp(clk,reset_n,systeme,joy,rvb,1'b0,1'b0,rpaused,rpp,rup);
assign vblank=vb;
video video1(.clk(clk),.ce_pix(ce_pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
video videoref(.clk(clk),.ce_pix(ce_pix&&!holdref),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(rvideo),.video_state_in(22'd0),.video_state_set(1'b0),.x(rx),.y(ry),.vcounter_cpu(),.hsync(),.vsync(),.hblank(rhb),.vblank(rvb));
wire[15:0]ca,ra;wire[7:0]co,ro;wire cm1,cmreq,rm1,rmreq,ciq,riq,crd,cwr,rrd,rwr;wire[229:0]rr;wire[1:0]riset;
// A increments once per loop. No forced CPU/bus or pause states.
function[7:0]rom(input[15:0]a);case(a)0:rom=8'h3c;1:rom=8'hc3;2:rom=0;3:rom=0;default:rom=0;endcase endfunction
assign z80_m1_n=cm1;assign z80_mreq_n=cmreq;
T80s #(.T2Write(0)) cpu(.RESET_n(reset_n),.CLK(clk),.CEN((ce_pix&&!ss_freeze&&!paused)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(cm1),.MREQ_n(cmreq),.IORQ_n(ciq),.RD_n(crd),.WR_n(cwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ca),.DI(rom(ca)),.DO(co),.REG(z80_reg),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
T80s #(.T2Write(0)) rcpu(.RESET_n(reset_n),.CLK(clk),.CEN((ce_pix&&!holdref&&!rpaused)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(rm1),.MREQ_n(rmreq),.IORQ_n(riq),.RD_n(rrd),.WR_n(rwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ra),.DI(rom(ra)),.DO(ro),.REG(rr),.DIRSet(1'b0),.DIR(230'd0),.ISet_out(riset));
generate if(FULL)begin:fullvdps
vdp vdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp vdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp2_regs),.ss_regs_in(vdp2_regs_in),.ss_regs_set(vdp2_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
end else begin:lightvdps assign vdp_regs=0;assign vdp2_regs=0;end endgenerate
wire pq1,pq2;wire[3:0]div2;wire signed[10:0]audio1,audio2;reg pwr=1;reg[7:0]pd=0;
assign audio_quiescent=pq1&&pq2;
jt89 psg1(.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&!paused),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(audio1),.soundR(),.ready(),.ss_out(psg_out),.ss_set(psg_set),.ss_in(psg_in),.ss_ext_out(psg_ext_out),.ss_ext_in(psg_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(psg_div_out),.ss_div_in(psg_div_in),.ss_quiescent(pq1));
jt89 psg2(.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&!paused),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(audio2),.soundR(),.ready(),.ss_out(psg2_out),.ss_set(psg2_set),.ss_in(psg2_in),.ss_ext_out(psg2_ext_out),.ss_ext_in(psg2_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(div2),.ss_div_in(psg_div_in),.ss_quiescent(pq2));
wire[95:0]rpsgext;wire[55:0]rpsgcfg;wire[3:0]rpsgdiv;wire signed[10:0]raudio;
jt89 rpsg(.clk(clk),.clk_en(ce_cpu&&!holdref&&!rpaused),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(raudio),.soundR(),.ready(),.ss_out(rpsgcfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(rpsgext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(rpsgdiv),.ss_div_in(4'd0),.ss_quiescent());
integer frame=0,accepts=0,freeze_count=0,release_count=0,start=0,firstdiff=-1,vdpticks=0,psgticks=0;
reg seen=0,released=0;reg[2:0]saved_phase;reg[229:0]atpause;reg[95:0]atpsg;reg[21:0]atvideo;
reg[6:0]oldstate=0;reg transport_started=0,first_ce=0;
always@(negedge clk)begin
 if(dut.state!==oldstate&&(dut.state==37||dut.state==41||dut.state==54||dut.state==1||dut.state==33||dut.state==59||dut.state==56||dut.state==34||dut.state==63))
  $display("FSM cycle%0d state%0d pause%0b/%0b/%0b xy%0d/%0d",cycle,dut.state,paused,pp,up,x,y);
 oldstate=dut.state;
 if(ss_freeze&&!transport_started&&(DDRAM_WE||DDRAM_RD))begin transport_started=1;$display("DDRAM FIRST cycle%0d write%0b read%0b pause%0b/%0b/%0b",cycle,DDRAM_WE,DDRAM_RD,paused,pp,up);end
 if(released&&!first_ce&&ce_pix&&!paused)begin first_ce=1;$display("FIRST RESUMED CPU tick cycle%0d xy%0d/%0d",cycle,x,y);end
end
always@(posedge vb)frame=frame+1;
always@(posedge clk)begin
 if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin accepts=accepts+1;$display("ACCEPT cycle%0d frame%0d xy%0d/%0d pause%0b pending%0b unpending%0b PCbus%h regs%h",cycle,frame,x,y,paused,pp,up,ca,z80_reg);end
 if(!ss_freeze&&ce_vdp)vdpticks=vdpticks+1;
 if(!ss_freeze&&ce_pix)psgticks=psgticks+1;
 if(released&&firstdiff<0&&z80_reg!==rr)begin firstdiff=cycle;$display("CPU DIVERGENCE cycle%0d xy%0d/%0d paused%0b/%0b regs%h/%h",cycle,x,y,paused,rpaused,z80_reg,rr);end
end
always@(posedge ss_freeze)begin
 seen=1;freeze_count=freeze_count+1;start=cycle;holdref=1;
 if(dut.do_save)saved_phase={paused,pp,up};
 $display("FREEZE cycle%0d pause%0b pending%0b unpending%0b",cycle,paused,pp,up);
end
always@(negedge ss_freeze)if(seen)begin
 holdref=0;released=1;release_count=release_count+1;
 $display("RELEASE cycle%0d transport%0d pause%0b pending%0b unpending%0b ref%0b/%0b/%0b",cycle,cycle-start,paused,pp,up,rpaused,rpp,rup);
end
always@(posedge clk)if(z80_set||vdp_regs_set||vdp2_regs_set||audio_ext_set)$display("RESTORE cycle%0d CPU%0b VDP%0b/%0b PSG%0b",cycle,z80_set,vdp_regs_set,vdp2_regs_set,audio_ext_set);
task button;begin joy=1;repeat(3)tick;joy=0;repeat(3)tick;end endtask
task request(input bit saveit);begin force dut.op_cooldown=0;ss_save=saveit;ss_load=!saveit;tick;ss_save=0;ss_load=0;$display("REQUEST cycle%0d saving%0b xy%0d/%0d pause%0b/%0b/%0b M1%0b MREQ%0b",cycle,saveit,x,y,paused,pp,up,cm1,cmreq);end endtask
task finish_operation;begin wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;end endtask
task put(input[7:0]b);begin pd=b;pwr=0;repeat(31)tick;pwr=1;repeat(31)tick;end endtask
integer tries=0,basev,basep;reg want;reg[229:0]saved_cpu;
initial begin
 systeme=1;ss_game_id=32'h12345678;reset_n=0;
 // Different physical reset release phases select naturally different stopped bus phases.
 if(CASE==3||CASE==5||CASE==6||CASE==8||CASE==9)repeat(36)tick;else repeat(6)tick;
 reset_n=1;
 put(8'h8d);put(8'h02);put(8'h91);put(8'he7);put(8'hf3);
 while(!(frame>=1&&vb&&x==200))tick;
 if(CASE==3||CASE==4||CASE==5||CASE==6||CASE==8||CASE==9)begin
  // Find BOTH naturally stopped bus phases, never force CPU/pause state.
  want=(CASE!=4);
  begin:find_phase
   repeat(12)begin
    button;wait(paused);tick;
    $display("PAUSED phase attempt%0d frame%0d xy%0d/%0d M1%0b MREQ%0b ISet%0d",tries,frame,x,y,cm1,cmreq,z80_iset);tries=tries+1;
    if((!cm1&&!cmreq&&z80_iset==0)==want)disable find_phase;
    button;wait(!paused);tick;
    // Physical reset during running VBlank varies instruction phase; no saved state exists yet.
    reset_n=0;repeat(10+10*tries)tick;reset_n=1;repeat(6)tick;
   end
   $fatal(1,"natural requested phase not reached");
  end
  atpause=z80_reg;atpsg=psg_ext_out;atvideo=video_state_out;basev=vdpticks;basep=psgticks;
  repeat(6000)tick;
  if(z80_reg!==atpause||video_state_out===atvideo||psg_ext_out!==atpsg)$fatal(1,"pause CPU/video/PSG behavior wrong");
  $display("PAUSED ACTIVITY CPU/PSG held, video advanced VDPticks%0d rawPIXticks%0d bothVDPstates%h/%h audio%0d/%0d",vdpticks-basev,psgticks-basep,vdp_regs,vdp2_regs,audio1,audio2);
  if(CASE==5)begin button;wait(!paused);tick;end
  if(CASE==9)begin wait(vb);button;end
 end
 if(CASE==1||CASE==7)button;
 if(CASE==2)begin
  request(1);while(!(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256))tick;
  // Input changes on the preceding falling clock, at the last host tick before acceptance.
  joy=1;tick;joy=0;
 end else request(1);
 if(CASE==4)begin
  repeat(1800000)tick;
  if(ss_freeze||accepts!=0||dut.state!=37||!paused)$fatal(1,"non-M1 stalled-pause expectation wrong");
  $display("LIVENESS STALL 1800000 clocks >2 frames state%0d pause%0b M1%0b MREQ%0b; clear cannot run before freeze",dut.state,paused,cm1,cmreq);
  button;finish_operation;
  $display("PASS case4 external unpause recovers stalled request");$finish;
 end
 finish_operation;
 if(CASE==6)button;
 saved_cpu=z80_reg;
 repeat(1000000)tick;
 $display("SAVE ONLY RESULT case%0d keep%0d pause%0b/%0b pending%0b/%0b firstCPUdiff%0d frame%0d busPC%h/%h VDP%h/%h PSG%h/%h",CASE,KEEP,paused,rpaused,pp,rpp,firstdiff,frame,ca,ra,vdp_regs,vdp2_regs,psg_ext_out,psg2_ext_out);
 $display("PSG REFERENCE ext%h ref%h divider%0d/%0d audio%0d/%0d",psg_ext_out,rpsgext,psg_div_out,rpsgdiv,audio1,raudio);
 if(CASE==0&&(z80_reg!==rr||psg_ext_out!==rpsgext))$fatal(1,"running control replay mismatch");
 if((CASE==1||CASE==2||CASE==3)&&KEEP==0&&firstdiff<0)$fatal(1,"expected pause cancellation divergence absent");
 if(CASE==7||CASE==8)begin
  repeat(2)begin request(0);finish_operation;
   $display("LOAD PHASE snapshot%0b actual%0b reference%0b CPU%h",saved_phase,{paused,pp,up},{rpaused,rpp,rup},z80_reg);
   if(saved_phase==0||{paused,pp,up}!==0)$fatal(1,"historical pause loss expectation missing");
   repeat(30000)tick;
  end
  if(freeze_count!=3||release_count!=3)$fatal(1,"repeat load coverage missing");
 end
 // Fresh physical edges must still operate after the transport.
 if(paused)begin button;wait(!paused);tick;end
 button;wait(paused);tick;button;wait(!paused);tick;
 $display("PASS case%0d keep%0d accepts%0d transfers%0d writes%0d reads%0d subsequent toggle works",CASE,KEEP,accepts,release_count,writes,reads);$finish;
end
initial begin #500000000;$fatal(1,"watchdog case%0d frame%0d state%0d pause%0b/%0b/%0b xy%0d/%0d",CASE,frame,dut.state,paused,pp,up,x,y);end
endmodule
