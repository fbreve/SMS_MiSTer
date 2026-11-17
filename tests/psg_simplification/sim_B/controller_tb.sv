`timescale 1ns/1ps
module controller_tb;
reg clk='0;
reg reset_n='0;
reg ss_save='0;
reg ss_load='0;
reg [1:0] ss_slot='0;
reg ss_bios_mode='0;
reg [31:0] ss_game_id='0;
wire ss_freeze;
reg vblank='0;
reg [8:0] x='0;
reg [229:0] z80_reg='0;
wire [229:0] z80_dir;
wire z80_set;
reg z80_m1_n='0;
reg z80_mreq_n='0;
reg [1:0] z80_iset='0;
reg cpu_ce='0;
reg vdp_ce='0;
reg pix_ce='0;
reg sp_ce='0;
reg [127:0] vdp_regs='0;
wire [127:0] vdp_regs_in;
wire vdp_regs_set;
reg [383:0] cram_out='0;
wire [4:0] cram_A;
wire [11:0] cram_D;
wire cram_wr;
wire vram_en;
wire [14:0] vram_A;
reg [7:0] vram_D='0;
wire vram_WE;
wire [14:0] vram_WA;
wire [7:0] vram_WD;
wire [55:0] psg_out;
wire [55:0] psg_in;
wire psg_set;
reg [63:0] mapper_out='0;
wire [63:0] mapper_in;
wire mapper_set;
reg [95:0] evolution_out='0;
wire [95:0] evolution_in;
wire evolution_set;
reg [63:0] eeprom_out='0;
wire [63:0] eeprom_in;
wire eeprom_set;
wire [13:0] wram_A;
reg [7:0] wram_D='0;
wire wram_WE;
wire [13:0] wram_WA;
wire [7:0] wram_WD;
wire [14:0] nvram_A;
reg [7:0] nvram_D='0;
wire nvram_WE;
wire [14:0] nvram_WA;
wire [7:0] nvram_WD;
reg systeme='0;
reg [127:0] vdp2_regs='0;
wire [127:0] vdp2_regs_in;
wire vdp2_regs_set;
reg [383:0] cram2_out='0;
wire [4:0] cram2_A;
wire [11:0] cram2_D;
wire cram2_wr;
wire vram2_en;
wire [14:0] vram2_A;
reg [7:0] vram2_D='0;
wire vram2_WE;
wire [14:0] vram2_WA;
wire [7:0] vram2_WD;
wire [55:0] psg2_out;
wire [55:0] psg2_in;
wire psg2_set;
reg [31:0] io_out='0;
wire [31:0] io_in;
wire io_set;
reg [21:0] video_state_out='0;
wire [21:0] video_state_in;
wire video_state_set;
wire [28:0] DDRAM_ADDR;
wire [63:0] DDRAM_DIN;
wire [7:0] DDRAM_BE;
wire DDRAM_WE;
reg [63:0] DDRAM_DOUT='0;
reg DDRAM_DOUT_READY='0;
wire DDRAM_RD;
wire [7:0] DDRAM_BURSTCNT;
reg DDRAM_BUSY='0;
wire [10:0] audio_control_out;reg [10:0] audio_control_in=0;
savestates dut(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg wr1=1,wr2=1;reg [7:0] din=0;reg detwr=1,balwr=1;
wire signed [10:0] l,r,l2,r2;
jt89 p1(.clk(clk),.clk_en(cpu_ce&&!ss_freeze),.rst(!reset_n),.wr_n(wr1),.din(din),.mux(audio_control_out[7:0]),.soundL(l),.soundR(r),.ready(),.ss_out(psg_out),.ss_in(psg_in),.ss_set(psg_set));
jt89 p2(.clk(clk),.clk_en(cpu_ce&&!ss_freeze),.rst(!reset_n),.wr_n(wr2),.din(din),.mux(8'hff),.soundL(l2),.soundR(r2),.ready(),.ss_out(psg2_out),.ss_in(psg2_in),.ss_set(psg2_set));
controls ctl(.clk_sys(clk),.RESET_n(reset_n),.ss_freeze(ss_freeze),.psg_set(psg_set),.audio_ext_set(1'b0),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(audio_control_in),.audio_control_out(audio_control_out));
wire signed[15:0] al,ar;
AudioMix mix(.clk(clk),.audio_in_l1({l,5'd0}),.audio_in_r1({r,5'd0}),.audio_in_l2(systeme?{l2,5'd0}:16'd0),.audio_in_r2(systeme?{r2,5'd0}:16'd0),.audio_l(al),.audio_r(ar));
reg [63:0] memory[0:98303];integer cycles=0,pending=0,writes=0,reads=0,loads=0,loads2=0,ops=0,stalled=0,rejected=0;
reg [28:0] ra;reg stalls=0;reg [31:0] rng=32'h7a9d321b;
reg[229:0] saved_cpu;reg[127:0] saved_vdp;reg[55:0] saved_psg,saved_psg2;reg[10:0] saved_controls,changed_controls;
integer cram_writes=0,ram_writes=0,restores=0,last_accept=0;
reg[28:0] held_addr;reg[63:0]held_data;reg[7:0]held_be;reg held_rd,held_we,holding=0;
always @(negedge clk)begin
 cycles=cycles+1;cpu_ce=cycles%15==0;vdp_ce=cycles%10==0;pix_ce=cycles%10==0;sp_ce=cycles%5==0;
 rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};DDRAM_BUSY=stalls&&(rng[3:0]<4);if(DDRAM_BUSY)stalled=stalled+1;
end
always @(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=memory[ra-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(holding && {DDRAM_RD,DDRAM_WE,DDRAM_ADDR,DDRAM_DIN,DDRAM_BE} !== {held_rd,held_we,held_addr,held_data,held_be})$fatal(1,"stalled request changed");
 holding=(DDRAM_RD||DDRAM_WE)&&DDRAM_BUSY;held_rd=DDRAM_RD;held_we=DDRAM_WE;held_addr=DDRAM_ADDR;held_data=DDRAM_DIN;held_be=DDRAM_BE;
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  if(DDRAM_ADDR<29'h07c00000||DDRAM_ADDR>=29'h07c18000)$fatal(1,"write out of slot range");
  for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])memory[DDRAM_ADDR-29'h07c00000][8*b+:8]<=DDRAM_DIN[8*b+:8];writes=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap");pending<=2+(rng[7:4]%5);ra<=DDRAM_ADDR;reads=reads+1;end
 if(z80_set)begin if(z80_dir!==saved_cpu)$fatal(1,"CPU roundtrip");loads=loads+1;end
 if(vdp_regs_set&&vdp_regs_in!==saved_vdp)$fatal(1,"VDP roundtrip");
 if(psg_set&&psg_in!==saved_psg)$fatal(1,"PSG1 payload");
 if(psg2_set)begin if(psg2_in!==saved_psg2)$fatal(1,"PSG2 payload");loads2=loads2+1;end
 if(cram_wr||cram2_wr)cram_writes=cram_writes+1;
 if(vram_WE||vram2_WE||wram_WE||nvram_WE)ram_writes=ram_writes+1;
 if(z80_set||vdp_regs_set||psg_set||mapper_set||io_set||eeprom_set||evolution_set||video_state_set||psg2_set||vdp2_regs_set)restores=restores+1;
 if(vram_WE&&vram_WD!==8'ha1)$fatal(1,"VRAM data");
 if(vram2_WE&&vram2_WD!==8'ha3)$fatal(1,"VRAM2 data");
 if(wram_WE&&wram_WD!==8'hb2)$fatal(1,"WRAM data");
 if(nvram_WE&&nvram_WD!==8'hc3)$fatal(1,"NVRAM data");
end
task tick;begin @(negedge clk);#2;end endtask
task put(input integer chip,input[7:0]b);begin din=b;wr1=chip==1?0:1;wr2=chip==2?0:1;repeat(2)tick;wr1=1;wr2=1;repeat(3)tick;end endtask
task controls_write(input[10:0]c);begin din={5'd0,c[10:8]};detwr=0;tick;detwr=1;din=c[7:0];balwr=0;tick;balwr=1;tick;end endtask
task operation(input bit saving);integer start_cycle;begin
 force dut.op_cooldown=0;start_cycle=cycles;
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);wait(dut.state==0);repeat(4)tick;release dut.op_cooldown;ops=ops+1;
 $display("operation=%0d saving=%0d mode=%0d bios=%0d slot=%0d cycles=%0d",ops,saving,systeme,ss_bios_mode,ss_slot,cycles-start_cycle);
end endtask
integer base,prior_loads,prior_restores,prior_ram,prior_cram;reg[63:0]oldword;
task reject(input integer offset,input[63:0]bad);begin
 oldword=memory[base+offset];memory[base+offset]=bad;prior_loads=loads;prior_restores=restores;prior_ram=ram_writes;prior_cram=cram_writes;
 operation(0);
 if(loads!=prior_loads||restores!=prior_restores||ram_writes!=prior_ram||cram_writes!=prior_cram)$fatal(1,"rejected image modified live state");
 memory[base+offset]=oldword;rejected=rejected+1;
end endtask
initial begin
 for(integer i=0;i<98304;i=i+1)memory[i]=64'hdeadbeefdeadbeef;
 repeat(6)tick;reset_n=1;vblank=1;x=0;ss_game_id=32'h12345678;
 vram_D=8'ha1;vram2_D=8'ha3;wram_D=8'hb2;nvram_D=8'hc3;cram_out='1;cram2_out=0;
 for(integer t=0;t<8;t=t+1)begin
  systeme=t%2;ss_bios_mode=(t/2)%2;ss_slot=t%4;stalls=t>=4;
  mapper_out=systeme?64'h60:64'h1000000000000;
  saved_cpu={102'h1923,128'h0123456789abcdef0011223344556677}^t;saved_vdp=128'hfedcba98765432100123456789abcdef^t;
  z80_reg=saved_cpu;vdp_regs=saved_vdp;vdp2_regs=~saved_vdp;video_state_out=22'h12345;
  put(1,8'h8d);put(1,8'h02);put(1,8'h91);put(1,8'he0|t);put(1,8'hf2);
  put(2,8'haf);put(2,8'h0b);put(2,8'hb3);put(2,8'he7);put(2,8'hf1);
  saved_controls={3'(t),8'ha5^8'(t)};controls_write(saved_controls);repeat(7)tick;
  saved_psg=psg_out;saved_psg2=psg2_out;operation(1);
  base=(ss_bios_mode?16'hc000:0)+ss_slot*16'h3000;
  if(memory[base][63:32]!=24574)$fatal(1,"size header");
  if(memory[base+1][31:0]!== (ss_bios_mode?32'h53424201:32'h534d4201))$fatal(1,"version");
  if(memory[base+32]!==64'hdeadbeefdeadbeef)$fatal(1,"obsolete extension written");
  changed_controls=~saved_controls;controls_write(changed_controls);put(1,8'h9f);put(2,8'hbf);repeat(113)tick;
  operation(0);if(psg_out!==saved_psg||systeme&&psg2_out!==saved_psg2)$fatal(1,"actual JT89 configuration restore");
  if(audio_control_out!==changed_controls)$fatal(1,"architectural control contract");
  // Repeat loading the same image after a new history and control write.
  controls_write(changed_controls);repeat(47)tick;operation(0);
  if(audio_control_out!==changed_controls)$fatal(1,"repeated controls");
 end
 // Reject before any live state writes: size, production, cross-candidate,
 // future version, wrong game, wrong mode, and (B) reserved PSG bits.
 reject(0,{32'd16382,memory[base][31:0]});reject(0,{32'd24575,memory[base][31:0]});
 reject(1,{ss_game_id,32'h534d5331});reject(1,{ss_game_id,32'h53424301});reject(1,{ss_game_id,32'h53424202});
 reject(1,{32'h87654321,memory[base+1][31:0]});
 reject(14,memory[base+14]^(64'd1<<52));
 reject(14,memory[base+14]^(64'd1<<63));
 if(loads!=16||loads2!=8||stalled==0||writes<1000||reads<1000)$fatal(1,"coverage");
 $display("PASS controller B: cycles=%0d ops=%0d loads=%0d PSG2=%0d safe_rejections=%0d reads=%0d writes=%0d busy=%0d controls=intentionally_not_restored",cycles,ops,loads,loads2,rejected,reads,writes,stalled);$finish;
end
initial begin #500000000;$fatal(1,"timeout state=%0d ops=%0d",dut.state,ops);end
endmodule
