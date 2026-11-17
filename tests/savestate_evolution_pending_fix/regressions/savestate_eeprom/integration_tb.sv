`timescale 1ns/1ps
module ee_integration;
parameter STALL=0,CASE_ONLY=-1;
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
wire [127:0] eeprom_ext_out;
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
wire [63:0] eeprom_out;
wire [63:0] eeprom_in;
wire eeprom_set;
wire [13:0] wram_A;
reg [7:0] wram_D = '0;
wire wram_WE;
wire [13:0] wram_WA;
wire [7:0] wram_WD;
wire [14:0] nvram_A;
wire [7:0] nvram_D;
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
reg fast_boundary=0;reg [15:0]lfsr=16'h1ace;
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=fast_boundary||cycle%15==0;cycle=cycle+1;lfsr={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?(cycle%31<13):STALL==2?(lfsr[3:0]<12):0);end
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
reg rst1=0,rst2=0,holdref=0,wr=1;reg[15:0]addr=16'h8000;reg[7:0]data=0;
reg perturb=0;wire[6:0]a1,a2;wire[7:0]wd1,wd2,pins1,pins2,qref;wire we1,we2,active1,active2;
wire[63:0]refstate;wire[127:0]refext;
reg sdwe=0;reg[14:0]sda=0;reg[7:0]sdd=0;wire[7:0]sdq1,sdq2;
wire[14:0]ramA=ss_freeze?(nvram_WE?nvram_WA:(nvram_refill?{8'd0,a1}:nvram_A)):{8'd0,a1};
wire[7:0]ramdata=ss_freeze?nvram_WD:wd1;
wire ramwe=ss_freeze?nvram_WE:we1;
cart_eeprom local1(.clk_sys(clk),.ce_cpu(1'b1),.reset_n(rst1),.soft_reset(1'b0),.A(addr),.D_in(data),.D_out(pins1),.WR_n(wr),.MREQ_n(1'b0),.enabled(eeprom_present),.mapper_eeprom(eeprom_present),.bus_active(active1),.nvram_a(a1),.nvram_di(wd1),.nvram_do(nvram_D),.nvram_we(we1),.ss_out(eeprom_out),.ss_in(eeprom_in),.ss_set(eeprom_set),.ss_ext_out(eeprom_ext_out),.ss_ext_in(eeprom_ext_in),.ss_full(eeprom_full),.ss_freeze(ss_freeze));
cart_eeprom local2(.clk_sys(clk),.ce_cpu(1'b1),.reset_n(rst2),.soft_reset(1'b0),.A(addr),.D_in(data),.D_out(pins2),.WR_n(wr),.MREQ_n(1'b0),.enabled(eeprom_present),.mapper_eeprom(eeprom_present),.bus_active(active2),.nvram_a(a2),.nvram_di(wd2),.nvram_do(qref),.nvram_we(we2),.ss_out(refstate),.ss_in(64'd0),.ss_set(1'b0),.ss_ext_out(refext),.ss_ext_in(128'd0),.ss_full(1'b0),.ss_freeze(holdref));
dpram #(.widthad_a(15),.init_file("UNUSED")) ram1(.clock_a(clk),.address_a(ramA),.data_a(ramdata),.wren_a(ramwe),.q_a(nvram_D),.clock_b(clk),.address_b(sda),.data_b(sdd),.wren_b(sdwe),.q_b(sdq1));
dpram #(.widthad_a(15),.init_file("UNUSED")) ram2(.clock_a(clk),.address_a({8'd0,a2}),.data_a(wd2),.wren_a(we2&&!holdref),.q_a(qref),.clock_b(clk),.address_b(sda),.data_b(sdd),.wren_b(sdwe&&!perturb),.q_b(sdq2));
integer k,j,size,run;reg[63:0]saved;reg[127:0]savedext;reg[7:0]expected[0:16383];
always @(posedge ss_freeze)begin #1;holdref=1;end
always @(negedge ss_freeze)if(!dut.do_save && eeprom_full)holdref=0;
task put(input[7:0]v);begin data=v;wr=0;tick;wr=1;repeat(2)tick;end endtask
task bitin(input bit b);begin put(4|b);put(6|b);put(4|b);end endtask
task cmd(input[7:0]v);begin put(0);bitin(1);for(integer b=7;b>=0;b=b-1)bitin(v[b]);end endtask
task check;begin if(eeprom_out!==refstate||eeprom_ext_out!==refext||pins1!==pins2||active1!==active2)$fatal(1,"full replay k%0d state%h/%h ext%h/%h pins%h/%h",k,eeprom_out,refstate,eeprom_ext_out,refext,pins1,pins2);end endtask
task scan(input bit pair,input bit original);begin
 for(integer b=0;b<size;b=b+1)begin sda=b;repeat(2)tick;
 if(pair)begin if(sdq1!==sdq2)$fatal(1,"RAM replay byte%0d %h/%h k%0d",b,sdq1,sdq2,k);end
 else if(sdq1!==(original?expected[b]:~expected[b]))$fatal(1,"RAM restore byte%0d k%0d got%h expected%h",b,k,sdq1,(original?expected[b]:~expected[b]));
 end
end endtask
initial begin
reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;
ss_game_id=32'h12345678;video_state_out=22'h12345;vdp_regs={8'h5a,128'd0};vdp2_regs={8'ha5,128'd0};
gg_out=128'h00001fe00003f8000000ffa07fff00ff;md_out={2'd2,1'b0,3'd2,17'd123,2'd2,1'b1,3'd3,17'd456};
for(run=0;run<24;run=run+1)begin
 k=run<4?run:run<11?run+13:run-7; // exact replays precede intentionally lossy legacy loads
 if(CASE_ONLY>=0 && CASE_ONLY!=k)continue;
 systeme=k==16||k==19;eeprom_present=k<14||k>=17;mapper_out=k==15?64'h4000000000000:64'd0;size=k==15?16384:128;
 holdref=0;rst1=0;rst2=0;wr=1;perturb=0;repeat(3)tick;
 sdwe=1;for(j=0;j<size;j=j+1)begin expected[j]=k==18?(j%2?8'haa:8'h55):((j*73)^(k%2?8'h55:8'ha5));sda=j;sdd=expected[j];tick;end sdwe=0;
 rst1=1;rst2=1;repeat(3)tick;
 if(eeprom_present)begin
 cmd(8'h80);repeat(6)tick;put(0);cmd(8'h30);put(0);
 case(k)
 0:begin cmd(0);put(0);bitin(1);bitin(0);bitin(0);bitin(1);bitin(1);end
 1:begin cmd(8'h10);end // WRAL is still active at accepted boundary
 2:begin
 put(0);bitin(1);for(j=7;j>=1;j=j-1)bitin((8'hbf>>j)&1);put(5);
 // Accept M1 while the guest's final opcode edge reaches the engine.
 fast_boundary=1;force dut.op_cooldown=0;ss_save=1;data=7;wr=0;tick;ss_save=0;wr=1;
 wait(ss_freeze);fast_boundary=0;wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
 end
 3:begin cmd(8'h7f);repeat(7)bitin(1);end
 default:put(0);
 endcase
 end
 if(k==17)addr=0; // EEPROM exists but no current access/window
 if(k!=2)operation(1);saved=dut.eeprom_snap;savedext=dut.eeprom_ext_snap;
 if(k==2&&savedext[3:0]!=5)$fatal(1,"READ latch phase not captured: %0d",savedext[3:0]);
 if(mem['h1a][63:38]!=={24'h48430b,2'd3})$fatal(1,"v4 tag");
 if(mem['h1e]!=={18'd0,md_out}||{mem['h1d],mem['h1c]}!==gg_out)$fatal(1,"F02/F08 positions");
 if(eeprom_present)begin
 if(mem['h1f]!=={15'd0,5'd16,3'd2,1'b1,8'd1,32'h45455058}||{mem['h31],mem['h30]}!==savedext||mem['h1b]!==saved)$fatal(1,"EEPROM descriptor/protocol");
 if((k<4||k>=17)&&(refstate!==saved||refext!==savedext))$fatal(1,"capture not coherent with natural reference");
 if(k==1&&(!savedext[52]||savedext[51:50]==0))$fatal(1,"write-all completed before capture");
 // Compare every serialized backing byte against frozen reference RAM.
 for(j=0;j<128;j=j+1)begin sda=j;repeat(2)tick;if(mem['h40+j/8][(j%8)*8+:8]!==sdq2)$fatal(1,"torn snapshot byte%0d k%0d",j,k);end
 end
 case(k)
 4:mem['h1a][63:22]=0;
 5:mem['h1a][63:38]={24'h484301,2'd0};
 6:mem['h1a][63:38]={24'h484302,2'd2};
 7:mem['h1a][63:38]={24'h484303,2'd3};
 8:mem['h1a][63:40]=24'h48430c;
 9:mem['h1a][39:38]=2;
 10:mem['h1f][63]=1;
 11:mem['h31][63]=1;
 12:mem['h30][3:0]=15;
 20:mem['h1a][63:40]=24'h484304;
 21:mem['h1a][63:40]=24'h484305;
22:mem['h1a][63:40]=24'h484306;
23:mem['h1a][63:40]=24'h484307;
 13:begin mem[0][63:32]=16382;mem['he][63]=0;end
 endcase
 // Only the DUT moves to a discarded timeline; mutate backing via RAM port B.
 perturb=1;rst1=0;repeat(3)tick;rst1=1;addr=16'h8000;
 sdwe=1;for(j=0;j<size;j=j+1)begin sda=j;sdd=~expected[j];tick;end sdwe=0;
 operation(0);
 if(k<4||k>=17)begin
 if(!eeprom_full)$fatal(1,"valid full EEPROM rejected");check;
 case(k)
 0:repeat(4)bitin(0);
 3:repeat(9)bitin(0);
 default:repeat(40)bitin(0);
 endcase
 repeat(140)begin tick;check;end
 scan(1,1);
 // Subsequent write and erase remain functional after restoration.
 cmd(8'h30);cmd(8'h7f);for(j=15;j>=0;j=j-1)bitin((16'h5aa5>>j)&1);repeat(5)tick;check;
 cmd(8'hff);repeat(5)tick;check;
 if(k==18)begin
 operation(1);rst1=0;repeat(3)tick;rst1=1;
 sdwe=1;for(j=0;j<128;j=j+1)begin sda=j;sdd=j;tick;end sdwe=0;
 operation(0);check;scan(1,1);
 end
 end else begin
 if(eeprom_full)$fatal(1,"legacy/invalid/nonEEP consumed full state");
 scan(0,k==15);
 if(eeprom_present&&(eeprom_ext_out[3:0]!=1||eeprom_ext_out[51:50]!=0||eeprom_ext_out[34]!=0))$fatal(1,"legacy protocol not normalized");
 if(k==13&&eeprom_out!==64'd1)$fatal(1,"old64 missing word must normalize to deterministic ready state");
 end
 if(k==7||k==10||k==11||k==12||k<4||k>=17)begin if(md_in!==md_out||gg_in!==gg_out)$fatal(1,"other extensions damaged");end
 $display("PASS EEPROM DDRAM case%0d stalls%0d full%0d size%0d",k,STALL,eeprom_full,size);
end
if(CASE_ONLY<0)$display("PASS EEPROM DDRAM: 24 cases, full protocol/backing, coherent natural reference, legacy v0-v3, invalid, SRAM, SystemE");
else $display("PASS EEPROM DDRAM targeted case%0d",CASE_ONLY);
$finish;
end
initial begin #600000000;$fatal(1,"watchdog");end
endmodule
