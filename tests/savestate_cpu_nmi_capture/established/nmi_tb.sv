`timescale 1ns/1ps
module nmi_tb;
parameter EDGE=100000, WIDTH=0, SOURCE=0, PROGRAM=0, RUN=2, TARGET=360, BASE=300, SECOND=9999999, WIDTH2=0, SCHEDULE=0, INJECT=0;

parameter CASE=0; parameter OFFSET=0; parameter HOST_CHANGE=0;
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
savestates dut(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(),.mapper_history_out(18'h0ffff),.mapper_history_in(),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
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

reg mrst=0,joya_pause=1,joyb_pause=1;wire pause_n=systeme?1'b1:(joya_pause&joyb_pause);
wire effective_gg=(SOURCE==1);reg[6:0]link_pins=7'h7f;wire link_nmi;
wire nmi_n=(pause_n|effective_gg)&link_nmi;
wire[15:0]addr;wire[7:0]data,di,io_data;wire wr,mreq,iq,rd;
wire[12:0]nstate;wire old_nmi;
wire io_port=(addr[7:6]==0)&&(addr[0]||(effective_gg&&addr[5:3]==0));
wire io_wr=wr|iq|!io_port,io_rd=rd|iq|!io_port;
`include "io_instance.sv"
assign mapper_out=64'h0040000003020100;
assign evolution_out=160'd0;assign z80_mreq_n=mreq;
reg[7:0]ram[0:8191];integer writes_cpu=0,entries=0,stage=0,iteration=0;
always @(posedge clk)begin
 wram_D<=ram[wram_A[12:0]];
 if(wram_WE)ram[wram_WA[12:0]]<=wram_WD;
 if(!mreq&&!wr&&!ss_freeze&&addr[15:14]==3)begin
  ram[addr[12:0]]<=data;
  if(cpu_ce)begin writes_cpu=writes_cpu+1;$display("WRITE stage%0d iter%0d A=%h D=%h PC=%h SP=%h N=%h",stage,iteration,addr,data,z80_reg[79:64],z80_reg[63:48],nstate);end
 end
end
function[7:0]rom(input[15:0]a);
 case(a)
 // Known primary/alternate registers, I/R/IM and SP before timing starts.
  0:rom='hf3;1:rom='h31;2:rom='he0;3:rom='hdf;
  4:rom='haf;5:rom='h08;6:rom='haf;7:rom='h08;
  8:rom='h01;9:rom=0;10:rom=0;11:rom='h11;12:rom=0;13:rom=0;14:rom='h21;15:rom=0;16:rom=0;
  17:rom='hd9;18:rom='h01;19:rom=0;20:rom=0;21:rom='h11;22:rom=0;23:rom=0;24:rom='h21;25:rom=0;26:rom=0;27:rom='hd9;
  28:rom='hdd;29:rom='h21;30:rom=0;31:rom=0;32:rom='hfd;33:rom='h21;34:rom=0;35:rom=0;
  36:rom='hed;37:rom='h47;38:rom='hed;39:rom='h4f;
  40:rom='h32;41:rom=0;42:rom='hc1;43:rom='h32;44:rom=1;45:rom='hc1;46:rom='h32;47:rom=2;48:rom='hc1;
  49:rom='h21;50:rom=1;51:rom='hc1;
  52:rom='h3e;53:rom='h7f;54:rom=effective_gg?'hd3:0;55:rom=effective_gg?2:0;
  56:rom='hd3;57:rom='h7e;58:rom='hc3;59:rom=0;60:rom=1;
 // Handler: increment counter and store current loop progress; acknowledge GG.
  'h66:rom='hf5;'h67:rom='h3a;'h68:rom=0;'h69:rom='hc1;'h6a:rom='h3c;
  'h6b:rom='h32;'h6c:rom=0;'h6d:rom='hc1;'h6e:rom='h3a;'h6f:rom=1;'h70:rom='hc1;
  'h71:rom='h32;'h72:rom=2;'h73:rom='hc1;
  'h74:rom='h3e;'h75:rom='hff;'h76:rom=effective_gg?'hd3:0;'h77:rom=effective_gg?2:0;
  'h78:rom='h3e;'h79:rom='h7f;'h7a:rom=effective_gg?'hd3:0;'h7b:rom=effective_gg?2:0;
  'h7c:rom='hf1;'h7d:rom='hed;'h7e:rom='h45;
  'h100:rom=PROGRAM==1?'hfb:PROGRAM==2?'h76:PROGRAM==3?'hdd:'h34;
  'h101:rom=PROGRAM==3?'h21:PROGRAM==0?'hc3:'h34;
  'h102:rom=PROGRAM==3?0:PROGRAM==0?0:'hc3;
  'h103:rom=PROGRAM==3?0:PROGRAM==0?1:0;
  'h104:rom=PROGRAM==3?'h34:1;
  'h105:rom='hc3;'h106:rom=0;'h107:rom=1;
  default:rom=0;
 endcase
