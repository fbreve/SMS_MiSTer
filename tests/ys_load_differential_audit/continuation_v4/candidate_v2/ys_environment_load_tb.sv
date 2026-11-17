`timescale 1ns/1ps
module ys_environment_load_tb;
parameter CANDIDATE=0,BOOT_FRAMES=150,STOP_FRAME=240,ACTION=1,CYCLE_LIMIT=0,MOTION_STEP=4;
parameter SEED_EXPORT=0,SEED_IMPORT=0,SHAM_SRAM=0,REFERENCE=0;
integer stage=0;
wire full_sram_allowed=1'b1; // This fixture is ordinary Sega SRAM, not SC/SystemE/EEPROM.
reg[31:0] game_id=32'h811c9dc5;
string seed_slot_path,seed_sram_path;
reg clk=0,reset_n=0,power_init=1,save_req=0,load_req=0;
always #9.312 clk=~clk;
reg [4:0] clkd=0;reg ce_cpu=0,ce_vdp=0,ce_pix=0,ce_sp=0;
always @(negedge clk)begin
 ce_sp<=clkd[0];ce_vdp<=clkd%5==4;ce_pix<=clkd%10==9;ce_cpu<=clkd==9||clkd==24;clkd<=clkd==29?0:clkd+1'b1;
end
wire [229:0] cpu_regs;wire [1:0] iset;wire [2:0] restart_ctx,mc,ts;wire [7:0] ir;
wire [15:0] addr;wire [7:0] cpu_do,cpu_di;wire m1_n,mreq_n,iorq_n,rd_n,wr_n;
wire [127:0] vdp_regs;wire [383:0] cram;wire [21:0] video_word;wire [31:0] io_word;
wire [8:0] x,y;wire [7:0] vc;wire vb,irq,hl;wire [3:0] sm;wire [11:0] color;
wire [7:0] vdp_do,io_do,vram_dma_d;wire [63:0] mapper_word;
function [127:0] fpga_powerup_known(input [127:0] d);begin for(integer b=0;b<128;b++)fpga_powerup_known[b]=(d[b]===1'b1);end endfunction
reg [7:0] wram_q=0,sram_q=8'hff;
reg [63:0] ddr_out=0;reg ddr_ready=0;
`include "map_controller.svh"
wire cpu_ce_live=ce_cpu&&!ss_ss_freeze;
wire pix_live=ce_pix&&!ss_ss_freeze;
wire io_cycle=!iorq_n&&m1_n;
reg [5:0] joy_n=6'b111111;
T80s_context #(.Mode(0),.T2Write(0),.IOWait(1)) cpu(
 .RESET_n(reset_n),.CLK(clk),.CEN(cpu_ce_live),.WAIT_n(1'b1),.INT_n(irq),.NMI_n(1'b1),.BUSRQ_n(1'b1),
 .M1_n(m1_n),.MREQ_n(mreq_n),.IORQ_n(iorq_n),.RD_n(rd_n),.WR_n(wr_n),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),
 .A(addr),.DI(cpu_di),.DO(cpu_do),.REG(cpu_regs),.DIRSet(ss_z80_set),.DIR(ss_z80_dir),.ISet_out(iset),
 .RestartContext(restart_ctx),.RestartDIR(ss_restart_dir),.RestartValid(ss_restart_valid),
 .NMIState(),.NMIDIR(3'b001),.NMIValid(1'b0),.NMIEnable(1'b0),.NMIHold(1'b0),.RestoreHold(1'b0),.ReplayT2(1'b1),.NMIReplay(),.TestIR(ir),.TestMC(mc),.TestTS(ts));
video beam(.clk(clk),.ce_pix(pix_live),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),
 .smode_M1(sm[0]),.smode_M2(sm[1]),.smode_M3(sm[2]),.smode_M4(sm[3]),.video_state_out(video_word),.video_state_in(ss_video_state_in),.video_state_set(ss_video_state_set),
 .x(x),.y(y),.vcounter_cpu(vc),.hsync(),.vsync(),.hblank(),.vblank(vb));
