`timescale 1ns/1ps
module fixed_tb;
parameter SOURCE=0,PROGRAM=0,EDGE=-15,WIDTH=5,SECOND=9999999,HELD=0,SCHEDULE=0,FORMAT=0,REPLAYS=3,RELEASE_SECOND=0;
reg clk = '0;
reg reset_n = '0;
reg ss_save = '0;
reg ss_load = '0;
reg [1:0] ss_slot = '0;
reg ss_bios_mode = '0;
reg [31:0] ss_game_id = '0;
wire transport_freeze,protocol_prepare,protocol_commit;reg protocol_ready=0;reg[4:0]protocol_clock=0;
wire ss_freeze=transport_freeze;
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
wire [7:0] wram_D;
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
wire[2:0]nmi_snap,nmi_dir;wire nmi_valid,nmi_hold;
wire[2:0]restart_out,restart_dir;wire restart_valid;
wire replay,replay_t2;
savestates dut(.fm_initialized(1'b1),.fm_state_rdata(32'd0),.audio_last_out(16'd0),.bg_out(139'd0),.bg2_out(139'd0),.ss_cpu_prepare(protocol_prepare),.z80_replay(replay),
 .z80_tick_active(1'b1),.z80_replay_t2(replay_t2),
 .clock_phase(2'd0),.clock_phase_in(),.clock_phase_set(protocol_commit),.clock_phase_ready(protocol_ready),
 .sprite_out(4778'd0),.sprite2_out(4778'd0),.sprite_in(),.sprite2_in(),.sprite_valid(),.z80_restart(restart_out),.z80_restart_dir(restart_dir),.z80_restart_valid(restart_valid),.z80_nmi(nmi_snap),.z80_nmi_dir(nmi_dir),.z80_nmi_valid(nmi_valid),.z80_nmi_hold(nmi_hold),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(transport_freeze),.ss_capture_progress(),.mapper_history_out(18'h0ffff),.mapper_history_in(),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin protocol_ready=protocol_commit;cpu_ce=!protocol_commit&&protocol_clock==0;protocol_clock=protocol_commit?1:(protocol_clock+1==15?0:protocol_clock+1);cycle=cycle+1;end
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

localparam LENGTH=6000;
reg mrst=0,dpause=1,rpause=1,ref_done=0;
reg[6:0]dpins=7'h7f,rpins=7'h7f;
wire[12:0]dn,rn;wire dold,rold,ready,rready,dmreq,dm1,dwr,drd,diq,dinput;
wire[15:0]da,ra;wire[7:0]dd,ddi,rdout,rdi;
wire[229:0]rr;wire[127:0]rgg;wire[31:0]rio;wire rm1,rmreq,rwr,rrd,riq;
nmi_machine #(.SOURCE(SOURCE),.PROGRAM(PROGRAM)) core(.prepare(protocol_prepare),.replay_t2(replay_t2),.restart_out(restart_out),.restart_dir(restart_dir),.restart_valid(restart_valid),.clk(clk),.mrst(mrst),.cpu_ce(cpu_ce),.ss_freeze(ss_freeze),.pause_n(dpause),.link_pins(dpins),.cpu_dir(z80_dir),.cpu_set(z80_set),.nmi_dir(nmi_dir),.nmi_valid(nmi_valid),.nmi_hold(nmi_hold),.gg_in(gg_in),.gg_set(gg_set),.io_in(io_in),.io_set(io_set),.wram_A(wram_A),.wram_WA(wram_WA),.wram_WD(wram_WD),.wram_WE(wram_WE),.wram_D(wram_D),.cpu_reg(z80_reg),.nmi_snap(nmi_snap),.nstate(dn),.old_nmi(dold),.nmi_replay(replay),.ready(ready),.gg_out(gg_out),.io_out(io_out),.addr(da),.data(dd),.di(ddi),.iset(z80_iset),.m1(dm1),.mreq(dmreq),.wr(dwr),.rd(drd),.iq(diq),.nmi_n(dinput));
nmi_machine #(.SOURCE(SOURCE),.PROGRAM(PROGRAM)) reference(.prepare(1'b0),.replay_t2(1'b1),.restart_out(),.restart_dir(3'd0),.restart_valid(1'b0),.clk(clk),.mrst(mrst),.cpu_ce(cpu_ce),.ss_freeze(ref_done),.pause_n(rpause),.link_pins(rpins),.cpu_dir(230'd0),.cpu_set(1'b0),.nmi_dir(3'b001),.nmi_valid(1'b0),.nmi_hold(1'b0),.gg_in(128'd0),.gg_set(1'b0),.io_in(32'd0),.io_set(1'b0),.wram_A(14'd0),.wram_WA(14'd0),.wram_WD(8'd0),.wram_WE(1'b0),.wram_D(),.cpu_reg(rr),.nmi_snap(),.nstate(rn),.old_nmi(rold),.nmi_replay(),.ready(rready),.gg_out(rgg),.io_out(rio),.addr(ra),.data(rdout),.di(rdi),.iset(),.m1(rm1),.mreq(rmreq),.wr(rwr),.rd(rrd),.iq(riq),.nmi_n());
assign z80_m1_n=dm1;assign z80_mreq_n=dmreq;
assign mapper_out=64'h0040000003020100;assign evolution_out=160'd0;
wire pix=(!mrst||cycle%10==0);wire[8:0]y;
video beam(.clk(clk),.ce_pix(pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(),.vblank(vblank));
wire[511:0]dobs={z80_reg,dn,dold,da,(!dwr?dd:8'd0),(!drd?ddi:8'd0),dm1,dmreq,drd,dwr,diq,gg_out,io_out,core.ram['h100],core.ram['h101],core.ram['h102]};
wire[511:0]robs={rr,rn,rold,ra,(!rwr?rdout:8'd0),(!rrd?rdi:8'd0),rm1,rmreq,rrd,rwr,riq,rgg,rio,reference.ram['h100],reference.ram['h101],reference.ram['h102]};
reg[511:0]golden[0:LENGTH];reg[7:0]golden_ram[0:8191];
integer ready_cycle=0,accepted_cycle=0,ref_index=0,loads=0,dirs=0,compare_count=0,stage=0,iteration=0;
integer future_offset=9999999,future_second=9999999;
reg accepted=0,recording=0;reg[2:0]captured;reg follow_d=0;integer d_index=0;
integer ref_vectors=0,d_vectors=0;reg last_rm1=1,last_dm1=1;
task tick;begin @(negedge clk);#1;end endtask
task dlevel(input bit active);begin if(SOURCE==0)dpause=!active;else dpins[6]=!active;end endtask
task rlevel(input bit active);begin if(SOURCE==0)rpause=!active;else rpins[6]=!active;end endtask
function future_active(input integer n);begin
 future_active=HELD!=0;
 if(future_offset>0&&future_offset<1000&&n>=future_offset&&n<future_offset+(WIDTH>0?WIDTH:6001))future_active=1;
 if(future_offset<=0&&WIDTH>0&&n<future_offset+WIDTH)future_active=1;
 if(future_second>0&&future_second<1000&&n>=future_second)future_active=1;
 if(SCHEDULE&&((n>=224&&n<229)||(n>=704&&n<709)))future_active=1;
end endfunction
task future_d(input integer n);begin dlevel(future_active(n));end endtask
task future_r(input integer n);begin rlevel(future_active(n));end endtask
always @(negedge clk)begin
 #1;
 if(accepted&&!ref_done)future_r(cycle-accepted_cycle);
 if(accepted&&cycle==accepted_cycle+1)future_d(1);
 if(follow_d)begin d_index=d_index+1;future_d(d_index);end
end
always @(posedge clk)begin
 if(ready&&ready_cycle==0)ready_cycle=cycle;
 if(!rm1&&last_rm1&&ra=='h66)ref_vectors=ref_vectors+1;
 if(!dm1&&last_dm1&&da=='h66)d_vectors=d_vectors+1;
 last_rm1=rm1;last_dm1=dm1;
 if(!accepted&&dut.state==37&&cpu_ce&&!dm1&&!dmreq&&z80_iset==0&&vblank&&x<256)begin
  accepted=1;accepted_cycle=cycle;captured=nmi_snap;
  future_offset=ready_cycle+359+EDGE-cycle;future_second=ready_cycle+359+SECOND-cycle;
  $display("ACCEPT cycle%0d relative%0d pre%b%b%b input%b normalized%b CPU%h",cycle,cycle-ready_cycle,dn[12],dn[11],dold,dinput,nmi_snap,z80_reg);
  #2;
  if({dn[12:11],dold}!==captured||dut.nmi_snap!==captured)$fatal(1,"Normalized capture differs");
  if(dobs!==robs)$fatal(1,"Prefix/reference differs");
  golden[0]=robs;recording=1;
 end else if(recording)begin
  #2;ref_index=ref_index+1;golden[ref_index]=robs;
  if(ref_index==LENGTH)begin
   for(integer i=0;i<8192;i=i+1)golden_ram[i]=reference.ram[i];
   recording=0;ref_done=1;
   $display("REFERENCE counter%0d signature%0d vectors%0d",reference.ram['h100],reference.ram['h102],ref_vectors);
  end
 end
 if(z80_set)begin dirs=dirs+1;$display("DIR iter%0d cycle%0d frozen%b hold%b triplet%b valid%b",iteration,cycle,ss_freeze,nmi_hold,nmi_dir,nmi_valid);end
 if(replay&&core.cpu.nmi_restart==1&&cpu_ce&&!ss_freeze)$display("INSTALL CPU-stopped cycle%0d",cycle);
 if(replay&&core.cpu.nmi_restart!=1&&cpu_ce&&!ss_freeze)begin
  if(dn[9:7]!=1||(dn[6:4]!=1&&dn[6:4]!=2)||!dwr)$fatal(1,"Premature entry during restart");
  $display("PREP iter%0d cycle%0d MC%0d TS%0d N%b%b%b",iteration,cycle,dn[9:7],dn[6:4],dn[12],dn[11],dold);
 end
end
task compare(input integer k);begin
 if(dobs!==golden[k])begin $display("DIFF stage%0d iter%0d clock%0d expected%h actual%h",stage,iteration,k,golden[k],dobs);$fatal(1,"CPU/NMI/GG/bus replay differs");end
 compare_count=compare_count+1;
end endtask
task trigger(input bit saving);begin
 force dut.op_cooldown=0;force alias_ctl.op_cooldown=0;tick;if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;release dut.op_cooldown;release alias_ctl.op_cooldown;
end endtask
initial begin
 for(integer i=0;i<12288;i=i+1)mem[i]=0;
 repeat(4)tick;reset_n=1;audio_quiescent=1;ss_game_id='hf1600030;
 while(!(vblank&&x<64))tick;mrst=1;wait(ready_cycle!=0);
 fork
  begin while(cycle<ready_cycle+359+EDGE)tick;if(!accepted)begin dlevel(1);rlevel(1);end if(WIDTH>0)begin repeat(WIDTH)tick;if(!accepted)begin dlevel(0);rlevel(0);end end end
  begin while(cycle<ready_cycle+359+SECOND)tick;if(!accepted)begin dlevel(1);rlevel(1);if(RELEASE_SECOND)begin repeat(5)tick;dlevel(0);rlevel(0);end end end
  begin while(cycle<ready_cycle+300)tick;trigger(1);end
 join_none
 wait(accepted);wait(ss_freeze);wait(!ss_freeze);wait(ref_done);
 $writememh($sformatf("image_s%0d_p%0d_e%0d_w%0d_h%0d_second%0d.hex",SOURCE,PROGRAM,EDGE,WIDTH,HELD,SECOND),mem);
 if(mem['h1a][63:40]!==24'h484313||mem[5][63:44]!==0||mem[5][40:38]!==captured)$fatal(1,"v14 payload");
 stage=1;d_index=0;follow_d=1;
 for(integer j=1;j<=400;j=j+1)begin
  @(posedge clk);while(!cpu_ce)@(posedge clk);#2;compare(j*15);
 end
 follow_d=0;$display("SAVE_ONLY exact ticks400 counter%0d",core.ram['h100]);
 if(FORMAT>0&&FORMAT<=11)begin mem['h1a][63:40]=24'h484300+FORMAT;mem[5][63:38]=26'h3ffffff;end
 if(FORMAT==99)begin mem[0][63:32]=32'h3ffe;mem['he][63:56]=0;mem[5][63:20]=0;end
 if(FORMAT==12)begin mem['h1a][63:40]=24'h48430c;mem[5][63:41]=0;end
 if(FORMAT>=100&&FORMAT<=119)mem[5][44+FORMAT-100]=1;
 if(FORMAT==120)mem[5][43:41]=6;
 if(FORMAT==121)mem[5][43:41]=7;
 if(FORMAT==122)mem['h1a][39:38]=0;
 if(FORMAT==123)mem['h1a][39:38]=2;
 for(iteration=0;iteration<REPLAYS;iteration=iteration+1)begin
  stage=2;dlevel(iteration!=0);repeat(120+iteration*375)tick;dlevel(HELD!=0);repeat(100)tick;
  if(FORMAT>=100)begin
   integer beforedirs;beforedirs=dirs;trigger(0);wait(ss_freeze);wait(!ss_freeze);if(dirs!=beforedirs)$fatal(1,"Malformed image applied CPU state");repeat(40)tick;
   $display("REJECT format%0d iter%0d",FORMAT,iteration);
  end else begin
   trigger(0);wait(replay);wait(!replay);wait(!ss_freeze);#2;loads=loads+1;
   stage=3;
   if((FORMAT==0||FORMAT==12))compare(0);
   else if(dn[12:11]!==0)$fatal(1,"Legacy retained NMI flags");
   d_index=0;follow_d=1;
   for(integer k=1;k<=LENGTH;k=k+1)begin
    @(posedge clk);#2;if((FORMAT==0||FORMAT==12))compare(k);
   end
   follow_d=0;
   if((FORMAT==0||FORMAT==12))begin for(integer a=0;a<8192;a=a+1)if(core.ram[a]!==golden_ram[a])$fatal(1,"WRAM mismatch %h",a);end
   else if(core.ram['h100]!==0)$fatal(1,"Legacy invented handler");
   $display("REPLAY iter%0d counter%0d signature%0d normalized%b",iteration,core.ram['h100],core.ram['h102],captured);
  end
 end
 $display("PASS F16 fixed source%0d program%0d edge%0d held%0d format%0d loads%0d comparisons%0d",SOURCE,PROGRAM,EDGE,HELD,FORMAT,loads,compare_count);$finish;
end
always @(posedge clk)if(FORMAT>=100&&stage==2&&ss_freeze&&(wram_WE||vram_WE||nvram_WE||vram2_WE||z80_set||mapper_set||evolution_set||gg_set||io_set||eeprom_set||gun_set||paddle_set||tap_set||vdp_regs_set||vdp2_regs_set||psg_set||psg2_set||cram_wr||cram2_wr||video_state_set||audio_ext_set||audio_phase_set))$fatal(1,"Malformed image wrote guest state");
initial begin repeat(12000000)tick;$fatal(1,"watchdog");end


// Complete controller outputs: four-state equality, except inactive CPU data.
wire [7:0] alias_fm_state_addr;
wire  alias_fm_state_read;
wire  alias_fm_state_write;
wire [31:0] alias_fm_state_wdata;
wire  alias_fm_legacy_reset;
wire  alias_fm_initialization_run;
wire  alias_ss_freeze;
wire  alias_ss_cpu_prepare;
wire  alias_z80_replay_t2;
wire [1:0] alias_clock_phase_in;
wire  alias_clock_phase_set;
wire [138:0] alias_bg_in;
wire [138:0] alias_bg2_in;
wire  alias_bg_valid;
wire [4777:0] alias_sprite_in;
wire [4777:0] alias_sprite2_in;
wire  alias_sprite_valid;
wire [2:0] alias_z80_restart_dir;
wire  alias_z80_restart_valid;
wire [2:0] alias_z80_nmi_dir;
wire  alias_z80_nmi_valid;
wire  alias_z80_nmi_hold;
wire [229:0] alias_z80_dir;
wire  alias_z80_set;
wire [135:0] alias_vdp_regs_in;
wire  alias_vdp_regs_set;
wire [4:0] alias_cram_A;
wire [11:0] alias_cram_D;
wire  alias_cram_wr;
wire  alias_vram_en;
wire [14:0] alias_vram_A;
wire  alias_vram_WE;
wire [14:0] alias_vram_WA;
wire [7:0] alias_vram_WD;
wire [55:0] alias_psg_in;
wire  alias_psg_set;
wire [95:0] alias_psg_ext_in;
wire [95:0] alias_psg2_ext_in;
wire [3:0] alias_psg_div_in;
wire [10:0] alias_audio_control_in;
wire [15:0] alias_audio_last_in;
wire  alias_audio_last_valid;
wire  alias_audio_phase_in;
wire  alias_audio_ext_set;
wire  alias_audio_phase_set;
wire  alias_audio_pending_tick;
wire [17:0] alias_mapper_history_in;
wire [63:0] alias_mapper_in;
wire  alias_mapper_set;
wire [159:0] alias_evolution_in;
wire  alias_evolution_set;
wire  alias_ss_busy;
wire  alias_ss_capture_progress;
wire [127:0] alias_eeprom_ext_in;
wire  alias_eeprom_full;
wire  alias_nvram_refill;
wire [45:0] alias_gun_in;
wire  alias_gun_set;
wire  alias_gun_valid;
wire [31:0] alias_paddle_in;
wire  alias_paddle_set;
wire  alias_paddle_valid;
wire [18:0] alias_tap_in;
wire  alias_tap_set;
wire  alias_tap_valid;
wire  alias_sc_ram_restored;
wire [63:0] alias_eeprom_in;
wire  alias_eeprom_set;
wire [13:0] alias_wram_A;
wire  alias_wram_WE;
wire [13:0] alias_wram_WA;
wire [7:0] alias_wram_WD;
wire [14:0] alias_nvram_A;
wire  alias_nvram_WE;
wire [14:0] alias_nvram_WA;
wire [7:0] alias_nvram_WD;
wire [135:0] alias_vdp2_regs_in;
wire  alias_vdp2_regs_set;
wire [4:0] alias_cram2_A;
wire [11:0] alias_cram2_D;
wire  alias_cram2_wr;
wire  alias_vram2_en;
wire [14:0] alias_vram2_A;
wire  alias_vram2_WE;
wire [14:0] alias_vram2_WA;
wire [7:0] alias_vram2_WD;
wire [55:0] alias_psg2_in;
wire  alias_psg2_set;
wire [45:0] alias_md_in;
wire  alias_md_set;
wire  alias_md_valid;
wire [127:0] alias_gg_in;
wire  alias_gg_set;
wire [31:0] alias_io_in;
wire  alias_io_set;
wire [21:0] alias_video_state_in;
wire  alias_video_state_set;
wire [28:0] alias_DDRAM_ADDR;
wire [63:0] alias_DDRAM_DIN;
wire [7:0] alias_DDRAM_BE;
wire  alias_DDRAM_WE;
wire  alias_DDRAM_RD;
wire [7:0] alias_DDRAM_BURSTCNT;
savestates_alias #(.TB_FAST(dut.TB_FAST)) alias_ctl(
.fm_state_rdata(dut.fm_state_rdata),
.fm_initialized(dut.fm_initialized),
.clk(dut.clk),
.reset_n(dut.reset_n),
.ss_save(dut.ss_save),
.ss_load(dut.ss_load),
.ss_slot(dut.ss_slot),
.ss_bios_mode(dut.ss_bios_mode),
.ss_game_id(dut.ss_game_id),
.z80_replay(dut.z80_replay),
.z80_tick_active(dut.z80_tick_active),
.clock_phase(dut.clock_phase),
.clock_phase_ready(dut.clock_phase_ready),
.bg_out(dut.bg_out),
.bg2_out(dut.bg2_out),
.sprite_out(dut.sprite_out),
.sprite2_out(dut.sprite2_out),
.vblank(dut.vblank),
.x(dut.x),
.z80_restart(dut.z80_restart),
.z80_nmi(dut.z80_nmi),
.z80_reg(dut.z80_reg),
.z80_m1_n(dut.z80_m1_n),
.z80_mreq_n(dut.z80_mreq_n),
.z80_iset(dut.z80_iset),
.cpu_ce(dut.cpu_ce),
.vdp_ce(dut.vdp_ce),
.pix_ce(dut.pix_ce),
.sp_ce(dut.sp_ce),
.vdp_regs(dut.vdp_regs),
.cram_out(dut.cram_out),
.vram_D(dut.vram_D),
.psg_out(dut.psg_out),
.psg_ext_out(dut.psg_ext_out),
.psg2_ext_out(dut.psg2_ext_out),
.psg_div_out(dut.psg_div_out),
.audio_control_out(dut.audio_control_out),
.audio_quiescent(dut.audio_quiescent),
.audio_phase_out(dut.audio_phase_out),
.audio_last_out(dut.audio_last_out),
.mapper_out(dut.mapper_out),
.mapper_history_out(dut.mapper_history_out),
.evolution_out(dut.evolution_out),
.storage_busy(dut.storage_busy),
.eeprom_present(dut.eeprom_present),
.eeprom_ext_out(dut.eeprom_ext_out),
.gun_out(dut.gun_out),
.paddle_out(dut.paddle_out),
.tap_out(dut.tap_out),
.sc_ram_size(dut.sc_ram_size),
.eeprom_out(dut.eeprom_out),
.wram_D(dut.wram_D),
.nvram_D(dut.nvram_D),
.systeme(dut.systeme),
.vdp2_regs(dut.vdp2_regs),
.cram2_out(dut.cram2_out),
.vram2_D(dut.vram2_D),
.psg2_out(dut.psg2_out),
.md_out(dut.md_out),
.gg_out(dut.gg_out),
.io_out(dut.io_out),
.video_state_out(dut.video_state_out),
.DDRAM_DOUT(dut.DDRAM_DOUT),
.DDRAM_DOUT_READY(dut.DDRAM_DOUT_READY),
.DDRAM_BUSY(dut.DDRAM_BUSY),
.fm_state_addr(alias_fm_state_addr),
.fm_state_read(alias_fm_state_read),
.fm_state_write(alias_fm_state_write),
.fm_state_wdata(alias_fm_state_wdata),
.fm_legacy_reset(alias_fm_legacy_reset),
.fm_initialization_run(alias_fm_initialization_run),
.ss_freeze(alias_ss_freeze),
.ss_cpu_prepare(alias_ss_cpu_prepare),
.z80_replay_t2(alias_z80_replay_t2),
.clock_phase_in(alias_clock_phase_in),
.clock_phase_set(alias_clock_phase_set),
.bg_in(alias_bg_in),
.bg2_in(alias_bg2_in),
.bg_valid(alias_bg_valid),
.sprite_in(alias_sprite_in),
.sprite2_in(alias_sprite2_in),
.sprite_valid(alias_sprite_valid),
.z80_restart_dir(alias_z80_restart_dir),
.z80_restart_valid(alias_z80_restart_valid),
.z80_nmi_dir(alias_z80_nmi_dir),
.z80_nmi_valid(alias_z80_nmi_valid),
.z80_nmi_hold(alias_z80_nmi_hold),
.z80_dir(alias_z80_dir),
.z80_set(alias_z80_set),
.vdp_regs_in(alias_vdp_regs_in),
.vdp_regs_set(alias_vdp_regs_set),
.cram_A(alias_cram_A),
.cram_D(alias_cram_D),
.cram_wr(alias_cram_wr),
.vram_en(alias_vram_en),
.vram_A(alias_vram_A),
.vram_WE(alias_vram_WE),
.vram_WA(alias_vram_WA),
.vram_WD(alias_vram_WD),
.psg_in(alias_psg_in),
.psg_set(alias_psg_set),
.psg_ext_in(alias_psg_ext_in),
.psg2_ext_in(alias_psg2_ext_in),
.psg_div_in(alias_psg_div_in),
.audio_control_in(alias_audio_control_in),
.audio_last_in(alias_audio_last_in),
.audio_last_valid(alias_audio_last_valid),
.audio_phase_in(alias_audio_phase_in),
.audio_ext_set(alias_audio_ext_set),
.audio_phase_set(alias_audio_phase_set),
.audio_pending_tick(alias_audio_pending_tick),
.mapper_history_in(alias_mapper_history_in),
.mapper_in(alias_mapper_in),
.mapper_set(alias_mapper_set),
.evolution_in(alias_evolution_in),
.evolution_set(alias_evolution_set),
.ss_busy(alias_ss_busy),
.ss_capture_progress(alias_ss_capture_progress),
.eeprom_ext_in(alias_eeprom_ext_in),
.eeprom_full(alias_eeprom_full),
.nvram_refill(alias_nvram_refill),
.gun_in(alias_gun_in),
.gun_set(alias_gun_set),
.gun_valid(alias_gun_valid),
.paddle_in(alias_paddle_in),
.paddle_set(alias_paddle_set),
.paddle_valid(alias_paddle_valid),
.tap_in(alias_tap_in),
.tap_set(alias_tap_set),
.tap_valid(alias_tap_valid),
.sc_ram_restored(alias_sc_ram_restored),
.eeprom_in(alias_eeprom_in),
.eeprom_set(alias_eeprom_set),
.wram_A(alias_wram_A),
.wram_WE(alias_wram_WE),
.wram_WA(alias_wram_WA),
.wram_WD(alias_wram_WD),
.nvram_A(alias_nvram_A),
.nvram_WE(alias_nvram_WE),
.nvram_WA(alias_nvram_WA),
.nvram_WD(alias_nvram_WD),
.vdp2_regs_in(alias_vdp2_regs_in),
.vdp2_regs_set(alias_vdp2_regs_set),
.cram2_A(alias_cram2_A),
.cram2_D(alias_cram2_D),
.cram2_wr(alias_cram2_wr),
.vram2_en(alias_vram2_en),
.vram2_A(alias_vram2_A),
.vram2_WE(alias_vram2_WE),
.vram2_WA(alias_vram2_WA),
.vram2_WD(alias_vram2_WD),
.psg2_in(alias_psg2_in),
.psg2_set(alias_psg2_set),
.md_in(alias_md_in),
.md_set(alias_md_set),
.md_valid(alias_md_valid),
.gg_in(alias_gg_in),
.gg_set(alias_gg_set),
.io_in(alias_io_in),
.io_set(alias_io_set),
.video_state_in(alias_video_state_in),
.video_state_set(alias_video_state_set),
.DDRAM_ADDR(alias_DDRAM_ADDR),
.DDRAM_DIN(alias_DDRAM_DIN),
.DDRAM_BE(alias_DDRAM_BE),
.DDRAM_WE(alias_DDRAM_WE),
.DDRAM_RD(alias_DDRAM_RD),
.DDRAM_BURSTCNT(alias_DDRAM_BURSTCNT));
integer alias_cycles=0,alias_consumes=0,alias_inactive=0,alias_writes=0,alias_reads=0;
always @(posedge clk)begin
 alias_cycles++;
if(dut.fm_state_addr !== alias_fm_state_addr)$fatal(1,"ALIAS controller output fm_state_addr cycle%0d",alias_cycles);
if(dut.fm_state_read !== alias_fm_state_read)$fatal(1,"ALIAS controller output fm_state_read cycle%0d",alias_cycles);
if(dut.fm_state_write !== alias_fm_state_write)$fatal(1,"ALIAS controller output fm_state_write cycle%0d",alias_cycles);
if(dut.fm_state_wdata !== alias_fm_state_wdata)$fatal(1,"ALIAS controller output fm_state_wdata cycle%0d",alias_cycles);
if(dut.fm_legacy_reset !== alias_fm_legacy_reset)$fatal(1,"ALIAS controller output fm_legacy_reset cycle%0d",alias_cycles);
if(dut.fm_initialization_run !== alias_fm_initialization_run)$fatal(1,"ALIAS controller output fm_initialization_run cycle%0d",alias_cycles);
if(dut.ss_freeze !== alias_ss_freeze)$fatal(1,"ALIAS controller output ss_freeze cycle%0d",alias_cycles);
if(dut.ss_cpu_prepare !== alias_ss_cpu_prepare)$fatal(1,"ALIAS controller output ss_cpu_prepare cycle%0d",alias_cycles);
if(dut.z80_replay_t2 !== alias_z80_replay_t2)$fatal(1,"ALIAS controller output z80_replay_t2 cycle%0d",alias_cycles);
if(dut.clock_phase_in !== alias_clock_phase_in)$fatal(1,"ALIAS controller output clock_phase_in cycle%0d",alias_cycles);
if(dut.clock_phase_set !== alias_clock_phase_set)$fatal(1,"ALIAS controller output clock_phase_set cycle%0d",alias_cycles);
if(dut.bg_in !== alias_bg_in)$fatal(1,"ALIAS controller output bg_in cycle%0d",alias_cycles);
if(dut.bg2_in !== alias_bg2_in)$fatal(1,"ALIAS controller output bg2_in cycle%0d",alias_cycles);
if(dut.bg_valid !== alias_bg_valid)$fatal(1,"ALIAS controller output bg_valid cycle%0d",alias_cycles);
if(dut.sprite_in !== alias_sprite_in)$fatal(1,"ALIAS controller output sprite_in cycle%0d",alias_cycles);
if(dut.sprite2_in !== alias_sprite2_in)$fatal(1,"ALIAS controller output sprite2_in cycle%0d",alias_cycles);
if(dut.sprite_valid !== alias_sprite_valid)$fatal(1,"ALIAS controller output sprite_valid cycle%0d",alias_cycles);
if(dut.z80_restart_dir !== alias_z80_restart_dir)$fatal(1,"ALIAS controller output z80_restart_dir cycle%0d",alias_cycles);
if(dut.z80_restart_valid !== alias_z80_restart_valid)$fatal(1,"ALIAS controller output z80_restart_valid cycle%0d",alias_cycles);
if(dut.z80_nmi_dir !== alias_z80_nmi_dir)$fatal(1,"ALIAS controller output z80_nmi_dir cycle%0d",alias_cycles);
if(dut.z80_nmi_valid !== alias_z80_nmi_valid)$fatal(1,"ALIAS controller output z80_nmi_valid cycle%0d",alias_cycles);
if(dut.z80_nmi_hold !== alias_z80_nmi_hold)$fatal(1,"ALIAS controller output z80_nmi_hold cycle%0d",alias_cycles);
if(dut.z80_set !== alias_z80_set)$fatal(1,"ALIAS controller output z80_set cycle%0d",alias_cycles);
if(dut.vdp_regs_in !== alias_vdp_regs_in)$fatal(1,"ALIAS controller output vdp_regs_in cycle%0d",alias_cycles);
if(dut.vdp_regs_set !== alias_vdp_regs_set)$fatal(1,"ALIAS controller output vdp_regs_set cycle%0d",alias_cycles);
if(dut.cram_A !== alias_cram_A)$fatal(1,"ALIAS controller output cram_A cycle%0d",alias_cycles);
if(dut.cram_D !== alias_cram_D)$fatal(1,"ALIAS controller output cram_D cycle%0d",alias_cycles);
if(dut.cram_wr !== alias_cram_wr)$fatal(1,"ALIAS controller output cram_wr cycle%0d",alias_cycles);
if(dut.vram_en !== alias_vram_en)$fatal(1,"ALIAS controller output vram_en cycle%0d",alias_cycles);
if(dut.vram_A !== alias_vram_A)$fatal(1,"ALIAS controller output vram_A cycle%0d",alias_cycles);
if(dut.vram_WE !== alias_vram_WE)$fatal(1,"ALIAS controller output vram_WE cycle%0d",alias_cycles);
if(dut.vram_WA !== alias_vram_WA)$fatal(1,"ALIAS controller output vram_WA cycle%0d",alias_cycles);
if(dut.vram_WD !== alias_vram_WD)$fatal(1,"ALIAS controller output vram_WD cycle%0d",alias_cycles);
if(dut.psg_in !== alias_psg_in)$fatal(1,"ALIAS controller output psg_in cycle%0d",alias_cycles);
if(dut.psg_set !== alias_psg_set)$fatal(1,"ALIAS controller output psg_set cycle%0d",alias_cycles);
if(dut.psg_ext_in !== alias_psg_ext_in)$fatal(1,"ALIAS controller output psg_ext_in cycle%0d",alias_cycles);
if(dut.psg2_ext_in !== alias_psg2_ext_in)$fatal(1,"ALIAS controller output psg2_ext_in cycle%0d",alias_cycles);
if(dut.psg_div_in !== alias_psg_div_in)$fatal(1,"ALIAS controller output psg_div_in cycle%0d",alias_cycles);
if(dut.audio_control_in !== alias_audio_control_in)$fatal(1,"ALIAS controller output audio_control_in cycle%0d",alias_cycles);
if(dut.audio_last_in !== alias_audio_last_in)$fatal(1,"ALIAS controller output audio_last_in cycle%0d",alias_cycles);
if(dut.audio_last_valid !== alias_audio_last_valid)$fatal(1,"ALIAS controller output audio_last_valid cycle%0d",alias_cycles);
if(dut.audio_phase_in !== alias_audio_phase_in)$fatal(1,"ALIAS controller output audio_phase_in cycle%0d",alias_cycles);
if(dut.audio_ext_set !== alias_audio_ext_set)$fatal(1,"ALIAS controller output audio_ext_set cycle%0d",alias_cycles);
if(dut.audio_phase_set !== alias_audio_phase_set)$fatal(1,"ALIAS controller output audio_phase_set cycle%0d",alias_cycles);
if(dut.audio_pending_tick !== alias_audio_pending_tick)$fatal(1,"ALIAS controller output audio_pending_tick cycle%0d",alias_cycles);
if(dut.mapper_history_in !== alias_mapper_history_in)$fatal(1,"ALIAS controller output mapper_history_in cycle%0d",alias_cycles);
if(dut.mapper_in !== alias_mapper_in)$fatal(1,"ALIAS controller output mapper_in cycle%0d",alias_cycles);
if(dut.mapper_set !== alias_mapper_set)$fatal(1,"ALIAS controller output mapper_set cycle%0d",alias_cycles);
if(dut.evolution_in !== alias_evolution_in)$fatal(1,"ALIAS controller output evolution_in cycle%0d",alias_cycles);
if(dut.evolution_set !== alias_evolution_set)$fatal(1,"ALIAS controller output evolution_set cycle%0d",alias_cycles);
if(dut.ss_busy !== alias_ss_busy)$fatal(1,"ALIAS controller output ss_busy cycle%0d",alias_cycles);
if(dut.ss_capture_progress !== alias_ss_capture_progress)$fatal(1,"ALIAS controller output ss_capture_progress cycle%0d",alias_cycles);
if(dut.eeprom_ext_in !== alias_eeprom_ext_in)$fatal(1,"ALIAS controller output eeprom_ext_in cycle%0d",alias_cycles);
if(dut.eeprom_full !== alias_eeprom_full)$fatal(1,"ALIAS controller output eeprom_full cycle%0d",alias_cycles);
if(dut.nvram_refill !== alias_nvram_refill)$fatal(1,"ALIAS controller output nvram_refill cycle%0d",alias_cycles);
if(dut.gun_in !== alias_gun_in)$fatal(1,"ALIAS controller output gun_in cycle%0d",alias_cycles);
if(dut.gun_set !== alias_gun_set)$fatal(1,"ALIAS controller output gun_set cycle%0d",alias_cycles);
if(dut.gun_valid !== alias_gun_valid)$fatal(1,"ALIAS controller output gun_valid cycle%0d",alias_cycles);
if(dut.paddle_in !== alias_paddle_in)$fatal(1,"ALIAS controller output paddle_in cycle%0d",alias_cycles);
if(dut.paddle_set !== alias_paddle_set)$fatal(1,"ALIAS controller output paddle_set cycle%0d",alias_cycles);
if(dut.paddle_valid !== alias_paddle_valid)$fatal(1,"ALIAS controller output paddle_valid cycle%0d",alias_cycles);
if(dut.tap_in !== alias_tap_in)$fatal(1,"ALIAS controller output tap_in cycle%0d",alias_cycles);
if(dut.tap_set !== alias_tap_set)$fatal(1,"ALIAS controller output tap_set cycle%0d",alias_cycles);
if(dut.tap_valid !== alias_tap_valid)$fatal(1,"ALIAS controller output tap_valid cycle%0d",alias_cycles);
if(dut.sc_ram_restored !== alias_sc_ram_restored)$fatal(1,"ALIAS controller output sc_ram_restored cycle%0d",alias_cycles);
if(dut.eeprom_in !== alias_eeprom_in)$fatal(1,"ALIAS controller output eeprom_in cycle%0d",alias_cycles);
if(dut.eeprom_set !== alias_eeprom_set)$fatal(1,"ALIAS controller output eeprom_set cycle%0d",alias_cycles);
if(dut.wram_A !== alias_wram_A)$fatal(1,"ALIAS controller output wram_A cycle%0d",alias_cycles);
if(dut.wram_WE !== alias_wram_WE)$fatal(1,"ALIAS controller output wram_WE cycle%0d",alias_cycles);
if(dut.wram_WA !== alias_wram_WA)$fatal(1,"ALIAS controller output wram_WA cycle%0d",alias_cycles);
if(dut.wram_WD !== alias_wram_WD)$fatal(1,"ALIAS controller output wram_WD cycle%0d",alias_cycles);
if(dut.nvram_A !== alias_nvram_A)$fatal(1,"ALIAS controller output nvram_A cycle%0d",alias_cycles);
if(dut.nvram_WE !== alias_nvram_WE)$fatal(1,"ALIAS controller output nvram_WE cycle%0d",alias_cycles);
if(dut.nvram_WA !== alias_nvram_WA)$fatal(1,"ALIAS controller output nvram_WA cycle%0d",alias_cycles);
if(dut.nvram_WD !== alias_nvram_WD)$fatal(1,"ALIAS controller output nvram_WD cycle%0d",alias_cycles);
if(dut.vdp2_regs_in !== alias_vdp2_regs_in)$fatal(1,"ALIAS controller output vdp2_regs_in cycle%0d",alias_cycles);
if(dut.vdp2_regs_set !== alias_vdp2_regs_set)$fatal(1,"ALIAS controller output vdp2_regs_set cycle%0d",alias_cycles);
if(dut.cram2_A !== alias_cram2_A)$fatal(1,"ALIAS controller output cram2_A cycle%0d",alias_cycles);
if(dut.cram2_D !== alias_cram2_D)$fatal(1,"ALIAS controller output cram2_D cycle%0d",alias_cycles);
if(dut.cram2_wr !== alias_cram2_wr)$fatal(1,"ALIAS controller output cram2_wr cycle%0d",alias_cycles);
if(dut.vram2_en !== alias_vram2_en)$fatal(1,"ALIAS controller output vram2_en cycle%0d",alias_cycles);
if(dut.vram2_A !== alias_vram2_A)$fatal(1,"ALIAS controller output vram2_A cycle%0d",alias_cycles);
if(dut.vram2_WE !== alias_vram2_WE)$fatal(1,"ALIAS controller output vram2_WE cycle%0d",alias_cycles);
if(dut.vram2_WA !== alias_vram2_WA)$fatal(1,"ALIAS controller output vram2_WA cycle%0d",alias_cycles);
if(dut.vram2_WD !== alias_vram2_WD)$fatal(1,"ALIAS controller output vram2_WD cycle%0d",alias_cycles);
if(dut.psg2_in !== alias_psg2_in)$fatal(1,"ALIAS controller output psg2_in cycle%0d",alias_cycles);
if(dut.psg2_set !== alias_psg2_set)$fatal(1,"ALIAS controller output psg2_set cycle%0d",alias_cycles);
if(dut.md_in !== alias_md_in)$fatal(1,"ALIAS controller output md_in cycle%0d",alias_cycles);
if(dut.md_set !== alias_md_set)$fatal(1,"ALIAS controller output md_set cycle%0d",alias_cycles);
if(dut.md_valid !== alias_md_valid)$fatal(1,"ALIAS controller output md_valid cycle%0d",alias_cycles);
if(dut.gg_in !== alias_gg_in)$fatal(1,"ALIAS controller output gg_in cycle%0d",alias_cycles);
if(dut.gg_set !== alias_gg_set)$fatal(1,"ALIAS controller output gg_set cycle%0d",alias_cycles);
if(dut.io_in !== alias_io_in)$fatal(1,"ALIAS controller output io_in cycle%0d",alias_cycles);
if(dut.io_set !== alias_io_set)$fatal(1,"ALIAS controller output io_set cycle%0d",alias_cycles);
if(dut.video_state_in !== alias_video_state_in)$fatal(1,"ALIAS controller output video_state_in cycle%0d",alias_cycles);
if(dut.video_state_set !== alias_video_state_set)$fatal(1,"ALIAS controller output video_state_set cycle%0d",alias_cycles);
if(dut.DDRAM_ADDR !== alias_DDRAM_ADDR)$fatal(1,"ALIAS controller output DDRAM_ADDR cycle%0d",alias_cycles);
if(dut.DDRAM_DIN !== alias_DDRAM_DIN)$fatal(1,"ALIAS controller output DDRAM_DIN cycle%0d",alias_cycles);
if(dut.DDRAM_BE !== alias_DDRAM_BE)$fatal(1,"ALIAS controller output DDRAM_BE cycle%0d",alias_cycles);
if(dut.DDRAM_WE !== alias_DDRAM_WE)$fatal(1,"ALIAS controller output DDRAM_WE cycle%0d",alias_cycles);
if(dut.DDRAM_RD !== alias_DDRAM_RD)$fatal(1,"ALIAS controller output DDRAM_RD cycle%0d",alias_cycles);
if(dut.DDRAM_BURSTCNT !== alias_DDRAM_BURSTCNT)$fatal(1,"ALIAS controller output DDRAM_BURSTCNT cycle%0d",alias_cycles);
if(dut.z80_set)begin alias_consumes++;if(dut.z80_dir!==alias_z80_dir)$fatal(1,"ALIAS consumed DIR mismatch");end
else if(dut.z80_dir!==alias_z80_dir)alias_inactive++;
if(dut.DDRAM_WE&&!dut.DDRAM_BUSY)alias_writes++;
if(dut.DDRAM_RD&&!dut.DDRAM_BUSY)alias_reads++;
end
final $display("ALIAS MITER cycles%0d consumes%0d inactive%0d writes%0d reads%0d",alias_cycles,alias_consumes,alias_inactive,alias_writes,alias_reads);
wire[$bits(dinput)-1:0]alias_cpu_nmi_n;
wire[$bits(diq)-1:0]alias_cpu_iq;
wire[$bits(drd)-1:0]alias_cpu_rd;
wire[$bits(dwr)-1:0]alias_cpu_wr;
wire[$bits(dmreq)-1:0]alias_cpu_mreq;
wire[$bits(dm1)-1:0]alias_cpu_m1;
wire[$bits(z80_iset)-1:0]alias_cpu_iset;
wire[$bits(ddi)-1:0]alias_cpu_di;
wire[$bits(dd)-1:0]alias_cpu_data;
wire[$bits(da)-1:0]alias_cpu_addr;
wire[$bits(io_out)-1:0]alias_cpu_io_out;
wire[$bits(gg_out)-1:0]alias_cpu_gg_out;
wire[$bits(ready)-1:0]alias_cpu_ready;
wire[$bits(replay)-1:0]alias_cpu_nmi_replay;
wire[$bits(dold)-1:0]alias_cpu_old_nmi;
wire[$bits(dn)-1:0]alias_cpu_nstate;
wire[$bits(nmi_snap)-1:0]alias_cpu_nmi_snap;
wire[$bits(z80_reg)-1:0]alias_cpu_cpu_reg;
wire[$bits(wram_D)-1:0]alias_cpu_wram_D;
wire[$bits(restart_out)-1:0]alias_cpu_restart_out;
nmi_machine #(.SOURCE(SOURCE),.PROGRAM(PROGRAM)) alias_cpu(.prepare(protocol_prepare),.replay_t2(replay_t2),.restart_out(alias_cpu_restart_out),.restart_dir(restart_dir),.restart_valid(restart_valid),.clk(clk),.mrst(mrst),.cpu_ce(cpu_ce),.ss_freeze(alias_ss_freeze),.pause_n(dpause),.link_pins(dpins),.cpu_dir(alias_z80_dir),.cpu_set(alias_z80_set),.nmi_dir(nmi_dir),.nmi_valid(nmi_valid),.nmi_hold(nmi_hold),.gg_in(alias_gg_in),.gg_set(alias_gg_set),.io_in(alias_io_in),.io_set(alias_io_set),.wram_A(alias_wram_A),.wram_WA(alias_wram_WA),.wram_WD(alias_wram_WD),.wram_WE(alias_wram_WE),.wram_D(alias_cpu_wram_D),.cpu_reg(alias_cpu_cpu_reg),.nmi_snap(alias_cpu_nmi_snap),.nstate(alias_cpu_nstate),.old_nmi(alias_cpu_old_nmi),.nmi_replay(alias_cpu_nmi_replay),.ready(alias_cpu_ready),.gg_out(alias_cpu_gg_out),.io_out(alias_cpu_io_out),.addr(alias_cpu_addr),.data(alias_cpu_data),.di(alias_cpu_di),.iset(alias_cpu_iset),.m1(alias_cpu_m1),.mreq(alias_cpu_mreq),.wr(alias_cpu_wr),.rd(alias_cpu_rd),.iq(alias_cpu_iq),.nmi_n(alias_cpu_nmi_n));
always@(posedge clk)begin #1;if(alias_cpu_nmi_n!==dinput)$fatal(1,"ALIAS real CPU nmi_n");
if(alias_cpu_iq!==diq)$fatal(1,"ALIAS real CPU iq");
if(alias_cpu_rd!==drd)$fatal(1,"ALIAS real CPU rd");
if(alias_cpu_wr!==dwr)$fatal(1,"ALIAS real CPU wr");
if(alias_cpu_mreq!==dmreq)$fatal(1,"ALIAS real CPU mreq");
if(alias_cpu_m1!==dm1)$fatal(1,"ALIAS real CPU m1");
if(alias_cpu_iset!==z80_iset)$fatal(1,"ALIAS real CPU iset");
if(alias_cpu_di!==ddi)$fatal(1,"ALIAS real CPU di");
if(alias_cpu_data!==dd)$fatal(1,"ALIAS real CPU data");
if(alias_cpu_addr!==da)$fatal(1,"ALIAS real CPU addr");
if(alias_cpu_io_out!==io_out)$fatal(1,"ALIAS real CPU io_out");
if(alias_cpu_gg_out!==gg_out)$fatal(1,"ALIAS real CPU gg_out");
if(alias_cpu_ready!==ready)$fatal(1,"ALIAS real CPU ready");
if(alias_cpu_nmi_replay!==replay)$fatal(1,"ALIAS real CPU nmi_replay");
if(alias_cpu_old_nmi!==dold)$fatal(1,"ALIAS real CPU old_nmi");
if(alias_cpu_nstate!==dn)$fatal(1,"ALIAS real CPU nstate");
if(alias_cpu_nmi_snap!==nmi_snap)$fatal(1,"ALIAS real CPU nmi_snap");
if(alias_cpu_cpu_reg!==z80_reg)$fatal(1,"ALIAS real CPU cpu_reg");
if(alias_cpu_wram_D!==wram_D)$fatal(1,"ALIAS real CPU wram_D");
if(alias_cpu_restart_out!==restart_out)$fatal(1,"ALIAS real CPU restart_out");
end
endmodule