endfunction
assign di=!iq?io_data:addr[15:14]==3?ram[addr[12:0]]:rom(addr);
wire pix=!mrst||cycle%10==0;wire[8:0]y;
video beam(.clk(clk),.ce_pix(pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(),.vblank(vblank));
T80s #(.T2Write(0)) cpu(.RESET_n(mrst),.CLK(clk),.CEN(cpu_ce&&!ss_freeze),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(nmi_n),.BUSRQ_n(1'b1),.M1_n(z80_m1_n),.MREQ_n(mreq),.IORQ_n(iq),.RD_n(rd),.WR_n(wr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(addr),.DI(di),.DO(data),.REG(z80_reg),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset),.debug_nmi(nstate),.debug_old(old_nmi));
integer ready_cycle=0,requested=0,accepted=0,accepted_cycle=0;reg[12:0]saved_n;reg saved_old,saved_level;reg[229:0]saved_cpu;
integer enabled=0;reg trace_on=0;reg [12:0]last_n;reg last_level,last_old;
reg prev_m1=1;integer start_cycle=0;
always @(posedge clk)begin
 if(ready_cycle!=0&&cpu_ce&&!ss_freeze)begin
  enabled=enabled+1;
  if(enabled<=430)$display("STEP %0d A=%h D=%h DI=%h M1%b MREQ%b RD%b WR%b IQ%b N=%h CPU=%h",enabled,addr,data,di,z80_m1_n,mreq,rd,wr,iq,nstate,z80_reg);
 end
 if(ready_cycle!=0&&(nstate!==last_n||nmi_n!==last_level||old_nmi!==last_old)&&cycle<ready_cycle+1500)begin
  $display("NMI_TRACE cycle%0d relative%0d enable%0d M1%b MREQ%b input%b old%b state%h PC%h SP%h",cycle,cycle-ready_cycle,enabled,z80_m1_n,mreq,nmi_n,old_nmi,nstate,z80_reg[79:64],z80_reg[63:48]);
 end
 last_n=nstate;last_level=nmi_n;last_old=old_nmi;
 if(!iq&&!wr&&addr[7:0]=='h7e&&ready_cycle==0)begin ready_cycle=cycle;$display("READY cycle%0d",cycle);end
 if(mrst&&!z80_m1_n&&prev_m1&&addr=='h66)begin entries=entries+1;$display("VECTOR stage%0d iter%0d cycle%0d PC=%h SP=%h N=%h",stage,iteration,cycle,z80_reg[79:64],z80_reg[63:48],nstate);end
 prev_m1=z80_m1_n;
 if(dut.state==37&&cpu_ce&&!z80_m1_n&&!mreq&&z80_iset==0&&vblank&&x<256)begin
  accepted=accepted+1;
  $display("ACCEPT op%0d cycle%0d relative%0d NMI=%b Old=%b State=%h PC=%h SP=%h M1%0b MREQ%0b ISet%0d CPU=%h",accepted,cycle,cycle-ready_cycle,nmi_n,old_nmi,nstate,z80_reg[79:64],z80_reg[63:48],z80_m1_n,mreq,z80_iset,z80_reg);
  if(accepted==1)begin accepted_cycle=cycle;saved_n=nstate;saved_old=old_nmi;saved_level=nmi_n;saved_cpu=z80_reg;end
 end
 if(z80_set)begin
  $display("DIR_BEFORE iter%0d cycle%0d NMI=%b Old=%b State=%h PC=%h SP=%h",iteration,cycle,nmi_n,old_nmi,nstate,z80_reg[79:64],z80_reg[63:48]);
  #1;$display("DIR_AFTER iter%0d NMI=%b Old=%b State=%h PC=%h SP=%h",iteration,nmi_n,old_nmi,nstate,z80_reg[79:64],z80_reg[63:48]);
 end
end
task tick;begin @(negedge clk);#1;end endtask
task level(input bit active);begin if(SOURCE==0)joya_pause=!active;else link_pins[6]=!active;end endtask
task operation(input bit saving);begin
 force dut.op_cooldown=0;
 tick;if(saving)ss_save=1;else ss_load=1;
 $display("REQUEST save%0d cycle%0d NMI=%b Old=%b State=%h PC=%h",saving,cycle,nmi_n,old_nmi,nstate,z80_reg[79:64]);
 tick;ss_save=0;ss_load=0;wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
initial begin
 for(integer i=0;i<8192;i=i+1)ram[i]=0;
 for(integer i=0;i<12288;i=i+1)mem[i]=0;
 repeat(4)tick;reset_n=1;audio_quiescent=1;ss_game_id='hf1600010;
 while(!(vblank&&x<64))tick;mrst=1;start_cycle=cycle;
 wait(ready_cycle!=0);
 fork
  begin while(cycle<ready_cycle+TARGET+SECOND)tick;level(1);$display("SECOND_EDGE cycle%0d relative%0d",cycle,cycle-ready_cycle);if(WIDTH2>0)begin repeat(WIDTH2)tick;level(0);end end
  begin if(SCHEDULE==1)begin while(enabled<29)tick;repeat(3)tick;end else while(cycle<ready_cycle+TARGET+EDGE)tick;level(1);$display("EDGE cycle%0d relative%0d",cycle,cycle-ready_cycle);if(WIDTH>0)begin repeat(WIDTH)tick;level(0);end end
  begin while(cycle<ready_cycle+BASE)tick;if(RUN!=0)operation(1);else begin $display("REFERENCE_T cycle%0d",cycle);end end
 join_any
 // Wait for SAVE completion if the NMI branch completed first.
 if(RUN!=0)begin wait(accepted!=0);wait(!ss_busy);end
 if(RUN!=0)$writememh($sformatf("snapshot_s%0d_p%0d_e%0d_w%0d_r%0d_second%0d.hex",SOURCE,PROGRAM,EDGE,WIDTH,RUN,SECOND),mem);
 stage=1;while(enabled<430)tick;
 $display("SAVE_SUFFIX count=%0d signature=%0d entries=%0d savedState=%h savedOld=%b savedNMI=%b CPU=%h",ram['h100],ram['h102],entries,saved_n,saved_old,saved_level,saved_cpu);
 if(RUN==0||RUN==1)begin $display("PASS F16 reference/save-only source%0d program%0d edge%0d run%0d",SOURCE,PROGRAM,EDGE,RUN);$finish;end
 for(iteration=0;iteration<3;iteration=iteration+1)begin
  stage=2;level(0);repeat(120)tick;
  if(iteration==1)begin level(1);repeat(600)tick;level(0);repeat(600)tick;end
  if(iteration==2)begin level(1);repeat(600)tick;end
  $display("Q iter%0d count=%0d level=%b Old=%b State=%h",iteration,ram['h100],nmi_n,old_nmi,nstate);
  if(INJECT==1&&iteration==1)begin
   fork operation(0);begin wait(ss_freeze);repeat(30)tick;level(1);repeat(5)tick;level(0);$display("Q_PENDING_DURING_FREEZE N=%h",nstate);end join
  end else operation(0);
  stage=3;repeat(6000)tick;
  $display("LOAD_SUFFIX iter%0d count=%0d signature=%0d entries=%0d level=%b Old=%b State=%h PC=%h SP=%h",iteration,ram['h100],ram['h102],entries,nmi_n,old_nmi,nstate,z80_reg[79:64],z80_reg[63:48]);
 end
 $display("PASS F16 investigation source%0d program%0d edge%0d captured=%h",SOURCE,PROGRAM,EDGE,saved_n);$finish;
end
initial begin repeat(12000000)tick;$fatal(1,"watchdog");end
endmodule
