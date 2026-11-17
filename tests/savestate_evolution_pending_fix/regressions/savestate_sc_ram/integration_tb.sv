`timescale 1ns/1ps
module sc_integration;parameter STALL=0;
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
reg [63:0] mapper_out = '0;
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
wire[7:0]nvram_D;
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
savestates dut(.mapper_history_out(18'h0ffff),.mapper_history_in(),.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.gun_out(gun_out),.gun_in(gun_in),.gun_set(gun_set),.gun_valid(gun_valid),.paddle_out(paddle_out),.paddle_in(paddle_in),.paddle_set(paddle_set),.paddle_valid(paddle_valid),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
reg[15:0]lfsr=16'h1ace;always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;lfsr={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?lfsr[3:0]<12:0);end
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
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg sc=1;reg[1:0]cfg=1;reg[15:0]a=0;reg[7:0]di=0;reg wr=1,mreq=1;wire we;wire[7:0]q;
wire[14:0]pa=cfg==1?{4'd0,a[10:0]}:cfg==2?{1'b0,a[13:0]}:a[14:0];
memory_bus bus(.A(a),.sc3000_en(sc),.sc_cart_ram(cfg),.mapper_castle(1'b0),.sc_multicart_en(1'b0),.WR_n(wr),.RD_n(1'b0),.MREQ_n(mreq),.ss_freeze(ss_freeze),.mapper_eeprom(1'b0),.nvram_e(1'b0),.nvram_ex(1'b0),.nvram_cme(1'b0),.dahjee_cart_access(1'b0),.eeprom_bus_active(1'b0),.eeprom_D_out(8'd0),.nvram_D_out(nvram_D),.ram_D_out(8'h66),.irom_D_out(8'h99),.ram_WR(),.rom_RD(),.nvram_WR(we),.memory_D_out(q));
dpram #(.widthad_a(15),.init_file("UNUSED")) ram(.clock_a(clk),.address_a(ss_freeze?(nvram_WE?nvram_WA:nvram_A):pa),.data_a(ss_freeze?nvram_WD:di),.wren_a(ss_freeze?nvram_WE:we),.q_a(nvram_D),.clock_b(clk),.address_b(15'd0),.data_b(8'd0),.wren_b(1'b0),.q_b());
integer size,k,i,mode,variant;reg[7:0]expectation[0:32767];integer payload_writes=0,payload_reads=0;reg counting=0;
always @(posedge clk)if(counting&&DDRAM_ADDR>=29'h07c00d01&&DDRAM_ADDR<=29'h07c01d00&&!DDRAM_BUSY)begin if(DDRAM_WE)payload_writes=payload_writes+1;if(DDRAM_RD)payload_reads=payload_reads+1;end
function[7:0]pattern(input integer ix,input integer seed);pattern=seed==0?((ix*73)^(ix>>5)^8'h35):seed==1?(ix%2?8'haa:8'h55):((ix*1103515245+12345)>>(ix%17))^ix;endfunction
task put(input integer ix,input[7:0]v);begin a=16'h8000+ix;di=v;mreq=0;wr=0;repeat(2)tick;wr=1;mreq=1;tick;end endtask
task fill(input bit perturb);begin for(i=0;i<size;i=i+1)put(i,perturb?~expectation[i]:expectation[i]);end endtask
task scan(input bit saved);begin for(i=0;i<size;i=i+1)begin a=16'h8000+i;mreq=0;repeat(3)tick;if(q!==(saved?expectation[i]:~expectation[i]))$fatal(1,"SC cfg%0d case%0d byte%0d got%h expected%h",cfg,k,i,q,saved?expectation[i]:~expectation[i]);end mreq=1;end endtask
initial begin
reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;
for(mode=1;mode<=3;mode=mode+1)begin cfg=mode;size=mode==1?2048:mode==2?16384:32768;
sc_ram_size=cfg;
for(k=0;k<20;k=k+1)begin
for(i=0;i<size;i=i+1)expectation[i]=pattern(i,k%3);
fill(0);payload_writes=0;payload_reads=0;counting=1;fork operation(1);begin wait(ss_freeze);if(k==0)begin wr=0;mreq=0;repeat(100)begin tick;if(we)$fatal(1,"CPU write during freeze");end wr=1;mreq=1;end end join counting=0;
if(payload_writes!=size/8)$fatal(1,"SC word count %0d != %0d",payload_writes,size/8);
if(mem['h25]!=={30'd0,cfg,32'h53435235})$fatal(1,"SC descriptor");
for(i=0;i<size;i=i+1)if(mem['hd01+i/8][(i%8)*8+:8]!==expectation[i])$fatal(1,"serialized byte%0d",i);
case(k)
17:mem['h1a][63:38]={24'h484305,2'd3};
18:mem['h1a][63:38]={24'h484306,2'd3};
19:mem['h1a][63:38]={24'h484307,2'd3};
3:mem['h1a][63:22]=0;
4:mem['h1a][63:38]={24'h484301,2'd0};
5:mem['h1a][63:38]={24'h484302,2'd2};
6:mem['h1a][63:38]={24'h484303,2'd3};
7:mem['h1a][63:38]={24'h484304,2'd3};
8:mem['h1a][63:40]=24'h48430c;
9:mem['h25][63]=1;
10:mem['h25][31:0]=0;
11:mem['h25][33:32]=0;
12:sc_ram_size=cfg==3?1:3;
13:mem['h1a][39:38]=2;
14:begin mem[0][63:32]=16382;mem['he][63]=0;end
endcase
fill(1);counting=1;operation(0);counting=0;
scan(k<3||k>=15);
if(payload_reads!==((k<3||k>=15)?size/8:0))$fatal(1,"load word count k%0d %0d",k,payload_reads);
sc_ram_size=cfg;
if(k==0)begin operation(0);scan(1);put(size-1,8'h7d);expectation[size-1]=8'h7d;operation(1);fill(1);operation(0);scan(1);end
if(k==15)begin reset_n=0;repeat(3)tick;reset_n=1;repeat(3)tick;scan(1);end
if(k==16)begin cfg=0;repeat(3)tick;cfg=mode;repeat(3)tick;scan(1);end
$display("PASS F05 fullDDR cfg%0d case%0d bytes%0d stall%0d",cfg,k,size,STALL);
end end
$display("PASS SC COMPLETE");$finish;
end
initial begin #(64'd3000000000);$fatal(1,"watchdog state%0d",dut.state);end
endmodule
