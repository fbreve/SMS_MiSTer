`timescale 1ns/1ps
module stalled_tb;
parameter SOURCE=0,PROGRAM=0,EDGE=-15,WIDTH=5,SECOND=9999999,HELD=0,SCHEDULE=0,FORMAT=0,REPLAYS=3;
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
savestates dut(.z80_nmi(nmi_snap),.z80_nmi_dir(nmi_dir),.z80_nmi_valid(nmi_valid),.z80_nmi_hold(nmi_hold),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.ss_capture_progress(),.mapper_history_out(18'h0ffff),.mapper_history_in(),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
always @(negedge clk) DDRAM_BUSY=(cycle%97<7)||(cycle%71<3);
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

localparam LENGTH=6000;
reg mrst=0,dpause=1,rpause=1,ref_done=0;
reg[6:0]dpins=7'h7f,rpins=7'h7f;
wire[12:0]dn,rn;wire dold,rold,replay,ready,rready,dmreq,dm1,dwr,drd,diq,dinput;
wire[15:0]da,ra;wire[7:0]dd,ddi,rdout,rdi;
wire[229:0]rr;wire[127:0]rgg;wire[31:0]rio;wire rm1,rmreq,rwr,rrd,riq;
nmi_machine #(.SOURCE(SOURCE),.PROGRAM(PROGRAM)) core(.clk(clk),.mrst(mrst),.cpu_ce(cpu_ce),.ss_freeze(ss_freeze),.pause_n(dpause),.link_pins(dpins),.cpu_dir(z80_dir),.cpu_set(z80_set),.nmi_dir(nmi_dir),.nmi_valid(nmi_valid),.nmi_hold(nmi_hold),.gg_in(gg_in),.gg_set(gg_set),.io_in(io_in),.io_set(io_set),.wram_A(wram_A),.wram_WA(wram_WA),.wram_WD(wram_WD),.wram_WE(wram_WE),.wram_D(wram_D),.cpu_reg(z80_reg),.nmi_snap(nmi_snap),.nstate(dn),.old_nmi(dold),.nmi_replay(replay),.ready(ready),.gg_out(gg_out),.io_out(io_out),.addr(da),.data(dd),.di(ddi),.iset(z80_iset),.m1(dm1),.mreq(dmreq),.wr(dwr),.rd(drd),.iq(diq),.nmi_n(dinput));
nmi_machine #(.SOURCE(SOURCE),.PROGRAM(PROGRAM)) reference(.clk(clk),.mrst(mrst),.cpu_ce(cpu_ce),.ss_freeze(ref_done),.pause_n(rpause),.link_pins(rpins),.cpu_dir(230'd0),.cpu_set(1'b0),.nmi_dir(3'b001),.nmi_valid(1'b0),.nmi_hold(1'b0),.gg_in(128'd0),.gg_set(1'b0),.io_in(32'd0),.io_set(1'b0),.wram_A(14'd0),.wram_WA(14'd0),.wram_WD(8'd0),.wram_WE(1'b0),.wram_D(),.cpu_reg(rr),.nmi_snap(),.nstate(rn),.old_nmi(rold),.nmi_replay(),.ready(rready),.gg_out(rgg),.io_out(rio),.addr(ra),.data(rdout),.di(rdi),.iset(),.m1(rm1),.mreq(rmreq),.wr(rwr),.rd(rrd),.iq(riq),.nmi_n());
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
 force dut.op_cooldown=0;tick;if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;release dut.op_cooldown;
end endtask
initial begin
 for(integer i=0;i<12288;i=i+1)mem[i]=0;
 repeat(4)tick;reset_n=1;audio_quiescent=1;ss_game_id='hf1600030;
 while(!(vblank&&x<64))tick;mrst=1;wait(ready_cycle!=0);
 fork
  begin while(cycle<ready_cycle+359+EDGE)tick;if(!accepted)begin dlevel(1);rlevel(1);end if(WIDTH>0)begin repeat(WIDTH)tick;if(!accepted)begin dlevel(0);rlevel(0);end end end
  begin while(cycle<ready_cycle+359+SECOND)tick;if(!accepted)begin dlevel(1);rlevel(1);end end
  begin while(cycle<ready_cycle+300)tick;trigger(1);end
 join_none
 wait(accepted);wait(ss_freeze);wait(!ss_freeze);wait(ref_done);
 $writememh($sformatf("stalled_image_s%0d_p%0d_e%0d_w%0d_h%0d_second%0d.hex",SOURCE,PROGRAM,EDGE,WIDTH,HELD,SECOND),mem);
 if(mem['h1a][63:40]!==24'h48430c||mem[5][63:41]!==0||mem[5][40:38]!==captured)$fatal(1,"v12 payload");
 stage=1;d_index=(cycle-accepted_cycle)%15;follow_d=1;
 for(integer j=1;j<=400;j=j+1)begin
  @(posedge clk);while(!cpu_ce)@(posedge clk);#2;compare(j*15);
 end
 follow_d=0;$display("SAVE_ONLY exact ticks400 counter%0d",core.ram['h100]);
 if(FORMAT>0&&FORMAT<=11)begin mem['h1a][63:40]=24'h484300+FORMAT;mem[5][63:38]=26'h3ffffff;end
 if(FORMAT==99)begin mem[0][63:32]=32'h3ffe;mem['he][63:56]=0;mem[5][63:20]=0;end
 if(FORMAT>=100&&FORMAT<=122)mem[5][41+FORMAT-100]=1;
 if(FORMAT==123)mem['h1a][39:38]=2;
 for(iteration=0;iteration<REPLAYS;iteration=iteration+1)begin
  stage=2;dlevel(iteration!=0);repeat(120+iteration*375)tick;dlevel(HELD!=0);repeat(100)tick;
  if(FORMAT>=100)begin
   integer beforedirs;beforedirs=dirs;trigger(0);wait(ss_freeze);wait(!ss_freeze);if(dirs!=beforedirs)$fatal(1,"Malformed image applied CPU state");repeat(40)tick;
   $display("REJECT format%0d iter%0d",FORMAT,iteration);
  end else begin
   trigger(0);wait(replay);wait(!replay);#2;loads=loads+1;
   stage=3;
   if(FORMAT==0)compare(0);
   else if(dn[12:11]!==0)$fatal(1,"Legacy retained NMI flags");
   d_index=0;follow_d=1;
   for(integer k=1;k<=LENGTH;k=k+1)begin
    @(posedge clk);#2;if(FORMAT==0)compare(k);
   end
   follow_d=0;
   if(FORMAT==0)begin for(integer a=0;a<8192;a=a+1)if(core.ram[a]!==golden_ram[a])$fatal(1,"WRAM mismatch %h",a);end
   else if(core.ram['h100]!==0)$fatal(1,"Legacy invented handler");
   $display("REPLAY iter%0d counter%0d signature%0d normalized%b",iteration,core.ram['h100],core.ram['h102],captured);
  end
 end
 $display("PASS F16 fixed source%0d program%0d edge%0d held%0d format%0d loads%0d comparisons%0d",SOURCE,PROGRAM,EDGE,HELD,FORMAT,loads,compare_count);$finish;
end
always @(posedge clk)if(FORMAT>=100&&ss_freeze&&(wram_WE||vram_WE||nvram_WE||vram2_WE||z80_set||mapper_set||evolution_set||gg_set||io_set||eeprom_set||gun_set||paddle_set||tap_set||vdp_regs_set||vdp2_regs_set||psg_set||psg2_set||cram_wr||cram2_wr||video_state_set||audio_ext_set||audio_phase_set))$fatal(1,"Malformed image wrote guest state");
initial begin repeat(12000000)tick;$fatal(1,"watchdog");end
endmodule
