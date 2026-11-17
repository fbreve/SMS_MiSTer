`timescale 1ns/1ps
module pause_tb;wire[135:0]refvdp_regs,refvdp2_regs;parameter SAVED_PAUSED=1,CURRENT_PAUSED=0,TAIL_DELAY=0,TAC=1,REQUEST_DELAY=0,WAIT_WINDOW=0,HIST=0,CACHEHISTORY=0,TRANSFER=0,PATTERN=0,BANKS=0,ROMBANK=1,DIVSEEK=-1,PAT=0,ROUTE=0,DUAL=0,BUS=0,HISTORY=0,BOOT=6,PAUSE=0,SEEK=0,REPLAYS=3,LATENCY=3,TARGET=0,REF=0,SEED=0,N=24000,CASE=0,KEEP=0,FULL=0,STALL=0,OFFSET=0,DELAY=6;
reg load_started=0;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
wire ss_freeze;wire cpu_prepare,replay,replay_t2,phase_set,actual_tick;wire[1:0]phase_in;reg phase_ready=0;reg[4:0]clkd=0;wire ss_capture_progress;
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
wire [10:0] audio_control_out;
reg[7:0]mux_control=8'hff,rmux=8'hff;assign audio_control_out={3'b111,mux_control};
wire [10:0] audio_control_in;
wire audio_quiescent;
wire audio_phase_out;
wire audio_phase_in;
wire audio_ext_set;
wire audio_phase_set;
wire [63:0] mapper_out;
wire [63:0] mapper_in;
wire mapper_set;
reg [159:0] evolution_out = '0;
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
wire [7:0] wram_D;
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
wire[2:0]restart_out;
wire audio_pending_tick;
savestates dut(.audio_pending_tick(audio_pending_tick),.bg_out(139'd0),.bg2_out(139'd0),.bg_in(),.bg2_in(),.bg_valid(),.ss_cpu_prepare(cpu_prepare),.z80_replay(replay),.z80_tick_active(actual_tick),.z80_replay_t2(replay_t2),
 .clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),.clock_phase_in(phase_in),.clock_phase_set(phase_set),.clock_phase_ready(phase_ready),
 .sprite_out(4778'd0),.sprite2_out(4778'd0),.sprite_in(),.sprite2_in(),.sprite_valid(),.z80_restart(restart_out),.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(ss_capture_progress),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #10 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
assign cpu_ce=(DUAL==3||DUAL==5)?ce_cpu:ce_pix;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
always@(negedge clk)begin cycle=cycle+1;phase_ready<=phase_set;
if(phase_set)begin case(phase_in)0:clkd<=0;1:clkd<=10;2:clkd<=20;3:clkd<=25;endcase
ce_cpu<=0;ce_pix<=0;ce_vdp<=0;ce_sp<=0;end else begin ce_cpu<=0;ce_pix<=0;ce_vdp<=0;ce_sp<=clkd[0];clkd<=clkd+1;
case(clkd)4:ce_vdp<=1;9:begin ce_cpu<=1;ce_pix<=1;ce_vdp<=1;end 14:ce_vdp<=1;19:begin ce_pix<=1;ce_vdp<=1;end 24:begin ce_cpu<=1;ce_vdp<=1;end 29:begin ce_pix<=1;ce_vdp<=1;clkd<=0;end endcase end end
always @(posedge clk) begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];writes<=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=LATENCY+((DDRAM_ADDR-29'h07c00000)==29'h2900 ? TAIL_DELAY : 0);readaddr<=DDRAM_ADDR;reads<=reads+1;end
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
reg[4:0]rclkd=0;reg rce_cpu=0,rce_pix=0;
always@(negedge clk)begin rce_cpu<=0;rce_pix<=0;rclkd<=rclkd==29?0:rclkd+1;
if(rclkd==9||rclkd==24)rce_cpu<=1;if(rclkd==9||rclkd==19||rclkd==29)rce_pix<=1;end
pause_fixture p(clk,reset_n,systeme,joy,vb,ss_freeze,KEEP!=0,paused,pp,up);
pause_fixture rp(clk,reset_n,systeme,joy,rvb,1'b0,1'b0,rpaused,rpp,rup);
assign vblank=vb;
video video1(.clk(clk),.ce_pix(ce_pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
video videoref(.clk(clk),.ce_pix(rce_pix&&!holdref),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(rvideo),.video_state_in(22'd0),.video_state_set(1'b0),.x(rx),.y(ry),.vcounter_cpu(),.hsync(),.vsync(),.hblank(rhb),.vblank(rvb));
wire[15:0]ca,ra;wire[7:0]co,ro;wire cm1,cmreq,rm1,rmreq,ciq,riq,crd,cwr,rrd,rwr;wire[229:0]rr;wire[1:0]riset;reg ref_request=0;
wire ref_progress=systeme&&ref_request&&!holdref&&!storage_busy&&rvb&&rx<256&&(rm1||rmreq||riset!=0);
always@(posedge clk)begin
 if(!reset_n)ref_request<=0;
 else if(ss_save||ss_load)ref_request<=1;
 else if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&!storage_busy)ref_request<=0;
end
reg[15:0]stall_rng=16'h1ace;
always@(negedge clk)begin #0.001;
 stall_rng={stall_rng[14:0],stall_rng[15]^stall_rng[13]^stall_rng[12]^stall_rng[10]};
 DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?stall_rng[3:0]<12:STALL==3?cycle%2048<2020:0);
end

// A increments once per loop. No forced CPU/bus or pause states.
reg[7:0]pause_rom[0:65535];initial $readmemh("rom.hex",pause_rom);function[7:0]rom(input[15:0]a);rom=pause_rom[a];endfunction
assign actual_tick=!paused||ss_capture_progress;
assign z80_m1_n=cm1;assign z80_mreq_n=cmreq;
wire[7:0]db0,db1,db2,db3,rb0,rb1,rb2,rb3;
assign mapper_out=(64'd1<<54)|{32'd0,db3,db2,db1,(systeme?{BANKS[1:0],2'b0,ROMBANK[3:0]}:db0)};
mapper_ctrl live_mapper(.RESET_n(reset_n),.clk_sys(clk),.evolution_game_launch(1'b0),.mapper_set(mapper_set),.mapper_evolution(1'b0),.mapper_in(mapper_in),.mapper_janggun(1'b0),.systeme(systeme),.bootloader_n(1'b1),.mapper_wonderkid(1'b0),.mapper_lock(1'b0),.detect_codies_static(1'b0),.mapper_codies_force(1'b0),.mapper_eeprom(1'b0),.mapper_zemina_force(1'b0),.mapper_nemesis_auto(1'b0),.rom_size_pages(8'hff),.ce_z80((cpu_ce&&!ss_freeze)),.WR_n(cwr),.MREQ_n(cmreq),.A(ca),.ss_freeze(ss_freeze),.D_in(co),.sc3000_en(1'b0),.mapper_castle(1'b0),.mapper_linear(1'b0),.mapper_dahjee_a(1'b0),.mapper_sega_locked(1'b0),.use_zem(1'b0),.mapper_manual_force(1'b1),.sega_mapper_write_seen(1'b1),.bank0_out(db0),.bank1_out(db1),.bank2_out(db2),.bank3_out(db3),.jang_bank1_out(),.jang_bank2_out(),.jang_bank3_out(),.jang_bank4_out(),.jang_rev1_out(),.jang_rev2_out(),.jang_rev3_out(),.jang_rev4_out(),.nvram_e_out(),.nvram_ex_out(),.nvram_p_out(),.nvram_cme_out(),.lock_mapper_B_out(),.mapper_codies_out(),.mapper_codies_lock_out(),.mapper_4pak_out(),.pak4_reg2_out(),.nem_bank0_out(),.eeprom_soft_reset_out());
mapper_ctrl ref_mapper(.RESET_n(reset_n),.clk_sys(clk),.evolution_game_launch(1'b0),.mapper_set(mapper_set),.mapper_evolution(1'b0),.mapper_in(mapper_in),.mapper_janggun(1'b0),.systeme(systeme),.bootloader_n(1'b1),.mapper_wonderkid(1'b0),.mapper_lock(1'b0),.detect_codies_static(1'b0),.mapper_codies_force(1'b0),.mapper_eeprom(1'b0),.mapper_zemina_force(1'b0),.mapper_nemesis_auto(1'b0),.rom_size_pages(8'hff),.ce_z80(cpu_ce&&!ss_freeze),.WR_n(rwr),.MREQ_n(rmreq),.A(ra),.ss_freeze(ss_freeze),.D_in(ro),.sc3000_en(1'b0),.mapper_castle(1'b0),.mapper_linear(1'b0),.mapper_dahjee_a(1'b0),.mapper_sega_locked(1'b0),.use_zem(1'b0),.mapper_manual_force(1'b1),.sega_mapper_write_seen(1'b1),.bank0_out(rb0),.bank1_out(rb1),.bank2_out(rb2),.bank3_out(rb3),.jang_bank1_out(),.jang_bank2_out(),.jang_bank3_out(),.jang_bank4_out(),.jang_rev1_out(),.jang_rev2_out(),.jang_rev3_out(),.jang_rev4_out(),.nvram_e_out(),.nvram_ex_out(),.nvram_p_out(),.nvram_cme_out(),.lock_mapper_B_out(),.mapper_codies_out(),.mapper_codies_lock_out(),.mapper_4pak_out(),.pak4_reg2_out(),.nem_bank0_out(),.eeprom_soft_reset_out());
wire[7:0]sd,rsd,cdi,rdi;wire rd,rrd_mem;wire[21:0]mapped,rmapped;wire[24:0]phys={3'd0,mapped},rphys={3'd0,rmapped};
memory_decode decoder(.gg(1'b0),.mapper_evolution(1'b0),.gg_bios_en(1'b0),.bios_en(1'b0),.ext_bios_sel(1'b0),.ext_bios_loaded(1'b0),.dbr(1'b1),.bootloader_n(1'b1),.ext_gg_bios_loaded(1'b0),.mapper_dahjee_a(1'b0),.use_zem(1'b0),.mapper_4pak(1'b0),.mapper_codies(1'b0),.systeme(systeme),.sc3000_en(1'b0),.sc_multicart_en(1'b0),.mapper_linear(1'b0),.mapper_janggun(1'b0),.A(ca),.media_control(3'b0),.bank0(8'd0),.bank1(db1),.bank2(db2),.bank3(8'd3),.nem_bank0(8'd0),.rom_bank(ROMBANK[3:0]),.sc_multicart_page(7'd0),.jang_bank1(6'd0),.jang_bank2(6'd0),.jang_bank3(6'd0),.jang_bank4(6'd0),.cart_precedence_out(),.cart_memory_selected_out(),.dahjee_cart_access_out(),.rom_a_i_out(mapped));
memory_decode rdecoder(.gg(1'b0),.mapper_evolution(1'b0),.gg_bios_en(1'b0),.bios_en(1'b0),.ext_bios_sel(1'b0),.ext_bios_loaded(1'b0),.dbr(1'b1),.bootloader_n(1'b1),.ext_gg_bios_loaded(1'b0),.mapper_dahjee_a(1'b0),.use_zem(1'b0),.mapper_4pak(1'b0),.mapper_codies(1'b0),.systeme(systeme),.sc3000_en(1'b0),.sc_multicart_en(1'b0),.mapper_linear(1'b0),.mapper_janggun(1'b0),.A(ra),.media_control(3'b0),.bank0(8'd0),.bank1(rb1),.bank2(rb2),.bank3(8'd3),.nem_bank0(8'd0),.rom_bank(ROMBANK[3:0]),.sc_multicart_page(7'd0),.jang_bank1(6'd0),.jang_bank2(6'd0),.jang_bank3(6'd0),.jang_bank4(6'd0),.cart_precedence_out(),.cart_memory_selected_out(),.dahjee_cart_access_out(),.rom_a_i_out(rmapped));
tri[15:0]dq,rdq;wire[12:0]sa,rsa;wire[1:0]sb,rsb;wire sc,sras,scas,swe,rsc,rras,rcas,rswe;wire ready,rready;
sdram live(.SDRAM_DQ(dq),.SDRAM_A(sa),.SDRAM_BA(sb),.SDRAM_nCS(sc),.SDRAM_nRAS(sras),.SDRAM_nCAS(scas),.SDRAM_nWE(swe),.init(1'b0),.clk(clk),.clkref(cpu_ce),.raddr(phys),.rd(rd),.rd_rdy(ready),.dout(sd),.waddr(25'd0),.din(8'd0),.we(1'b0),.we_ack());
sdram reference_live(.SDRAM_DQ(rdq),.SDRAM_A(rsa),.SDRAM_BA(rsb),.SDRAM_nCS(rsc),.SDRAM_nRAS(rras),.SDRAM_nCAS(rcas),.SDRAM_nWE(rswe),.init(1'b0),.clk(clk),.clkref((DUAL==3||DUAL==5)?rce_cpu:rce_pix),.raddr(rphys),.rd(rrd_mem),.rd_rdy(rready),.dout(rsd),.waddr(25'd0),.din(8'd0),.we(1'b0),.we_ack());
pin_model #(.TAC(TAC),.SYSTEME(DUAL<3),.CACHEHISTORY(CACHEHISTORY)) chip(clk,sa,sb,sc,sras,scas,swe,dq),rchip(clk,rsa,rsb,rsc,rras,rcas,rswe,rdq);
wire rw,nw,rrw,rnw;reg[7:0]ram_bytes[0:16383],ref_bytes[0:16383];reg[7:0]ram_q=0,ref_q=0;
initial begin
for(integer b=0;b<16384;b++)begin ram_bytes[b]=(b*73)^(b>>5)^8'hd9;ref_bytes[b]=ram_bytes[b];end
if(CACHEHISTORY)begin
 // IN A,(7c); ADD A,40; LD H,A; LD L,fd; LD A,(HL).
 // Erase the distinct input/read history, then execute a fixed RAM-only loop.
 ram_bytes[0]=8'hdb;ram_bytes[1]=8'h7c;ram_bytes[2]=8'hc6;ram_bytes[3]=8'h40;ram_bytes[4]=8'h67;ram_bytes[5]=8'h2e;ram_bytes[6]=8'hfd;ram_bytes[7]=8'h7e;
 ram_bytes[8]=8'haf;ram_bytes[9]=8'h01;ram_bytes[10]=0;ram_bytes[11]=0;ram_bytes[12]=8'h11;ram_bytes[13]=0;ram_bytes[14]=0;ram_bytes[15]=8'h21;ram_bytes[16]=0;ram_bytes[17]=0;
 ram_bytes[18]=8'hc3;ram_bytes[19]=8'h20;ram_bytes[20]=8'hc0;
 ram_bytes[32]=8'h00;ram_bytes[33]=8'hc3;ram_bytes[34]=8'h20;ram_bytes[35]=8'hc0;
 for(integer b=0;b<16384;b++)ref_bytes[b]=ram_bytes[b];
end
end
wire[13:0]ram_address=systeme?ca[13:0]:{1'b0,ca[12:0]},ref_address=systeme?ra[13:0]:{1'b0,ra[12:0]};
always@(posedge clk)begin
 if(!load_started&&reset_n&&!ss_freeze&&cpu_ce&&!crd&&!cmreq&&ca<16'hc000&&sd!==chip.byte_at(phys))$fatal(1,"ordinary SDRAM timing/model error cycle%0d A%h actual%h expected%h q%0d a%h rd%b ready%b",cycle,ca,sd,chip.byte_at(phys),live.q,live.a,rd,ready);
 ram_q<=ram_bytes[(ss_freeze&&!cpu_prepare)?(wram_WE?wram_WA:wram_A):ram_address];
 if(ss_freeze?wram_WE:rw)ram_bytes[ss_freeze?wram_WA:ram_address]<=ss_freeze?wram_WD:co;
 ref_q<=ref_bytes[ref_address];if(!ss_freeze&&rrw)ref_bytes[ref_address]<=ro;if(wram_WE)ref_bytes[wram_WA]<=wram_WD;
end
assign wram_D=ram_q;
memory_bus bus(.A(ca),.sc3000_en(1'b0),.sc_cart_ram(2'b0),.mapper_castle(1'b0),.sc_multicart_en(1'b0),.WR_n(cwr),.RD_n(crd),.MREQ_n(cmreq),.ss_freeze(ss_freeze),.mapper_eeprom(1'b0),.nvram_e(1'b0),.nvram_ex(1'b0),.nvram_cme(1'b0),.dahjee_cart_access(1'b0),.eeprom_bus_active(1'b0),.eeprom_D_out(8'd0),.nvram_D_out(8'd0),.ram_D_out(ram_q),.irom_D_out(sd),.ram_WR(rw),.nvram_WR(nw),.rom_RD(rd),.memory_D_out(cdi));
memory_bus rbus(.A(ra),.sc3000_en(1'b0),.sc_cart_ram(2'b0),.mapper_castle(1'b0),.sc_multicart_en(1'b0),.WR_n(rwr),.RD_n(rrd),.MREQ_n(rmreq),.ss_freeze(1'b0),.mapper_eeprom(1'b0),.nvram_e(1'b0),.nvram_ex(1'b0),.nvram_cme(1'b0),.dahjee_cart_access(1'b0),.eeprom_bus_active(1'b0),.eeprom_D_out(8'd0),.nvram_D_out(8'd0),.ram_D_out(ref_q),.irom_D_out(rchip.byte_at(rphys)),.ram_WR(rrw),.nvram_WR(rnw),.rom_RD(rrd_mem),.memory_D_out(rdi));
wire[47:0]signature={ram_bytes[256],ram_bytes[257],ram_bytes[258],ram_bytes[259],ram_bytes[260],ram_bytes[261]},ref_signature={ref_bytes[256],ref_bytes[257],ref_bytes[258],ref_bytes[259],ref_bytes[260],ref_bytes[261]};
wire[250:0]cpu_actual={z80_reg,ca,cm1,cmreq,ciq,crd,cwr},cpu_ref={rr,ra,rm1,rmreq,riq,rrd,rwr};
reg[250:0]cpu_oracle[0:N-1];reg[47:0]sig_oracle[0:N-1];
integer consumed=0,refconsumed=0;reg[7:0]seen_q=0;integer edge_left=0;
integer dram_accepts=0,returns=0,refresh_count=0;reg flight=0;reg[24:0]flight_addr;reg[15:0]phase_seen=0;
always@(posedge clk)begin
 if(live.mode==0&&live.q==0&&!live.access_manager.old_rd&&rd)begin
  if(flight)$fatal(1,"overlap accepted transaction");flight=1;flight_addr=phys;dram_accepts++;
 end
 if(live.mode==0&&live.q==6&&live.ram_req&&!live.wr)begin
  if(!flight)$fatal(1,"duplicate/unowned return");flight=0;returns++;
  #1;if(sd!==chip.byte_at(flight_addr))$fatal(1,"wrong returned transaction address/data");
 end
end
always@(posedge ss_freeze)begin
 phase_seen[live.q]=1;
 $display("G12_ACCEPT q%0d flight%b ready%b accepted%0d returned%0d phyReads%0d A%h retainedAddr%h retainedData%h",live.q,flight,ready,dram_accepts,returns,chip.reads,phys,live.a,live.sd_dat);
end
final $display("G12_LEDGER accepted%0d returned%0d physical%0d flight%b refresh%0d captures%h",dram_accepts,returns,chip.reads,flight,chip.refreshes,phase_seen);
always@(posedge clk)begin
 if(reset_n&&!ss_freeze&&cpu_ce&&!crd&&!cmreq)consumed++;
 if(reset_n&&((DUAL==3||DUAL==5)?rce_cpu:rce_pix)&&!rrd&&!rmreq)refconsumed++;
 if(reset_n&&dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&!storage_busy)edge_left=12;
 if(edge_left>0)begin $display("G12_EDGE cycle%0d state%0d freeze%b prep%b cpu%h addr%h rd%b q%0d pending%b wr%b ready%b data%h DDR%0b%0b%0b",cycle,dut.state,ss_freeze,cpu_prepare,z80_reg,phys,rd,live.q,live.ram_req,live.wr,ready,sd,DDRAM_BUSY,DDRAM_RD,DDRAM_WE);edge_left--;end
 if(cpu_prepare&&cpu_ce)$display("G12_PREP cycle%0d A%h rd%b q%0d ready%b data%h",cycle,ca,rd,live.q,ready,sd);
end

reg[7:0]v1[0:32767],v2[0:32767],saved_ram[0:16383],saved_v1[0:32767],saved_v2[0:32767];
integer wram_restore_count=0,v1_restore_count=0,v2_restore_count=0;integer wc[0:16383],vc1[0:32767],vc2[0:32767];
function[7:0]pattern(input integer addr,input integer owner);reg[31:0]h;begin
 h=(addr+owner*32'h9e3779b9+PATTERN*32'h5d713f49)*32'h45d9f3b;h=(h^(h>>16))*32'h45d9f3b;pattern=h^(h>>8)^(h>>16)^(h>>24);
end endfunction
initial begin
 for(integer n=0;n<32768;n++)begin v1[n]=pattern(n,1);v2[n]=pattern(n,2);vc1[n]=0;vc2[n]=0;end
 for(integer n=0;n<16384;n++)wc[n]=0;
end
always@(posedge clk)begin
 vram_D<=v1[vram_A];vram2_D<=v2[vram2_A];
 if(vram_WE)begin v1[vram_WA]<=vram_WD;vc1[vram_WA]++;v1_restore_count++;end
 if(vram2_WE)begin v2[vram2_WA]<=vram2_WD;vc2[vram2_WA]++;v2_restore_count++;end
 if(wram_WE)begin wc[wram_WA]++;wram_restore_count++;end
end
always@(posedge ss_freeze)begin
 if(dut.do_save)begin
  for(integer n=0;n<16384;n++)saved_ram[n]=ram_bytes[n];
  for(integer n=0;n<32768;n++)begin saved_v1[n]=v1[n];saved_v2[n]=v2[n];end
 end else begin
  wram_restore_count=0;v1_restore_count=0;v2_restore_count=0;
  for(integer n=0;n<16384;n++)wc[n]=0;
  for(integer n=0;n<32768;n++)begin vc1[n]=0;vc2[n]=0;end
 end
end
task perturb_memory;begin
 if(TRANSFER)begin
 for(integer n=0;n<16384;n++)ram_bytes[n]=saved_ram[n]^8'h5a;
 for(integer n=0;n<32768;n++)begin v1[n]=saved_v1[n]^8'ha5;v2[n]=saved_v2[n]^8'hc3;end
 end
end endtask
always@(negedge ss_freeze)if(reset_n&&!dut.do_save&&TRANSFER)begin
 for(integer n=0;n<(systeme?16384:8192);n++)if(ram_bytes[n]!==saved_ram[n]||wc[n]!=1)$fatal(1,"WRAM data/count addr%0d actual%h expected%h count%0d",n,ram_bytes[n],saved_ram[n],wc[n]);
 for(integer n=(systeme?16384:8192);n<16384;n++)if(ram_bytes[n]!== (saved_ram[n]^8'h5a)||wc[n]!=0)$fatal(1,"WRAM boundary canary");
 for(integer n=0;n<(systeme?32768:16384);n++)if(v1[n]!==saved_v1[n]||vc1[n]!=1)$fatal(1,"VRAM1 data/count addr%0d actual%h expected%h count%0d",n,v1[n],saved_v1[n],vc1[n]);
 for(integer n=0;n<(systeme?32768:0);n++)if(v2[n]!==saved_v2[n]||vc2[n]!=1)$fatal(1,"VRAM2 data/count addr%0d",n);
 if(wram_restore_count!=(systeme?16384:8192)||v1_restore_count!=(systeme?32768:16384)||v2_restore_count!=(systeme?32768:0))$fatal(1,"wrong transfer lengths");
 $display("PASS SHARED_TRANSFER banks%0d pattern%0d WRAM%0d V1%0d V2%0d everyByteExactlyOnce",BANKS,PATTERN,wram_restore_count,v1_restore_count,v2_restore_count);
end

T80s #(.T2Write(0)) cpu(.RESET_n(reset_n),.CLK(clk),.CEN((((DUAL==3||DUAL==5)?ce_cpu:ce_pix)&&!ss_freeze&&(!paused||ss_capture_progress))||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(nmi_future),.BUSRQ_n(1'b1),.M1_n(cm1),.MREQ_n(cmreq),.IORQ_n(ciq),.RD_n(crd),.WR_n(cwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ca),.DI(ciq?cdi:{7'd0,HIST[0]}),.DO(co),.REG(z80_reg),.NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.RestoreHold(ss_freeze),.ReplayT2(replay_t2),.NMIReplay(replay),.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
T80s #(.T2Write(0)) rcpu(.RESET_n(reset_n),.CLK(clk),.CEN((((DUAL==3||DUAL==5)?ce_cpu:ce_pix)&&!ss_freeze&&(!paused||ss_capture_progress))||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(nmi_future),.BUSRQ_n(1'b1),.M1_n(rm1),.MREQ_n(rmreq),.IORQ_n(riq),.RD_n(rrd),.WR_n(rwr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(ra),.DI(riq?rdi:{7'd0,HIST[0]}),.DO(ro),.REG(rr),.NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.RestoreHold(ss_freeze),.ReplayT2(replay_t2),.RestartContext(),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(riset));
generate if(FULL)begin:fullvdps
vdp vdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp refvdp1(.clk_sys(clk),.ce_vdp((ce_vdp&&!holdref)),.ce_pix((ce_pix&&!holdref)),.ce_sp((ce_sp&&!holdref)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(rx),.y(ry),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(refvdp_regs),.ss_regs_in(136'd0),.ss_regs_set(1'b0),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp vdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!ss_freeze)),.ce_pix((ce_pix&&!ss_freeze)),.ce_sp((ce_sp&&!ss_freeze)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(x),.y(y),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp2_regs),.ss_regs_in(vdp2_regs_in),.ss_regs_set(vdp2_regs_set),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
vdp refvdp2(.clk_sys(clk),.ce_vdp((ce_vdp&&!holdref)),.ce_pix((ce_pix&&!holdref)),.ce_sp((ce_sp&&!holdref)),.gg(1'b0),.ggres(1'b0),.se_bank(1'b1),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(1'b1),.WR_n(1'b1),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'b0),.A(8'h00),.D_in(8'b0),.D_out(),.x(rx),.y(ry),.vcounter_cpu(8'b0),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(refvdp2_regs),.ss_regs_in(136'd0),.ss_regs_set(1'b0),.ss_cram_out(),.ss_cram_wr(1'b0),.ss_cram_A(5'b0),.ss_cram_D(12'b0),.ss_vram_en(1'b0),.ss_vram_A(15'b0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'b0),.ss_vram_WD(8'b0));
end else begin:lightvdps assign vdp_regs=0;assign vdp2_regs=0;end endgenerate
reg pwr2=1;reg[7:0]pd2=0;reg qmode=0;wire signed[10:0]a1r,a2r,rar;wire pq1,pq2;wire[3:0]div2;wire signed[10:0]audio1,audio2;reg pwr=1;reg[7:0]pd=0;
assign audio_quiescent=pq1&&pq2;
jt89 psg1(.ss_pending_tick(audio_pending_tick),.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress)),.rst(!reset_n),.wr_n(BUS&&!ciq&&ca[7:6]==1&&(!systeme||!ca[2])?cwr:pwr),.din(BUS&&!ciq&&ca[7:6]==1&&(!systeme||!ca[2])?co:pd),.mux(mux_control),.soundL(audio1),.soundR(a1r),.ready(),.ss_out(psg_out),.ss_set(psg_set),.ss_in(psg_in),.ss_ext_out(psg_ext_out),.ss_ext_in(psg_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(psg_div_out),.ss_div_in(psg_div_in),.ss_quiescent(pq1));
jt89 psg2(.ss_pending_tick(audio_pending_tick && systeme),.clk(clk),.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress)),.rst(!reset_n),.wr_n(BUS&&systeme&&!ciq&&ca[7:6]==1&&ca[2]?cwr:pwr2),.din(BUS&&systeme&&!ciq&&ca[7:6]==1&&ca[2]?co:pd2),.mux(mux_control),.soundL(audio2),.soundR(a2r),.ready(),.ss_out(psg2_out),.ss_set(psg2_set),.ss_in(psg2_in),.ss_ext_out(psg2_ext_out),.ss_ext_in(psg2_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(div2),.ss_div_in(psg_div_in),.ss_quiescent(pq2));
wire[95:0]rpsgext;wire[55:0]rpsgcfg;wire[3:0]rpsgdiv;wire signed[10:0]raudio;
jt89 rpsg(.ss_pending_tick(1'b0),.clk(clk),.clk_en(rce_cpu&&!holdref&&(!rpaused||ref_progress)),.rst(!reset_n),.wr_n(BUS&&!riq&&ra[7:6]==1&&(!systeme||!ra[2])?rwr:(qmode?1'b1:pwr)),.din(BUS&&!riq&&ra[7:6]==1&&(!systeme||!ra[2])?ro:pd),.mux(rmux),.soundL(raudio),.soundR(rar),.ready(),.ss_out(rpsgcfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(rpsgext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(rpsgdiv),.ss_div_in(4'd0),.ss_quiescent());
integer frame=0,accepts=0,transfers=0,request_cycle=0,max_latency=0,progress_cpu=0,progress_psg=0;
integer checks=0,freeze_start=0,freeze_clocks=0,quiet=0,i;
reg compare_machine=0,held=0;reg[2:0]phase_at_freeze;
reg[258:0]replay_cpu[0:127];reg[166:0]replay_psg[0:127];
always@(posedge vb)frame=frame+1;
always@(posedge clk)begin
 if(reset_n&&ss_capture_progress)begin
  if(dut.state!=37||!vb||x>=256||storage_busy||(!cm1&&!cmreq&&z80_iset==0)||ss_freeze)$fatal(1,"override outside minimal seek window");
  if(paused&&ce_pix)progress_cpu=progress_cpu+1;
  if(paused&&ce_cpu)progress_psg=progress_psg+1;
 end
 if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&!storage_busy)begin
  accepts=accepts+1;if(cycle-request_cycle>max_latency)max_latency=cycle-request_cycle;
  $display("ACCEPT case%0d cycle%0d latency%0d phase%0b%0b%0b bus%h progressCPU%0d PSG%0d",CASE,cycle,cycle-request_cycle,paused,pp,up,ca,progress_cpu,progress_psg);
 end
end
always@(posedge ss_freeze)begin
 held=1;phase_at_freeze={paused,pp,up};freeze_start=cycle;
 if(ss_capture_progress)$fatal(1,"override persists at freeze");
 $display("FREEZE case%0d cycle%0d phase%0b",CASE,cycle,phase_at_freeze);
end
always@(negedge ss_freeze)if(held)begin
 transfers=transfers+1;freeze_clocks=cycle-freeze_start;quiet=4;
 $display("RELEASE case%0d cycle%0d transport%0d phase%0b reference%0b",CASE,cycle,freeze_clocks,{paused,pp,up},{rpaused,rpp,rup});
end
task button;begin joy=1;repeat(3)tick;joy=0;repeat(3)tick;end endtask
task put(input[7:0]b);begin pd=b;pwr=0;repeat(31)tick;pwr=1;repeat(31)tick;end endtask
task request(input bit saving);begin
 // Replay monitoring returns after a rising edge. Align before pulsing so
 // every request includes a sampling edge rather than ending at the next fall.
 tick;
 $display("REQUEST ENTER case%0d save%b cycle%0d state%0d cooldown%0d",CASE,saving,cycle,dut.state,dut.op_cooldown);
 force dut.op_cooldown=0;request_cycle=cycle;
 ss_save=saving;ss_load=!saving;tick;ss_save=0;ss_load=0;
 $display("REQUEST SENT case%0d save%b cycle%0d state%0d cooldown%0d",CASE,saving,cycle,dut.state,dut.op_cooldown);
 if(dut.state==0)$fatal(1,"test driver failed to present a sampled request");
end endtask
task complete;begin wait(ss_freeze);wait(!ss_freeze);repeat(12)tick;release dut.op_cooldown;end endtask
task automatic sample_replay(input integer pass);begin
 // Start at release, not after the UI helper's arbitrary twelve-clock wait.
 // Compare each subsystem from its FIRST native enable, without skipping any.
 fork
  begin integer n;n=0;while(n<128)begin @(posedge clk);if(ce_pix)begin #1;
   // DO is not driven as meaningful data during a read. Check it on writes;
   // registers, address, M1/MREQ/IORQ/RD/WR are checked on every CPU tick.
   if(pass==0)replay_cpu[n]={z80_reg,ca,(cwr?8'd0:co),cm1,cmreq,ciq,crd,cwr};
   else if(replay_cpu[n]!=={z80_reg,ca,(cwr?8'd0:co),cm1,cmreq,ciq,crd,cwr})$fatal(1,"repeated load CPU/bus mismatch sample%0d regs%h/%h address%h/%h DO%h/%h bus%0b/%0b",n,replay_cpu[n][258:29],z80_reg,replay_cpu[n][28:13],ca,replay_cpu[n][12:5],co,replay_cpu[n][4:0],{cm1,cmreq,ciq,crd,cwr});
   n=n+1;
  end end end
  begin integer n;n=0;while(n<128)begin @(posedge clk);if(CASE==7?ce_pix:ce_cpu)begin #1;
   if(pass==0)replay_psg[n]={psg_out,psg_ext_out,psg_div_out,audio1};
   else if(replay_psg[n]!=={psg_out,psg_ext_out,psg_div_out,audio1})$fatal(1,"repeated load PSG mismatch sample%0d",n);
   n=n+1;
  end end end
 join
end endtask


wire[55:0]r2cfg;wire[95:0]r2ext;wire[3:0]r2div;wire signed[10:0]r2l,r2r;
always@(posedge clk)if(audio_ext_set)mux_control<=audio_control_in[7:0];
jt89 rpsg2(.ss_pending_tick(1'b0),.clk(clk),.clk_en(rce_cpu&&(!rpaused||ref_progress)),.rst(!reset_n),.wr_n(BUS&&systeme&&!riq&&ra[7:6]==1&&ra[2]?rwr:(qmode?1'b1:pwr2)),.din(BUS&&systeme&&!riq&&ra[7:6]==1&&ra[2]?ro:pd2),.mux(rmux),.soundL(r2l),.soundR(r2r),.ready(),.ss_out(r2cfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(r2ext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(r2div),.ss_div_in(4'd0),.ss_quiescent());
// Include capture-seeking PSG progress in the independent second reference.
wire[15:0]al,ar,rl,rr_audio;wire refphase;
wire[15:0]ml1=DUAL==1?16'd0:{audio1[10],audio1,4'b0},mr1=DUAL==1?16'd0:{a1r[10],a1r,4'b0};
wire[15:0]ml2=(DUAL==1||DUAL==2)?{audio2[10],audio2,4'b0}:16'd0,mr2=(DUAL==1||DUAL==2)?{a2r[10],a2r,4'b0}:16'd0;
wire[15:0]rml1=DUAL==1?16'd0:{raudio[10],raudio,4'b0},rmr1=DUAL==1?16'd0:{rar[10],rar,4'b0};
wire[15:0]rml2=(DUAL==1||DUAL==2)?{r2l[10],r2l,4'b0}:16'd0,rmr2=(DUAL==1||DUAL==2)?{r2r[10],r2r,4'b0}:16'd0;
AudioMix mix(.clk(clk),.audio_in_l1(ml1),.audio_in_r1(mr1),.audio_in_l2(ml2),.audio_in_r2(mr2),.audio_l(al),.audio_r(ar),.ss_phase_out(audio_phase_out),.ss_phase_in(reset_n?audio_phase_in:1'b0),.ss_phase_set(audio_phase_set||!reset_n));
AudioMix rmix(.clk(clk),.audio_in_l1(rml1),.audio_in_r1(rmr1),.audio_in_l2(rml2),.audio_in_r2(rmr2),.audio_l(rl),.audio_r(rr_audio),.ss_phase_out(refphase),.ss_phase_in(1'b0),.ss_phase_set(!reset_n));
wire[177:0]raw2=DUAL>=3?178'd0:{psg2_out,psg2_ext_out,div2,audio2,a2r};
wire[177:0]rraw2=DUAL>=3?178'd0:{r2cfg,r2ext,r2div,r2l,r2r};
wire[360:0]raw={clkd,psg_out,psg_ext_out,psg_div_out,audio1,a1r,raw2};
wire[360:0]rraw={rclkd,rpsgcfg,rpsgext,rpsgdiv,raudio,rar,rraw2};
reg[31:0]oracle[0:N-1];reg[360:0]raw_oracle[0:N-1];reg phase_oracle[0:N-1];reg[63:0]image_copy[0:12287];
integer edge_window=0;
always@(posedge clk)begin
 if(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&!storage_busy)edge_window=5;
 if(edge_window>0)begin
 $display("RAW_EDGE_PRE cycle%0d state%0d freeze%b clkd%0d rawCE%b gatedCE%b refCE%b cen16%b/%b div%0d/%0d cnt%0d/%0d snd%0d/%0d",cycle,dut.state,ss_freeze,clkd,ce_cpu,psg1.clk_en,rpsg.clk_en,psg1.cen_16,rpsg.cen_16,psg_div_out,rpsgdiv,psg1.u_tone0.cnt,rpsg.u_tone0.cnt,audio1,raudio);
 #1;$display("RAW_EDGE_POST cycle%0d freeze%b cen16%b/%b div%0d/%0d cnt%0d/%0d snd%0d/%0d ext%h/%h",cycle,ss_freeze,psg1.cen_16,rpsg.cen_16,psg_div_out,rpsgdiv,psg1.u_tone0.cnt,rpsg.u_tone0.cnt,audio1,raudio,psg_ext_out,rpsgext);
 edge_window--;
 end
end
integer fd,k,j,pass,scan,events=0,changed_pairs=0;reg[31:0]last_pair;reg[31:0]last_ref_pair;
function[15:0]clip(input[15:0]a,input[15:0]b);reg signed[16:0]v;begin v=$signed(a)+$signed(b);clip=(v[16]!=v[15])?(v[16]?16'h8000:16'h7fff):v[15:0];end endfunction
always@(posedge clk)begin
 if(BUS&&(DUAL==4||DUAL==5)&&!ss_freeze&&!ciq&&!cwr&&ca[7:0]==6)mux_control<=co;
 if(BUS&&(DUAL==4||DUAL==5)&&!riq&&!rwr&&ra[7:0]==6)rmux<=ro;
 if(dut.state==41&&dut.do_save)begin
 if({al,ar}!=={clip(ml1,ml2),clip(mr1,mr2)})$fatal(1,"historical mixer cache at accepted ARM: requires additional state");
 $display("ARM_BOUNDARY cycle%0d divider%0d phase%b outputs%h/%h raw%h",cycle,clkd,audio_phase_out,al,ar,raw);
 end
end
task put2(input[7:0]v);begin pd2=v;pwr2=0;repeat(31)tick;pwr2=1;repeat(31)tick;end endtask
task program_sound;begin
put(8'h86);put(8'h00);put(8'h90);
put2(8'hc9);put2(8'h00);put2(8'hd3);
if(PAT==1)begin put(8'h9f);put(8'hc6);put(8'h00);put(8'he7);put(8'hf0);end
if(PAT==2||PAT==3)begin put(8'hc6);put(8'h00);put(8'he7);put(8'hf3);end
if(PAT==3)begin put(8'ha9);put(8'h00);put(8'hb5);put(8'hd8);end
if(PAT==6)put(8'h9f);
if(HISTORY)begin put(8'h9f);put(8'h90);end
case(ROUTE)1:begin mux_control=8'hf1;rmux=8'hf1;end 2:begin mux_control=8'h1f;rmux=8'h1f;end 3:begin mux_control=8'hf0;rmux=8'hf0;end 4:begin mux_control=8'h0f;rmux=8'h0f;end endcase
end endtask
reg nmi_future=1;
task future(input integer n,input bit reference_run);begin
if(CACHEHISTORY&&n==500)nmi_future=0;if(CACHEHISTORY&&n==504)nmi_future=1;
// Identical logical-time future writes, reset after every LOAD.
if((PAT==4||PAT==6||PAT==7)&&n==500)begin pd=PAT==7?8'h9f:8'h90;pwr=0;end
if((PAT==4||PAT==6||PAT==7)&&n==531)pwr=1;
if(PAT==4&&n==900)begin pd=8'h9a;pwr=0;end
if(PAT==4&&n==931)pwr=1;
if(PAT==5&&n==500)begin pd=8'h89;pwr=0;end
if(PAT==5&&n==531)pwr=1;
if(ROUTE==5&&n==501)begin mux_control=8'h0f;rmux=8'h0f;end
if(ROUTE==5&&n==900)begin mux_control=8'hf0;rmux=8'hf0;end
if(PAUSE==3&&n==100)joy=1;
if(PAUSE==3&&n==104)joy=0;
end endtask

integer wrong_fetches=0,architectural_differences=0,preload_equal=0;
always@(posedge clk)if(reset_n&&!load_started&&cycle>BOOT+5000&&!ss_freeze&&cpu_ce)begin
 #1;if($isunknown({z80_reg,rr})||z80_reg!==rr||ca!==ra)$fatal(1,"golden CPU differs before LOAD");preload_equal++;
end
always@(posedge clk)if(load_started&&!ss_freeze&&cpu_ce&&!paused)begin
 if(!crd&&!cmreq&&ca<16'hc000&&sd!==chip.byte_at(phys))begin wrong_fetches++;$display("WRONG_G12_FETCH cycle%0d A%h physical%h actual%h expected%h q%0d ready%b flight%b",cycle,ca,phys,sd,chip.byte_at(phys),live.q,ready,flight);end
 #1;if(z80_reg!==rr||ca!==ra)begin architectural_differences++;if(architectural_differences<=6)$display("G12_GUEST_DIVERGENCE cycle%0d actual%h golden%h A%h/%h",cycle,z80_reg,rr,ca,ra);end
end
initial begin
 for(j=0;j<12288;j++)mem[j]=0;
 systeme=1;ss_game_id=32'h12345678;repeat(BOOT)tick;reset_n=1;repeat(2)tick;program_sound;
 if(SAVED_PAUSED)begin while(!(vb&&x==200))tick;button;wait(paused);repeat(64)tick;end
 request(1);wait(ss_freeze);wait(!ss_freeze);
 $writememh("image.hex",mem);
 if(mem['h2f][3]!==!SAVED_PAUSED)$fatal(1,"wrong capture consumption");
 $display("PAUSED_IMAGE phase%0d tick%b PC%h",mem['h2f][1:0],mem['h2f][3],z80_reg[79:64]);
 if(SAVED_PAUSED)begin button;wait(!paused);end repeat(2000)tick;
 if(CURRENT_PAUSED)begin button;wait(paused);repeat(64)tick;end
 load_started=1;request(0);wait(ss_freeze);wait(!ss_freeze);
 $display("LOAD_RUNNING_RELEASE q%0d oldrd%b retained%h SD%h expected%h prepTick%b",live.q,live.access_manager.old_rd,live.a,sd,chip.byte_at(phys),mem['h2f][3]);
 if(CURRENT_PAUSED)begin repeat(100)tick;button;wait(!paused);end
 repeat(1000)tick;
 if(wrong_fetches&&architectural_differences)$display("CONFIRMED G12 wrongFetches%0d guestDifferences%0d tailDelay%0d preloadEqual%0d",wrong_fetches,architectural_differences,TAIL_DELAY,preload_equal);
 else if(wrong_fetches||architectural_differences)$fatal(1,"incomplete characterization fetch%0d architecture%0d",wrong_fetches,architectural_differences);
 else $display("PASS G12 LOAD_RUNNING tailDelay%0d",TAIL_DELAY);
 $finish;
end
initial begin #2000000000;$fatal(1,"matrix watchdog state%0d",dut.state);end
reg[311:0]held_psgs;reg preparing=0;integer prepare_clocks=0;
always@(posedge clk)begin
 if(cpu_prepare&&!preparing)begin held_psgs={psg_ext_out,psg_out,psg_div_out,psg2_ext_out,psg2_out,div2};prepare_clocks=0;end
 if(cpu_prepare)begin
  prepare_clocks++;
  if(prepare_clocks>48)$fatal(1,"paused private preparation exceeded bound");
  if({psg_ext_out,psg_out,psg_div_out,psg2_ext_out,psg2_out,div2}!==held_psgs)$fatal(1,"paused CPU preparation advanced PSGs");
 end
 if(compare_machine&&frame>=1&&!ss_freeze&&$isunknown({z80_reg,rr}))$fatal(1,"uninitialized Pause CPU oracle");
 if(preparing&&!cpu_prepare)$display("PAUSE_PRIVATE_PREPARATION clocks%0d savedT2%b UIpaused%b",prepare_clocks,replay_t2,paused);
 preparing<=cpu_prepare;
end
integer pending_replays=0;
always@(posedge ss_freeze)pending_replays=0;
always@(negedge clk)if(audio_pending_tick)begin
 pending_replays++;
 if(pending_replays>1||ss_freeze||cpu_prepare||audio_ext_set)$fatal(1,"pending event replayed outside single guest release edge");
 $display("PENDING_REPLAY cycle%0d savedPhase%0d savedDiv%0d active%b",cycle,dut.phase_snap,dut.audio_div_snap,dut.capture_tick_snap);
end
always@(posedge clk)if(cpu_prepare||audio_phase_set||(load_started&&!ss_freeze&&cycle%2==0))$display("RUNNING_TRACE cycle%0d prepare%b replay%b cpuCE%b pixelCE%b phase%0d A%h rd%b q%0d oldrd%b ready%b data%h golden%h",cycle,cpu_prepare,replay,ce_cpu,ce_pix,clkd,ca,rd,live.q,live.access_manager.old_rd,ready,sd,rchip.byte_at(rphys));
always@(posedge clk)if(cpu_prepare||audio_phase_set||(load_started&&!ss_freeze&&cycle%2==0))$display("G12_CAUSAL cycle%0d paused%b MC%0d TS%0d PC%h A%h MREQ%b RD%b romRD%b q%0d pending%b ready%b raw%h freeze%b state%0d replay%b",cycle,paused,cpu.MCycle,cpu.TState,z80_reg[79:64],ca,cmreq,crd,rd,live.q,live.ram_req,ready,sd,ss_freeze,dut.state,replay);
endmodule
