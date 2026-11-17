`timescale 1ns/1ps
module history_tb;
parameter CASE=0,ITERATIONS=2,STALL=0,SAVE_DELAY=0;
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
wire [63:0] mapper_out;wire [17:0]mapper_history_out,mapper_history_in;wire[17:0]refhistory,peerhistory;
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
savestates dut(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_history_in(mapper_history_in),.mapper_history_out(mapper_history_out),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?(cycle%31<13):STALL==2?((cycle*17)%47<29):0);end
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
 tick;if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg mrst=0,romclk=0,romen=0,boot=0,wr=1,mreq=1,holdref=0,perturb=0;
reg[24:0]ra=0;reg[7:0]rd=0,data=0;reg[15:0]addr=0;
wire[63:0]refstate,peerstate;wire[21:0]adr0,adr1,adr2;
wire dh0,dh1,dh2,sg0,sg1,sg2;wire[7:0]q0,q1,q2;
reg peer_ignore=0;
reg trace_active=0,trace_record=0;integer trace_pos=0,trace_length=0,replay_checks=0;
reg[112:0]trace_words[0:70000];
wire[112:0]observed={mapper_out,mapper_history_out,adr0,dh0,q0};
always @(negedge clk)begin
 #2;
 if(trace_active)begin
  if(trace_record)begin
   same(100);
   trace_words[trace_pos]=observed;
  end else if(observed!==trace_words[trace_pos])$fatal(1,"future clock mismatch case%0d sample%0d got%h expected%h",CASE,trace_pos,observed,trace_words[trace_pos]);
  trace_pos=trace_pos+1;replay_checks=replay_checks+1;
 end
end
machine loaded_machine(.clk_sys(clk),.ROMCL(romclk),.ROMAD(ra),.ROMDT(rd),.ROMEN(romen),.RESET_n(mrst),.ss_freeze(ss_freeze),.bootloader_n(boot),.A(addr),.D_in(data),.WR_n(wr),.MREQ_n(mreq),.mapper_set(mapper_set),.mapper_in(mapper_in),.mapper_history_in(mapper_history_in),.mapper_history_out(mapper_history_out),.state_out(mapper_out),.rom_address(adr0),.dahjee(dh0),.sega_seen(sg0),.read_data(q0));
machine reference(.clk_sys(clk),.ROMCL(romclk),.ROMAD(ra),.ROMDT(rd),.ROMEN(romen),.RESET_n(mrst),.ss_freeze(holdref),.bootloader_n(boot),.A(addr),.D_in(data),.WR_n(wr|perturb),.MREQ_n(mreq),.mapper_set(1'b0),.mapper_in(64'd0),.mapper_history_in(18'h0ffff),.mapper_history_out(refhistory),.state_out(refstate),.rom_address(adr1),.dahjee(dh1),.sega_seen(sg1),.read_data(q1));
machine peer(.clk_sys(clk),.ROMCL(romclk),.ROMAD(ra),.ROMDT(rd),.ROMEN(romen),.RESET_n(mrst),.ss_freeze(holdref),.bootloader_n(boot),.A(addr),.D_in(data),.WR_n(wr|perturb|peer_ignore),.MREQ_n(mreq),.mapper_set(1'b0),.mapper_in(64'd0),.mapper_history_in(18'h0ffff),.mapper_history_out(peerhistory),.state_out(peerstate),.rom_address(adr2),.dahjee(dh2),.sega_seen(sg2),.read_data(q2));
always @(posedge ss_freeze)holdref=1;
always @(negedge ss_freeze)if(mrst)holdref=0;
integer captures=0,restores=0,bootcycle=0,capture_age=0;
always @(posedge clk)begin
 if(dut.state==41)begin captures=captures+1;if(dut.do_save)capture_age=cycle-bootcycle;$display("CAPTURE case%0d clock%0d age%0d mapper%h sega%0d",CASE,cycle,cycle-bootcycle,mapper_out,sg0);end
 if(mapper_set)begin
  restores=restores+1;$display("RESTORE case%0d clock%0d mapper%h sega-before%0d",CASE,cycle,mapper_in,sg0);
  #1;if(mapper_out!==mapper_in||mapper_history_out!==mapper_history_in)$fatal(1,"exact mapper/history restore edge mismatch");
 end
end
task download(input integer pages,input bit ab);begin
 // Every byte is downloaded through production metadata scanners.
 romen=1;
 for(integer i=0;i<pages*8192;i=i+1)begin
  ra=i;rd=i >> 14;if(ab&&i==0)rd=8'h41;if(ab&&i==1)rd=8'h42;
  romclk=0;#1;romclk=1;#1;
 end
 romclk=0;romen=0;
end endtask
task put(input[15:0]a,input[7:0]v,input integer clocks);begin
 addr=a;data=v;wr=0;mreq=0;repeat(clocks)tick;wr=1;mreq=1;tick;
end endtask
task same(input integer labelid);begin
 if(mapper_out!==refstate||mapper_history_out!==refhistory||adr0!==adr1||dh0!==dh1||sg0!==sg1||q0!==q1)$fatal(1,"equivalence case%0d label%0d state%h/%h history%h/%h addr%h/%h sega%0d/%0d",CASE,labelid,mapper_out,refstate,mapper_history_out,refhistory,adr0,adr1,sg0,sg1);
end endtask
task future;begin
 addr=0;data=0;wr=1;mreq=0;
 case(CASE)
  0,2,4,11:put(16'h2000,8'h77,30);
  1,3,5:put(16'h3ffe,8'h01,30);
  6,7,10:begin repeat(66000)tick;put(16'hfffd,8'h01,30);end
  8,9:put(16'h8000,8'h03,30);
 endcase
 addr=(CASE==6||CASE==7||CASE==10)?16'h0412:16'h8123;repeat(3)tick;
end endtask
reg[63:0]saved;reg[63:0]firststate;reg[21:0]firstaddr;integer pages;bit expected;
initial begin
 reset_n=0;repeat(4)tick;reset_n=1;
 vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;
 ss_game_id=32'hf1300001;
 pages=(CASE==6||CASE==10)?4:CASE==7?6:16;
 download(pages,CASE!=1&&CASE!=3&&CASE!=5&&CASE!=6&&CASE!=7&&CASE!=10);
 mrst=1;repeat(3)tick;boot=1;bootcycle=cycle;repeat(3)tick;
 addr=0;mreq=0;tick;mreq=1;
 case(CASE)
  0,1:begin peer_ignore=1;put(16'hfffd,0,30);peer_ignore=0;put(16'ha000,3,30);end
  4:put(16'h2000,8'h77,30);
  5:put(16'h3ffe,8'h01,30);
  8:put(16'h8000,8'h03,30);
  10:begin peer_ignore=1;put(16'h4000,0,30);peer_ignore=0;end
 endcase
 if(CASE<6||CASE==11)repeat(66000)tick;
 if(CASE==11)put(16'hfffd,0,30); // Too late to set startup-window evidence.
 same(0);saved=mapper_out;
 if(CASE==0||CASE==1||CASE==10)begin
  if(peerstate!==mapper_out)$fatal(1,"noninjective mapper pair not reached");
  if(CASE!=10&&(sg2!==0||sg0!==1))$fatal(1,"Sega history pair not reached");
  $display("NONINJECTIVE case%0d mapper=%h sega_history=%0d/%0d",CASE,mapper_out,sg0,sg2);
 end
 repeat(SAVE_DELAY)tick;
 mreq=0;operation(1);holdref=0;same(1);
 saved=mem['hf];
 if(mem['h1a][63:40]!==24'h484309||mem['h2a]!=={46'd0,dut.mapper_history_snap}||mem['h2b]!==64'h000000124d444839)$fatal(1,"v9 payload representation");
 $display("SAVE_ONLY PASS case%0d writes%0d",CASE,writes);
 future;same(2);
 if(CASE==0||CASE==1||CASE==10)begin
  if(peerstate===refstate||q2===q1)$fatal(1,"noninjective future not distinguished");
  $display("NONINJECTIVE_FUTURE case%0d reference%h peer%h DATA=%h/%h",CASE,refstate,peerstate,q1,q2);
 end
 // Saved reference is rebuilt naturally with reset+same prefix, without forcing history.
 // Preserve its T checkpoint by resetting all machines and replaying the prefix,
 // while the external DDR snapshot remains intact.
 mrst=0;boot=0;repeat(3)tick;mrst=1;repeat(3)tick;boot=1;bootcycle=cycle;repeat(3)tick;
 addr=0;mreq=0;tick;mreq=1;
 case(CASE)
  0,1:begin peer_ignore=1;put(16'hfffd,0,30);peer_ignore=0;put(16'ha000,3,30);end
  4:put(16'h2000,8'h77,30);
  5:put(16'h3ffe,8'h01,30);
  8:put(16'h8000,8'h03,30);
  10:begin peer_ignore=1;put(16'h4000,0,30);peer_ignore=0;end
 endcase
 if(CASE<6||CASE==11)repeat(66000)tick;
 if(CASE==11)put(16'hfffd,0,30);
 // Rebuild exactly the original capture age using external clocks, then hold
 // the uninterrupted reference at T. No internal state is assigned or forced.
 repeat(capture_age+1-(cycle-bootcycle))tick;
 holdref=1;repeat(40)tick; // match the post-freeze terminal-decision drain
 if(refstate!==saved)$fatal(1,"rebuilt reference is not the saved architectural state");
 if(refhistory!==mem['h2a][17:0])$fatal(1,"reference capture age mismatch %h/%h",refhistory,mem['h2a][17:0]);
 holdref=1;perturb=1;put(16'hffff,8'h07,30);put(16'h3ffe,8'h30,30);perturb=0;
 mreq=0;operation(0);
 same(30); // both machines may legitimately reach the deadline after release
 holdref=0;trace_pos=0;trace_record=1;trace_active=1;future;trace_active=0;trace_length=trace_pos;
 same(3); expected=0;
 firststate=mapper_out;firstaddr=adr0;
 // Repeated LOAD must restore the identical saved mapping and reproduce S.
 for(integer iteration=1;iteration<ITERATIONS;iteration=iteration+1)begin
  holdref=1;perturb=1;put(iteration%2?16'hffff:16'h4000,iteration+4,30);put(16'h8000,iteration+2,30);perturb=0;
  mreq=0;operation(0);
  trace_pos=0;trace_record=0;trace_active=1;future;trace_active=0;
  if(trace_pos!=trace_length||mapper_out!==firststate||adr0!==firstaddr)$fatal(1,"repeat load nondeterminism");
 end
 if(captures!=ITERATIONS+1||restores!=ITERATIONS)$fatal(1,"controller path count captures%0d loads%0d",captures,restores);
 $display("PASS FIXED F13 case%0d iterations%0d stall%0d delay%0d checks%0d first/repeated LOAD data%h mapper%h history%h",CASE,ITERATIONS,STALL,SAVE_DELAY,replay_checks,q0,mapper_out,mapper_history_out);$finish;
end
initial begin repeat(8000000)tick;$fatal(1,"watchdog state%0d",dut.state);end
endmodule
