`timescale 1ns/1ps
module compat_tb;
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
savestates dut(.z80_nmi(3'b001),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_history_in(mapper_history_in),.mapper_history_out(mapper_history_out),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;DDRAM_BUSY=STALL==1?(cycle%31<13):STALL==2?((cycle*17)%47<29):0;end
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
reg[63:0]header,historyword,desc;reg[17:0]expected_history;integer k;integer checks=0;
initial begin
 reset_n=0;repeat(4)tick;reset_n=1;audio_quiescent=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;ss_game_id=32'hf1300010;
 gg_out=128'h0001456789abcdef0011223344556677;md_out=46'h100000;tap_out=19'h40000;paddle_out=32'h123;gun_out=46'h123456;
 download(16,1);mrst=1;boot=1;repeat(4)tick;put(16'hfffd,0,30);operation(1);
 header=mem['h1a];historyword=mem['h2a];desc=mem['h2b];
 if(header[63:38]!=={24'h48430c,2'd3}||historyword[63:18]!==0||desc!==64'h000000124d444839)$fatal(1,"new payload encoding");
 for(k=0;k<30;k=k+1)begin
  mem['h1a]=header;mem['h2a]=historyword;mem['h2b]=desc;mem['h2c]=0;mem['h2d]=64'h0000003c45563131;mem[0][63:32]=24574;mem['he][63]=1;
  expected_history=18'h0ffff;
  if(k==0)mem['h1a][63:22]=0;
  if(k>=1&&k<=8)mem['h1a][63:38]={24'h484300+k[23:0],k==1?2'd0:k==2?2'd2:2'd3};
  case(k)
   9:expected_history=historyword[17:0];
   10:mem['h1a][63:40]=24'h48430d;
   11:mem['h2b][31:0]=0;
   12:mem['h2b][39:32]=17;
   13:mem['h2b][63]=1;
   14:mem['h2a][18]=1;
   15:mem['h2a][63]=1;
   16:begin mem['h1a][63:40]=24'h48430b;mem['h1a][39:38]=2;end
   17:begin mem[0][63:32]=16382;mem['he][63]=0;end
   18:begin mem['h2a]=0;expected_history=0;end
   19:begin mem['h2a]=18'h0ffff;expected_history=18'h0ffff;end
   20:begin mem['h2a]=18'h10042;expected_history=18'h10042;end
   21:begin mem['h2a]=18'h3fffe;expected_history=18'h3fffe;end
   22:mem['h2b]=0;
   23:mem['h1a][63:40]=24'h484308;
   24:begin mem['h2d]=64'h0000003945563130;mem['h1a][63:40]=24'h48430a;expected_history=historyword[17:0];end
   25:begin mem['h2d]=0;expected_history=historyword[17:0];end
   26:begin mem['h2c]='1;expected_history=historyword[17:0];end
   27:begin mem['h2d]='1;expected_history=historyword[17:0];end
   28:begin mem['h1a][63:40]=24'h484309;mem['h2c]='1;mem['h2d]='1;expected_history=historyword[17:0];end
   29:begin mem['h1a][63:40]=24'h48430d;end
  endcase
  mrst=0;boot=0;repeat(3)tick;mrst=1;boot=1;repeat(4)tick;put(k%2?16'hfffd:16'h4000,0,30);
  operation(0);
  if(evolution_in[159:96]!==0)$fatal(1,"non-Evolution history was not normalized");
  if(mapper_history_in!==expected_history)$fatal(1,"history format case%0d got%h expected%h",k,mapper_history_in,expected_history);
  if(k>=2&&k<=9||k>=11&&k<=15||k>=18&&k<=28)begin
   if(gg_in!==gg_out)$fatal(1,"GG payload moved case%0d",k);
  end
  if(k>=3&&k<=9||k>=11&&k<=15||k>=18&&k<=28)if(!md_valid||md_in!==md_out)$fatal(1,"MD payload moved case%0d",k);
  if(k>=6&&k<=9||k>=11&&k<=15||k>=18&&k<=28)if(!tap_valid||tap_in!==tap_out)$fatal(1,"Tap payload moved case%0d",k);
  if(k>=7&&k<=9||k>=11&&k<=15||k>=18&&k<=28)if(!paddle_valid||paddle_in!==paddle_out)$fatal(1,"Paddle payload moved case%0d",k);
  if(k==8||k==9||k>=11&&k<=15||k>=18&&k<=28)if(!gun_valid||gun_in!==gun_out)$fatal(1,"Gun payload moved case%0d",k);
  checks=checks+1;$display("PASS F13 format case%0d history%h",k,mapper_history_in);
 end
 $display("PASS F13 format cases%0d untagged v1-v10 future padding descriptor old64K previous payloads intact",checks);$finish;
end
initial begin repeat(30000000)tick;$fatal(1,"format watchdog");end
endmodule
