`timescale 1ns/1ps
module sram_tb; parameter STALL=0,OLD=0; parameter GG=1,PAL=0,REQUEST_X=40,SPRITE_X=120,SPRITES=2,REPLAYS=3,REFERENCE=0,PROTO=1,TURBO=1,SAVE_ONLY=0,DIAGNOSTIC=0,SAVE_PHASE=-1,COMMON_PHASE=0,FIX=1,SCAN_MASK=0,SLOTS=8,EXT_REFERENCE=0,PHASE_SWEEP=0,WARMUP=0,PAUSE_CAPTURE=0,NATURAL_PHASE=0;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
wire fm_write,fm_reset;wire ss_freeze;wire ss_capture_progress;
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
wire [383:0] cram_out;
wire [4:0] cram_A;
wire [11:0] cram_D;
wire cram_wr;
wire vram_en;
wire [14:0] vram_A;
wire [7:0] vram_D;
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
reg audio_phase_out = 1'b1;
wire audio_phase_in;
wire audio_ext_set;
wire audio_phase_set;
wire [63:0] mapper_out;
wire [63:0] mapper_in;
wire mapper_set;
reg [159:0] evolution_out = '0;
wire [159:0] evolution_in;
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
wire [7:0] nvram_D;
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
localparam N=74*SLOTS;
wire[N+41:0]g06_live;wire[4777:0]sprite_restored;wire sprite_valid;
wire cpu_prepare,phase_set,replay,replay_t2;wire[1:0]phase_in;reg phase_ready=0;reg[4:0]clkd=0;reg logical_pause=0;
reg[138:0] bg_live=0,bg2_live=0;wire[138:0] bg_restored,bg2_restored;wire bg_valid;
reg expect_background=1;
savestates #(.TB_FAST(1)) dut(.fm_initialized(1'b1),.fm_state_rdata(32'd0),.fm_state_write(fm_write),.fm_legacy_reset(fm_reset),.bg_out(bg_live),.bg2_out(bg2_live),.bg_in(bg_restored),.bg2_in(bg2_restored),.bg_valid(bg_valid),.ss_cpu_prepare(cpu_prepare),.z80_replay(replay),
 .z80_tick_active(!logical_pause),.z80_replay_t2(replay_t2),
 .clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),
 .clock_phase_in(phase_in),.clock_phase_set(phase_set),.clock_phase_ready(phase_ready),
 .sprite_out({{(4778-(N+42)){1'b0}},g06_live}),.sprite2_out(4778'd0),
 .sprite_in(sprite_restored),.sprite2_in(),.sprite_valid(sprite_valid),.z80_restart(restart_out),.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(ss_capture_progress),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));

always #5 clk=~clk;
assign vblank=1;assign x=0;assign z80_reg=0;assign z80_m1_n=0;assign z80_mreq_n=0;assign z80_iset=0;
assign cpu_ce=1;assign vdp_ce=0;assign pix_ce=0;assign sp_ce=0;
assign vdp_regs=0;assign cram_out=0;assign vram_D=0;assign wram_D=0;
assign psg_out=0;assign psg2_out=0;assign psg_ext_out=0;assign psg2_ext_out=0;assign psg_div_out=0;assign audio_quiescent=1;
assign vdp2_regs=0;assign video_state_out=0;assign g06_live=0;assign replay=0; assign restart_out=0;
always@(negedge clk)phase_ready<=phase_set;
reg[15:0]stall_lfsr=16'h1ace;integer cyc=0;
always@(negedge clk)begin
 cyc++;stall_lfsr={stall_lfsr[14:0],stall_lfsr[15]^stall_lfsr[13]^stall_lfsr[12]^stall_lfsr[10]};
 DDRAM_BUSY=(DDRAM_WE||DDRAM_RD)&&(STALL==1?cyc%31<13:STALL==2?stall_lfsr[3:0]<12:0);
end
reg[63:0]mem[0:12287];integer pending=0;reg[28:0]readaddr;
always@(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b++)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending)$fatal(1,"overlapping read");pending<=STALL==0?3:STALL==1?17:3+stall_lfsr[3:0];readaddr<=DDRAM_ADDR;end
end
task tick;begin @(negedge clk);#1;end endtask
integer guest_writes=0,rejections=0,accepted=0;reg loading=0;
always@(posedge clk)if(loading&&(fm_write||fm_reset||wram_WE||vram_WE||nvram_WE||vram2_WE||z80_set||mapper_set||evolution_set||gg_set||io_set||eeprom_set||gun_set||paddle_set||tap_set||vdp_regs_set||vdp2_regs_set||psg_set||psg2_set||cram_wr||cram2_wr||video_state_set||audio_ext_set||audio_phase_set))guest_writes++;
task transfer(input bit saveop);begin
 wait(!ss_busy);force dut.op_cooldown=0;tick;guest_writes=0;loading=!saveop;
 ss_save=saveop;ss_load=!saveop;tick;ss_save=0;ss_load=0;
 wait(ss_busy);wait(!ss_busy);loading=0;release dut.op_cooldown;tick;
end endtask
task reject_bit(input integer wordaddr,bitnum);reg[63:0]oldword;begin
 oldword=mem[wordaddr];mem[wordaddr]=oldword^(64'd1<<bitnum);
 transfer(0);if(guest_writes)$fatal(1,"malformed image wrote guest state word%h bit%0d",wordaddr,bitnum);
 mem[wordaddr]=oldword;rejections++;$display("REJECT word%h bit%0d",wordaddr,bitnum);
end endtask
always@(posedge clk)if(loading&&vdp_regs_set)begin
 if(bg_valid!==expect_background)$fatal(1,"background validity mismatch");
 if(expect_background)begin
  if(bg_restored!==bg_live||(systeme&&bg2_restored!==bg2_live))$fatal(1,"background payload roundtrip mismatch");
 end else if(bg_restored!==0||bg2_restored!==0)$fatal(1,"legacy background history leaked");
end
reg[63:0]oldtag;reg[63:0]saved_image[0:12287];
wire[7:0]physical_q;reg[14:0]host_addr=0;reg[7:0]host_data=0;reg host_we=0;
reg mapper_reset_n=0; reg[15:0]a=0;reg[7:0]di=0;reg wr=1,mreq=1;
wire en,ext,bank,cme,we;wire[7:0]q,b0,b1,b2,b3,pak,nem;
wire[14:0]pa={bank & ~a[14],a[13:0]};
// Exact ordinary-Sega slice of system.vhd mapper_out (non-Sega flags zero).
assign mapper_out={10'd0,cme,bank,ext,en,2'd0,nem,pak,b3,b2,b1,b0};
mapper_ctrl mapper(.RESET_n(mapper_reset_n),.clk_sys(clk),.evolution_game_launch(1'b0),.mapper_set(mapper_set),.mapper_evolution(1'b0),.mapper_in(mapper_in),.mapper_janggun(1'b0),.systeme(1'b0),.bootloader_n(1'b1),.mapper_wonderkid(1'b0),.mapper_lock(1'b0),.detect_codies_static(1'b0),.mapper_codies_force(1'b0),.mapper_eeprom(1'b0),.mapper_zemina_force(1'b0),.mapper_nemesis_auto(1'b0),.rom_size_pages(8'd0),.ce_z80(1'b1),.WR_n(wr),.MREQ_n(mreq),.A(a),.ss_freeze(ss_freeze),.D_in(di),.sc3000_en(1'b0),.mapper_castle(1'b0),.mapper_linear(1'b0),.mapper_dahjee_a(1'b0),.mapper_sega_locked(1'b0),.use_zem(1'b0),.mapper_manual_force(1'b0),.sega_mapper_write_seen(1'b0),.bank0_out(b0),.bank1_out(b1),.bank2_out(b2),.bank3_out(b3),.jang_bank1_out(),.jang_bank2_out(),.jang_bank3_out(),.jang_bank4_out(),.jang_rev1_out(),.jang_rev2_out(),.jang_rev3_out(),.jang_rev4_out(),.nvram_e_out(en),.nvram_ex_out(ext),.nvram_p_out(bank),.nvram_cme_out(cme),.lock_mapper_B_out(),.mapper_codies_out(),.mapper_codies_lock_out(),.mapper_4pak_out(),.pak4_reg2_out(pak),.nem_bank0_out(nem),.eeprom_soft_reset_out());
memory_bus bus(.A(a),.sc3000_en(1'b0),.sc_cart_ram(2'd0),.mapper_castle(1'b0),.sc_multicart_en(1'b0),.WR_n(wr),.RD_n(1'b0),.MREQ_n(mreq),.ss_freeze(ss_freeze),.mapper_eeprom(1'b0),.nvram_e(en),.nvram_ex(ext),.nvram_cme(cme),.dahjee_cart_access(1'b0),.eeprom_bus_active(1'b0),.eeprom_D_out(8'd0),.nvram_D_out(nvram_D),.ram_D_out(8'h66),.irom_D_out(8'h99),.ram_WR(),.rom_RD(),.nvram_WR(we),.memory_D_out(q));
dpram #(.widthad_a(15),.init_file("../../../rtl/nvram_ff.mif")) ram(.clock_a(clk),.address_a(ss_freeze?(nvram_WE?nvram_WA:nvram_A):pa),.data_a(ss_freeze?nvram_WD:di),.wren_a(ss_freeze?nvram_WE:we),.q_a(nvram_D),.clock_b(clk),.address_b(host_addr),.data_b(host_data),.wren_b(host_we),.q_b(physical_q));
task put(input[15:0]addr,input[7:0]value);begin a=addr;di=value;mreq=0;wr=0;repeat(2)tick;wr=1;mreq=1;tick;end endtask
task control(input[7:0]v);begin put(16'hfffc,v);end endtask
task readbank(input bit upper,input[7:0]expected);begin control(upper?8'h0c:8'h08);a=16'h8000;mreq=0;repeat(3)tick;if(q!==expected)$fatal(1,"read bank%0d got%h expected%h",upper,q,expected);mreq=1;end endtask
task fill(input[7:0]lo,hi);begin
 control(8'h08);for(integer j=0;j<16384;j++)put(16'h8000+j,lo);
 control(8'h0c);for(integer j=0;j<16384;j++)put(16'h8000+j,hi);control(0);
end endtask
integer payload=0,restore_bytes=0,clocks=0,start_clock,save_clocks,load_clocks;
reg counting_save=0,counting_load=0;
reg[7:0]expected[0:32767];reg[63:0]image[0:12287];
integer write_seen[0:4095],byte_seen[0:32767];
always@(posedge clk)begin
 clocks++;
 if(counting_save&&DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR>=29'h07c00d01&&DDRAM_ADDR<=29'h07c01d00)begin payload++;write_seen[DDRAM_ADDR-29'h07c00d01]++;end
 if(counting_load&&nvram_WE)begin restore_bytes++;byte_seen[nvram_WA]++;if(!ss_freeze)$fatal(1,"SRAM restore outside freeze");end
end
function[7:0]pattern(input integer j,seed);pattern=(j*73)^(j>>3)^(j>>8)^seed;endfunction
task hostfill(input bit perturb,input integer seed);begin
 for(integer j=0;j<32768;j++)begin host_addr=j;host_data=perturb?~expected[j]:pattern(j,seed);if(!perturb)expected[j]=host_data;host_we=1;tick;end
 host_we=0;tick;
end endtask
task guestfill;begin
 for(integer banknum=0;banknum<2;banknum++)begin control(banknum?8'h0c:8'h08);for(integer j=0;j<16384;j++)put(16'h8000+j,expected[banknum*16384+j]);end
 control(0);
end endtask
task scan(input integer limit);reg changed_by_control;begin
 changed_by_control=ext;
 for(integer banknum=0;banknum<2;banknum++)begin
  control(banknum?8'h0c:8'h08);
  for(integer j=0;j<16384;j++)begin a=16'h8000+j;mreq=0;repeat(2)tick;
   // Exposing bank0 after extension mode writes FFFC through the still-live
   // C000 SRAM alias first. The uninterrupted bus performs the same write.
   if(q!==((changed_by_control&&banknum==0&&j=='h3ffc)?8'h08:(banknum*16384+j<limit?expected[banknum*16384+j]:~expected[banknum*16384+j])))$fatal(1,"byte mismatch bank%0d off%h got%h",banknum,j,q);
  end
  mreq=1;
 end
end endtask
task physical_scan(input integer limit);begin
 for(integer j=0;j<32768;j++)begin host_addr=j;repeat(2)tick;if(physical_q!==(j<limit?expected[j]:~expected[j]))$fatal(1,"physical byte%h got%h expected%h",j,physical_q,j<limit?expected[j]:~expected[j]);end
end endtask
task save_now(input integer expected_words);reg[63:0]mapper_before;begin
 mapper_before=mapper_out;payload=0;for(integer j=0;j<4096;j++)write_seen[j]=0;
 counting_save=1;start_clock=clocks;transfer(1);save_clocks=clocks-start_clock;counting_save=0;
 if(mapper_out!==mapper_before)$fatal(1,"SAVE changed mapper");
 if(payload!=expected_words)$fatal(1,"payload words %0d expected%0d",payload,expected_words);
 for(integer j=0;j<expected_words;j++)if(write_seen[j]!=1)$fatal(1,"duplicate/skipped word%0d",j);
 for(integer j=0;j<32768&&j<expected_words*8;j++)if(mem['hd01+j/8][(j%8)*8+:8]!==expected[j])$fatal(1,"image byte%h",j);
 for(integer j=0;j<12288;j++)if((^mem[j])===1'bx)$fatal(1,"unknown full image%h",j);
end endtask
task load_now(input integer expected_bytes);begin
 restore_bytes=0;for(integer j=0;j<32768;j++)byte_seen[j]=0;
 counting_load=1;start_clock=clocks;transfer(0);load_clocks=clocks-start_clock;counting_load=0;
 if(restore_bytes!=expected_bytes)$fatal(1,"restore bytes%0d expected%0d",restore_bytes,expected_bytes);
 for(integer j=0;j<expected_bytes;j++)if(byte_seen[j]!=1)$fatal(1,"duplicate/skipped restore byte%h",j);
end endtask
integer mode,words;reg[7:0]flags;
initial begin
 for(integer j=0;j<12288;j++)mem[j]=0;
 repeat(4)tick;reset_n=1;mapper_reset_n=1;repeat(4)tick;
 for(mode=0;mode<4;mode++)begin
  flags=mode==0?0:mode==1?8'h08:mode==2?8'h0c:8'h18;
  hostfill(0,mode+37);control(flags);if(flags[4])expected['h3ffc]=flags;a=0;di=0;repeat(3)tick;
  save_now(4096);mem['h1a][63:40]=24'h484311;
  // The legacy tag must retain its exact old prefix, even with a populated
  // modern tail. Tail bytes are deliberately poisoned against accidental use.
  words=(flags&8'h14)?4096:(flags&8)?2048:0;
  for(integer j=words;j<4096;j++)mem['hd01+j]=~mem['hd01+j];
  control(0);hostfill(1,0);load_now(words*8);physical_scan(words*8);
  $display("PASS LEGACY v17 flags%h restorebytes%0d missingbytesretained%0d",flags,restore_bytes,32768-restore_bytes);
 end
 $display("PASS LEGACY COMPLETE");$finish;
end
initial begin #100000000;$fatal(1,"legacy watchdog");end
endmodule
