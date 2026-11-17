`timescale 1ns/1ps
module io_order_tb;parameter STALL=0,PAL=0,PORT=0,BORDER=0,REGION=0,ALLOW_EQUAL=0,MODE=0,PX=255,PY=252,SWEEP=0,CAPTURE_X=0;
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
reg [229:0] z80_reg = '0;
wire [229:0] z80_dir;
wire z80_set;
reg z80_m1_n = '0;
reg z80_mreq_n = '0;
reg [1:0] z80_iset = '0;
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
reg [55:0] psg_out = '0;
wire [55:0] psg_in;
wire psg_set;
reg [95:0] psg_ext_out = '0;
reg [95:0] psg2_ext_out = '0;
wire [95:0] psg_ext_in;
wire [95:0] psg2_ext_in;
reg [3:0] psg_div_out = '0;
wire [3:0] psg_div_in;
reg [10:0] audio_control_out = '0;
wire [10:0] audio_control_in;
reg audio_quiescent = '0;
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
wire [45:0] gun_out;
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
reg [135:0] vdp2_regs = '0;
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
reg [55:0] psg2_out = '0;
wire [55:0] psg2_in;
wire psg2_set;
reg [45:0] md_out = '0;
wire [45:0] md_in;
wire md_set;
wire md_valid;
wire [127:0] gg_out;
wire [127:0] gg_in;
wire gg_set;
wire [31:0] io_out;
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
savestates dut(.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
reg[4:0]clkd=0;reg ce_cpu=0,ce_vdp=0,ce_pix=0,ce_sp=0;reg[15:0]lfsr=16'h1ace;
assign cpu_ce=ce_cpu;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
always @(negedge clk)begin cycle=cycle+1;ce_sp<=clkd[0];ce_cpu<=0;ce_vdp<=0;ce_pix<=0;clkd<=clkd+1'b1;
if(clkd==29)begin clkd<=0;ce_vdp<=1;ce_pix<=1;end
else if(clkd==24)begin ce_cpu<=1;ce_vdp<=1;end
else if(clkd==19)begin ce_vdp<=1;ce_pix<=1;end
else if(clkd==14)ce_vdp<=1;
else if(clkd==9)begin ce_cpu<=1;ce_vdp<=1;ce_pix<=1;end
else if(clkd==4)ce_vdp<=1;
lfsr<={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};
DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?lfsr[3:0]<12:STALL==3?cycle%2048<2020:0);
end
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
 tick;
 force dut.op_cooldown=0; // UI cooldown only; all transfer/restore FSM stages run normally
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg holdref=0,iorst=0,wr=1,rd=1;reg[7:0]addr=8'h3f,data=8'hff;reg[7:0]jx=8'h7f,jy=8'h7c;reg[24:0]mouse=0;reg mousexy=0;
wire[8:0]y,rx,ry;wire hb,vb,rhb,rvb;wire[21:0]refvideo;wire sensor,refsensor,target,reftarget,trigger,reftrigger,hl,refhl;
wire[7:0]guest,refguest,hval,refhval;wire nmi,refnmi;reg th1,th2,rth1,rth2;
always@(posedge clk)begin th1<=PORT?1'b1:!sensor;th2<=PORT?!sensor:1'b1;rth1<=PORT?1'b1:!refsensor;rth2<=PORT?!refsensor:1'b1;end
assign vblank=vb;
video live_video(.clk(clk),.ce_pix(ce_pix),.pal(PAL[0]),.border(BORDER[0]),.ggres(1'd0),.mask_column(1'd0),.cut_mask(1'd0),.smode_M1((MODE==1)),.smode_M2((MODE!=0)),.smode_M3((MODE==2)),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
gun_fixture live_gun(.CLK(clk),.SS_FREEZE(ss_freeze),.SS_STATE_IN(gun_in),.SS_STATE_SET(gun_set),.SS_STATE_VALID(gun_valid),.SS_STATE_OUT(gun_out),.hold(1'b0),.RESET(!reset_n),.MOUSE(mouse),.MOUSE_XY(mousexy),.JOY_X(jx),.JOY_Y(jy),.JOY(12'd0),.HDE(!hb),.VDE(!vb),.CE_PIX(ce_pix&&!ss_freeze),.BTN_MODE(1'b0),.SIZE(2'd0),.SENSOR_DELAY(8'd34),.TARGET(target),.SENSOR(sensor),.TRIGGER(trigger));
io live_io(.clk(clk),.ce_cpu(ce_cpu),.WR_n(wr),.RD_n(rd),.A(addr),.D_in(data),.D_out(guest),.HL_out(hl),.vdp1_bank(),.vdp2_bank(),.vdp_cpu_bank(),.rom_bank(),.J1_tr_out(),.J1_th_out(),.J2_tr_out(),.J2_th_out(),.J1_up(1'd0),.J1_down(1'd0),.J1_left(1'd0),.J1_right(1'd0),.J1_tl((PORT?1'b1:!trigger)),.J1_tr(1'd0),.J1_th(th1),.j1_start(1'd0),.j1_coin(1'd0),.j1_a3(1'd0),.J2_up(1'd0),.J2_down(1'd0),.J2_left(1'd0),.J2_right(1'd0),.J2_tl((PORT?!trigger:1'b1)),.J2_tr(1'd0),.J2_th(th2),.j2_start(1'd0),.j2_coin(1'd0),.j2_a3(1'd0),.Pause(1'd0),.soft_reset(1'd0),.E0Type(2'd0),.E1Use(1'd0),.E2Use(1'd0),.E0(8'd0),.F2(8'd0),.F3(8'd0),.has_paddle(1'd0),.has_pedal(1'd0),.paddle(8'd0),.paddle2(8'd0),.pedal(8'd0),.palettemode(1'd0),.sc3000_en(1'd0),.sc_multicart_en(1'd0),.sc_megacart_en(1'd0),.sk1100_en(1'd0),.sc_multicart_page(),.sk1100_row_sel(),.sk1100_row_data(12'd0),.pal(PAL[0]),.gg(1'd0),.gg_link_en(1'd0),.gg_link_in(7'd0),.gg_link_out(),.gg_link_nmi_n(nmi),.systeme(1'd0),.region(REGION[0]),.se_mapper_in(8'd0),.se_mapper_set(1'd0),.vdp_enables(2'd0),.psg_enables(2'd0),.gg_state_out(gg_out),.gg_state_in(gg_in),.gg_state_set(gg_set),.io_state_out(io_out),.io_state_in(io_in),.io_state_set(io_set),.mapper_evolution_force(1'd0),.evolution_menu_io(1'd0),.evolution_bank61(8'd0),.evolution_bank62(8'd0),.evolution_reg8c(8'd0),.evolution_regcd(8'd0),.evolution_reg63(8'd0),.evolution_reg88(8'd0),.evolution_reg8d(8'd0),.evolution_reg8e(8'd0),.evolution_reg8f(8'd0),.ss_freeze(ss_freeze),.RESET_n(iorst));
video reference_video(.clk(clk),.ce_pix((ce_pix&&!holdref)),.pal(PAL[0]),.border(BORDER[0]),.ggres(1'd0),.mask_column(1'd0),.cut_mask(1'd0),.smode_M1((MODE==1)),.smode_M2((MODE!=0)),.smode_M3((MODE==2)),.smode_M4(1'b1),.video_state_out(refvideo),.video_state_in(video_state_in),.video_state_set(1'b0),.x(rx),.y(ry),.vcounter_cpu(),.hsync(),.vsync(),.hblank(rhb),.vblank(rvb));
gun_fixture reference_gun(.CLK(clk),.SS_FREEZE(holdref),.SS_STATE_IN(gun_in),.SS_STATE_SET(1'b0),.SS_STATE_VALID(gun_valid),.SS_STATE_OUT(),.hold(holdref),.RESET(!reset_n),.MOUSE(mouse),.MOUSE_XY(mousexy),.JOY_X(jx),.JOY_Y(jy),.JOY(12'd0),.HDE(!rhb),.VDE(!rvb),.CE_PIX(ce_pix&&!holdref),.BTN_MODE(1'b0),.SIZE(2'd0),.SENSOR_DELAY(8'd34),.TARGET(reftarget),.SENSOR(refsensor),.TRIGGER(reftrigger));
io reference_io(.clk(clk),.ce_cpu(ce_cpu),.WR_n(wr),.RD_n(rd),.A(addr),.D_in(data),.D_out(refguest),.HL_out(refhl),.vdp1_bank(),.vdp2_bank(),.vdp_cpu_bank(),.rom_bank(),.J1_tr_out(),.J1_th_out(),.J2_tr_out(),.J2_th_out(),.J1_up(1'd0),.J1_down(1'd0),.J1_left(1'd0),.J1_right(1'd0),.J1_tl((PORT?1'b1:!reftrigger)),.J1_tr(1'd0),.J1_th(rth1),.j1_start(1'd0),.j1_coin(1'd0),.j1_a3(1'd0),.J2_up(1'd0),.J2_down(1'd0),.J2_left(1'd0),.J2_right(1'd0),.J2_tl((PORT?!reftrigger:1'b1)),.J2_tr(1'd0),.J2_th(rth2),.j2_start(1'd0),.j2_coin(1'd0),.j2_a3(1'd0),.Pause(1'd0),.soft_reset(1'd0),.E0Type(2'd0),.E1Use(1'd0),.E2Use(1'd0),.E0(8'd0),.F2(8'd0),.F3(8'd0),.has_paddle(1'd0),.has_pedal(1'd0),.paddle(8'd0),.paddle2(8'd0),.pedal(8'd0),.palettemode(1'd0),.sc3000_en(1'd0),.sc_multicart_en(1'd0),.sc_megacart_en(1'd0),.sk1100_en(1'd0),.sc_multicart_page(),.sk1100_row_sel(),.sk1100_row_data(12'd0),.pal(PAL[0]),.gg(1'd0),.gg_link_en(1'd0),.gg_link_in(7'd0),.gg_link_out(),.gg_link_nmi_n(refnmi),.systeme(1'd0),.region(REGION[0]),.se_mapper_in(8'd0),.se_mapper_set(1'd0),.vdp_enables(2'd0),.psg_enables(2'd0),.gg_state_out(),.gg_state_in(gg_in),.gg_state_set(1'b0),.io_state_out(),.io_state_in(io_in),.io_state_set(1'b0),.mapper_evolution_force(1'd0),.evolution_menu_io(1'd0),.evolution_bank61(8'd0),.evolution_bank62(8'd0),.evolution_reg8c(8'd0),.evolution_regcd(8'd0),.evolution_reg63(8'd0),.evolution_reg88(8'd0),.evolution_reg8d(8'd0),.evolution_reg8e(8'd0),.evolution_reg8f(8'd0),.ss_freeze(holdref),.RESET_n(iorst));
reg oldhl=0,refoldhl=0;reg[7:0]latched,ref_latched;
assign vdp_regs={latched,128'd0};assign hval=latched;assign refhval=ref_latched;
always @(posedge clk)begin
if(!reset_n)begin oldhl<=0;refoldhl<=0;end else begin
if(vdp_regs_set)begin latched<=vdp_regs_in[135:128];oldhl<=hl;end
oldhl<=hl;if(!vdp_regs_set&&!oldhl&&hl)latched<=x[8:1];
if(!holdref)begin refoldhl<=refhl;if(!refoldhl&&refhl)ref_latched<=rx[8:1];end
end end
integer guard_checks=0,legitimate_rises=0;reg restored_latch=0,previous_sensor=0,seen_freeze=0;reg[7:0]freeze_h;
integer frame=0,accepted=0,start,savecycles,loadcycles,firstdiff=-1;reg[7:0]saved_h;reg saved_sensor;reg[21:0]saved_video;reg[8:0]saved_local_h,saved_local_v;reg[7:0]saved_time;
always @(posedge vb)if(!ss_freeze)begin frame=frame+1;$display("FRAME %0d xy%0d/%0d target%0d/%0d vtotal%0d sensor%b",frame,x,y,live_gun.x,live_gun.y,live_gun.vtotal,sensor);end
always @(posedge ss_freeze)begin #1;holdref=1;start=cycle;end
always @(negedge ss_freeze)begin if(dut.do_save)savecycles=cycle-start;else begin loadcycles=cycle-start;holdref=0;end end
always @(posedge clk)if(dut.state==37&&!storage_busy&&cpu_ce&&!z80_m1_n&&!z80_mreq_n&&z80_iset==0&&vb&&x<256)begin
accepted=accepted+1;$display("ACCEPT %0d xy=%0d/%0d sensor=%b localHV=%0d/%0d time=%0d pend=%b clkd=%0d",accepted,x,y,sensor,live_gun.hcnt,live_gun.vcnt,live_gun.sensor_time,live_gun.sensor_pend,clkd);end
task read_port;begin addr=8'hdd;rd=1;wait(ce_cpu);tick;rd=0;wait(ce_cpu);tick;rd=1;end endtask
initial begin
reset_n=0;repeat(4)tick;reset_n=1;iorst=1;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;
// Real IO configuration enables input TH/HL detection on both ports.
wr=0;data=8'hff;repeat(30)tick;wr=1;
wait(frame>=3);if(SWEEP)begin jx=PX^128;jy=PY^128;wait(frame>=4);end if(CAPTURE_X)wait(vb&&x>=CAPTURE_X&&x<256);else wait(vb&&y==(BORDER?(PAL?240:216):(MODE==1?224:MODE==2?240:192))&&x>=489);
operation(1);saved_video=mem['h1a][21:0];saved_h=mem['h1a][29:22];saved_sensor=refsensor;saved_local_h=reference_gun.hcnt;saved_local_v=reference_gun.vcnt;saved_time=reference_gun.sensor_time;
$display("SAVED video=%h H=%h sensor=%b localHV=%0d/%0d time=%0d saveClocks=%0d",saved_video,saved_h,saved_sensor,saved_local_h,saved_local_v,saved_time,savecycles);
if(!SWEEP&&!CAPTURE_X&&!saved_sensor)$fatal(1,"sensitive reachable save phase missed");
addr=8'h3f;data=0;wr=0;repeat(30)tick;wr=1;repeat(30)tick;if(io_out[7:0]!==0)$fatal(1,"discarded IO control write missed");
// Let discarded execution reach a later quiet VBlank. No host input changes.
wait(!vb);wait(vb);wait(x>100&&x<200&&y>(BORDER?(PAL?240:216):(MODE==1?224:MODE==2?240:192))+2);repeat(20)tick;
if(sensor!==0)$fatal(1,"discarded sensor did not clear naturally");
fork
operation(0);
begin wait(ss_freeze);wait(!ss_freeze);#1;
if(gun_out!==reference_gun.SS_STATE_OUT)$fatal(1,"gun state not restored exactly");
if(video_state_out!==refvideo)$fatal(1,"beam release alignment failure %h/%h",video_state_out,refvideo);
if(hval!==saved_h)$fatal(1,"F07 latch did not restore before observation %h/%h",hval,saved_h);
$display("RELEASE beam=%h/%h sensor=%b/%b TH=%b/%b H=%h/%h localHV=%0d/%0d refHV=%0d/%0d time=%0d/%0d loadClocks=%0d",video_state_out,refvideo,sensor,refsensor,!sensor,!refsensor,hval,refhval,live_gun.hcnt,live_gun.vcnt,reference_gun.hcnt,reference_gun.vcnt,live_gun.sensor_time,reference_gun.sensor_time,loadcycles);
end
join
read_port;
$display("GUEST portDD DUT=%h reference=%h sensor=%b/%b HL=%b/%b H=%h/%h NMI=%b/%b",guest,refguest,sensor,refsensor,hl,refhl,hval,refhval,nmi,refnmi);
if(guest!==refguest)$fatal(1,"accepted-boundary guest divergence persists");
if(nmi!==refnmi)$fatal(1,"unexpected NMI dependency");
if(guest===refguest)$display("PASS F11 accepted-boundary equivalence stalls=%0d PAL=%0d PORT=%0d BORDER=%0d accepted=%0d saveClocks=%0d loadClocks=%0d",STALL,PAL,PORT,BORDER,accepted,savecycles,loadcycles);
else $display("PASS F11 negative sample: released sensor mismatch converged before tested port read; no exclusion claimed");
repeat(1300000)begin tick;if(!vb&&!hb&&{live_gun.hcnt,live_gun.x,live_gun.y,live_gun.old_vde}!=={reference_gun.hcnt,reference_gun.x,reference_gun.y,reference_gun.old_vde})$fatal(1,"omitted fields not converged before active hit window");if(sensor!==refsensor||hl!==refhl||hval!==refhval||nmi!==refnmi)$fatal(1,"future event divergence xy%0d/%0d S%b/%b H%h/%h",x,y,sensor,refsensor,hval,refhval);end
if(guard_checks<900000||legitimate_rises==0)$fatal(1,"HCounter guard/event coverage missed");
$display("PASS F11 HCounter held after restore checks%0d legitimate rises%0d",guard_checks,legitimate_rises);
$display("PASS F11 future frame and first legitimate event equivalence");$finish;
end
initial begin #(64'd250000000);$fatal(1,"watchdog xy%0d/%0d state%0d frame%0d sensor%b",x,y,dut.state,frame,sensor);end

always@(posedge ss_freeze)begin #1;restored_latch=0;seen_freeze=1;freeze_h=hval;end
always@(posedge clk)begin
 previous_sensor<=sensor;
 if(vdp_regs_set)begin #1;restored_latch=1;end
 if(!ss_freeze&&restored_latch&&!previous_sensor&&sensor)legitimate_rises=legitimate_rises+1;
end
always@(negedge clk)begin
 if(ss_freeze&&seen_freeze&&dut.do_save&&hval!==freeze_h)$fatal(1,"save transport changed HCounter latch");
 // Applying gun/TH state early can settle HL before F07 installs the saved latch.
 // Once F07 has installed it, transport must never overwrite that latch.
 if(ss_freeze&&restored_latch&&!vdp_regs_set)begin
  guard_checks=guard_checks+1;
  if(hval!==saved_h||sensor!==saved_sensor)$fatal(1,"false event after F07 restore");
 end
end
endmodule