wire[35:0] cpu_vdp_probe; reg[35:0] previous_vdp_probe=0; reg[63:0] previous_mapper=0;
wire vram_we;wire [14:0] vram_wa;wire [7:0] vram_wd;
vdp_probe #(.MAX_SPPL(7)) vdp_unit(.clk_sys(clk),.ce_vdp(ce_vdp&&!ss_ss_freeze),.ce_pix(pix_live),.ce_sp(ce_sp&&!ss_ss_freeze),
 .gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(hl),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),
 .RD_n((io_cycle&&(addr[7:6]==1||addr[7:6]==2))?rd_n:1'b1),.WR_n((io_cycle&&addr[7:6]==2)?wr_n:1'b1),.IRQ_n(irq),.WR_direct(1'b0),.A_direct(6'd0),.A(addr[7:0]),.D_in(cpu_do),.D_out(vdp_do),
 .x(x),.y(y),.vcounter_cpu(vc),.color(color),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(sm[0]),.smode_M2(sm[1]),.smode_M3(sm[2]),.smode_M4(sm[3]),.ysj_quirk(1'b0),.reset_n(reset_n),
 .ss_regs_out(vdp_regs),.ss_regs_in(power_init?fpga_powerup_known(vdp_regs):ss_vdp_regs_in),.ss_regs_set(power_init|ss_vdp_regs_set),.ss_cram_out(cram),.ss_cram_wr(ss_cram_wr),.ss_cram_A(ss_cram_A),.ss_cram_D(ss_cram_D),
 .ss_vram_en(ss_vram_en),.ss_vram_A(ss_vram_A),.ss_vram_D(vram_dma_d),.ss_vram_WE(ss_vram_WE),.ss_vram_WA(ss_vram_WA),.ss_vram_WD(ss_vram_WD),.TestCPUState(cpu_vdp_probe),.TestWE(vram_we),.TestWA(vram_wa),.TestWD(vram_wd));
