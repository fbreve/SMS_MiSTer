`timescale 1ns/1ps
module md_integration;
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
wire [45:0] md_out;
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
savestates dut(.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(cycle%13<3);end
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
reg iorst=0,padreset=1,refreset=1,holdref=0,wr=1;reg [7:0]addr=8'h3f,data=0;
wire th1,th2;wire [45:0] refstate;wire [5:0] pins1,pins2,refpins1,refpins2;reg [1:0]kind1=2,kind2=2;reg [3:0] buttons=15;
io localio(.clk(clk),.ce_cpu(1'b1),.WR_n(wr),.RD_n(1'b1),.A(addr),.D_in(data),.D_out(),.HL_out(),.vdp1_bank(),.vdp2_bank(),.vdp_cpu_bank(),.rom_bank(),.J1_tr_out(),.J1_th_out(th1),.J2_tr_out(),.J2_th_out(th2),.J1_up(1'b0),.J1_down(1'b0),.J1_left(1'b0),.J1_right(1'b0),.J1_tl(1'b0),.J1_tr(1'b0),.J1_th(1'b0),.j1_start(1'b0),.j1_coin(1'b0),.j1_a3(1'b0),.J2_up(1'b0),.J2_down(1'b0),.J2_left(1'b0),.J2_right(1'b0),.J2_tl(1'b0),.J2_tr(1'b0),.J2_th(1'b0),.j2_start(1'b0),.j2_coin(1'b0),.j2_a3(1'b0),.Pause(1'b0),.soft_reset(1'b0),.E0Type(2'b0),.E1Use(1'b0),.E2Use(1'b0),.E0(8'b0),.F2(8'b0),.F3(8'b0),.has_paddle(1'b0),.has_pedal(1'b0),.paddle(8'b0),.paddle2(8'b0),.pedal(8'b0),.palettemode(1'b0),.sc3000_en(1'b0),.sc_multicart_en(1'b0),.sc_megacart_en(1'b0),.sk1100_en(1'b0),.sc_multicart_page(),.sk1100_row_sel(),.sk1100_row_data(12'b0),.pal(1'b0),.gg(1'b0),.gg_link_en(1'b0),.gg_link_in(7'b0),.gg_link_out(),.gg_link_nmi_n(),.systeme(1'b0),.region(1'b0),.se_mapper_in(8'b0),.se_mapper_set(1'b0),.vdp_enables(2'b0),.psg_enables(2'b0),.gg_state_out(gg_out),.gg_state_in(gg_in),.gg_state_set(gg_set),.io_state_out(io_out),.io_state_in(io_in),.io_state_set(io_set),.mapper_evolution_force(1'b0),.evolution_menu_io(1'b0),.evolution_bank61(8'b0),.evolution_bank62(8'b0),.evolution_reg8c(8'b0),.evolution_regcd(8'b0),.evolution_reg63(8'b0),.evolution_reg88(8'b0),.evolution_reg8d(8'b0),.evolution_reg8e(8'b0),.evolution_reg8f(8'b0),.ss_freeze(ss_freeze),.RESET_n(iorst));
sega_controller pad1(.clk(clk),.reset(padreset),.controller_type(kind1),.sms_pins(6'h3f),.th(th1),.md_a(1'b0),.md_start(1'b0),.md_x(buttons[1]),.md_y(buttons[2]),.md_z(buttons[3]),.md_mode(buttons[0]),.pins(pins1),.ss_freeze(ss_freeze),.ss_set(md_set),.ss_valid(md_valid),.ss_in(md_in[22:0]),.ss_out(md_out[22:0]));
sega_controller pad1ref(.clk(clk),.reset(refreset),.controller_type(kind1),.sms_pins(6'h3f),.th(th1),.md_a(1'b0),.md_start(1'b0),.md_x(buttons[1]),.md_y(buttons[2]),.md_z(buttons[3]),.md_mode(buttons[0]),.pins(refpins1),.ss_freeze(holdref),.ss_set(1'b0),.ss_valid(md_valid),.ss_in(md_in[22:0]),.ss_out(refstate[22:0]));
sega_controller pad2(.clk(clk),.reset(padreset),.controller_type(kind2),.sms_pins(6'h3f),.th(th2),.md_a(1'b0),.md_start(1'b0),.md_x(buttons[1]),.md_y(buttons[2]),.md_z(buttons[3]),.md_mode(buttons[0]),.pins(pins2),.ss_freeze(ss_freeze),.ss_set(md_set),.ss_valid(md_valid),.ss_in(md_in[45:23]),.ss_out(md_out[45:23]));
sega_controller pad2ref(.clk(clk),.reset(refreset),.controller_type(kind2),.sms_pins(6'h3f),.th(th2),.md_a(1'b0),.md_start(1'b0),.md_x(buttons[1]),.md_y(buttons[2]),.md_z(buttons[3]),.md_mode(buttons[0]),.pins(refpins2),.ss_freeze(holdref),.ss_set(1'b0),.ss_valid(md_valid),.ss_in(md_in[45:23]),.ss_out(refstate[45:23]));
task put(input [7:0]d);begin data=d;wr=0;tick;wr=1;repeat(2)tick;end endtask
task check;begin if(md_out!==refstate||pins1!==refpins1||pins2!==refpins2)$fatal(1,"integrated replay k=%0d state=%h/%h pins=%b/%b %b/%b",k,md_out,refstate,pins1,refpins1,pins2,refpins2);end endtask
reg [45:0]saved;reg [127:0]savedgg;integer k,j,freeze_start,freeze_length;reg [45:0]frozen;
// Observe the actual freeze boundary, including its final active clock.
always @(posedge ss_freeze)begin #1;holdref=1;freeze_start=cycle;end
always @(negedge ss_freeze)begin freeze_length=cycle-freeze_start;end
always @(negedge ss_freeze)if(!dut.do_save)holdref=0;
initial begin
reset_n=0;repeat(4)tick;reset_n=1;iorst=1;padreset=0;refreset=0;
vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;video_state_out=22'h12345;
vdp_regs={8'h5a,128'd0};vdp2_regs={8'ha5,128'd0};
for(k=0;k<13;k=k+1)begin
 buttons=15;
 holdref=0;padreset=1;refreset=1;put(8'hff);padreset=0;refreset=0;
 // Set P1 to third rise, P2 to second rise; settle real IO TH outputs.
 repeat(3)begin put(8'h55);put(8'h77);end
 put(8'h55);put(8'hff); // P1 fourth, P2 first: reset and rebuild distinct phases below
 padreset=1;refreset=1;tick;padreset=0;refreset=0;put(8'h55);
 repeat(2)begin put(8'hff);put(8'h55);end
 put(8'h77); // P1 third rise high, P2 second-rise low
 repeat(37)tick;
 operation(1);saved=dut.md_snap;savedgg={mem['h1d],mem['h1c]};
 if(md_out[22:17]!==saved[22:17]||md_out[45:40]!==saved[45:40])$fatal(1,"save transport consumed phase");
 $display("SAVE case%0d frozen=%0d clocks captured P1=%h P2=%h",k,freeze_length,saved[22:0],saved[45:23]);
 if(mem['h1a][63:38]!=={24'h48430c,2'd3}||mem['h1e]!=={18'd0,saved})$fatal(1,"v3 storage");
 if(saved[19:17]!=3||saved[42:40]!=2||saved[16:0]==0||saved[39:23]==0)$fatal(1,"nontrivial setup %h",saved);
 if(savedgg!==gg_out)$fatal(1,"GG words changed");
 // Reference reached the same state through actual TH edges and was held at
 // the freeze boundary. It never loads any DUT snapshot or restored payload.
 if(refstate!==saved)$fatal(1,"natural reference capture mismatch");
 case(k)
 1:mem['h1a][63:22]=0;
 2:mem['h1a][63:38]={24'h484301,2'd0};
 3:mem['h1a][63:38]={24'h484302,2'd2};
 4:mem['h1a][63:38]={24'h48430d,2'd3};
 5:begin mem['h1a][63:40]=24'h48430b;mem['h1a][39:38]=2;end
 6:mem['h1e][63]=1;
 7:mem['h1e][16:0]=80540;
 8:mem['h1e][19:17]=5;
 9:begin mem[0][63:32]=16382;mem['he][63]=0;end
 12:mem['h1a][63:38]={24'h484303,2'd3}; // F08 v3
 10:mem['h1a][63:40]=24'h123456;
 endcase
 put(8'h55);repeat(80545)tick;put(8'hff);
 operation(0);
 if(freeze_length<=80540)$fatal(1,"real freeze not longer than timeout");
 // operation includes ten active tail clocks; account for them equally on reference.
 if(k==0||k==11||k==12)begin
 if(!md_valid)$fatal(1,"valid v3 rejected");
 if(md_out[19:17]!=3||md_out[42:40]!=2||pins1[3:0]!=0)$fatal(1,"saved phases collapsed %h",md_out);
 if(md_out[22:17]!==saved[22:17]||md_out[45:40]!==saved[45:40])$fatal(1,"port histories");
 // The independently held reference resumes on the same release clock.
 check;
 holdref=0;
 for(j=0;j<80548;j=j+1)begin buttons=j%16;tick;check;end
 end else begin
 if(md_valid)$fatal(1,"legacy/invalid state accepted");
 if(md_out[19:17]!=0||md_out[42:40]!=0||md_out[20]!==th1||md_out[43]!==th2)$fatal(1,"legacy phase/history");
 end
 if(k==0||k==3||k==11||k==12)if(gg_out!==savedgg)$fatal(1,"GG preservation");
 $display("PASS MD DDRAM case%0d freeze=%0d cycles P1=%h P2=%h",k,freeze_length,md_out[22:0],md_out[45:23]);
end
$display("PASS MD DDRAM both real-timeout pads / stalls / untagged / v1 / v2 / invalid / oldest64");$finish;
end
initial begin #500000000;$fatal(1,"watchdog");end
endmodule
