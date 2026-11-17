`include "header.svh"


always #5 clk=~clk;

reg warming=WARMUP!=0;wire frozen=ss_freeze&&(!REFERENCE||warming);
// AUDIT_IO_CONSUMPTION
reg[7:0]io_sample=0;integer io_count=0;integer ref_io_count[0:SAMPLES-1];
reg hl=0;
integer cycle=0;reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
// Supported production turbo cadence. CPU/pixel events share /10 so the
// scoped VDP oracle does not depend on reconstruction of the separate /15
// divider phase (G10 is explicitly outside this investigation).
wire cpu_tick=TURBO?ce_pix:ce_cpu;
wire[2:0] mc_probe,ts_probe;wire[1:0]restart_probe;
assign cpu_ce=cpu_tick;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
always@(negedge clk)cycle=cycle+1;
always @(negedge clk) begin
 phase_ready<=phase_set;
 if(phase_set&&(!REFERENCE||warming))begin
 case(phase_in)0:clkd<=0;1:clkd<=10;2:clkd<=20;3:clkd<=25;endcase
 ce_cpu<=0;ce_vdp<=0;ce_pix<=0;ce_sp<=0;end else begin
	ce_sp <= clkd[0];
	ce_vdp <= 0;//div5
	ce_pix <= 0;//div10
	ce_cpu <= 0;//div15
	clkd <= clkd + 1'd1;
	if (clkd==29) begin
		clkd <= 0;
		ce_vdp <= 1;
		ce_pix <= 1;
	end else if (clkd==24) begin
		ce_cpu <= 1;  //-- changed cpu phase to please VDPTEST HCounter test;
		ce_vdp <= 1;
	end else if (clkd==19) begin
		ce_vdp <= 1;
		ce_pix <= 1;
	end else if (clkd==14) begin
		ce_vdp <= 1;
	end else if (clkd==9) begin
		ce_cpu <= 1;
		ce_vdp <= 1;
		ce_pix <= 1;
	end else if (clkd==4) begin
		ce_vdp <= 1;
	end
end

end
integer last_issue_cycle=0,phase_distance=-1,phase_profile_index=0,expected_prepare_phase=-1;
integer natural_phases[0:11]='{1,3,7,9,11,13,17,19,21,23,27,29};
reg[63:0]image_saved[0:12287];reg[63:0]mem[0:12287];integer pending=0;reg[28:0]readaddr;
always@(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=3;readaddr<=DDRAM_ADDR;
 if(NATURAL_PHASE&&DDRAM_ADDR==29'h07c00000+(systeme?29'h2900:29'hd00))begin
  last_issue_cycle=cycle;
  if(phase_distance>=0)begin
   expected_prepare_phase=natural_phases[phase_profile_index%12];
   pending<=3+(expected_prepare_phase-((clkd+phase_distance)%30)+30)%30;
   phase_profile_index++;
  end
 end
end
end
task tick;begin @(negedge clk);#1;end endtask
reg setup=1,runvideo=0,holdref=0,lockref=0;integer frame=0;wire[8:0]y,rx,ry;wire[7:0]vc,rvc;wire vb,rvb;wire[21:0]rvideo;
wire m1,m2,m3,m4;
assign vblank=vb;
video video1(.clk(clk),.ce_pix(ce_pix&&runvideo),.pal(PAL!=0),.border(1'b0),.ggres(GG!=0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(m1),.smode_M2(m2),.smode_M3(m3),.smode_M4(m4),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set&&(!REFERENCE||warming)),.x(x),.y(y),.vcounter_cpu(vc),.hsync(),.vsync(),.hblank(),.vblank(vb));
wire[15:0]ca,ra;wire[7:0]co,ro;wire cm1,cmreq,rm1,rmreq,ciq,riq,crd,cwr,rrd,rwr;wire[229:0]rr;wire[1:0]riset;wire[7:0]vd,rvd;wire irq,rirq;
reg[7:0]rom[0:65535],ram[0:8191],rram[0:8191];
reg[7:0]wram_read_q;assign wram_D=wram_read_q;always@(posedge clk)wram_read_q<=ram[wram_A[12:0]];
always@(posedge clk)begin
 if(wram_WE)ram[wram_WA[12:0]]<=wram_WD;else if(!frozen&&!cmreq&&!cwr&&ca>=16'hc000)ram[ca[12:0]]<=co;
 if(!holdref&&!lockref&&!rmreq&&!rwr&&ra>=16'hc000)rram[ra[12:0]]<=ro;
end
assign z80_m1_n=cm1;assign z80_mreq_n=cmreq;
T80s #(.T2Write(0)) cpu(.RESET_n(reset_n&&!setup),.CLK(clk),.CEN((cpu_tick&&!frozen&&!logical_pause)||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n(1'b1),.INT_n(IRQ_ENABLE?irq:1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(cm1),.MREQ_n(cmreq),.IORQ_n(ciq),.RD_n(crd),.WR_n(cwr),.OUT0(1'b0),.A(ca),.DI(!ciq?vd:ca>=16'hc000 ? ram[ca[12:0]]:rom[ca]),.DO(co),.REG(z80_reg),.NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.RestoreHold(FIX&&frozen),.ReplayT2(replay_t2),.NMIReplay(replay),.MCProbe(mc_probe),.TSProbe(ts_probe),.RestartProbe(restart_probe),.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
reg init_we=0;reg[14:0]init_a=0;reg[7:0]init_d=0;reg init_cwe=0;reg[4:0]init_ca=0;reg[11:0]init_cd=0;
wire[135:0]refregs;wire[383:0]refcram;wire[11:0]color,rcolor;wire[31:0]probe,rprobe;wire[63:0]audit;
vdp #(.MAX_SPPL(SLOTS-1)) vdp1(.ss_bg_out(candidate_bg_live),.ss_bg_in(candidate_bg_in),.ss_bg_valid(candidate_bg_valid),.audit(audit),.clk_sys(clk),.ce_vdp(ce_vdp&&!frozen&&!setup),.ce_pix(ce_pix&&!frozen&&runvideo),.ce_sp(ce_sp&&!frozen&&runvideo),.gg(GG!=0),.ggres(GG!=0),.se_bank(1'b0),.sp64(1'b0),.HL(hl),.mask_line_irq(1'b0),.capture_cpu_edges(CLONE!=0),.legacy_ext_nt(1'b0),.RD_n(crd|ciq),.WR_n(cwr|ciq),.IRQ_n(irq),.WR_direct(1'b0),.A_direct(6'd0),.A(ca[7:0]),.D_in(co),.D_out(vd),.x(x),.y(y),.vcounter_cpu(vc),.color(color),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(m1),.smode_M2(m2),.smode_M3(m3),.smode_M4(m4),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(cram_out),.ss_cram_wr(init_cwe|cram_wr),.ss_cram_A(init_cwe?init_ca:cram_A),.ss_cram_D(init_cwe?init_cd:cram_D),.ss_vram_en((vram_en&&(!REFERENCE||warming))|setup),.ss_vram_A(vram_A),.ss_vram_D(vram_D),.ss_vram_WE(init_we|vram_WE),.ss_vram_WA(init_we?init_a:vram_WA),.ss_vram_WD(init_we?init_d:vram_WD),.ss_sprite_out(g06_live),.ss_sprite_in(sprite_restored[N+41:0]),.ss_sprite_valid(sprite_valid),.ss_freeze(frozen));
assign probe=0;assign psg_out=0;assign psg2_out=0;assign psg_ext_out=0;assign psg2_ext_out=0;assign psg_div_out=0;assign audio_quiescent=1;
assign vdp2_regs=0;
always@(posedge vb)frame=frame+1;
reg hadfreeze=0;integer accepted_x,accepted_y;
always@(posedge clk)if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
 accepted_x=x;accepted_y=y;$display("ACCEPT save%b cycle%0d x%0d y%0d PC%h ce%0b%0b%0b regs%h probe%h",dut.do_save,cycle,x,y,ca,ce_vdp,ce_pix,ce_cpu,vdp_regs,probe);
end
always@(posedge ss_freeze)begin holdref=1;hadfreeze=1;$display("ARM x%0d y%0d regs%h probe%h audit%h CPU%h",x,y,vdp_regs,probe,audit,z80_reg);end
always@(negedge ss_freeze)if(hadfreeze)begin
 holdref=0;$display("RELEASE save%b cycle%0d x%0d y%0d snap%h regs%h probe%h",dut.do_save,cycle,x,y,dut.video_snap,vdp_regs,probe);
 if(!FIX&&!REFERENCE&&video_state_out[21:4]!==dut.video_snap[21:4])$fatal(1,"release alignment timeout");
end
function[7:0]pattern(input integer n);integer off;begin
 pattern=((n*37)^(n>>3)^8'ha7)&255;
 if(n>=14'h3800&&n<14'h3f00)pattern=n[0]?8'h08:8'h01;
 if(n>=14'h2000&&n<14'h2040)pattern=n[1:0]==0?8'hff:8'h00;
 if(n>=14'h3f00&&n<14'h3f40)begin off=n-14'h3f00;pattern=off<SPRITES?8'd167:8'd208;end
 if(n>=14'h3f80&&n<16384)pattern=n[0]?0:SPRITE_X+((NEAR&&((n-14'h3f80)/2)%2)?8:0);
end endfunction
task request(input bit saveop);begin if(PAUSE_CAPTURE)begin while(cm1||cmreq)tick;logical_pause=1;end
 while(dut.state!=0)tick;
 force dut.op_cooldown=0;force alias_ctl.op_cooldown=0;ss_save=saveop;ss_load=!saveop;tick;ss_save=0;ss_load=0;if(REFERENCE&&!warming)begin wait(dut.state==41);tick;end else begin wait(ss_freeze);wait(!frozen);end #1;io_count=0;release dut.op_cooldown;release alias_ctl.op_cooldown;if(PAUSE_CAPTURE)logical_pause=0;
end endtask
reg[229:0]rcpu[0:SAMPLES-1];
integer n,j,f,checks=0,divs=0,guestdiv=0,savechecks=0,line_diag=0,saveflags=0,savereads=0,gueststores=0,guestacc=0;reg[135:0]trace[0:SAMPLES-1];reg[7:0]readtrace[0:SAMPLES-1],racc[0:SAMPLES-1],rmem[0:SAMPLES-1];reg[11:0]pixels[0:SAMPLES-1];reg[8:0]tx[0:SAMPLES-1],ty[0:SAMPLES-1];reg[7:0]sigref;reg scoring=0;reg native_done=0;reg[63:0] audit_trace[0:SAMPLES-1];reg irq_trace[0:SAMPLES-1];integer visible=0;
initial begin
 $readmemh("rom.hex",rom);for(n=0;n<12288;n=n+1)mem[n]=0;for(n=0;n<8192;n=n+1)begin ram[n]=0;rram[n]=0;end
 repeat(10)tick;reset_n=1;init_we=1;
 for(n=0;n<32768;n=n+1)begin init_a=n;init_d=pattern(n%16384);tick;end init_we=0;
 init_cwe=1;for(n=0;n<32;n=n+1)begin init_ca=n;init_cd=(n*12'h135)^12'h5a3;tick;end init_cwe=0;hl=1;tick;hl=0;tick;setup=0;runvideo=1;
 while(!(frame>=1&&vb&&x>=REQUEST_X&&x<256&&y==REQUEST_Y))tick;

 if(WARMUP)begin
  // A genuine v13 LOAD invokes the documented legacy normalization. No force
  // initializes retained sprite history. Then run another complete frame.
  request(1);mem[26][63:40]=24'h48430d;mem[32][39:32]=8'd1;mem[34][63:32]=0;
  repeat(20)tick;request(0);
  if($isunknown(g06_live))$fatal(1,"legacy normalization left unknown sprite state");
  $display("LEGAL_LEGACY_WARMUP complete spritebits%0d",N+42);
  warming=0;
  begin integer next_frame;next_frame=frame+1;
   while(!(frame>=next_frame&&vb&&x>=REQUEST_X&&x<256&&y==REQUEST_Y))tick;
  end
 end
 if(ON_IO)begin while(ciq||((ON_IO==1)?crd:cwr))tick;end
 $display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);fork native_score;join_none
 if(accepted_y!=REQUEST_Y)$fatal(1,"request missed target blank line");
 // Reference and DUT execute identical P in independent simulations.
 if(REFERENCE)f=$fopen("reference.dat","w");else begin
  f=$fopen("reference.dat","r");if(!f)$fatal(1,"missing uninterrupted reference");
  for(j=0;j<SAMPLES;j=j+1)begin
   if(EXT_REFERENCE)begin n=$fscanf(f,"%h %h %h %h %h %h %h %h %h %h %h\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j],racc[j],rmem[j],rcpu[j],audit_trace[j],irq_trace[j],ref_io_count[j]);if(n!=11)$fatal(1,"short extended reference");end
   else if(SPRITES>2)begin n=$fscanf(f,"%h %h %h %h %h %h %h\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j],racc[j],rmem[j]);if(n!=7)$fatal(1,"short CPU reference");end
   else begin n=$fscanf(f,"%h %h %h %h %h\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j]);if(n!=5)$fatal(1,"short reference");end
  end $fclose(f);
 end
 for(j=0;j<SAMPLES;j=j+1)begin
  do tick;while(!ce_pix);@(posedge clk);#1;
  if($isunknown({vdp_regs,color,irq}))$fatal(1,"unknown initialized oracle x%0d y%0d regs%h color%h",x,y,vdp_regs,color);
  if(REFERENCE)begin
   if(EXT_REFERENCE)$fdisplay(f,"%h %h %h %h %h %h %h %h %h %h %h",x,y,vdp_regs,color,io_sample,z80_reg[7:0],ram[256],z80_reg,audit,irq,io_count);
   else if(SPRITES>2)$fdisplay(f,"%h %h %h %h %h %h %h",x,y,vdp_regs,color,vd,z80_reg[7:0],ram[256]);
   else $fdisplay(f,"%h %h %h %h %h",x,y,vdp_regs,color,vd);
  end
  else begin
   if({x,y}!=={tx[j],ty[j]})$fatal(1,"save-only beam misalignment");
   // line_overflow is an internal gate, not the returned overflow flag.
   // It clears from raw beam movement during freeze. Preserve the diagnostic;
   // exclude it only in this <=2-sprite fixture, with its sole set consumer
   // guarded by an explicit inactive-overflow-source assertion.
   if(EXT_REFERENCE&&(z80_reg!==rcpu[j]||ram[256]!==rmem[j]))$fatal(1,"extended SAVE-only CPU/RAM mismatch x%0d y%0d",x,y);
   if(PROTO)begin
    if(vdp_regs!==trace[j]||(color!==pixels[j]))begin if(!DIAGNOSTIC)$fatal(1,"prototype SAVE-only VDP mismatch x%0d y%0d",x,y); if(saveflags<4)$display("DIAGNOSTIC_SAVE_MISMATCH j%0d x%0d y%0d dut%h ref%h",j,x,y,vdp_regs,trace[j]);saveflags++;end
    if(SPRITES>2&&(z80_reg[7:0]!==racc[j]||ram[256]!==rmem[j]))$fatal(1,"prototype SAVE-only CPU/RAM mismatch");
   end else begin
   if(SPRITES>2)begin
    // Separate nine-sprite SAVE-only characterization. Do not grant the
    // inactive-source exclusion to an actual overflow-producing fixture.
    if(vdp_regs[118]!==trace[j][118])begin
     if(saveflags<4)$display("SAVE_OVERFLOW_DIVERGENCE j%0d x%0d y%0d dut%b ref%b source%b",j,x,y,vdp_regs[118],trace[j][118],probe[16]);saveflags++;
    end
    if(vd[6]!==readtrace[j][6]&&!ciq&&!crd&&ca[7:0]==8'hbf)begin
     if(savereads<4)$display("SAVE_STATUS_DIVERGENCE j%0d x%0d y%0d dut%h ref%h",j,x,y,vd,readtrace[j]);savereads++;
    end
    if($isunknown({z80_reg[7:0],ram[256],racc[j],rmem[j]}))$fatal(1,"unknown guest signature");
    if(y==168&&x<100&&z80_reg[7:0]!==racc[j])guestacc++;
    if(y==168&&x<100&&ram[256]!==rmem[j])begin
     if(gueststores==0)$display("SAVE_GUEST_STORE x%0d y%0d C100=%h ref=%h ACC=%h refACC=%h",x,y,ram[256],rmem[j],z80_reg[7:0],racc[j]);gueststores++;
    end
   end else begin
   if(vdp_regs[119]!==trace[j][119])begin
    if(SPRITES>2||probe[16]!==0)$fatal(1,"line_overflow distinction may be observable");
    if(line_diag==0)$display("LINE_OVERFLOW_DIAGNOSTIC x%0d y%0d dut%b ref%b source%b",x,y,vdp_regs[119],trace[j][119],probe[16]);line_diag++;
   end
   if({vdp_regs[135:120],vdp_regs[118:0]}!=={trace[j][135:120],trace[j][118:0]}||(color!==pixels[j]))$fatal(1,"SAVE-only reference mismatch x%0d y%0d dut%h ref%h",x,y,vdp_regs,trace[j]);
   end
  end
   end
  if(y<192&&x<256)visible++;
  if(!REFERENCE&&irq!==irq_trace[j])$fatal(1,"SAVE IRQ mismatch x%0d y%0d",x,y);
  if(!REFERENCE&&EXT_REFERENCE&&(io_count!=ref_io_count[j]||(io_count>0&&io_sample!==readtrace[j])))$fatal(1,"SAVE consumed IN value/count differs xy%0d,%0d count%0d ref%0d value%h ref%h",x,y,io_count,ref_io_count[j],io_sample,readtrace[j]);
  savechecks++;
 end
 wait(native_done);
 if(REFERENCE)begin $fclose(f);$display("PASS UNINTERRUPTED REFERENCE samples%0d",savechecks);$finish;end
 for(n=0;n<12288;n++)image_saved[n]=mem[n];f=$fopen("image.hex","w");for(n=0;n<12288;n=n+1)begin if($isunknown(mem[n]))begin if(WARMUP || n<10497 || n>10646)$fatal(1,"unknown established image word%0d",n);else $display("INACTIVE_PAYLOAD_UNKNOWN word%h",n);end $fdisplay(f,"%016h",mem[n]);end $fclose(f);
 if(SAVE_ONLY)begin $display("DONE SAVE_ONLY samples%0d mismatches%0d",savechecks,saveflags);$finish;end
 for(integer pass=0;pass<REPLAYS;pass=pass+1)begin
  // Legal DMA perturbation of backing memory plus normal running histories.
  for(n=0;n<80+pass*1370;n=n+1)tick;
  request(0);fork native_score;join_none divs=0;guestdiv=0;
  for(j=0;j<SAMPLES;j=j+1)begin
   do tick;while(!ce_pix);@(posedge clk);#1;
   if({x,y}!=={tx[j],ty[j]})$fatal(1,"logical beam misalignment j%0d actual%0d,%0d ref%0d,%0d",j,x,y,tx[j],ty[j]);
   if($isunknown({vdp_regs,color,irq}))$fatal(1,"unknown restored state");
   if(EXT_REFERENCE&&(z80_reg!==rcpu[j]||ram[256]!==rmem[j]))$fatal(1,"extended LOAD CPU/RAM mismatch x%0d y%0d cpu%h ref%h ram%h ref%h",x,y,z80_reg,rcpu[j],ram[256],rmem[j]);
   if(FIX&&vdp_regs!==trace[j])$fatal(1,"full VDP LOAD mismatch x%0d y%0d",x,y);
   if((color!==pixels[j]))$fatal(1,"integrated LOAD pixel mismatch x%0d y%0d dut%h ref%h",x,y,color,pixels[j]);
   if(irq!==irq_trace[j])$fatal(1,"LOAD IRQ mismatch x%0d y%0d",x,y);
   if(EXT_REFERENCE&&(io_count!=ref_io_count[j]||(io_count>0&&io_sample!==readtrace[j])))$fatal(1,"LOAD consumed IN value/count differs xy%0d,%0d count%0d ref%0d value%h ref%h",x,y,io_count,ref_io_count[j],io_sample,readtrace[j]);
   checks++;
   if(vdp_regs[117]!==trace[j][117])begin
    if(divs<4)$display("COLLISION_DIVERGENCE pass%0d j%0d x%0d y%0d dut%b ref%b probe%h",pass,j,x,y,vdp_regs[117],trace[j][117],probe);
    divs++;
   end
   if(!EXT_REFERENCE&&(vd[5]!==readtrace[j][5])&&!ciq&&!crd&&ca[7:0]==8'hbf)begin
    if(guestdiv<4)$display("STATUS_DIVERGENCE pass%0d j%0d x%0d y%0d dut%h ref%h PC%h",pass,j,x,y,vd,readtrace[j],ca);guestdiv++;
   end
  end
  wait(native_done);
  for(n=0;n<12288;n++)if(mem[n]!==image_saved[n])$fatal(1,"LOAD changed saved image word%h",n);
  $display("RESULT pass%0d collisionSamples%0d statusBusSamples%0d",pass,divs,guestdiv);if(FIX&&(divs||guestdiv))$fatal(1,"protocol LOAD mismatch");
 end
 $display("PASS V15 VDP gg%0d pal%0d sprite%0d saveonly%0d checks%0d lineDiagnostics%0d",GG,PAL,SPRITES,savechecks,checks,line_diag);$finish;
end
initial begin #300000000;$fatal(1,"watchdog");end



reg[N+41:0]held_sprite;reg[135:0]held_vdp;reg was_prepare=0;integer prep_ticks=0;
always@(posedge clk)begin
 if(cpu_prepare&&!was_prepare)begin held_sprite=g06_live;held_vdp=vdp_regs;prep_ticks=0;end
 if(cpu_prepare)begin
  if(ce_cpu&&replay)prep_ticks++;
  if(g06_live!==held_sprite||vdp_regs!==held_vdp)$fatal(1,"integrated preparation advanced VDP");
  if(!ciq||!cwr)$fatal(1,"integrated preparation issued IO/write");
 end
 if(was_prepare&&!cpu_prepare)$display("INTEGRATED_PREP_DONE ticks%0d MC%0d TS%0d",prep_ticks,mc_probe,ts_probe);
 was_prepare<=cpu_prepare;
end
always@(negedge ss_freeze)if(hadfreeze&&(!REFERENCE||warming))begin #1;
 if(video_state_out!==dut.video_snap)$fatal(1,"integrated canonical beam mismatch");
 $display("INTEGRATED_RELEASE phase%0d",clkd);
end
// Semantic enable contract, expressed as first-event distances and periods,
// independently of the divider's case implementation.
integer native_age=-1;integer first_cpu,first_vdp,first_pix,first_sp;
always@(negedge ss_freeze)if(hadfreeze&&!REFERENCE)begin
 native_age=0;first_vdp=5;
 case(phase_in)
 0:begin first_cpu=10;first_pix=10;first_sp=2;end
 1:begin first_cpu=15;first_pix=10;first_sp=2;end
 2:begin first_cpu=5;first_pix=10;first_sp=2;end
 3:begin first_cpu=15;first_pix=5;first_sp=1;end
 endcase
end
always@(posedge clk)if(native_age>=0&&!ss_freeze)begin
 native_age++;
 if(ce_cpu!==(native_age>=first_cpu&&(native_age-first_cpu)%15==0)||
    ce_vdp!==(native_age>=first_vdp&&(native_age-first_vdp)%5==0)||
    ce_pix!==(native_age>=first_pix&&(native_age-first_pix)%10==0)||
    ce_sp!==(native_age>=first_sp&&(native_age-first_sp)%2==0))$fatal(1,"native enable ordering clock%0d phasecode%0d",native_age,phase_in);
 if(native_age==60)begin $display("NATIVE_ENABLE_ORDER PASS phasecode%0d hostclocks60",phase_in);native_age=-1;end
end
always@(posedge cpu_prepare)if(NATURAL_PHASE&&!warming)begin
 if(phase_distance<0)begin phase_distance=cycle-last_issue_cycle;$display("NATURAL_PHASE_CALIBRATION distance%0d",phase_distance);end
 else begin
  if(clkd!==expected_prepare_phase)$fatal(1,"transport phase target failed actual%0d expected%0d",clkd,expected_prepare_phase);
  $display("NATURAL_TRANSPORT_PHASE %0d",clkd);
 end
end
integer boundaries=0,pending_clear=0,pending_incr=0,pending_write=0;
always@(posedge clk)if(!setup&&!frozen&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
 boundaries++;if(vdp_regs[103])pending_clear++;if(audit[2])pending_incr++;if(audit[3])pending_write++;
 if(dut.state==37)$display("BOUNDARY T cycle%0d xy%0d,%0d MC%0d TS%0d phase%0d ce_vdp%b audit%h reset%b",cycle,x,y,mc_probe,ts_probe,clkd,ce_vdp,audit,vdp_regs[103]);
end
reg[6:0]old_state=0;
always@(posedge clk)begin
 if(dut.state!=old_state&&(dut.state>=45||cpu_prepare||phase_set))$display("RESTART cycle%0d state%0d prep%b phaseSet%b ce%b%b%b%b",cycle,dut.state,cpu_prepare,phase_set,ce_cpu,ce_vdp,ce_pix,ce_sp);
 old_state<=dut.state;
end
final $display("AUDIT_COUNTS eligible%0d pendingClear%0d pendingIncr%0d pendingWrite%0d visiblePixels%0d",boundaries,pending_clear,pending_incr,pending_write,visible);
reg[229+136:0]q_sig[0:2];integer q_seen=0;
always@(posedge ss_freeze)if(!dut.do_save&&!warming)begin
 for(integer z=0;z<q_seen;z++)if(q_sig[z]==={z80_reg,vdp_regs})$fatal(1,"G04 perturbation histories converged");
 q_sig[q_seen]={z80_reg,vdp_regs};q_seen++;
 $display("G04_DISTINCT_Q index%0d CPU%h VDP%h",q_seen,z80_reg,vdp_regs);
end
always@(posedge clk)if(!setup&&!frozen&&cpu_tick&&!ciq&&!crd&&ts_probe==2&&ca[7:6]==2'b10)begin
 if($isunknown(vd))$fatal(1,"unknown value actually consumed by CPU VDP IN");
 io_sample<=vd;io_count<=io_count+1;
end

task native_score;integer nf,k,n;reg[8:0]nx,ny;reg[135:0]nr;reg[15:0]na;reg[229:0]nc;reg[7:0]nm;bit seen_vdp;begin
 native_done=0;seen_vdp=0;nf=$fopen("native_reference.dat",REFERENCE?"w":"r");if(!nf)$fatal(1,"missing native reference");
 for(k=0;k<10000;k++)begin @(posedge clk);#1;
  if($isunknown({x,y,vdp_regs,audit[31:16],z80_reg,ram[256]}))$fatal(1,"unknown native G04 observation");
  if(ce_vdp)seen_vdp=1;
  if(REFERENCE)$fdisplay(nf,"%h %h %h %h %h %h",x,y,vdp_regs,audit[31:16],z80_reg,ram[256]);
  else begin n=$fscanf(nf,"%h %h %h %h %h %h\n",nx,ny,nr,na,nc,nm);
   if(n!=6||{x,y,vdp_regs,audit[31:17],z80_reg,ram[256]}!=={nx,ny,nr,na[15:1],nc,nm})$fatal(1,"native G04 collision/IRQ/CPU/RAM mismatch host%0d",k);
   if(seen_vdp&&audit[16]!==na[0])$fatal(1,"last_x0 did not converge on first VDP enable");
  end
 end
 $fclose(nf);native_done=1;$display("PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP");
end endtask
assign candidate_bg2_live=0;
reg[138:0]bg_capture,bg2_capture,bg_hold,bg2_hold;reg bg_was_frozen=0;integer bg_settle=0;
always@(posedge ss_freeze)if(dut.do_save)begin #0.001;bg_capture=candidate_bg_live;bg2_capture=candidate_bg2_live;
 if(!warming&&$isunknown({candidate_bg_live,candidate_bg2_live}))$fatal(1,"unknown accepted background payload");
 $display("CAPTURE_BG139 primary%h secondary%h",bg_capture,bg2_capture);
end
always@(posedge clk)begin
 if(vdp_regs_set||vdp2_regs_set)bg_settle=3;
 if(bg_settle>0)bg_settle--;
 if(frozen&&bg_was_frozen&&bg_settle==0)begin #0.001;
  if(candidate_bg_live!==bg_hold||candidate_bg2_live!==bg2_hold)$fatal(1,"background advanced while frozen");
 end
 #0.002;bg_hold=candidate_bg_live;bg2_hold=candidate_bg2_live;bg_was_frozen=frozen;
end
reg[138:0]prepare_bg,prepare_bg2;
always@(posedge cpu_prepare)begin prepare_bg=candidate_bg_live;prepare_bg2=candidate_bg2_live;end
always@(posedge clk)if(cpu_prepare&&(candidate_bg_live!==prepare_bg||candidate_bg2_live!==prepare_bg2))$fatal(1,"CPU preparation advanced background");
reg[15:0]stall_rng=16'h1ace;integer frozen_start=0;
always@(negedge clk)begin #0.001;
 stall_rng={stall_rng[14:0],stall_rng[15]^stall_rng[13]^stall_rng[12]^stall_rng[10]};
 DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%97<83:STALL==2?stall_rng[3:0]<13:0);
end
always@(posedge ss_freeze)frozen_start=cycle;
always@(negedge ss_freeze)if(hadfreeze)$display("TRANSPORT_DURATION save%b profile%0d hostclocks%0d",dut.do_save,STALL,cycle-frozen_start);
// Original G06 SAVE-transport hold assertion, retained alongside G05 monitors.
reg[N+41:0]save_sprite_held;reg[135:0]save_vdp_held;reg[229:0]save_cpu_held;
reg save_monitoring=0;integer frozen_samples=0;
always@(posedge clk)begin
 if(dut.state==41&&dut.do_save)begin
  save_sprite_held=g06_live;save_vdp_held=vdp_regs;save_cpu_held=z80_reg;save_monitoring=1;
 end
 if(save_monitoring&&frozen)begin
  frozen_samples++;
  if({g06_live,vdp_regs,z80_reg}!=={save_sprite_held,save_vdp_held,save_cpu_held})$fatal(1,"SAVE transport advanced guest state");
 end
 if(save_monitoring&&!frozen)begin
  save_monitoring=0;$display("SAVE_TRANSPORT_HOLD PASS profile%0d hostclocks%0d",STALL,frozen_samples);
 end
end

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
wire[$bits(z80_iset)-1:0]alias_cpu_ISet_out;
wire[$bits(restart_out)-1:0]alias_cpu_RestartContext;
wire[$bits(restart_probe)-1:0]alias_cpu_RestartProbe;
wire[$bits(ts_probe)-1:0]alias_cpu_TSProbe;
wire[$bits(replay)-1:0]alias_cpu_NMIReplay;
wire[$bits(z80_reg)-1:0]alias_cpu_REG;
wire[$bits(co)-1:0]alias_cpu_DO;
wire[$bits(ca)-1:0]alias_cpu_A;
wire[$bits(cwr)-1:0]alias_cpu_WR_n;
wire[$bits(crd)-1:0]alias_cpu_RD_n;
wire[$bits(ciq)-1:0]alias_cpu_IORQ_n;
wire[$bits(cmreq)-1:0]alias_cpu_MREQ_n;
wire[$bits(cm1)-1:0]alias_cpu_M1_n;
T80s #(.T2Write(0)) alias_cpu(.RESET_n(reset_n&&!setup),.CLK(clk),.CEN((cpu_tick&&!frozen&&!logical_pause)||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n(1'b1),.INT_n(IRQ_ENABLE?irq:1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(alias_cpu_M1_n),.MREQ_n(alias_cpu_MREQ_n),.IORQ_n(alias_cpu_IORQ_n),.RD_n(alias_cpu_RD_n),.WR_n(alias_cpu_WR_n),.OUT0(1'b0),.A(alias_cpu_A),.DI(!ciq?vd:ca>=16'hc000 ? ram[ca[12:0]]:rom[ca]),.DO(alias_cpu_DO),.REG(alias_cpu_REG),.NMIEnable(1'b1),.NMIDIR(alias_ctl.z80_nmi_dir),.NMIValid(alias_ctl.z80_nmi_valid),.NMIHold(alias_ctl.z80_nmi_hold),.RestoreHold(FIX&&frozen),.ReplayT2(replay_t2),.NMIReplay(alias_cpu_NMIReplay),.MCProbe(mc_probe),.TSProbe(alias_cpu_TSProbe),.RestartProbe(alias_cpu_RestartProbe),.RestartContext(alias_cpu_RestartContext),.RestartDIR(alias_ctl.z80_restart_dir),.RestartValid(alias_ctl.z80_restart_valid),.DIRSet(alias_z80_set),.DIR(alias_z80_dir),.ISet_out(alias_cpu_ISet_out));
always@(posedge clk)begin #1;if(alias_cpu_ISet_out!==z80_iset)$fatal(1,"ALIAS real CPU ISet_out");
if(alias_cpu_RestartContext!==restart_out)$fatal(1,"ALIAS real CPU RestartContext");
if(alias_cpu_RestartProbe!==restart_probe)$fatal(1,"ALIAS real CPU RestartProbe");
if(alias_cpu_TSProbe!==ts_probe)$fatal(1,"ALIAS real CPU TSProbe");
if(alias_cpu_NMIReplay!==replay)$fatal(1,"ALIAS real CPU NMIReplay");
if(alias_cpu_REG!==z80_reg)$fatal(1,"ALIAS real CPU REG");
if(alias_cpu_DO!==co)$fatal(1,"ALIAS real CPU DO");
if(alias_cpu_A!==ca)$fatal(1,"ALIAS real CPU A");
if(alias_cpu_WR_n!==cwr)$fatal(1,"ALIAS real CPU WR_n");
if(alias_cpu_RD_n!==crd)$fatal(1,"ALIAS real CPU RD_n");
if(alias_cpu_IORQ_n!==ciq)$fatal(1,"ALIAS real CPU IORQ_n");
if(alias_cpu_MREQ_n!==cmreq)$fatal(1,"ALIAS real CPU MREQ_n");
if(alias_cpu_M1_n!==cm1)$fatal(1,"ALIAS real CPU M1_n");
end
endmodule
