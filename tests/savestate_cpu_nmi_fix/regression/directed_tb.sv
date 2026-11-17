`timescale 1ns/1ps
module evolution_fixed_tb;
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
savestates dut(.z80_nmi(3'b001),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(),.mapper_history_out(18'h0ffff),.mapper_history_in(),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
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
 tick;if(saving)ss_save=1;else ss_load=1;$display("REQUEST CASE%0d saving%0d cycle%0d phase=%b A=%h M1=%b MREQ=%b WR=%b",CASE,saving,cycle,phase0,addr,m1,mreq,wr);tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg mrst=0,wr=1,mreq=1,iq=1,rd=1,m1=1,perturb=0,save_peer=0;
reg[15:0]addr=0;reg[7:0]data=0;
wire[159:0]ext0,ext1;wire[63:0]map0,map1;
wire[23:0]pa0,pa1;wire[15:0]game0,game1,prev0,prev1;
wire[7:0]mode0,mode1;wire launch0,launch1;wire[5:0]phase0,phase1;
assign evolution_out=save_peer?ext1:ext0;assign mapper_out=save_peer?map1:map0;
assign z80_m1_n=m1;assign z80_mreq_n=mreq;
evolution_banked_machine loaded(.freeze(ss_freeze),.clk(clk),.reset_n(mrst),.a(addr),.d(data),.mreq(mreq),.iorq(iq),.rd(rd),.wr(wr),.m1(m1),.set(evolution_set),.ein(evolution_in),.min(mapper_in),.extra(ext0),.mapped(map0),.physical(pa0),.game(game0),.previous(prev0),.mode(mode0),.launch(launch0),.phase(phase0));
evolution_banked_machine reference(.freeze(1'b0),.clk(clk),.reset_n(mrst),.a(perturb?16'h8123:addr),.d(data),.mreq(mreq|perturb),.iorq(iq|perturb),.rd(rd|perturb),.wr(wr|perturb),.m1(m1|perturb),.set(1'b0),.ein(160'd0),.min(64'd0),.extra(ext1),.mapped(map1),.physical(pa1),.game(game1),.previous(prev1),.mode(mode1),.launch(launch1),.phase(phase1));
integer accepts=0,checks=0,pulses0=0,pulses1=0;reg compare=0;
reg record_s=0,replay_s=0;integer pos=0,trace_len=0,first_state=-1,first_flash=-1;
wire[253:0]observed={ext0,map0,pa0,phase0};reg[253:0]trajectory[0:1023];
reg[253:0]loaded_trajectory[0:1023];integer replay_iteration=0;
reg[159:0]savedextra;reg[63:0]savedmap;reg[5:0]savedphase;
always @(negedge clk)begin #2;
 if(compare)begin checks=checks+1;if({ext0,map0,pa0,phase0}!=={ext1,map1,pa1,phase1})$fatal(1,"SAVE-only mismatch");end
 if(record_s)begin trajectory[pos]=observed;pos=pos+1;end
 if(replay_s)begin
  if(replay_iteration==0)loaded_trajectory[pos]=observed;
  else if(loaded_trajectory[pos]!==observed)$fatal(1,"Repeated full trajectory differs at sample%0d",pos);
  if(trajectory[pos]!==observed)$fatal(1,"Reference trajectory differs at sample%0d",pos);
  if(trajectory[pos]!==observed&&first_state<0)begin first_state=pos;$display("FIRST_STATE sample%0d REF=%h LOAD=%h",pos,trajectory[pos],observed);end
  if(trajectory[pos][29:6]!==pa0&&first_flash<0)begin first_flash=pos;$display("FIRST_FLASH sample%0d REF=%h LOAD=%h",pos,trajectory[pos][29:6],pa0);end
  pos=pos+1;
 end
end
always @(posedge clk)begin
 if(dut.state==37&&cpu_ce&&!m1&&!mreq&&vblank&&x<256)begin
  accepts=accepts+1;$display("ACCEPT CASE%0d cycle%0d phase=%b A=%h bus M1%0b MREQ%0b RD%0b WR%0b",CASE,cycle,phase0,addr,m1,mreq,rd,wr);
 end
 if(evolution_set)begin #1;if(ext0!==evolution_in||map0!==mapper_in||{phase0[2],phase0[3],phase0[4]}!==evolution_in[155:153])$fatal(1,"F14 restore incorrect");$display("RESTORE phase=%b saved=%b F14=%h",phase0,savedphase,ext0[152:96]);end
 if(launch0)pulses0=pulses0+1;if(launch1)pulses1=pulses1+1;
end
task idle;begin wr=1;mreq=1;iq=1;rd=1;m1=1;repeat(3)tick;end endtask
task boundary;begin wr=1;iq=1;rd=0;mreq=0;m1=0;tick;end endtask
task fetch(input[15:0]a);begin idle;addr=a;boundary;repeat(30)tick;idle;end endtask
task outport(input[7:0]p,input[7:0]v);begin idle;addr={8'd0,p};data=v;wr=0;iq=0;repeat(30)tick;idle;end endtask
task selectbank(input[15:0]v);begin outport('h61,v[7:0]);outport('h62,v[15:8]);end endtask
task command(input[7:0]v);begin idle;addr='h3ffe;data=v;wr=0;mreq=0;repeat(30)tick;idle;end endtask
task switchmode(input[7:0]v);begin command(v);fetch('h100);fetch('h200);end endtask
task probe;begin idle;addr='h8123;mreq=0;rd=0;repeat(3)tick;end endtask
task suffix;begin
 addr=CASE==0?'h100:(CASE==1||CASE==5||CASE==7||CASE==8||CASE==9)?'h1380:'h1400;
 case(CASE)
  0:fetch('h200); // second M1 commits the armed command
  1:begin idle;addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;switchmode('h87);end
  2,3,4:switchmode('h87); // completed record read must authorize re-launch
  5,8:begin idle;addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;fetch('h200);end
  6:fetch('h200);
  7:begin idle;addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;switchmode('h87);end
  9:begin idle;addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;end
 endcase
 probe;
end endtask
reg[63:0]snapshot[0:12287];integer lp0,lp1;reg[23:0]repeatedpa;integer repeatedpulses;
initial begin
 for(integer i=0;i<12288;i=i+1)mem[i]=0;
 repeat(4)tick;reset_n=1;mrst=1;audio_quiescent=1;vblank=1;x=0;ss_game_id='hf1500010;
 repeat(4)tick;
 if(CASE==3||CASE==4)begin
  selectbank('h2400);fetch('h1380);addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;switchmode('h87);switchmode('h85);
  addr='hffff;data=8;wr=0;mreq=0;repeat(30)tick;idle;
  perturb=1;fetch('h1380);addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;perturb=0;addr='h1400;
  if(ext0[152:0]!==ext1[152:0]||map0!==map1||phase0[2]!==1||phase1[2]!==0)$fatal(1,"pair prefix");
  save_peer=(CASE==4);operation(1);save_peer=0;
  if(CASE==3)$writememh("pairA.mem",mem);else $writememh("pairB.mem",mem);
  $display("PAIR initialized DDR slot, extra=%h map=%h phaseA=%b phaseB=%b CPUfixture=%h",ext0,map0,phase0,phase1,z80_reg);
  suffix;if(pa0===pa1)$fatal(1,"pair future identical");
  $display("PASS F15 projection pair A=%h B=%h; compare separate slots externally; synthetic CPU architectural input constant (not a full T80 pair)",pa0,pa1);$finish;
 end
 else if(CASE==9)begin selectbank('h2400);switchmode('h87);switchmode('h85);selectbank('h4800);command('h87);fetch('h100);addr='h1380;end
 else if(CASE==0)begin selectbank('h2800);command('h87);addr='h100;end
 else begin
  selectbank('h2400);switchmode('h87);switchmode('h85);selectbank('h4800);
  if(CASE>=5)begin
   if(CASE>=6)begin fetch('h1380);addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;end
   addr='hffff;data=8;wr=0;mreq=0;repeat(30)tick;idle;
   if(CASE==5||CASE==6||CASE==8)command('h87);
   addr=CASE==6?'h1400:'h1380;
  end
  else if(CASE==2)begin fetch('h1380);addr='h20a8;mreq=0;rd=0;repeat(30)tick;idle;addr='hffff;data=8;wr=0;mreq=0;repeat(30)tick;idle;addr='h1400;end
  else addr='h1380;
 end
 compare=1;operation(1);compare=0;savedextra=ext0;savedmap=map0;savedphase=phase0;
 for(integer i=0;i<12288;i=i+1)snapshot[i]=mem[i];
 $display("V10 CASE%0d phase=%b mapper=%h 019=%h 01b=%h 02c=%h 02d=%h",CASE,savedphase,mem['hf],mem['h19],mem['h1b],mem['h2c],mem['h2d]);
 compare=1;lp0=pulses0;lp1=pulses1;pos=0;record_s=1;suffix;record_s=0;trace_len=pos;compare=0;
 $display("SAVE_ONLY PASS CASE%0d Flash=%h DATA=%h launchDelta=%0d checks=%0d",CASE,pa0,pa0[23:16],pulses0-lp0,checks);
 // Reload after five distinct Q histories, each starting from the previous
 // replay's end. Reference remains at the saved boundary until its first S.
 // S above established the independent save-only trajectory; remember it.
 repeatedpa=pa1;repeatedpulses=pulses1-lp1;
 for(integer iteration=0;iteration<5;iteration=iteration+1)begin
  perturb=1;
  case(iteration)
   0:begin fetch('h300);fetch('h400);end
   1:command('h97);
   2:begin switchmode('h85);fetch('h1380);addr='h2100;mreq=0;rd=0;repeat(30)tick;idle;end
   3:begin selectbank('h9440);outport('h8c,'haa);switchmode('hc7);end
   4:begin switchmode('h85);idle;end
  endcase
  addr='h1500;operation(0);
  if(ext0!==savedextra||map0!==savedmap)$fatal(1,"Q leaked into F14 state");
  lp0=pulses0;pos=0;first_state=-1;first_flash=-1;replay_iteration=iteration;replay_s=1;suffix;replay_s=0;
  if(pos!=trace_len||first_state>=0||first_flash>=0)$fatal(1,"Cycle replay coverage missing");
  if(iteration==0)begin repeatedpa=pa0;repeatedpulses=pulses0-lp0;end
  else if(pa0!==repeatedpa||pulses0-lp0!=repeatedpulses)$fatal(1,"Repeated LOAD differs");
  if(pa0!==pa1)$fatal(1,"Future Flash mismatch");
  if(CASE==2&&pulses0-lp0!=1)$fatal(1,"Expected lost relaunch");
  $display("REPLAY CASE%0d Q%0d REF=%h/%h LOAD=%h/%h launches=%0d phase=%b",CASE,iteration,pa1,pa1[23:16],pa0,pa0[23:16],pulses0-lp0,phase0);
 end
 $display("PASS F15 CASE%0d five perturbations/repeated LOADs accepted=%0d comparisons=%0d",CASE,accepts,checks);$finish;
end
initial begin repeat(15000000)tick;$fatal(1,"watchdog");end
endmodule
