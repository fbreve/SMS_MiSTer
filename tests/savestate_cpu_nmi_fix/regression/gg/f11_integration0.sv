`timescale 1ns/1ps
module gg_integration_tb;
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
reg storage_busy=0,eeprom_present=0;wire ss_busy,eeprom_full,nvram_refill;reg[127:0]eeprom_ext_out=0;wire[127:0]eeprom_ext_in;
reg [45:0] md_out = '0; wire [45:0] md_in; wire md_set,md_valid;
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
savestates dut(.z80_nmi(3'b001),.mapper_history_out(18'h0ffff),.mapper_history_in(),.gun_out(46'd0),.gun_in(),.gun_set(),.gun_valid(),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.sc_ram_size(2'd0),.sc_ram_restored(),.paddle_out(32'd0),.paddle_in(),.paddle_set(),.paddle_valid(),.tap_out(19'd0),.tap_in(),.tap_set(),.tap_valid(),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;end
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
reg rst1=0,rst2=0,gg_mode=1,sg_mode=0,sc_mode=0,protocol_run=0,refhold=0;
reg wr1=1,wr2=1,io_rd=1;reg [7:0]io_addr=0,io_din=0;reg [6:0]link=7'h7f;
wire [7:0]data1,data2;wire [6:0]pins1,pins2;wire nmi1,nmi2;wire [127:0]refgg;wire [31:0]refio;
io local1(.clk(clk),.ce_cpu(protocol_run && !ss_freeze && cpu_ce),.WR_n(wr1),.RD_n(io_rd),.A(io_addr),.D_in(io_din),.D_out(data1),.HL_out(),.vdp1_bank(),.vdp2_bank(),.vdp_cpu_bank(),.rom_bank(),.J1_tr_out(),.J1_th_out(),.J2_tr_out(),.J2_th_out(),.J1_up(1'b0),.J1_down(1'b0),.J1_left(1'b0),.J1_right(1'b0),.J1_tl(1'b0),.J1_tr(1'b0),.J1_th(1'b0),.j1_start(1'b0),.j1_coin(1'b0),.j1_a3(1'b0),.J2_up(1'b0),.J2_down(1'b0),.J2_left(1'b0),.J2_right(1'b0),.J2_tl(1'b0),.J2_tr(1'b0),.J2_th(1'b0),.j2_start(1'b0),.j2_coin(1'b0),.j2_a3(1'b0),.Pause(1'b0),.soft_reset(1'b0),.E0Type(2'b0),.E1Use(1'b0),.E2Use(1'b0),.E0(8'b0),.F2(8'b0),.F3(8'b0),.has_paddle(1'b0),.has_pedal(1'b0),.paddle(8'b0),.paddle2(8'b0),.pedal(8'b0),.palettemode(sg_mode),.sc3000_en(sc_mode),.sc_multicart_en(sc_mode),.sc_megacart_en(1'b0),.sk1100_en(sc_mode),.sc_multicart_page(),.sk1100_row_sel(),.sk1100_row_data(12'habc),.pal(1'b0),.gg(gg_mode),.gg_link_en(1'b1),.gg_link_in(link),.gg_link_out(pins1),.gg_link_nmi_n(nmi1),.systeme(systeme),.region(1'b0),.se_mapper_in(mapper_in[7:0]),.se_mapper_set(mapper_set),.vdp_enables(2'b0),.psg_enables(2'b0),.gg_state_out(gg_out),.gg_state_in(gg_in),.gg_state_set(gg_set),.io_state_out(io_out),.io_state_in(io_in),.io_state_set(io_set),.mapper_evolution_force(1'b0),.evolution_menu_io(1'b0),.evolution_bank61(8'b0),.evolution_bank62(8'b0),.evolution_reg8c(8'b0),.evolution_regcd(8'b0),.evolution_reg63(8'b0),.evolution_reg88(8'b0),.evolution_reg8d(8'b0),.evolution_reg8e(8'b0),.evolution_reg8f(8'b0),.ss_freeze(ss_freeze),.RESET_n(rst1));
io local2(.clk(clk),.ce_cpu(protocol_run && !ss_freeze && cpu_ce),.WR_n(wr2),.RD_n(io_rd),.A(io_addr),.D_in(io_din),.D_out(data2),.HL_out(),.vdp1_bank(),.vdp2_bank(),.vdp_cpu_bank(),.rom_bank(),.J1_tr_out(),.J1_th_out(),.J2_tr_out(),.J2_th_out(),.J1_up(1'b0),.J1_down(1'b0),.J1_left(1'b0),.J1_right(1'b0),.J1_tl(1'b0),.J1_tr(1'b0),.J1_th(1'b0),.j1_start(1'b0),.j1_coin(1'b0),.j1_a3(1'b0),.J2_up(1'b0),.J2_down(1'b0),.J2_left(1'b0),.J2_right(1'b0),.J2_tl(1'b0),.J2_tr(1'b0),.J2_th(1'b0),.j2_start(1'b0),.j2_coin(1'b0),.j2_a3(1'b0),.Pause(1'b0),.soft_reset(1'b0),.E0Type(2'b0),.E1Use(1'b0),.E2Use(1'b0),.E0(8'b0),.F2(8'b0),.F3(8'b0),.has_paddle(1'b0),.has_pedal(1'b0),.paddle(8'b0),.paddle2(8'b0),.pedal(8'b0),.palettemode(sg_mode),.sc3000_en(sc_mode),.sc_multicart_en(sc_mode),.sc_megacart_en(1'b0),.sk1100_en(sc_mode),.sc_multicart_page(),.sk1100_row_sel(),.sk1100_row_data(12'habc),.pal(1'b0),.gg(gg_mode),.gg_link_en(1'b1),.gg_link_in(link),.gg_link_out(pins2),.gg_link_nmi_n(nmi2),.systeme(systeme),.region(1'b0),.se_mapper_in(mapper_in[7:0]),.se_mapper_set(1'b0),.vdp_enables(2'b0),.psg_enables(2'b0),.gg_state_out(refgg),.gg_state_in(gg_in),.gg_state_set(1'b0),.io_state_out(refio),.io_state_in(io_in),.io_state_set(1'b0),.mapper_evolution_force(1'b0),.evolution_menu_io(1'b0),.evolution_bank61(8'b0),.evolution_bank62(8'b0),.evolution_reg8c(8'b0),.evolution_regcd(8'b0),.evolution_reg63(8'b0),.evolution_reg88(8'b0),.evolution_reg8d(8'b0),.evolution_reg8e(8'b0),.evolution_reg8f(8'b0),.ss_freeze(refhold || ss_freeze),.RESET_n(rst2));
task put(input [7:0]a,d,input bit both);begin io_addr=a;io_din=d;wr1=0;if(both)wr2=0;tick;wr1=1;wr2=1;tick;end endtask
task get(input [7:0]a);begin io_addr=a;io_rd=0;repeat(2)tick;if(data1!==data2)$fatal(1,"guest read mismatch port%h %h %h",a,data1,data2);io_rd=1;tick;end endtask
localparam [127:0] GG_RESET=128'h00001fe00003f8000000ffa07fff00ff;
reg [127:0]savedgg;reg [31:0]savedio;integer k;
initial begin
reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;
ss_game_id=32'h12345678;video_state_out=22'h12345;vdp_regs={8'h5a,128'd0};vdp2_regs={8'ha5,128'd0};
for(k=0;k<14;k=k+1)begin
 systeme=k==9;gg_mode=k<8||k>=12;sg_mode=k==10;sc_mode=k==11;
 protocol_run=0;refhold=0;rst1=0;rst2=0;io_rd=1;link=7'h7f;tick;rst1=1;rst2=1;tick;
 if(gg_mode)begin put(2,0,1);put(1,8'h35,1);put(2,8'h40,1);put(5,8'h38,1);put(3,8'ha6,1);put(3,8'h93,1);link=7'h1f;protocol_run=1;repeat(13000)tick;protocol_run=0;tick;end
 else if(sc_mode)begin put(8'hc2,8'h05,1);put(8'he0,8'h42,1);end
 else put(8'h3f,8'hf3,1);
 savedgg=gg_out;savedio=io_out;
 if(k==0&&(!savedgg[38]||!savedgg[66]||savedgg[83:82]==0||savedgg[31:24]!=8'h35||savedgg[7:0]!=8'h40))$fatal(1,"Nontrivial serial setup not reached");
 refhold=1;operation(1);
 if(mem['h1a][63:38]!=={24'h48430c,2'd3}||{mem['h1d],mem['h1c]}!==savedgg)$fatal(1,"extension save mismatch");
 case(k)
  1:mem['h1a][63:38]={24'h484301,2'd0}; // F07 v1
  2:mem['h1a][63:22]=0;
  3:mem['h1a][63:40]=24'h123456;
  4:mem['h1a][63:40]=24'h48430d;
  5:begin mem['h1a][63:40]=24'h48430b;mem['h1a][39:38]=1;end
  6:mem['h1d][63]=1; // reserved padding invalid
  13:mem['h1a][63:38]={24'h484303,2'd3}; // F08
  12:mem['h1a][63:38]={24'h484302,2'd2}; // F02 v2 retains GG
  7:begin mem[0][63:32]=32'd16382;mem['he][63]=0;end
 endcase
 rst1=0;tick;rst1=1;tick;
 if(gg_mode)begin put(2,0,0);put(1,8'h6a,0);put(2,8'hff,0);put(3,8'h55,0);end
 else if(sc_mode)begin put(8'hc2,8'h01,0);put(8'he0,8'h11,0);end
 else put(8'h3f,0,0);
 operation(0);
 if(gg_out!==((k>=1&&k<=7)?GG_RESET:savedgg))$fatal(1,"GG restore case%0d actual%h expected%h",k,gg_out,((k>=1&&k<=7)?GG_RESET:savedgg));
 if(k!=7&&io_out[26:0]!==savedio[26:0])$fatal(1,"ordinary IO fields changed case%0d",k);
 if(k==0)begin
  refhold=0;get(1);get(2);get(3);get(5);get(4);
  protocol_run=1;
  repeat(250000)begin tick;if(gg_out!==refgg||pins1!==pins2||nmi1!==nmi2)$fatal(1,"integrated replay mismatch");end
  protocol_run=0;
 end
 if(!gg_mode&&(pins1!==7'h7f||nmi1!==1'b1))$fatal(1,"inactive GG affects non-GG outputs");
 $display("PASS integrated GG case%0d gg=%0d SystemE=%0d SG=%0d SC=%0d",k,gg_mode,systeme,sg_mode,sc_mode);
end
$display("PASS F02 DDRAM integration: 14 modern/legacy/invalid/non-GG cases plus mid-transfer replay");$finish;
end
initial begin #400000000;$fatal(1,"watchdog");end
endmodule
