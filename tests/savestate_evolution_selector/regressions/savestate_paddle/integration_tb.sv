`timescale 1ns/1ps
module paddle_integration;parameter STALL=0,ONLY=-1;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
wire ss_freeze;
reg vblank = '0;
reg [8:0] x = '0;
reg [229:0] z80_reg = '0;
wire [229:0] z80_dir;
wire z80_set;
reg z80_m1_n = '0;
reg z80_mreq_n = '0;
reg [1:0] z80_iset = '0;
reg cpu_ce = '0;
reg vdp_ce = '0;
reg pix_ce = '0;
reg sp_ce = '0;
reg [135:0] vdp_regs = '0;
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
reg [45:0] gun_out = '0;
wire [45:0] gun_in;
wire gun_set;
wire gun_valid;
wire [31:0] paddle_out;
wire [31:0] paddle_in;
wire paddle_set;
wire paddle_valid;
wire [18:0] tap_out;
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
reg [21:0] video_state_out = '0;
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
savestates dut(.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
reg[15:0]lfsr=16'h1ace;always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;lfsr={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?lfsr[3:0]<12:0);end
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

reg iorst=0,holdref=0,wr=1,rd=1,jp=0,joy=0,enabled=1,tap_enabled=0;reg[7:0]addr=8'h3f,data=8'hff,p0=8'ha3,p1=8'h5c,x0=8'h23,x1=8'hdc;
wire[18:0]reftap;wire[7:0]routea,routeb,refroutea,refrouteb;wire th,th2,refth,refth2;wire[7:0]guest,refguest;wire[9:0]pins,refpins;wire[31:0]refstate;

io iodut(.clk(clk),.ce_cpu(1'b1),.WR_n(wr),.RD_n(rd),.A(addr),.D_in(data),.D_out(guest),.HL_out(),.vdp1_bank(),.vdp2_bank(),.vdp_cpu_bank(),.rom_bank(),.J1_tr_out(),.J1_th_out(th),.J2_tr_out(),.J2_th_out(th2),.J1_up(routea[3]),.J1_down(routea[2]),.J1_left(routea[1]),.J1_right(routea[0]),.J1_tl(routea[4]),.J1_tr(routea[5]),.J1_th(1'd0),.j1_start(1'd0),.j1_coin(1'd0),.j1_a3(1'd0),.J2_up(routeb[3]),.J2_down(routeb[2]),.J2_left(routeb[1]),.J2_right(routeb[0]),.J2_tl(routeb[4]),.J2_tr(routeb[5]),.J2_th(1'd0),.j2_start(1'd0),.j2_coin(1'd0),.j2_a3(1'd0),.Pause(1'd0),.soft_reset(1'd0),.E0Type(2'd0),.E1Use(1'd0),.E2Use(1'd0),.E0(8'd0),.F2(8'd0),.F3(8'd0),.has_paddle(1'd0),.has_pedal(1'd0),.paddle(8'd0),.paddle2(8'd0),.pedal(8'd0),.palettemode(1'd0),.sc3000_en(1'd0),.sc_multicart_en(1'd0),.sc_megacart_en(1'd0),.sk1100_en(1'd0),.sc_multicart_page(),.sk1100_row_sel(),.sk1100_row_data(12'd0),.pal(1'd0),.gg(1'd0),.gg_link_en(1'd0),.gg_link_in(7'd0),.gg_link_out(),.gg_link_nmi_n(),.systeme(1'd0),.region(1'd0),.se_mapper_in(8'd0),.se_mapper_set(1'd0),.vdp_enables(2'd0),.psg_enables(2'd0),.gg_state_out(gg_out),.gg_state_in(gg_in),.gg_state_set(gg_set),.io_state_out(io_out),.io_state_in(io_in),.io_state_set(io_set),.mapper_evolution_force(1'd0),.evolution_menu_io(1'd0),.evolution_bank61(8'd0),.evolution_bank62(8'd0),.evolution_reg8c(8'd0),.evolution_regcd(8'd0),.evolution_reg63(8'd0),.evolution_reg88(8'd0),.evolution_reg8d(8'd0),.evolution_reg8e(8'd0),.evolution_reg8f(8'd0),.ss_freeze(ss_freeze),.RESET_n(iorst));

io ioref(.clk(clk),.ce_cpu(1'b1),.WR_n(wr),.RD_n(rd),.A(addr),.D_in(data),.D_out(refguest),.HL_out(),.vdp1_bank(),.vdp2_bank(),.vdp_cpu_bank(),.rom_bank(),.J1_tr_out(),.J1_th_out(refth),.J2_tr_out(),.J2_th_out(refth2),.J1_up(refroutea[3]),.J1_down(refroutea[2]),.J1_left(refroutea[1]),.J1_right(refroutea[0]),.J1_tl(refroutea[4]),.J1_tr(refroutea[5]),.J1_th(1'd0),.j1_start(1'd0),.j1_coin(1'd0),.j1_a3(1'd0),.J2_up(refrouteb[3]),.J2_down(refrouteb[2]),.J2_left(refrouteb[1]),.J2_right(refrouteb[0]),.J2_tl(refrouteb[4]),.J2_tr(refrouteb[5]),.J2_th(1'd0),.j2_start(1'd0),.j2_coin(1'd0),.j2_a3(1'd0),.Pause(1'd0),.soft_reset(1'd0),.E0Type(2'd0),.E1Use(1'd0),.E2Use(1'd0),.E0(8'd0),.F2(8'd0),.F3(8'd0),.has_paddle(1'd0),.has_pedal(1'd0),.paddle(8'd0),.paddle2(8'd0),.pedal(8'd0),.palettemode(1'd0),.sc3000_en(1'd0),.sc_multicart_en(1'd0),.sc_megacart_en(1'd0),.sk1100_en(1'd0),.sc_multicart_page(),.sk1100_row_sel(),.sk1100_row_data(12'd0),.pal(1'd0),.gg(1'd0),.gg_link_en(1'd0),.gg_link_in(7'd0),.gg_link_out(),.gg_link_nmi_n(),.systeme(1'd0),.region(1'd0),.se_mapper_in(8'd0),.se_mapper_set(1'd0),.vdp_enables(2'd0),.psg_enables(2'd0),.gg_state_out(),.gg_state_in(gg_in),.gg_state_set(1'b0),.io_state_out(),.io_state_in(io_out),.io_state_set(1'b0),.mapper_evolution_force(1'd0),.evolution_menu_io(1'd0),.evolution_bank61(8'd0),.evolution_bank62(8'd0),.evolution_reg8c(8'd0),.evolution_regcd(8'd0),.evolution_reg63(8'd0),.evolution_reg88(8'd0),.evolution_reg8d(8'd0),.evolution_reg8e(8'd0),.evolution_reg8f(8'd0),.ss_freeze(holdref),.RESET_n(iorst));
paddle_fixture localdut(clk,1'b0,ss_freeze,paddle_set,paddle_valid,jp,joy,paddle_in,p0,p1,x0,x1,th,th2,paddle_out,pins);
paddle_fixture localref(clk,holdref,1'b0,1'b0,1'b0,jp,joy,32'd0,p0,p1,x0,x1,refth,refth2,refstate,refpins);
routing_fixture routedut(.clk_sys(clk),.reset_active(1'b0),.ce_cpu(cpu_ce),.ss_freeze(ss_freeze),.ss_set(tap_set),.ss_valid(tap_valid),.hold(1'b0),.th(th),.enabled(tap_enabled),.raw_serial(1'b0),.ss_in(tap_in),.players(tap_enabled?32'h77331100:32'd0),.physical(7'h7f),.pause_combo(1'b0),.paddle_pins(pins),.paddle_enabled(enabled),.joya(routea),.joyb(routeb),.state(tap_out),.joyser(),.USER_OUT());
routing_fixture routeref(.clk_sys(clk),.reset_active(1'b0),.ce_cpu(cpu_ce),.ss_freeze(holdref),.ss_set(1'b0),.ss_valid(tap_valid),.hold(1'b0),.th(refth),.enabled(tap_enabled),.raw_serial(1'b0),.ss_in(tap_in),.players(tap_enabled?32'h77331100:32'd0),.physical(7'h7f),.pause_combo(1'b0),.paddle_pins(refpins),.paddle_enabled(enabled),.joya(refroutea),.joyb(refrouteb),.state(reftap),.joyser(),.USER_OUT());
integer k,j,start,saveclocks,loadclocks;reg[31:0]saved;reg[63:0]oldvideo;reg exact;reg[11:0]normalize_counter;
always @(posedge ss_freeze)begin #1;holdref=1;start=cycle;end
always @(negedge ss_freeze)begin if(dut.do_save)saveclocks=cycle-start;else begin loadclocks=cycle-start;holdref=0;end end
task put(input[7:0]v);begin addr=8'h3f;data=v;wr=0;tick;wr=1;repeat(3)tick;if(tap_enabled)repeat(2)begin wait(cpu_ce);tick;end end endtask
task check;begin if(tap_out!==reftap||paddle_out!==refstate||pins!==refpins||guest!==refguest||th!==refth||th2!==refth2)$fatal(1,"DDR k%0d state%h/%h pins%h/%h guest%h/%h",k,paddle_out,refstate,pins,refpins,guest,refguest);end endtask
always @(posedge clk)if(paddle_set&&!paddle_valid)begin #1;if(paddle_out!=={12'd0,th2,th,2'd0,(joy?{~x1[7],x1[6:0]}:p1),(joy?{~x0[7],x0[6:0]}:p0)})$fatal(1,"legacy normalization at strobe k%0d %h",k,paddle_out);end
initial begin
reset_n=0;repeat(4)tick;reset_n=1;iorst=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;vdp_regs={8'h5a,128'd0};video_state_out=22'h12345;
for(k=0;k<(ONLY>=22?26:22);k=k+1)begin
if(ONLY>=0&&ONLY!=k)continue;
holdref=0;tap_enabled=k>=22;enabled=k!=21;
routedut.tmr=57001;routeref.tmr=57001;routedut.old_th=1;routeref.old_th=1;jp=0;joy=k%2;localdut.cnt_en16khz=17;localref.cnt_en16khz=17;
put(8'hff);put(8'h55);put(8'hff);put(8'h55);p0=8'ha3;p1=8'h5c;x0=8'h23;x1=8'hdc;
put(8'hff);put(8'h55);
jp=(k==1||k==2||k==19||k==23||k==24);if(jp)begin while(paddle_out[31:20]!=0)tick;tick;if(k==2||k==24)begin while(paddle_out[31:20]!=0)tick;tick;end end
repeat(139)tick;
if(k==20)begin force dut.op_cooldown=0;ss_save=1;tick;ss_save=0;wait(cpu_ce);addr=8'h3f;data=8'hff;wr=0;tick;wr=1;wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;end else operation(1);saved=dut.paddle_snap;oldvideo=mem['h1a];
if(k==20&&saved[18]===th)$fatal(1,"pending edge missing");
if(saved!==refstate||mem['h27]!=={saved,32'h50414437}||mem['h1a][63:38]!=={24'h484309,2'd3})$fatal(1,"capture/format mismatch");
// Existing slots are canaries, including v6 Master Tap and v3 MD6.
if(mem['h26]!=={13'd0,dut.tap_snap,32'h4d544150}||mem['h1e]!=={18'd0,md_out}||mem['h25]!==64'h53435235||mem['h1f]!==64'h0000000145455058)$fatal(1,"old payload moved");
exact=k<3||k==18||k==19||k==20||k==21||k>=22;
case(k)
25:mem['h1a][63:40]=24'h484307;
3:mem['h1a][63:22]=0;
4:mem['h1a][63:38]={24'h484301,2'd0};
5:mem['h1a][63:38]={24'h484302,2'd2};
6:mem['h1a][63:38]={24'h484303,2'd3};
7:mem['h1a][63:38]={24'h484304,2'd3};
8:mem['h1a][63:38]={24'h484305,2'd3};
9:mem['h1a][63:38]={24'h484306,2'd3};
10:mem['h1a][63:40]=24'h48430a;
11:mem['h1a][63:40]=24'h123456;
12:mem['h1a][39:38]=2;
13:mem['h27][31:0]=0;
14:mem['h27][63:52]=3356;
15:begin mem[0][63:32]=16382;mem['he][63]=0;end
16:mem['h1a][63:40]=24'h484300;
17:mem['h27][63:52]=4095;
endcase
// The reference remains held without loading paddle fields. Its IO writes are frozen too.
p0=8'h76;p1=8'h29;x0=8'hfa;x1=8'h03;repeat(8)begin put(8'hff);put(8'h55);end
repeat(8000)tick;p0=8'he1;p1=8'hb4;x0=8'h96;x1=8'h78;
operation(0);
if(loadclocks<900000)$fatal(1,"transport too short");
if(exact)begin
check;if(k==21&&routea!==8'hff)$fatal(1,"disabled routing altered ordinary pins");for(j=0;j<6800;j=j+1)begin if(j==0||j==1||j==3||j==45)put(j%2?8'hff:8'h55);addr=j%2?8'hdc:8'hdd;rd=0;tick;check;rd=1;end
if(k==18||k==19)begin operation(1);repeat(9)put(8'hff);operation(0);check;end
end else if(paddle_valid)$fatal(1,"invalid/legacy treated as exact k%0d",k);
if(k==21)begin iorst=0;repeat(5)tick;check;iorst=1;repeat(5)tick;check;enabled=1;repeat(5)tick;check;end
if(k>=22)$display("PASS combined Tap/Paddle case%0d JP%0d savedTap%h liveTap%h referenceTap%h",k,jp,dut.tap_snap,tap_out,reftap);
$display("PASS Paddle DDR case%0d stalls%0d JP%0d joystick%0d saved%h saveClocks%0d loadClocks%0d exact%0d",k,STALL,jp,joy,saved,saveclocks,loadclocks,exact);
end
$display("PASS Paddle DDRAM COMPLETE");$finish;
end
initial begin #(64'd2500000000);$fatal(1,"watchdog k%0d state%0d",k,dut.state);end
endmodule
