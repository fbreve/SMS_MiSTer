`timescale 1ns/1ps
module format_tb;
parameter STALL=0;
parameter CASE=0;
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
wire z80_m1_n;
wire z80_mreq_n;
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
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=STALL?3+cycle%7:3;readaddr<=DDRAM_ADDR;reads<=reads+1;end
 if(vdp_regs_set)begin seen1<=vdp_regs_in;restored<=1;end
 if(vdp2_regs_set)seen2<=vdp2_regs_in;
end
task tick;begin @(negedge clk);#1;end endtask
task operation(input bit saving);begin
 boundary;
 force dut.op_cooldown=0; // UI cooldown only; all transfer/restore FSM stages run normally
 tick;if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg mrst=0,wr=1,mreq=1,iq=1,rd=1,m1=1,perturb=0,peer_alt=0,save_peer=0;
reg[15:0]addr=0;reg[7:0]data=0;
always @(negedge clk)DDRAM_BUSY=STALL&&(DDRAM_RD||DDRAM_WE)&&cycle%13<7;
wire[159:0]ext0,ext1,ext2;wire[63:0]map0,map1,map2;
wire[23:0]pa0,pa1,pa2;wire[15:0]game0,game1,game2,prev0,prev1,prev2;
wire[7:0]mode0,mode1,mode2;wire launch0,launch1,launch2;
assign evolution_out=save_peer?ext2:ext0;assign mapper_out=save_peer?map2:map0;
assign z80_m1_n=m1;assign z80_mreq_n=mreq;
evolution_machine loaded(.clk(clk),.reset_n(mrst),.a(addr),.d(data),.mreq(mreq),.iorq(iq),.rd(rd),.wr(wr),.m1(m1),.set(evolution_set),.ein(evolution_in),.min(mapper_in),.extra(ext0),.mapped(map0),.physical(pa0),.game(game0),.previous(prev0),.mode(mode0),.launch(launch0));
evolution_machine reference(.clk(clk),.reset_n(mrst),.a(perturb?16'd0:addr),.d(data),.mreq(mreq|perturb),.iorq(iq|perturb),.rd(rd|perturb),.wr(wr|perturb),.m1(m1|perturb),.set(1'b0),.ein(160'd0),.min(64'd0),.extra(ext1),.mapped(map1),.physical(pa1),.game(game1),.previous(prev1),.mode(mode1),.launch(launch1));
wire[7:0]peer_data=peer_alt?((CASE==0||CASE==1)?8'h24:8'h02):data;
evolution_machine peer(.clk(clk),.reset_n(mrst),.a(perturb?16'd0:addr),.d(peer_data),.mreq(mreq|perturb),.iorq(iq|perturb),.rd(rd|perturb),.wr(wr|perturb),.m1(m1|perturb),.set(1'b0),.ein(160'd0),.min(64'd0),.extra(ext2),.mapped(map2),.physical(pa2),.game(game2),.previous(prev2),.mode(mode2),.launch(launch2));
integer captures=0,loads=0,pulses0=0,pulses1=0,comparisons=0;
reg check_save=0,check_future=0,record_future=0;integer trace_pos=0,trace_len=0;
wire[304:0]observed={ext0,map0,pa0,game0,prev0,launch0,pa0[23:16],16'd0};
reg[304:0]trace[0:2047];
always @(negedge clk)begin #2;
 if(check_save)equal_ref;
 if(check_future)begin
  if(record_future)begin equal_ref;trace[trace_pos]=observed;end
  else if(trace[trace_pos]!==observed)$fatal(1,"repeated future state sample%0d mismatch",trace_pos);
  trace_pos=trace_pos+1;comparisons=comparisons+1;
 end
end
reg[159:0]savedextra;reg[63:0]savedmap;reg[63:0]snapshot[0:12287];
always @(posedge clk)begin
 if(dut.state==41)begin captures=captures+1;if(z80_m1_n||z80_mreq_n||!vblank||x>=256)$fatal(1,"unaccepted boundary");end
 if(evolution_set)begin
  loads=loads+1;#1;
  if(ext0!==evolution_in||map0!==mapper_in)$fatal(1,"exact restore edge mismatch CASE%0d got%h expected%h",CASE,ext0,evolution_in);
 end
 if(launch0)pulses0=pulses0+1;if(launch1)pulses1=pulses1+1;
end
task idle;begin wr=1;mreq=1;iq=1;rd=1;m1=1;tick;end endtask
task boundary;begin addr=0;wr=1;iq=1;rd=0;mreq=0;m1=0;tick;end endtask
task outport(input[7:0]p,input[7:0]v);begin addr={8'd0,p};data=v;wr=0;iq=0;repeat(30)tick;idle;end endtask
task selectbank(input[15:0]v);begin outport('h61,v[7:0]);outport('h62,v[15:8]);end endtask
task fetch(input[15:0]a);begin addr=a;m1=0;mreq=0;rd=0;repeat(15)tick;idle;end endtask
task switchmode(input[7:0]v);begin addr='h3ffe;data=v;wr=0;mreq=0;repeat(30)tick;idle;fetch('h100);fetch('h200);repeat(3)tick;end endtask
task probe;begin addr='h8123;mreq=0;rd=0;repeat(3)tick;end endtask
task equal_ref;begin
 if(ext0!==ext1||map0!==map1||game0!==game1||prev0!==prev1||pa0!==pa1||launch0!==launch1)$fatal(1,"reference mismatch CASE%0d ext%h/%h Flash%h/%h",CASE,ext0,ext1,pa0,pa1);
 comparisons=comparisons+1;
end endtask
task suffix;begin
 case(CASE)
  2:begin selectbank('h4800);switchmode('h87);end
  3:switchmode('h87);
  4:begin selectbank('h4800);switchmode('h87);end
 endcase
 probe;
end endtask
integer formatcase,beforeloads,rejected=0,accepted=0;reg rejecting=0;reg[159:0]qext;reg[63:0]qmap;
always @(posedge clk)if(rejecting&&(mapper_set||evolution_set||z80_set||vdp_regs_set||vdp2_regs_set||io_set||gun_set||gg_set||md_set||tap_set||paddle_set||audio_ext_set||audio_phase_set||vram_WE||wram_WE||nvram_WE||vram2_WE||cram_wr||cram2_wr||psg_set||psg2_set))$fatal(1,"rejected snapshot performed restore write case%0d",formatcase);
initial begin
 repeat(4)tick;reset_n=1;mrst=1;audio_quiescent=1;vblank=1;x=0;ss_game_id='hf14000f0;perturb=1;
 selectbank('h2800);switchmode('h87);selectbank('h4800);switchmode('h87);operation(1);
 for(integer j=0;j<12288;j=j+1)snapshot[j]=mem[j];
 for(formatcase=0;formatcase<30;formatcase=formatcase+1)begin
  for(integer j=0;j<12288;j=j+1)mem[j]=snapshot[j];
  if(formatcase==1)mem['h1a][63:22]=0;
  if(formatcase>=2&&formatcase<=10)mem['h1a][63:38]={24'h4842ff+formatcase[23:0],formatcase==2?2'd0:formatcase==3?2'd2:2'd3};
  case(formatcase)
   11:mem['h1a][63:40]=24'h48430b;
   12:mem['h1a][39:38]=2;
   13:mem['h2d]=0;
   14:mem['h2d][31:0]=32'h45563131;
   15:mem['h2d][39:32]=56;
   16:mem['h2d][63]=1;
   17,18,19,20,21,22,23:mem['h2c][57+formatcase-17]=1;
   24:begin mem[0][63:32]=16382;mem['he][63]=0;end
   25:mem['h19][63:48]=0; // live Evolution cannot accept missing owner
   26:begin mem['h2a][18]=1;end // F13 independently normalizes; F14 remains valid
   27:begin mem['h2b]=0;end
   28:begin mem['h1a][63:38]={24'h484309,2'd3};mem['h2c]='1;end
   29:begin mem['h1a][63:38]={24'h484309,2'd3};mem['h2d]=64'h0000003945563130;end
  endcase
  selectbank(formatcase%2?'h9440:'h6000);switchmode('h87);outport('h8c,formatcase[7:0]);idle;
  qext=ext0;qmap=map0;beforeloads=loads;rejecting=(formatcase!=0&&formatcase!=26&&formatcase!=27);
  operation(0);
  if(rejecting)begin
   if(loads!=beforeloads||ext0!==qext||map0!==qmap)$fatal(1,"legacy/malformed changed runtime case%0d",formatcase);
   rejected=rejected+1;
  end else begin
   if(loads!=beforeloads+1||ext0!=={snapshot['h2c],snapshot['h1b],snapshot['h19][63:32]})$fatal(1,"valid v10 not restored case%0d",formatcase);
   if(formatcase>=26&&dut.mapper_history_in!==18'h0ffff)$fatal(1,"F13 fallback changed");
   accepted=accepted+1;
  end
  $display("PASS F14 format case%0d rejected=%0d loads=%0d",formatcase,rejecting,loads);rejecting=0;
 end
 $display("PASS F14 format cases30 rejected%0d accepted%0d, legacy/no-owner/bad-version/descriptor/all-padding fail before restore writes",rejected,accepted);$finish;
end
initial begin repeat(30000000)tick;$fatal(1,"format watchdog");end
endmodule
