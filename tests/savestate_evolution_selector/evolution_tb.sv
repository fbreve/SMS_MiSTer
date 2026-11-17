`timescale 1ns/1ps
module evolution_tb;
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
wire [95:0] evolution_out;
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
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=3;readaddr<=DDRAM_ADDR;reads<=reads+1;end
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
reg mrst=0,wr=1,mreq=1,iq=1,rd=1,m1=1,perturb=0,peer_alt=0;
reg[15:0]addr=0;reg[7:0]data=0;
wire[159:0]ext0,ext1,ext2;wire[63:0]map1,map2;
wire[23:0]pa0,pa1,pa2;wire[15:0]game0,game1,game2,prev0,prev1,prev2;
wire[7:0]mode0,mode1,mode2;wire launch0,launch1,launch2;
assign evolution_out=ext0[95:0];
assign z80_m1_n=m1;assign z80_mreq_n=mreq;
evolution_machine loaded(.clk(clk),.reset_n(mrst),.a(addr),.d(data),.mreq(mreq),.iorq(iq),.rd(rd),.wr(wr),.m1(m1),.set(evolution_set),.ein(evolution_in),.min(mapper_in),.extra(ext0),.mapped(mapper_out),.physical(pa0),.game(game0),.previous(prev0),.mode(mode0),.launch(launch0));
evolution_machine reference(.clk(clk),.reset_n(mrst),.a(perturb?16'd0:addr),.d(data),.mreq(mreq|perturb),.iorq(iq|perturb),.rd(rd|perturb),.wr(wr|perturb),.m1(m1|perturb),.set(1'b0),.ein(96'd0),.min(64'd0),.extra(ext1),.mapped(map1),.physical(pa1),.game(game1),.previous(prev1),.mode(mode1),.launch(launch1));
wire[7:0]peer_data=peer_alt ? ((CASE==0||CASE==1)?8'h24:8'h02) : data;
evolution_machine peer(.clk(clk),.reset_n(mrst),.a(perturb?16'd0:addr),.d(peer_data),.mreq(mreq|perturb),.iorq(iq|perturb),.rd(rd|perturb),.wr(wr|perturb),.m1(m1|perturb),.set(1'b0),.ein(96'd0),.min(64'd0),.extra(ext2),.mapped(map2),.physical(pa2),.game(game2),.previous(prev2),.mode(mode2),.launch(launch2));
integer captures=0,loads=0,pulses0=0,pulses1=0,comparisons=0;
reg check_save=0;
always @(negedge clk)if(check_save)begin #2;equal_ref;end
always @(posedge clk)begin
 if(dut.state==41)begin captures=captures+1;if(z80_m1_n||z80_mreq_n||!vblank||x>=256)$fatal(1,"unaccepted boundary");end
 if(evolution_set)begin
  loads=loads+1;
  #1;$display("RESTORE_EDGE CASE%0d cycle=%0d active=%h/%h previous=%h/%h Flash=%h/%h",CASE,cycle,game0,game1,prev0,prev1,pa0,pa1);
 end
 if(launch0)pulses0=pulses0+1;if(launch1)pulses1=pulses1+1;
end
task idle;begin wr=1;mreq=1;iq=1;rd=1;m1=1;tick;end endtask
task boundary;begin addr=0;wr=1;iq=1;rd=0;mreq=0;m1=0;tick;end endtask
task outport(input[7:0]p,input[7:0]v);begin
 addr={8'd0,p};data=v;wr=0;iq=0;repeat(30)tick;idle;
end endtask
task selectbank(input[15:0]v);begin outport('h61,v[7:0]);outport('h62,v[15:8]);end endtask
task fetch(input[15:0]a);begin addr=a;m1=0;mreq=0;rd=0;repeat(15)tick;idle;end endtask
task switchmode(input[7:0]v);begin
 addr='h3ffe;data=v;wr=0;mreq=0;repeat(30)tick;idle;
 fetch('h100);fetch('h200);repeat(3)tick;
end endtask
task probe;begin addr='h8123;mreq=0;rd=0;repeat(3)tick;end endtask
task equal_ref;begin
 if(ext0!==ext1||mapper_out!==map1||game0!==game1||prev0!==prev1||pa0!==pa1)$fatal(1,"save-only state changed CASE%0d",CASE);
 comparisons=comparisons+1;
end endtask
task suffix;begin
 case(CASE)
  2:begin selectbank('h4800);switchmode('h87);end
  3: switchmode('h87);
  4:begin selectbank('h4800);switchmode('h87);end
 endcase
 probe;
end endtask
reg[95:0]savedextra;reg[63:0]savedmap;reg[23:0]firstpa;
integer lp0,lp1;
initial begin
 repeat(4)tick;reset_n=1;mrst=1;audio_quiescent=1;vblank=1;x=0;ss_game_id='hf1400001;
 repeat(4)tick;
 case(CASE)
  0,1,5:begin
   outport('h61,0);peer_alt=(CASE!=5);outport('h62,'h28);peer_alt=0;switchmode('h87);
   selectbank('h4800);if(CASE!=1)switchmode('h87);
  end
  2,3:begin
   selectbank('h2400);switchmode('h87);
   peer_alt=1;outport('h61,0);peer_alt=0;outport('h62,'h28);
   if(CASE==2)outport('h61,1);else selectbank('h4800);
  end
  4: switchmode('h85);
  6: begin end // reset/initial state
  7:begin selectbank('h2800);switchmode('h87);end
  8:begin selectbank('h2800);switchmode('h87);selectbank('h2800);switchmode('h87);end
  9:begin selectbank('h2800);switchmode('h87);selectbank('h4800);switchmode('h87);selectbank('h2800);switchmode('h87);end
  10:begin selectbank('h2800);switchmode('h87);selectbank('h2900);switchmode('h87);selectbank('h4800);switchmode('h87);end
  11:begin selectbank('h2800);switchmode('h87);selectbank('h6000);switchmode('h87);selectbank('h4800);switchmode('h87);end
  12,13:begin selectbank('h2800);switchmode('h87);outport('h61,4);if(CASE==13)outport('h62,'h28);end
  14:begin selectbank('h2800);switchmode('h87);selectbank('h4800);switchmode('h87);selectbank('h2800);switchmode('h87);selectbank('h4800);switchmode('h87);end
 endcase
 if(CASE==5)begin
  switchmode('h85);fetch('h1380);addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;switchmode('h87);
 end
 probe;equal_ref;
 savedextra=evolution_out;savedmap=mapper_out;
 if(CASE<4&&(ext0[95:0]!==ext2[95:0]||mapper_out!==map2))$fatal(1,"noninjective representation not equal");
 $display("PAIR CASE%0d mapper=%h extra=%h A game=%h prev=%h B game=%h prev=%h Flash=%h/%h",CASE,mapper_out,evolution_out,game0,prev0,game2,prev2,pa0,pa2);
 check_save=1;operation(1);check_save=0;probe;equal_ref;
 if(mem['hf]!==savedmap||{mem['h1b],mem['h19][63:32]}!==savedextra||mem['h1a][63:40]!==24'h484309)$fatal(1,"v9 stored bytes mismatch");
 $display("SAVE_ONLY PASS CASE%0d clocks=%0d boundary=%0d mapperWord=%h extra=%h",CASE,cycle,captures,mem['hf],{mem['h1b],mem['h19][63:32]});
 // Hold reference/peer at T; perturb only loaded machine, using legal CPU writes.
 perturb=1;selectbank('h6000);switchmode('h87);outport('h8c,'haa);idle;
 operation(0);perturb=0;idle;
 lp0=pulses0;lp1=pulses1;suffix;
 if(CASE==5)begin if(pa0!==pa1)$fatal(1,"record override should mask selector history");end
 else if(CASE==4)begin if(pulses0-lp0!==0||pulses1-lp1!==1)$fatal(1,"game_started omission not reproduced");end
 else if((CASE<4||CASE==12||CASE==13||CASE==14)&&pa0===pa1)$fatal(1,"missing expected F14 divergence CASE%0d",CASE);
 else if(CASE>=6&&CASE<=11&&pa0!==pa1)$fatal(1,"unexpected history-control mapping mismatch CASE%0d",CASE);
 if(CASE<4&&pa1===pa2)$fatal(1,"noninjective pair did not diverge");
 if(CASE==0&&(pa1!==24'h288123||pa0!==24'h488123))$fatal(1,"wrong previous-bank causal addresses");
 $display("REPLAY CASE%0d reference game=%h previous=%h Flash=%h DATA=%h loaded game=%h previous=%h Flash=%h DATA=%h peerFlash=%h launchDelta=%0d/%0d",CASE,game1,prev1,pa1,pa1[23:16],game0,prev0,pa0,pa0[23:16],pa2,pulses1-lp1,pulses0-lp0);
 firstpa=pa0;
 // A different post-save menu-latch perturbation must not leak into load.
 perturb=1;selectbank('h9440);switchmode('h85);outport('h8c,'h55);operation(0);perturb=0;idle;suffix;
 if(pa0!==firstpa)$fatal(1,"repeated LOAD address differs");
 if(evolution_out[95:32]!==savedextra[95:32]&&CASE!=4)$fatal(1,"saved board latches not restored");
 if(loads!=2||captures!=3)$fatal(1,"operation coverage");
 $display("PASS F14 CASE%0d expected-defect-or-control reproduced, save-only equivalent %0d cycle comparisons, repeated LOAD deterministic, accepted=%0d loaded=%0d",CASE,comparisons,captures,loads);$finish;
end
initial begin repeat(7000000)tick;$fatal(1,"watchdog");end
endmodule
