`timescale 1ns/1ps
module vdp_tb;
reg[383:0]palette1=0,palette2=0,keep1,keep2;
reg[1:0]test_phase=0;reg test_tick=1;
integer profile=0,wallcycle=0,images=0,load_count=0,stream;
reg[31:0]rng=32'h6384a117;
reg[11:0]serial1,serial2;
reg[15:0]history_source=16'h5aa5;wire[15:0]history_restored;wire history_valid;reg want_history=1; parameter GG=1,PAL=0,REQUEST_X=40,SPRITE_X=120,SPRITES=2,REPLAYS=3,REFERENCE=0,PROTO=1,TURBO=1,SAVE_ONLY=0,DIAGNOSTIC=0,SAVE_PHASE=-1,COMMON_PHASE=0,FIX=1,SCAN_MASK=0,SLOTS=8,EXT_REFERENCE=0,PHASE_SWEEP=0,WARMUP=0,PAUSE_CAPTURE=0,NATURAL_PHASE=0;
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
reg [63:0] mapper_out = '0;
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
reg [7:0] nvram_D = '0;
wire nvram_WE;
wire [14:0] nvram_WA;
wire [7:0] nvram_WD;
reg systeme = '0;
wire [135:0] vdp2_regs;
wire [135:0] vdp2_regs_in;
wire vdp2_regs_set;
wire [383:0] cram2_out=palette2;
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
savestates dut(.audio_last_out(history_source),.audio_last_in(history_restored),.audio_last_valid(history_valid),.fm_initialized(1'b1),.fm_state_rdata(32'd0),.fm_state_write(fm_write),.fm_legacy_reset(fm_reset),.bg_out(bg_live),.bg2_out(bg2_live),.bg_in(bg_restored),.bg2_in(bg2_restored),.bg_valid(bg_valid),.ss_cpu_prepare(cpu_prepare),.z80_replay(replay),
 .z80_tick_active(test_tick),.z80_replay_t2(replay_t2),
 .clock_phase(test_phase),
 .clock_phase_in(phase_in),.clock_phase_set(phase_set),.clock_phase_ready(phase_ready),
 .sprite_out({{(4778-(N+42)){1'b0}},g06_live}),.sprite2_out(4778'd0),
 .sprite_in(sprite_restored),.sprite2_in(),.sprite_valid(sprite_valid),.z80_restart(restart_out),.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(ss_capture_progress),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));

reg[31:0]bus_rng=32'hca8b17e3;always@(negedge clk)begin bus_rng={bus_rng[30:0],bus_rng[31]^bus_rng[21]^bus_rng[1]^bus_rng[0]};end
always #5 clk=~clk;
assign vblank=1;assign x=0;assign z80_reg=0;assign z80_m1_n=0;assign z80_mreq_n=0;assign z80_iset=0;
assign cpu_ce=1;assign vdp_ce=0;assign pix_ce=0;assign sp_ce=0;
assign vdp_regs=0;assign cram_out=palette1;assign vram_D=0;assign wram_D=0;
assign psg_out=0;assign psg2_out=0;assign psg_ext_out=0;assign psg2_ext_out=0;assign psg_div_out=0;assign audio_quiescent=1;
assign vdp2_regs=0;assign video_state_out=0;assign g06_live=0;assign replay=0;assign restart_out=0;
always@(negedge clk)phase_ready<=phase_set;
reg[63:0]mem[0:12287];integer pending=0;reg[28:0]readaddr;
always@(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending==0&&!DDRAM_RD&&bus_rng[4:0]==0)begin DDRAM_DOUT_READY<=1;DDRAM_DOUT<=64'hbaddecaf12345678;end
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b++)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending)$fatal(1,"overlapping read");pending<=1+(profile%5);readaddr<=DDRAM_ADDR;end
end
task tick;begin @(negedge clk);#1;end endtask
integer guest_writes=0,rejections=0,accepted=0;reg loading=0;
always@(posedge clk)if(loading&&(fm_write||fm_reset||wram_WE||vram_WE||nvram_WE||vram2_WE||z80_set||mapper_set||evolution_set||gg_set||io_set||eeprom_set||gun_set||paddle_set||tap_set||vdp_regs_set||vdp2_regs_set||psg_set||psg2_set||cram_wr||cram2_wr||video_state_set||audio_ext_set||audio_phase_set))guest_writes++;
task transfer(input bit saveop);begin
 wait(!ss_busy);force dut.op_cooldown=0;force alias_ctl.op_cooldown=0;tick;guest_writes=0;loading=!saveop;
 ss_save=saveop;ss_load=!saveop;tick;ss_save=0;ss_load=0;
 wait(ss_busy);wait(!ss_busy);loading=0;release dut.op_cooldown;release alias_ctl.op_cooldown;tick;
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


function[31:0]rnd;begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};rnd=rng;end endfunction
always@(negedge clk)begin wallcycle++;DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&profile%3!=0&&(wallcycle%8<(profile%3==1?2:7));end
always@(posedge clk)begin
 if(cram_wr)palette1[12*cram_A+:12]<=cram_D;
 if(cram2_wr)palette2[12*cram2_A+:12]<=cram2_D;
end
initial begin
 for(integer i=0;i<12288;i++)mem[i]=0;
 for(integer i=0;i<139;i++)begin bg_live[i]=(i%3)==0;bg2_live[i]=(i%5)==0;end
 bg_live[22:15]=179;bg2_live[22:15]=239;
 repeat(4)tick;reset_n=1;
 stream=$fopen("images.hex","w");
 for(profile=0;profile<16;profile++)begin
  systeme=profile[2];test_phase=profile[1:0];test_tick=profile[3];
  for(integer a=0;a<32;a++)begin palette1[12*a+:12]=rnd();palette2[12*a+:12]=rnd();end
  keep1=palette1;keep2=palette2;
  transfer(1);
  if(mem[47][1:0]!==test_phase||mem[47][3]!==test_tick)$fatal(1,"phase profile encoding");
  if({mem[13],mem[12],mem[11],mem[10],mem[9],mem[8]}!==keep1)$fatal(1,"SAVE primary packing profile%0d",profile);
  if(systeme&&{mem[23],mem[22],mem[21],mem[20],mem[19],mem[18]}!==keep2)$fatal(1,"SAVE secondary packing");
  for(integer w=0;w<12288;w++)begin
   if($isunknown(mem[w]))$fatal(1,"unknown complete image profile%0d word%0h",profile,w);
   saved_image[w]=mem[w];$fdisplay(stream,"%016h",mem[w]);
  end
  images++;
  for(integer rep=0;rep<3;rep++)begin
   for(integer a=0;a<32;a++)begin palette1[12*a+:12]=rnd();palette2[12*a+:12]=rnd();end
   transfer(0);
   if(palette1!==keep1||(systeme&&palette2!==keep2))$fatal(1,"LOAD contents profile%0d rep%0d",profile,rep);
   for(integer w=0;w<12288;w++)if(mem[w]!==saved_image[w])$fatal(1,"image mutated");
   load_count++;
  end
  $display("PASS CRAM IMAGE profile%0d phase%0d owner%b tick%b loads3",profile,test_phase,systeme,test_tick);
 end
 // Old64 with System E must preserve the current secondary palette.
 systeme=1;expect_background=0;want_history=0;
 for(integer a=0;a<32;a++)begin palette1[12*a+:12]=rnd();palette2[12*a+:12]=rnd();end
 keep2=palette2;
 mem[0][63:32]=32'h3ffe;mem[14][63:56]=0;mem[5][63:20]=0;
 for(integer w=18;w<=23;w++)mem[w]='1;
 transfer(0);
 if(palette2!==keep2)$fatal(1,"legacy64 System E changed live secondary palette");
 $display("PASS CRAM LEGACY64 SYSTEME secondary_retained");
 $fclose(stream);$display("PASS CRAM IMAGE ALL images%0d loads%0d",images,load_count);$finish;
end
initial begin #2000000000;$fatal(1,"image proof watchdog");end
always@(posedge clk)if(loading&&audio_phase_set)begin
 if(history_valid!==want_history)$fatal(1,"history presence");
 if(want_history&&history_restored!==history_source)$fatal(1,"history contents");
end

// Complete controller outputs: four-state equality, except inactive CPU data.
wire [7:0] alias_fm_state_addr;
wire  alias_fm_state_read;
wire  alias_fm_state_write;
wire [31:0] alias_fm_state_wdata;
wire  alias_fm_legacy_reset;
wire  alias_fm_initialization_run;
wire  alias_ss_freeze;
wire  alias_ss_cpu_prepare;
wire  alias_z80_replay_t2;
wire [1:0] alias_clock_phase_in;
wire  alias_clock_phase_set;
wire [138:0] alias_bg_in;
wire [138:0] alias_bg2_in;
wire  alias_bg_valid;
wire [4777:0] alias_sprite_in;
wire [4777:0] alias_sprite2_in;
wire  alias_sprite_valid;
wire [2:0] alias_z80_restart_dir;
wire  alias_z80_restart_valid;
wire [2:0] alias_z80_nmi_dir;
wire  alias_z80_nmi_valid;
wire  alias_z80_nmi_hold;
wire [229:0] alias_z80_dir;
wire  alias_z80_set;
wire [135:0] alias_vdp_regs_in;
wire  alias_vdp_regs_set;
wire [4:0] alias_cram_A;
wire [11:0] alias_cram_D;
wire  alias_cram_wr;
wire  alias_vram_en;
wire [14:0] alias_vram_A;
wire  alias_vram_WE;
wire [14:0] alias_vram_WA;
wire [7:0] alias_vram_WD;
wire [55:0] alias_psg_in;
wire  alias_psg_set;
wire [95:0] alias_psg_ext_in;
wire [95:0] alias_psg2_ext_in;
wire [3:0] alias_psg_div_in;
wire [10:0] alias_audio_control_in;
wire [15:0] alias_audio_last_in;
wire  alias_audio_last_valid;
wire  alias_audio_phase_in;
wire  alias_audio_ext_set;
wire  alias_audio_phase_set;
wire  alias_audio_pending_tick;
wire [17:0] alias_mapper_history_in;
wire [63:0] alias_mapper_in;
wire  alias_mapper_set;
wire [159:0] alias_evolution_in;
wire  alias_evolution_set;
wire  alias_ss_busy;
wire  alias_ss_capture_progress;
wire [127:0] alias_eeprom_ext_in;
wire  alias_eeprom_full;
wire  alias_nvram_refill;
wire [45:0] alias_gun_in;
wire  alias_gun_set;
wire  alias_gun_valid;
wire [31:0] alias_paddle_in;
wire  alias_paddle_set;
wire  alias_paddle_valid;
wire [18:0] alias_tap_in;
wire  alias_tap_set;
wire  alias_tap_valid;
wire  alias_sc_ram_restored;
wire [63:0] alias_eeprom_in;
wire  alias_eeprom_set;
wire [13:0] alias_wram_A;
wire  alias_wram_WE;
wire [13:0] alias_wram_WA;
wire [7:0] alias_wram_WD;
wire [14:0] alias_nvram_A;
wire  alias_nvram_WE;
wire [14:0] alias_nvram_WA;
wire [7:0] alias_nvram_WD;
wire [135:0] alias_vdp2_regs_in;
wire  alias_vdp2_regs_set;
wire [4:0] alias_cram2_A;
wire [11:0] alias_cram2_D;
wire  alias_cram2_wr;
wire  alias_vram2_en;
wire [14:0] alias_vram2_A;
wire  alias_vram2_WE;
wire [14:0] alias_vram2_WA;
wire [7:0] alias_vram2_WD;
wire [55:0] alias_psg2_in;
wire  alias_psg2_set;
wire [45:0] alias_md_in;
wire  alias_md_set;
wire  alias_md_valid;
wire [127:0] alias_gg_in;
wire  alias_gg_set;
wire [31:0] alias_io_in;
wire  alias_io_set;
wire [21:0] alias_video_state_in;
wire  alias_video_state_set;
wire [28:0] alias_DDRAM_ADDR;
wire [63:0] alias_DDRAM_DIN;
wire [7:0] alias_DDRAM_BE;
wire  alias_DDRAM_WE;
wire  alias_DDRAM_RD;
wire [7:0] alias_DDRAM_BURSTCNT;
savestates_alias #(.TB_FAST(dut.TB_FAST)) alias_ctl(
.fm_state_rdata(dut.fm_state_rdata),
.fm_initialized(dut.fm_initialized),
.clk(dut.clk),
.reset_n(dut.reset_n),
.ss_save(dut.ss_save),
.ss_load(dut.ss_load),
.ss_slot(dut.ss_slot),
.ss_bios_mode(dut.ss_bios_mode),
.ss_game_id(dut.ss_game_id),
.z80_replay(dut.z80_replay),
.z80_tick_active(dut.z80_tick_active),
.clock_phase(dut.clock_phase),
.clock_phase_ready(dut.clock_phase_ready),
.bg_out(dut.bg_out),
.bg2_out(dut.bg2_out),
.sprite_out(dut.sprite_out),
.sprite2_out(dut.sprite2_out),
.vblank(dut.vblank),
.x(dut.x),
.z80_restart(dut.z80_restart),
.z80_nmi(dut.z80_nmi),
.z80_reg(dut.z80_reg),
.z80_m1_n(dut.z80_m1_n),
.z80_mreq_n(dut.z80_mreq_n),
.z80_iset(dut.z80_iset),
.cpu_ce(dut.cpu_ce),
.vdp_ce(dut.vdp_ce),
.pix_ce(dut.pix_ce),
.sp_ce(dut.sp_ce),
.vdp_regs(dut.vdp_regs),
.cram_out(dut.cram_out),
.vram_D(dut.vram_D),
.psg_out(dut.psg_out),
.psg_ext_out(dut.psg_ext_out),
.psg2_ext_out(dut.psg2_ext_out),
.psg_div_out(dut.psg_div_out),
.audio_control_out(dut.audio_control_out),
.audio_quiescent(dut.audio_quiescent),
.audio_phase_out(dut.audio_phase_out),
.audio_last_out(dut.audio_last_out),
.mapper_out(dut.mapper_out),
.mapper_history_out(dut.mapper_history_out),
.evolution_out(dut.evolution_out),
.storage_busy(dut.storage_busy),
.eeprom_present(dut.eeprom_present),
.eeprom_ext_out(dut.eeprom_ext_out),
.gun_out(dut.gun_out),
.paddle_out(dut.paddle_out),
.tap_out(dut.tap_out),
.sc_ram_size(dut.sc_ram_size),
.eeprom_out(dut.eeprom_out),
.wram_D(dut.wram_D),
.nvram_D(dut.nvram_D),
.systeme(dut.systeme),
.vdp2_regs(dut.vdp2_regs),
.cram2_out(dut.cram2_out),
.vram2_D(dut.vram2_D),
.psg2_out(dut.psg2_out),
.md_out(dut.md_out),
.gg_out(dut.gg_out),
.io_out(dut.io_out),
.video_state_out(dut.video_state_out),
.DDRAM_DOUT(dut.DDRAM_DOUT),
.DDRAM_DOUT_READY(dut.DDRAM_DOUT_READY),
.DDRAM_BUSY(dut.DDRAM_BUSY),
.fm_state_addr(alias_fm_state_addr),
.fm_state_read(alias_fm_state_read),
.fm_state_write(alias_fm_state_write),
.fm_state_wdata(alias_fm_state_wdata),
.fm_legacy_reset(alias_fm_legacy_reset),
.fm_initialization_run(alias_fm_initialization_run),
.ss_freeze(alias_ss_freeze),
.ss_cpu_prepare(alias_ss_cpu_prepare),
.z80_replay_t2(alias_z80_replay_t2),
.clock_phase_in(alias_clock_phase_in),
.clock_phase_set(alias_clock_phase_set),
.bg_in(alias_bg_in),
.bg2_in(alias_bg2_in),
.bg_valid(alias_bg_valid),
.sprite_in(alias_sprite_in),
.sprite2_in(alias_sprite2_in),
.sprite_valid(alias_sprite_valid),
.z80_restart_dir(alias_z80_restart_dir),
.z80_restart_valid(alias_z80_restart_valid),
.z80_nmi_dir(alias_z80_nmi_dir),
.z80_nmi_valid(alias_z80_nmi_valid),
.z80_nmi_hold(alias_z80_nmi_hold),
.z80_dir(alias_z80_dir),
.z80_set(alias_z80_set),
.vdp_regs_in(alias_vdp_regs_in),
.vdp_regs_set(alias_vdp_regs_set),
.cram_A(alias_cram_A),
.cram_D(alias_cram_D),
.cram_wr(alias_cram_wr),
.vram_en(alias_vram_en),
.vram_A(alias_vram_A),
.vram_WE(alias_vram_WE),
.vram_WA(alias_vram_WA),
.vram_WD(alias_vram_WD),
.psg_in(alias_psg_in),
.psg_set(alias_psg_set),
.psg_ext_in(alias_psg_ext_in),
.psg2_ext_in(alias_psg2_ext_in),
.psg_div_in(alias_psg_div_in),
.audio_control_in(alias_audio_control_in),
.audio_last_in(alias_audio_last_in),
.audio_last_valid(alias_audio_last_valid),
.audio_phase_in(alias_audio_phase_in),
.audio_ext_set(alias_audio_ext_set),
.audio_phase_set(alias_audio_phase_set),
.audio_pending_tick(alias_audio_pending_tick),
.mapper_history_in(alias_mapper_history_in),
.mapper_in(alias_mapper_in),
.mapper_set(alias_mapper_set),
.evolution_in(alias_evolution_in),
.evolution_set(alias_evolution_set),
.ss_busy(alias_ss_busy),
.ss_capture_progress(alias_ss_capture_progress),
.eeprom_ext_in(alias_eeprom_ext_in),
.eeprom_full(alias_eeprom_full),
.nvram_refill(alias_nvram_refill),
.gun_in(alias_gun_in),
.gun_set(alias_gun_set),
.gun_valid(alias_gun_valid),
.paddle_in(alias_paddle_in),
.paddle_set(alias_paddle_set),
.paddle_valid(alias_paddle_valid),
.tap_in(alias_tap_in),
.tap_set(alias_tap_set),
.tap_valid(alias_tap_valid),
.sc_ram_restored(alias_sc_ram_restored),
.eeprom_in(alias_eeprom_in),
.eeprom_set(alias_eeprom_set),
.wram_A(alias_wram_A),
.wram_WE(alias_wram_WE),
.wram_WA(alias_wram_WA),
.wram_WD(alias_wram_WD),
.nvram_A(alias_nvram_A),
.nvram_WE(alias_nvram_WE),
.nvram_WA(alias_nvram_WA),
.nvram_WD(alias_nvram_WD),
.vdp2_regs_in(alias_vdp2_regs_in),
.vdp2_regs_set(alias_vdp2_regs_set),
.cram2_A(alias_cram2_A),
.cram2_D(alias_cram2_D),
.cram2_wr(alias_cram2_wr),
.vram2_en(alias_vram2_en),
.vram2_A(alias_vram2_A),
.vram2_WE(alias_vram2_WE),
.vram2_WA(alias_vram2_WA),
.vram2_WD(alias_vram2_WD),
.psg2_in(alias_psg2_in),
.psg2_set(alias_psg2_set),
.md_in(alias_md_in),
.md_set(alias_md_set),
.md_valid(alias_md_valid),
.gg_in(alias_gg_in),
.gg_set(alias_gg_set),
.io_in(alias_io_in),
.io_set(alias_io_set),
.video_state_in(alias_video_state_in),
.video_state_set(alias_video_state_set),
.DDRAM_ADDR(alias_DDRAM_ADDR),
.DDRAM_DIN(alias_DDRAM_DIN),
.DDRAM_BE(alias_DDRAM_BE),
.DDRAM_WE(alias_DDRAM_WE),
.DDRAM_RD(alias_DDRAM_RD),
.DDRAM_BURSTCNT(alias_DDRAM_BURSTCNT));
integer alias_cycles=0,alias_consumes=0,alias_inactive=0,alias_writes=0,alias_reads=0;
always @(posedge clk)begin
 alias_cycles++;
if(dut.fm_state_addr !== alias_fm_state_addr)$fatal(1,"ALIAS controller output fm_state_addr cycle%0d",alias_cycles);
if(dut.fm_state_read !== alias_fm_state_read)$fatal(1,"ALIAS controller output fm_state_read cycle%0d",alias_cycles);
if(dut.fm_state_write !== alias_fm_state_write)$fatal(1,"ALIAS controller output fm_state_write cycle%0d",alias_cycles);
if(dut.fm_state_wdata !== alias_fm_state_wdata)$fatal(1,"ALIAS controller output fm_state_wdata cycle%0d",alias_cycles);
if(dut.fm_legacy_reset !== alias_fm_legacy_reset)$fatal(1,"ALIAS controller output fm_legacy_reset cycle%0d",alias_cycles);
if(dut.fm_initialization_run !== alias_fm_initialization_run)$fatal(1,"ALIAS controller output fm_initialization_run cycle%0d",alias_cycles);
if(dut.ss_freeze !== alias_ss_freeze)$fatal(1,"ALIAS controller output ss_freeze cycle%0d",alias_cycles);
if(dut.ss_cpu_prepare !== alias_ss_cpu_prepare)$fatal(1,"ALIAS controller output ss_cpu_prepare cycle%0d",alias_cycles);
if(dut.z80_replay_t2 !== alias_z80_replay_t2)$fatal(1,"ALIAS controller output z80_replay_t2 cycle%0d",alias_cycles);
if(dut.clock_phase_in !== alias_clock_phase_in)$fatal(1,"ALIAS controller output clock_phase_in cycle%0d",alias_cycles);
if(dut.clock_phase_set !== alias_clock_phase_set)$fatal(1,"ALIAS controller output clock_phase_set cycle%0d",alias_cycles);
if(dut.bg_in !== alias_bg_in)$fatal(1,"ALIAS controller output bg_in cycle%0d",alias_cycles);
if(dut.bg2_in !== alias_bg2_in)$fatal(1,"ALIAS controller output bg2_in cycle%0d",alias_cycles);
if(dut.bg_valid !== alias_bg_valid)$fatal(1,"ALIAS controller output bg_valid cycle%0d",alias_cycles);
if(dut.sprite_in !== alias_sprite_in)$fatal(1,"ALIAS controller output sprite_in cycle%0d",alias_cycles);
if(dut.sprite2_in !== alias_sprite2_in)$fatal(1,"ALIAS controller output sprite2_in cycle%0d",alias_cycles);
if(dut.sprite_valid !== alias_sprite_valid)$fatal(1,"ALIAS controller output sprite_valid cycle%0d",alias_cycles);
if(dut.z80_restart_dir !== alias_z80_restart_dir)$fatal(1,"ALIAS controller output z80_restart_dir cycle%0d",alias_cycles);
if(dut.z80_restart_valid !== alias_z80_restart_valid)$fatal(1,"ALIAS controller output z80_restart_valid cycle%0d",alias_cycles);
if(dut.z80_nmi_dir !== alias_z80_nmi_dir)$fatal(1,"ALIAS controller output z80_nmi_dir cycle%0d",alias_cycles);
if(dut.z80_nmi_valid !== alias_z80_nmi_valid)$fatal(1,"ALIAS controller output z80_nmi_valid cycle%0d",alias_cycles);
if(dut.z80_nmi_hold !== alias_z80_nmi_hold)$fatal(1,"ALIAS controller output z80_nmi_hold cycle%0d",alias_cycles);
if(dut.z80_set !== alias_z80_set)$fatal(1,"ALIAS controller output z80_set cycle%0d",alias_cycles);
if(dut.vdp_regs_in !== alias_vdp_regs_in)$fatal(1,"ALIAS controller output vdp_regs_in cycle%0d",alias_cycles);
if(dut.vdp_regs_set !== alias_vdp_regs_set)$fatal(1,"ALIAS controller output vdp_regs_set cycle%0d",alias_cycles);
if(dut.cram_A !== alias_cram_A)$fatal(1,"ALIAS controller output cram_A cycle%0d",alias_cycles);
if(dut.cram_D !== alias_cram_D)$fatal(1,"ALIAS controller output cram_D cycle%0d",alias_cycles);
if(dut.cram_wr !== alias_cram_wr)$fatal(1,"ALIAS controller output cram_wr cycle%0d",alias_cycles);
if(dut.vram_en !== alias_vram_en)$fatal(1,"ALIAS controller output vram_en cycle%0d",alias_cycles);
if(dut.vram_A !== alias_vram_A)$fatal(1,"ALIAS controller output vram_A cycle%0d",alias_cycles);
if(dut.vram_WE !== alias_vram_WE)$fatal(1,"ALIAS controller output vram_WE cycle%0d",alias_cycles);
if(dut.vram_WA !== alias_vram_WA)$fatal(1,"ALIAS controller output vram_WA cycle%0d",alias_cycles);
if(dut.vram_WD !== alias_vram_WD)$fatal(1,"ALIAS controller output vram_WD cycle%0d",alias_cycles);
if(dut.psg_in !== alias_psg_in)$fatal(1,"ALIAS controller output psg_in cycle%0d",alias_cycles);
if(dut.psg_set !== alias_psg_set)$fatal(1,"ALIAS controller output psg_set cycle%0d",alias_cycles);
if(dut.psg_ext_in !== alias_psg_ext_in)$fatal(1,"ALIAS controller output psg_ext_in cycle%0d",alias_cycles);
if(dut.psg2_ext_in !== alias_psg2_ext_in)$fatal(1,"ALIAS controller output psg2_ext_in cycle%0d",alias_cycles);
if(dut.psg_div_in !== alias_psg_div_in)$fatal(1,"ALIAS controller output psg_div_in cycle%0d",alias_cycles);
if(dut.audio_control_in !== alias_audio_control_in)$fatal(1,"ALIAS controller output audio_control_in cycle%0d",alias_cycles);
if(dut.audio_last_in !== alias_audio_last_in)$fatal(1,"ALIAS controller output audio_last_in cycle%0d",alias_cycles);
if(dut.audio_last_valid !== alias_audio_last_valid)$fatal(1,"ALIAS controller output audio_last_valid cycle%0d",alias_cycles);
if(dut.audio_phase_in !== alias_audio_phase_in)$fatal(1,"ALIAS controller output audio_phase_in cycle%0d",alias_cycles);
if(dut.audio_ext_set !== alias_audio_ext_set)$fatal(1,"ALIAS controller output audio_ext_set cycle%0d",alias_cycles);
if(dut.audio_phase_set !== alias_audio_phase_set)$fatal(1,"ALIAS controller output audio_phase_set cycle%0d",alias_cycles);
if(dut.audio_pending_tick !== alias_audio_pending_tick)$fatal(1,"ALIAS controller output audio_pending_tick cycle%0d",alias_cycles);
if(dut.mapper_history_in !== alias_mapper_history_in)$fatal(1,"ALIAS controller output mapper_history_in cycle%0d",alias_cycles);
if(dut.mapper_in !== alias_mapper_in)$fatal(1,"ALIAS controller output mapper_in cycle%0d",alias_cycles);
if(dut.mapper_set !== alias_mapper_set)$fatal(1,"ALIAS controller output mapper_set cycle%0d",alias_cycles);
if(dut.evolution_in !== alias_evolution_in)$fatal(1,"ALIAS controller output evolution_in cycle%0d",alias_cycles);
if(dut.evolution_set !== alias_evolution_set)$fatal(1,"ALIAS controller output evolution_set cycle%0d",alias_cycles);
if(dut.ss_busy !== alias_ss_busy)$fatal(1,"ALIAS controller output ss_busy cycle%0d",alias_cycles);
if(dut.ss_capture_progress !== alias_ss_capture_progress)$fatal(1,"ALIAS controller output ss_capture_progress cycle%0d",alias_cycles);
if(dut.eeprom_ext_in !== alias_eeprom_ext_in)$fatal(1,"ALIAS controller output eeprom_ext_in cycle%0d",alias_cycles);
if(dut.eeprom_full !== alias_eeprom_full)$fatal(1,"ALIAS controller output eeprom_full cycle%0d",alias_cycles);
if(dut.nvram_refill !== alias_nvram_refill)$fatal(1,"ALIAS controller output nvram_refill cycle%0d",alias_cycles);
if(dut.gun_in !== alias_gun_in)$fatal(1,"ALIAS controller output gun_in cycle%0d",alias_cycles);
if(dut.gun_set !== alias_gun_set)$fatal(1,"ALIAS controller output gun_set cycle%0d",alias_cycles);
if(dut.gun_valid !== alias_gun_valid)$fatal(1,"ALIAS controller output gun_valid cycle%0d",alias_cycles);
if(dut.paddle_in !== alias_paddle_in)$fatal(1,"ALIAS controller output paddle_in cycle%0d",alias_cycles);
if(dut.paddle_set !== alias_paddle_set)$fatal(1,"ALIAS controller output paddle_set cycle%0d",alias_cycles);
if(dut.paddle_valid !== alias_paddle_valid)$fatal(1,"ALIAS controller output paddle_valid cycle%0d",alias_cycles);
if(dut.tap_in !== alias_tap_in)$fatal(1,"ALIAS controller output tap_in cycle%0d",alias_cycles);
if(dut.tap_set !== alias_tap_set)$fatal(1,"ALIAS controller output tap_set cycle%0d",alias_cycles);
if(dut.tap_valid !== alias_tap_valid)$fatal(1,"ALIAS controller output tap_valid cycle%0d",alias_cycles);
if(dut.sc_ram_restored !== alias_sc_ram_restored)$fatal(1,"ALIAS controller output sc_ram_restored cycle%0d",alias_cycles);
if(dut.eeprom_in !== alias_eeprom_in)$fatal(1,"ALIAS controller output eeprom_in cycle%0d",alias_cycles);
if(dut.eeprom_set !== alias_eeprom_set)$fatal(1,"ALIAS controller output eeprom_set cycle%0d",alias_cycles);
if(dut.wram_A !== alias_wram_A)$fatal(1,"ALIAS controller output wram_A cycle%0d",alias_cycles);
if(dut.wram_WE !== alias_wram_WE)$fatal(1,"ALIAS controller output wram_WE cycle%0d",alias_cycles);
if(dut.wram_WA !== alias_wram_WA)$fatal(1,"ALIAS controller output wram_WA cycle%0d",alias_cycles);
if(dut.wram_WD !== alias_wram_WD)$fatal(1,"ALIAS controller output wram_WD cycle%0d",alias_cycles);
if(dut.nvram_A !== alias_nvram_A)$fatal(1,"ALIAS controller output nvram_A cycle%0d",alias_cycles);
if(dut.nvram_WE !== alias_nvram_WE)$fatal(1,"ALIAS controller output nvram_WE cycle%0d",alias_cycles);
if(dut.nvram_WA !== alias_nvram_WA)$fatal(1,"ALIAS controller output nvram_WA cycle%0d",alias_cycles);
if(dut.nvram_WD !== alias_nvram_WD)$fatal(1,"ALIAS controller output nvram_WD cycle%0d",alias_cycles);
if(dut.vdp2_regs_in !== alias_vdp2_regs_in)$fatal(1,"ALIAS controller output vdp2_regs_in cycle%0d",alias_cycles);
if(dut.vdp2_regs_set !== alias_vdp2_regs_set)$fatal(1,"ALIAS controller output vdp2_regs_set cycle%0d",alias_cycles);
if(dut.cram2_A !== alias_cram2_A)$fatal(1,"ALIAS controller output cram2_A cycle%0d",alias_cycles);
if(dut.cram2_D !== alias_cram2_D)$fatal(1,"ALIAS controller output cram2_D cycle%0d",alias_cycles);
if(dut.cram2_wr !== alias_cram2_wr)$fatal(1,"ALIAS controller output cram2_wr cycle%0d",alias_cycles);
if(dut.vram2_en !== alias_vram2_en)$fatal(1,"ALIAS controller output vram2_en cycle%0d",alias_cycles);
if(dut.vram2_A !== alias_vram2_A)$fatal(1,"ALIAS controller output vram2_A cycle%0d",alias_cycles);
if(dut.vram2_WE !== alias_vram2_WE)$fatal(1,"ALIAS controller output vram2_WE cycle%0d",alias_cycles);
if(dut.vram2_WA !== alias_vram2_WA)$fatal(1,"ALIAS controller output vram2_WA cycle%0d",alias_cycles);
if(dut.vram2_WD !== alias_vram2_WD)$fatal(1,"ALIAS controller output vram2_WD cycle%0d",alias_cycles);
if(dut.psg2_in !== alias_psg2_in)$fatal(1,"ALIAS controller output psg2_in cycle%0d",alias_cycles);
if(dut.psg2_set !== alias_psg2_set)$fatal(1,"ALIAS controller output psg2_set cycle%0d",alias_cycles);
if(dut.md_in !== alias_md_in)$fatal(1,"ALIAS controller output md_in cycle%0d",alias_cycles);
if(dut.md_set !== alias_md_set)$fatal(1,"ALIAS controller output md_set cycle%0d",alias_cycles);
if(dut.md_valid !== alias_md_valid)$fatal(1,"ALIAS controller output md_valid cycle%0d",alias_cycles);
if(dut.gg_in !== alias_gg_in)$fatal(1,"ALIAS controller output gg_in cycle%0d",alias_cycles);
if(dut.gg_set !== alias_gg_set)$fatal(1,"ALIAS controller output gg_set cycle%0d",alias_cycles);
if(dut.io_in !== alias_io_in)$fatal(1,"ALIAS controller output io_in cycle%0d",alias_cycles);
if(dut.io_set !== alias_io_set)$fatal(1,"ALIAS controller output io_set cycle%0d",alias_cycles);
if(dut.video_state_in !== alias_video_state_in)$fatal(1,"ALIAS controller output video_state_in cycle%0d",alias_cycles);
if(dut.video_state_set !== alias_video_state_set)$fatal(1,"ALIAS controller output video_state_set cycle%0d",alias_cycles);
if(dut.DDRAM_ADDR !== alias_DDRAM_ADDR)$fatal(1,"ALIAS controller output DDRAM_ADDR cycle%0d",alias_cycles);
if(dut.DDRAM_DIN !== alias_DDRAM_DIN)$fatal(1,"ALIAS controller output DDRAM_DIN cycle%0d",alias_cycles);
if(dut.DDRAM_BE !== alias_DDRAM_BE)$fatal(1,"ALIAS controller output DDRAM_BE cycle%0d",alias_cycles);
if(dut.DDRAM_WE !== alias_DDRAM_WE)$fatal(1,"ALIAS controller output DDRAM_WE cycle%0d",alias_cycles);
if(dut.DDRAM_RD !== alias_DDRAM_RD)$fatal(1,"ALIAS controller output DDRAM_RD cycle%0d",alias_cycles);
if(dut.DDRAM_BURSTCNT !== alias_DDRAM_BURSTCNT)$fatal(1,"ALIAS controller output DDRAM_BURSTCNT cycle%0d",alias_cycles);
if(dut.z80_set)begin alias_consumes++;if(dut.z80_dir!==alias_z80_dir)$fatal(1,"ALIAS consumed DIR mismatch");end
else if(dut.z80_dir!==alias_z80_dir)alias_inactive++;
if(dut.DDRAM_WE&&!dut.DDRAM_BUSY)alias_writes++;
if(dut.DDRAM_RD&&!dut.DDRAM_BUSY)alias_reads++;
end
final $display("ALIAS MITER cycles%0d consumes%0d inactive%0d writes%0d reads%0d",alias_cycles,alias_consumes,alias_inactive,alias_writes,alias_reads);
wire[229:0]b_reg;wire[15:0]b_addr;wire[7:0]b_do;wire b_m1,b_mreq,b_halt,b_replay;wire[2:0]b_nmi;
T80s b_cpu(.CLK(clk),.RESET_n(reset_n),.CEN(!dut.ss_freeze||(dut.ss_cpu_prepare&&b_replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.OUT0(1'b0),.DI(8'h00),.DIR(dut.z80_dir),.DIRSet(dut.z80_set),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.NMIEnable(1'b1),.RestoreHold(dut.ss_freeze),.ReplayT2(dut.z80_replay_t2),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.REG(b_reg),.A(b_addr),.DO(b_do),.M1_n(b_m1),.MREQ_n(b_mreq),.HALT_n(b_halt),.NMIReplay(b_replay),.NMIState(b_nmi));
wire[229:0]a_reg;wire[15:0]a_addr;wire[7:0]a_do;wire a_m1,a_mreq,a_halt,a_replay;wire[2:0]a_nmi;
T80s a_cpu(.CLK(clk),.RESET_n(reset_n),.CEN(!alias_ctl.ss_freeze||(alias_ctl.ss_cpu_prepare&&a_replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.OUT0(1'b0),.DI(8'h00),.DIR(alias_ctl.z80_dir),.DIRSet(alias_ctl.z80_set),.NMIDIR(alias_ctl.z80_nmi_dir),.NMIValid(alias_ctl.z80_nmi_valid),.NMIHold(alias_ctl.z80_nmi_hold),.NMIEnable(1'b1),.RestoreHold(alias_ctl.ss_freeze),.ReplayT2(alias_ctl.z80_replay_t2),.RestartDIR(alias_ctl.z80_restart_dir),.RestartValid(alias_ctl.z80_restart_valid),.REG(a_reg),.A(a_addr),.DO(a_do),.M1_n(a_m1),.MREQ_n(a_mreq),.HALT_n(a_halt),.NMIReplay(a_replay),.NMIState(a_nmi));
always@(posedge clk)begin #1;if({a_reg,a_addr,a_do,a_m1,a_mreq,a_halt,a_replay,a_nmi}!=={b_reg,b_addr,b_do,b_m1,b_mreq,b_halt,b_replay,b_nmi})$fatal(1,"ALIAS real format CPU/RegDIR");end
endmodule