wire [7:0] bank0,bank1,bank2,bank3,pak4reg,nembank;
wire nv_e,nv_ex,nv_p,nv_cme,map_lock,map_codies,map_codies_lock,map_4pak;
`include "mapper.svh"
`include "io.svh"
assign mapper_word=(64'd1<<54)|({63'd0,nv_cme}<<53)|({63'd0,nv_p}<<52)|({63'd0,nv_ex}<<51)|({63'd0,nv_e}<<50)|({63'd0,map_lock}<<59)|({63'd0,map_codies}<<58)|({63'd0,map_codies_lock}<<60)|({63'd0,map_4pak}<<57)|{16'd0,nembank,pak4reg,bank3,bank2,bank1,bank0};
reg [7:0] cart[0:262143],wram[0:8191],sram[0:32767],vram_trace[0:32767];
reg [7:0] saved_vram[0:32767],saved_wram[0:8191],saved_sram[0:32767];
reg [7:0] rom_q=8'hff;integer rom_size,rom_fd;string rom_path,out_prefix;
function integer rom_offset(input [15:0] a);begin
 if(a<1024)rom_offset=a;else case(a[15:14])
 0:rom_offset=bank0*16384+a[13:0];1:rom_offset=bank1*16384+a[13:0];default:rom_offset=bank2*16384+a[13:0];endcase
end endfunction
wire [14:0] nv_addr={(nv_p&&!addr[14]),addr[13:0]};
wire wram_wr=!ss_ss_freeze&&!mreq_n&&!wr_n&&addr[15:14]==3;
wire nv_wr=!ss_ss_freeze&&!mreq_n&&!wr_n&&((addr[15:14]==2&&nv_e)||(addr[15:14]==3&&nv_ex)||(addr[15:13]==5&&nv_cme));
wire [7:0] memory_di=addr[15:14]==3?(nv_ex?sram_q:wram_q):(addr[15:14]==2&&nv_e)?sram_q:(addr[15:13]==5&&nv_cme)?sram_q:rom_q;
assign cpu_di=io_cycle?(addr[7:6]==3?io_do:vdp_do):memory_di;
always @(posedge clk)begin
 rom_q<=cart[rom_offset(addr)%262144];
 if(ss_ss_freeze)begin
  wram_q<=wram[ss_wram_WE?ss_wram_WA[12:0]:ss_wram_A[12:0]];
  sram_q<=sram[ss_nvram_WE?ss_nvram_WA:ss_nvram_A];
  if(ss_wram_WE)begin wram[ss_wram_WA[12:0]]<=ss_wram_WD;wram_q<=ss_wram_WD;end
  if(ss_nvram_WE)begin
   if(!(SHAM_SRAM&&stage==3))begin sram[ss_nvram_WA]<=ss_nvram_WD;sram_q<=ss_nvram_WD;end
  end
 end else begin
  wram_q<=wram[addr[12:0]];sram_q<=sram[nv_addr];
  if(wram_wr)begin wram[addr[12:0]]<=cpu_do;wram_q<=cpu_do;end
  if(nv_wr)begin sram[nv_addr]<=cpu_do;sram_q<=cpu_do;end
 end
 if(vram_we===1'b1)begin
  if($isunknown({vram_wa,vram_wd}))$fatal(1,"unknown VRAM write");vram_trace[vram_wa]<=vram_wd;
 end
end
reg [63:0] ddr[0:12287];integer pending=0;reg [28:0] read_address;
integer ddr_reads=0,ddr_writes=0;
always @(posedge clk)begin
 ddr_ready<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin ddr_out<=ddr[read_address-29'h7c00000];ddr_ready<=1;end end
 if(ss_DDRAM_RD)begin if(pending!=0)$fatal(1,"overlapping DDR read");read_address<=ss_DDRAM_ADDR;pending<=3;ddr_reads++;end
 if(ss_DDRAM_WE)begin for(integer b=0;b<8;b++)if(ss_DDRAM_BE[b])ddr[ss_DDRAM_ADDR-29'h7c00000][8*b+:8]<=ss_DDRAM_DIN[8*b+:8];ddr_writes++;end
end
integer frame=0,trace_fd,cpu_events=0,vram_events=0,io_events=0,unknown_writes=0;
integer map_mutations=0;
integer nv_events=0,wr_events=0,dma_sram_bytes=0,save_sram_words=0,load_sram_words=0;
reg previous_rd=1;
wire cpu_sram_selected=(addr[15:14]==2&&nv_e)||(addr[15:14]==3&&nv_ex)||(addr[15:13]==5&&nv_cme);longint cycles=0,release_cycle=0;reg tracing=0,prev_wr=1,had_freeze=0;
reg [11:0] pixels[0:49151];
always @(posedge clk)begin
 cycles++;
 if(reset_n&&!ss_ss_freeze&&!wr_n&&prev_wr&&$isunknown(cpu_do))begin
  if(unknown_writes<4)$display("UNKNOWN_WRITE cycle=%0d PC=%h IR=%h A=%h DI=%h ROM=%h W=%h S=%h",cycles,cpu_regs[79:64],ir,addr,cpu_di,rom_q,wram_q,sram_q);unknown_writes++;
 end
 if(cycles%1000000==0)$display("HEARTBEAT cycle=%0d frame=%0d beam=%0d,%0d VB=%b SS=%0d frozen=%b PC=%h",cycles,frame,x,y,vb,controller.state,ss_ss_freeze,addr);
 if(tracing&&cpu_ce_live&&(cpu_events<20000||(mc==1&&(ts==1||ts==2))))begin
  $fdisplay(trace_fd,"C %0d %h %h %h %h %h %h %b%b%b%b%b %h %h",cycles-release_cycle,addr,ir,restart_ctx,iset,mc,ts,m1_n,mreq_n,iorq_n,rd_n,wr_n,cpu_di,cpu_do);cpu_events++;
 end
 if(tracing&&io_cycle&&!wr_n&&prev_wr&&addr[7:6]==2)begin $fdisplay(trace_fd,"P %0d %h %h %h %h %h",cycles-release_cycle,addr,cpu_do,vdp_regs[83:70],vdp_regs[84],vdp_regs[85]);io_events++;end
 if(tracing&&vram_we&&!ss_ss_freeze)begin $fdisplay(trace_fd,"V %0d %h %h %0d %0d",cycles-release_cycle,vram_wa,vram_wd,x,y);vram_events++;end
 if(tracing&&cpu_ce_live&&!mreq_n&&cpu_sram_selected&&(!rd_n||!wr_n))begin
  $fdisplay(trace_fd,"N %0d %h %h %h %h %h %h %h %b%b %h",cycles-release_cycle,cpu_regs[79:64],addr,nv_addr,cpu_di,cpu_do,mc,ts,rd_n,wr_n,mapper_word);nv_events++;
 end
 if(tracing&&wram_wr&&prev_wr)begin
  $fdisplay(trace_fd,"W %0d %h %h %h",cycles-release_cycle,cpu_regs[79:64],addr,cpu_do);wr_events++;
 end
 if(tracing&&vram_we&&!ss_ss_freeze&&vram_wa>=15'h3800&&vram_wa<15'h3d00&&vram_trace[vram_wa]!==vram_wd)map_mutations++;
 if(ss_nvram_WE)dma_sram_bytes++;
 if(ss_DDRAM_WE&&ss_DDRAM_ADDR>=29'h7c00d01&&ss_DDRAM_ADDR<=29'h7c01d00)save_sram_words++;
 if(ss_DDRAM_RD&&ss_DDRAM_ADDR>=29'h7c00d01&&ss_DDRAM_ADDR<=29'h7c01d00)load_sram_words++;
 if(tracing&&cpu_vdp_probe!==previous_vdp_probe)$fdisplay(trace_fd,"T %0d %h",cycles-release_cycle,cpu_vdp_probe);
 if(tracing&&mapper_word!==previous_mapper)$fdisplay(trace_fd,"M %0d %h %h",cycles-release_cycle,mapper_word,cpu_regs[79:64]);
 previous_mapper<=mapper_word;previous_vdp_probe<=cpu_vdp_probe;
 prev_wr<=wr_n;previous_rd<=rd_n;
 if(controller.state==37&&ce_cpu&&!m1_n&&!mreq_n&&iset==0&&vb&&x<256)$display("ACCEPT stage=%0d save=%0d cycle=%0d frame=%0d beam=%0d,%0d PC=%h IR=%h CTX=%h MAP=%h MC=%h TS=%h",stage,controller.do_save,cycles,frame,x,y,addr,ir,restart_ctx,mapper_word,mc,ts);
 if(ss_z80_set)$display("RESTORE cycle=%0d PC=%h CTX=%h VALID=%b",cycles,ss_z80_dir[79:64],ss_restart_dir,ss_restart_valid);
 if(controller.state==40)$fatal(1,"controller ST_ERROR");
end
always @(posedge clk)if(pix_live)begin #1;if(x>=1&&x<=256&&y<192)pixels[y*256+x-1]=color;end
always @(posedge vb)begin
 frame++;
 $display("FRAME %0d cycle=%0d stage=%0d PC=%h MAP=%h VDP=%h",frame,cycles,stage,addr,mapper_word,vdp_regs);
end
task image(input string label);integer f;string name;reg [11:0] c;begin
 name={out_prefix,"_",label,".ppm"};f=$fopen(name,"wb");$fwrite(f,"P6\n256 192\n255\n");
 for(integer n=0;n<49152;n++)begin c=pixels[n];$fwrite(f,"%c%c%c",{c[3:0],c[3:0]},{c[7:4],c[7:4]},{c[11:8],c[11:8]});end
 $fclose(f);$display("IMAGE %s",name);
end endtask
task checkpoint(input string label);reg [63:0] hv,hw,hs;integer f;begin
 hv=64'hcbf29ce484222325;hw=hv;hs=hv;
 for(integer n=0;n<32768;n++)begin hv=(hv^vram_trace[n])*64'h100000001b3;hs=(hs^sram[n])*64'h100000001b3;end
 for(integer n=0;n<8192;n++)hw=(hw^wram[n])*64'h100000001b3;
 $display("CHECKPOINT %s cycle=%0d frame=%0d VRAM=%h WRAM=%h SRAM=%h MAP=%h VDP=%h CPU=%h CRAM=%h IO=%h VIDEO=%h PROBE=%h",label,cycles,frame,hv,hw,hs,mapper_word,vdp_regs,cpu_regs,cram,io_word,video_word,cpu_vdp_probe);
 // Full local diagnostic state; never contains a copy of the cartridge ROM file.
 f=$fopen({out_prefix,"_",label,".mem"},"wb");
 for(integer n=0;n<32768;n++)$fwrite(f,"%c",vram_trace[n]);
 for(integer n=0;n<8192;n++)$fwrite(f,"%c",wram[n]);
 for(integer n=0;n<32768;n++)$fwrite(f,"%c",sram[n]);$fclose(f);
end endtask
task ticks(input integer n);begin repeat(n)@(negedge clk);end endtask
// Pinned master SMS.sv: raw_reset starts ram_clr_run; CPU/controller reset
// remains active until all16384 physical WRAM addresses have been cleared.
task native_reset;begin
 reset_n=0;$display("RESET_BEGIN cycle=%0d raw_hold=128 WRAM_clear_clocks=16384",cycles);
 ticks(128);
 for(integer n=0;n<16384;n++)begin
  @(posedge clk);if(n<8192)wram[n]<=8'd0;@(negedge clk);
 end
 for(integer n=0;n<8192;n++)if(wram[n]!==0)$fatal(1,"WRAM reset clear failed");
 reset_n=1;$display("RESET_RELEASE cycle=%0d visible_WRAM_zero=8192",cycles);
end endtask
task wait_frames(input integer n);integer target;begin target=frame+n;wait(frame>=target);ticks(2);end endtask
task operation(input bit saving);begin
 wait(controller.state==0 && controller.op_cooldown==0);
 $display("OP_READY saving=%b cycle=%0d frame=%0d",saving,cycles,frame);
 @(negedge clk);save_req=saving;load_req=!saving;@(negedge clk);save_req=0;load_req=0;
 wait(ss_ss_freeze);wait(!ss_ss_freeze);ticks(1);
end endtask
task check_load;integer vd,wd,sd;reg [7:0] expected_byte;begin
 vd=0;wd=0;sd=0;
 for(integer n=0;n<16384;n++)begin expected_byte=ddr['h101+n/8][8*(n%8)+:8];if(vram_trace[n]!==expected_byte)vd++;end
 for(integer n=0;n<8192;n++)begin expected_byte=ddr['h901+n/8][8*(n%8)+:8];if(wram[n]!==expected_byte)wd++;end
 for(integer n=0;n<32768;n++)if(sram[n]!==saved_sram[n])sd++;
 $display("LOAD_CHECK VRAM_vs_slot=%0d WRAM_vs_slot=%0d SRAM_vs_saved_complete=%0d DMA_SRAM_WE=%0d SAVE_SRAM_WORDS=%0d LOAD_SRAM_WORDS=%0d metadata=%h",vd,wd,sd,dma_sram_bytes,save_sram_words,load_sram_words,ddr[5]);
end endtask
initial begin
 if(!$value$plusargs("ROM=%s",rom_path))$fatal(1,"external ROM path required");
 if(!$value$plusargs("OUT=%s",out_prefix))out_prefix="run";
 rom_fd=$fopen(rom_path,"rb");if(!rom_fd)$fatal(1,"cannot open ROM");rom_size=$fread(cart,rom_fd);$fclose(rom_fd);if(rom_size!=262144)$fatal(1,"wrong ROM size");
 for(integer n=0;n<262144;n++)game_id={game_id[30:0],game_id[31]} ^ {24'd0,cart[n]} ^ {29'd0,n[0],n[8],n[16]};
 if(game_id!==32'ha458e3d4)$fatal(1,"this qualified fixture requires the standard ROM");
 trace_fd=$fopen({out_prefix,"_events.log"},"w");
 for(integer n=0;n<12288;n++)ddr[n]=0;
 for(integer n=0;n<8192;n++)wram[n]=0;
 for(integer n=0;n<32768;n++)begin sram[n]=8'hff;vram_trace[n]=0;end
 for(integer n=0;n<49152;n++)pixels[n]=0;
 ticks(64);reset_n=1;ticks(1);power_init=0;
 $display("CONFIG CANDIDATE=%0d ACTION=%0d BIOS=off NTSC export turbo=off T2Write=0",CANDIDATE,ACTION);
 if(SEED_IMPORT)begin
  if(!$value$plusargs("SEED_SLOT=%s",seed_slot_path)||!$value$plusargs("SEED_SRAM=%s",seed_sram_path))$fatal(1,"seed paths required");
  $readmemh(seed_slot_path,ddr);
  if(ddr[1][63:32]!==game_id||ddr[5][63:38]!==0)$fatal(1,"seed ownership/legacy context mismatch");
  stage=-1;
  @(negedge clk);load_req=1;@(negedge clk);load_req=0;
  wait(ss_ss_freeze);
  // Explicit initial fixture memory, NOT an interpretation of the unmarked slot tail.
  $readmemh(seed_sram_path,sram);
  wait(!ss_ss_freeze);ticks(1);wait_frames(5);
  checkpoint("qualified_start");image("qualified_start");stage=0;
 end
 // Deterministic discovery movie: short button-1 presses, neutral between presses.
 while(!SEED_IMPORT&&frame<BOOT_FRAMES)begin
  wait_frames(1);joy_n=6'b111111;
  if(frame>=2&&frame%8<2)joy_n[4]=0;
  if(frame==1||frame==5||frame==10||frame==30||frame==60||frame%30==0||frame==BOOT_FRAMES)begin image($sformatf("boot%0d",frame));checkpoint($sformatf("boot%0d",frame));end
 end
 joy_n=6'b111111;
 if(ACTION<0)begin $display("INCONCLUSIVE discovery only; scene must be visually verified before SAVE");$fclose(trace_fd);$finish;end
 stage=1;save_sram_words=0;load_sram_words=0;dma_sram_bytes=0;
 operation(1);checkpoint("saved");image("saved");
 $display("SAVE_METADATA word5=%h mapper=%h payload_words=%0d context=%0d",ddr[5],ddr[15],save_sram_words,controller.restart_snap);
 $writememh({out_prefix,"_saved_slot.hex"},ddr);
 if(SEED_EXPORT)begin
  if(CANDIDATE!=0||controller.restart_snap!=0||!vdp_regs[7])$fatal(1,"seed requires legacy ordinary-context displayed scene");
  $writememh({out_prefix,"_slot.hex"},ddr);
  $writememh({out_prefix,"_sram.hex"},sram);
  $display("SEED_READY actual master controller slot plus explicitly separate complete physical SRAM fixture; not an expanded savestate");
  if(!REFERENCE)begin $fclose(trace_fd);$finish;end
 end
 if(REFERENCE)begin
  release_cycle=cycles;tracing=1;stage=4;
 end
 for(integer n=0;n<32768;n++)begin saved_vram[n]=vram_trace[n];saved_sram[n]=sram[n];end
 for(integer n=0;n<8192;n++)saved_wram[n]=wram[n];
 if(!REFERENCE)begin
 stage=2;
 if(ACTION==1)begin
  native_reset;wait_frames(8);
 end else begin
  // Qualified natural history: through the north gate, then settle outdoors.
  joy_n[0]=0;wait_frames(112);joy_n=6'b111111;wait_frames(40);
  begin: qualify_history
   integer changed;
   changed=0;for(integer n='h400;n<'h800;n++)if(sram[n]!==saved_sram[n])changed++;
   $display("ENV_HISTORY cache_differences=%0d display=%b mapper=%h",changed,vdp_regs[7],mapper_word);
   image("changed_environment");checkpoint("changed_environment");
   if(changed==0||!vdp_regs[7])$fatal(1,"environment history did not qualify; no causal LOAD trial");
  end
 end
 checkpoint("before_load");stage=3;operation(0);release_cycle=cycles;tracing=1;
 check_load;checkpoint("loaded");image("loaded");
 end
 stage=4;wait_frames(1);checkpoint("first_frame");image("first_frame");wait_frames(4);checkpoint("neutral5");image("neutral5");joy_n[2]=0;
 for(integer step=0;step<2;step++)begin wait_frames(MOTION_STEP);image($sformatf("left%0d",(step+1)*MOTION_STEP));checkpoint($sformatf("left%0d",(step+1)*MOTION_STEP));end
 joy_n=6'b111111;joy_n[3]=0;
 for(integer step=0;step<20;step++)begin wait_frames(MOTION_STEP);image($sformatf("right%0d",(step+1)*MOTION_STEP));checkpoint($sformatf("right%0d",(step+1)*MOTION_STEP));end
 // Additional path clears the tree that blocks the initial rightward movie.
 joy_n=6'b111111;joy_n[1]=0;
 for(integer step=0;step<4;step++)begin wait_frames(MOTION_STEP);image($sformatf("down%0d",(step+1)*MOTION_STEP));checkpoint($sformatf("down%0d",(step+1)*MOTION_STEP));end
 joy_n=6'b111111;joy_n[3]=0;
 for(integer step=0;step<16;step++)begin wait_frames(MOTION_STEP);image($sformatf("clear_right%0d",(step+1)*MOTION_STEP));checkpoint($sformatf("clear_right%0d",(step+1)*MOTION_STEP));end
 joy_n=6'b111111;checkpoint("end");$display("MAP_QUALIFICATION effective_map_name_writes=%0d",map_mutations);$display("COMPLETE movement sequence candidate=%0d CPU_events=%0d PORT_events=%0d VRAM_events=%0d DDR_reads=%0d DDR_writes=%0d; visual validation still required",CANDIDATE,cpu_events,io_events,vram_events,ddr_reads,ddr_writes);$fclose(trace_fd);$finish;
end
initial begin #(64'd20000000000);$fatal(1,"watchdog: sequence incomplete");end
initial begin if(CYCLE_LIMIT>0)begin wait(cycles>=CYCLE_LIMIT);image("bounded");checkpoint("bounded");$display("INCONCLUSIVE cycle limit reached before complete validated movement sequence");$fclose(trace_fd);$finish;end end
endmodule
