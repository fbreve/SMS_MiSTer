`timescale 1ns/1ps
module cpu_tb;
reg host_turbo=0;
parameter CASE=0; parameter OFFSET=0;
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
wire [63:0] mapper_out;
wire [63:0] mapper_in;
wire mapper_set;
wire [159:0] evolution_out;
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
savestates dut(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(),.mapper_history_out(18'h0ffff),.mapper_history_in(),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=cycle%(host_turbo?10:15)==0;cycle=cycle+1;end
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
 tick;if(saving)ss_save=1;else ss_load=1;$display("OP_REQUEST saving%0d cycle%0d phase=%b A=%h M1=%b MREQ=%b RD=%b WR=%b",saving,cycle,phase,addr,z80_m1_n,mreq,rd,wr);tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg mrst=0;wire[15:0]addr;wire[7:0]data,di;wire wr,mreq,iq,rd;
wire[159:0]extra;wire[23:0]physical;wire[15:0]game,previous;wire[7:0]mode;wire launch;wire[5:0]phase;
assign evolution_out=extra;assign z80_mreq_n=mreq;
evolution_machine mapped(.clk(clk),.reset_n(mrst),.a(addr),.d(data),.mreq(mreq),.iorq(iq),.rd(rd),.wr(wr),.m1(z80_m1_n),.set(evolution_set),.ein(evolution_in),.min(mapper_in),.extra(extra),.mapped(mapper_out),.physical(physical),.game(game),.previous(previous),.mode(mode),.launch(launch),.phase(phase));
function[7:0]rom(input[23:0]a);case(a[15:0])
0:rom=8'h3e;
1:rom=8'h0;
2:rom=8'hd3;
3:rom=8'h61;
4:rom=8'h3e;
5:rom=8'h28;
6:rom=8'hd3;
7:rom=8'h62;
8:rom=8'h3e;
9:rom=8'h87;
10:rom=8'h32;
11:rom=8'hfe;
12:rom=8'h3f;
13:rom=8'hc3;
14:rom=8'h20;
15:rom=8'h0;
16:rom=8'h3e;
17:rom=8'h0;
18:rom=8'hd3;
19:rom=8'h61;
20:rom=8'h3e;
21:rom=8'h48;
22:rom=8'hd3;
23:rom=8'h62;
24:rom=8'h3e;
25:rom=8'h87;
26:rom=8'h32;
27:rom=8'hfe;
28:rom=8'h3f;
29:rom=8'hc3;
30:rom=8'h20;
31:rom=8'h0;
32:rom=8'h3a;
33:rom=8'h23;
34:rom=8'h81;
35:rom=8'hd3;
36:rom=8'h20;
37:rom=8'hc3;
38:rom=8'h20;
39:rom=8'h0;
default:rom=a[23:16];endcase endfunction
assign di=rom(physical);
wire pix=cycle%10==0;wire[8:0]y;
video beam(.clk(clk),.ce_pix(pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(),.vblank(vblank));
T80s #(.T2Write(0)) cpu(.RESET_n(mrst),.CLK(clk),.CEN((cpu_ce&&!ss_freeze)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(z80_m1_n),.MREQ_n(mreq),.IORQ_n(iq),.RD_n(rd),.WR_n(wr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(addr),.DI(di),.DO(data),.REG(z80_reg),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
reg accepted_saved_armed;
integer accepts=0,guest_reads=0;integer accepted_cycle=0;reg[5:0]accepted_phase;reg[159:0]savedextra;reg[63:0]savedmap;reg[7:0]guest_data=0;integer stage=0;reg first_before=0,first_after=0;
always @(posedge clk)begin
 if(cpu_ce&&!ss_freeze&&mrst&&!first_before)$display("CE A=%h BUS=%b%b%b%b%b phase=%b extra=%h map=%h Flash=%h DI=%h CPU=%h",addr,z80_m1_n,mreq,iq,rd,wr,phase,evolution_out,mapper_out,physical,di,z80_reg);
 if(evolution_set)begin #1;if(evolution_out!==evolution_in||mapper_out!==mapper_in)$fatal(1,"F14/mapper restore mismatch");$display("RESTORE exact F14=%h phase=%b",evolution_out[152:96],phase);end
 if(dut.state==37&&cpu_ce&&!z80_m1_n&&!z80_mreq_n&&z80_iset==0&&vblank&&x<256)begin accepts=accepts+1;accepted_cycle=cycle;accepted_phase=phase;$display("ACCEPT op%0d cycle%0d phase=%b A=%h M1=%b MREQ=%b RD=%b WR=%b CPU=%h",accepts,cycle,phase,addr,z80_m1_n,mreq,rd,wr,z80_reg);end
 if(!iq&&!wr&&addr[7:0]==8'h20&&!ss_freeze)begin
 guest_data<=data;guest_reads=guest_reads+1;
 if((stage==0&&data!==8'h28)||(stage==2&&data!==(accepted_saved_armed?8'h00:8'h28)))$fatal(1,"unexpected CPU data stage%0d data%h",stage,data);
 end
 if(!mreq&&!rd&&addr==16'h8123&&!ss_freeze)begin
  if(stage==0&&!first_before)begin first_before=1;$display("CPU READ before cycle%0d addr=%h Flash=%h DI=%h",cycle,addr,physical,di);end
  if(stage==2&&!first_after)begin first_after=1;$display("CPU READ restored cycle%0d addr=%h Flash=%h DI=%h",cycle,addr,physical,di);end
 end
end
initial begin
 repeat(4)tick;reset_n=1;audio_quiescent=1;ss_game_id='hf1400080;

 while(!(vblank&&x<64))tick;mrst=1;
 if(OFFSET<0)begin wait(!z80_m1_n&&!mreq&&addr==16'h000a);repeat(-OFFSET-1)tick;end
 else begin wait(!wr&&!mreq&&addr==16'h3ffe);repeat(OFFSET)tick;end
 $display("REQUEST cycle%0d offset%0d phase=%b A=%h M1=%b MREQ=%b WR=%b",cycle,OFFSET,phase,addr,z80_m1_n,mreq,wr);
 if(CASE==1)begin wait(guest_data==8'h28);$display("PASS F15 uninterrupted real T80 Flash288123 DI28");$finish;end
 operation(1);accepted_saved_armed=accepted_phase[4];savedextra={mem['h2c],mem['h1b],mem['h19][63:32]};savedmap=mem['hf];
 $display("V10 map=%h extra=%h cpu=%h_%h_%h_%h",savedmap,savedextra,mem[5],mem[4],mem[3],mem[2]);
 wait(guest_data==8'h28);$display("SAVE_ONLY PASS reference CPU8123 Flash288123 DI28 acceptedPhase=%b",accepted_phase);
 for(integer iteration=0;iteration<(OFFSET==0?3:1);iteration=iteration+1)begin
  stage=1;repeat(300+iteration*71)tick;operation(0);stage=2;first_after=0;
  wait(first_after);repeat(200)tick;
  $display("REPLAY iteration%0d phase=%b game=%h mode=%h physical=%h guest=%h",iteration,phase,game,mode,physical,guest_data);
 end
 if(accepted_saved_armed)begin if(mode!==0||game!==0)$fatal(1,"expected lost pending commit");end
 else if(mode!==8'h87||game!==16'h2800)$fatal(1,"completed control failed");
 $display("PASS F15 real T80 OFFSET%0d vulnerable=%0d accepted=%0d",OFFSET,accepted_saved_armed,accepts);$finish;
end
initial begin repeat(10000000)tick;$fatal(1,"CPU watchdog");end
endmodule
