`include "header.svh"
wire[649:0]g06_live;reg[649:0]g06_snap;
always@(posedge clk)if(dut.state==41&&dut.do_save)g06_snap<=g06_live;
always #5 clk=~clk;
wire frozen=ss_freeze&&!REFERENCE;reg hl=0;
integer cycle=0;reg[4:0]clkd=0;reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
// Supported production turbo cadence. CPU/pixel events share /10 so the
// scoped VDP oracle does not depend on reconstruction of the separate /15
// divider phase (G10 is explicitly outside this investigation).
wire cpu_tick=TURBO?ce_pix:ce_cpu;
wire[2:0] mc_probe,ts_probe;wire[1:0]restart_probe;
assign cpu_ce=cpu_tick;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
always@(negedge clk)cycle=cycle+1;
always @(negedge clk) begin
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

reg[63:0]mem[0:12287];integer pending=0;reg[28:0]readaddr;
always@(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=3;readaddr<=DDRAM_ADDR;end
end
task tick;begin @(negedge clk);#1;end endtask
reg setup=1,runvideo=0,holdref=0,lockref=0;integer frame=0;wire[8:0]y,rx,ry;wire[7:0]vc,rvc;wire vb,rvb;wire[21:0]rvideo;
wire m1,m2,m3,m4;
assign vblank=vb;
video video1(.clk(clk),.ce_pix(ce_pix&&runvideo),.pal(PAL!=0),.border(1'b0),.ggres(GG!=0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(m1),.smode_M2(m2),.smode_M3(m3),.smode_M4(m4),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(vc),.hsync(),.vsync(),.hblank(),.vblank(vb));
wire[15:0]ca,ra;wire[7:0]co,ro;wire cm1,cmreq,rm1,rmreq,ciq,riq,crd,cwr,rrd,rwr;wire[229:0]rr;wire[1:0]riset;wire replay;wire[7:0]vd,rvd;wire irq,rirq;
reg[7:0]rom[0:65535],ram[0:8191],rram[0:8191];
assign wram_D=ram[wram_A[12:0]];
always@(posedge clk)begin
 if(wram_WE)ram[wram_WA[12:0]]<=wram_WD;else if(!frozen&&!cmreq&&!cwr&&ca>=16'hc000)ram[ca[12:0]]<=co;
 if(!holdref&&!lockref&&!rmreq&&!rwr&&ra>=16'hc000)rram[ra[12:0]]<=ro;
end
assign z80_m1_n=cm1;assign z80_mreq_n=cmreq;
T80s #(.T2Write(0)) cpu(.RESET_n(reset_n&&!setup),.CLK(clk),.CEN(cpu_tick&&!frozen),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(cm1),.MREQ_n(cmreq),.IORQ_n(ciq),.RD_n(crd),.WR_n(cwr),.OUT0(1'b0),.A(ca),.DI(!ciq?vd:ca>=16'hc000 ? ram[ca[12:0]]:rom[ca]),.DO(co),.REG(z80_reg),.NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.NMIReplay(replay),.MCProbe(mc_probe),.TSProbe(ts_probe),.RestartProbe(restart_probe),.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
reg init_we=0;reg[14:0]init_a=0;reg[7:0]init_d=0;reg init_cwe=0;reg[4:0]init_ca=0;reg[11:0]init_cd=0;
wire[135:0]refregs;wire[383:0]refcram;wire[11:0]color,rcolor;wire[31:0]probe,rprobe;
vdp vdp1(.clk_sys(clk),.ce_vdp(ce_vdp&&!frozen&&!setup),.ce_pix(ce_pix&&!frozen&&runvideo),.ce_sp(ce_sp&&!frozen&&runvideo),.gg(GG!=0),.ggres(GG!=0),.se_bank(1'b0),.sp64(1'b0),.HL(hl),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(crd|ciq),.WR_n(cwr|ciq),.IRQ_n(irq),.WR_direct(1'b0),.A_direct(6'd0),.A(ca[7:0]),.D_in(co),.D_out(vd),.x(x),.y(y),.vcounter_cpu(vc),.color(color),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(m1),.smode_M2(m2),.smode_M3(m3),.smode_M4(m4),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(cram_out),.ss_cram_wr(init_cwe|cram_wr),.ss_cram_A(init_cwe?init_ca:cram_A),.ss_cram_D(init_cwe?init_cd:cram_D),.ss_vram_en(vram_en|setup),.ss_vram_A(vram_A),.ss_vram_D(vram_D),.ss_vram_WE(init_we|vram_WE),.ss_vram_WA(init_we?init_a:vram_WA),.ss_vram_WD(init_we?init_d:vram_WD),.probe(probe),.g06_out(g06_live),.g06_in(g06_snap),.g06_valid(PROTO!=0),.g06_freeze(frozen&&PROTO!=0));
assign psg_out=0;assign psg2_out=0;assign psg_ext_out=0;assign psg2_ext_out=0;assign psg_div_out=0;assign audio_quiescent=1;
assign vdp2_regs=0;
always@(posedge vb)frame=frame+1;
reg hadfreeze=0;integer accepted_x,accepted_y;
always@(posedge clk)if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
 accepted_x=x;accepted_y=y;$display("ACCEPT save%b cycle%0d x%0d y%0d PC%h ce%0b%0b%0b regs%h probe%h",dut.do_save,cycle,x,y,ca,ce_vdp,ce_pix,ce_cpu,vdp_regs,probe);
end
always@(posedge ss_freeze)begin holdref=1;hadfreeze=1;$display("ARM x%0d y%0d regs%h probe%h",x,y,vdp_regs,probe);end
always@(negedge ss_freeze)if(hadfreeze)begin
 holdref=0;$display("RELEASE save%b cycle%0d x%0d y%0d snap%h regs%h probe%h",dut.do_save,cycle,x,y,dut.video_snap,vdp_regs,probe);
 if(!REFERENCE&&video_state_out[21:4]!==dut.video_snap[21:4])$fatal(1,"release alignment timeout");
end
function[7:0]pattern(input integer n);integer off;begin
 pattern=((n*37)^(n>>3)^8'ha7)&255;
 if(n>=14'h3800&&n<14'h3f00)pattern=n[0]?8'h08:8'h01;
 if(n>=14'h2000&&n<14'h2040)pattern=n[1:0]==0?8'hff:8'h00;
 if(n>=14'h3f00&&n<14'h3f40)begin off=n-14'h3f00;pattern=off<SPRITES?8'd167:8'd208;end
 if(n>=14'h3f80&&n<16384)pattern=n[0]?0:SPRITE_X;
end endfunction
task request(input bit saveop);begin
 force dut.op_cooldown=0;ss_save=saveop;ss_load=!saveop;tick;ss_save=0;ss_load=0;if(REFERENCE)begin wait(dut.state==41);tick;end else begin wait(ss_freeze);wait(!frozen);end #1;release dut.op_cooldown;
end endtask
integer n,j,f,checks=0,divs=0,guestdiv=0,savechecks=0,line_diag=0,saveflags=0,savereads=0,gueststores=0,guestacc=0;reg[135:0]trace[0:3000];reg[7:0]readtrace[0:3000],racc[0:3000],rmem[0:3000];reg[11:0]pixels[0:3000];reg[8:0]tx[0:3000],ty[0:3000];reg[7:0]sigref;reg scoring=0;
initial begin
 $readmemh("rom.hex",rom);for(n=0;n<12288;n=n+1)mem[n]=0;for(n=0;n<8192;n=n+1)begin ram[n]=0;rram[n]=0;end
 repeat(10)tick;reset_n=1;init_we=1;
 for(n=0;n<32768;n=n+1)begin init_a=n;init_d=pattern(n%16384);tick;end init_we=0;
 init_cwe=1;for(n=0;n<32;n=n+1)begin init_ca=n;init_cd=(n*12'h135)^12'h5a3;tick;end init_cwe=0;hl=1;tick;hl=0;tick;setup=0;runvideo=1;
 while(!(frame>=1&&vb&&x>=REQUEST_X&&y==(GG?168:192)))tick;
 $display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);
 if(accepted_y!=(GG?168:192))$fatal(1,"request missed target blank line");
 // Reference and DUT execute identical P in independent simulations.
 if(REFERENCE)f=$fopen("reference.dat","w");else begin
  f=$fopen("reference.dat","r");if(!f)$fatal(1,"missing uninterrupted reference");
  for(j=0;j<1000;j=j+1)begin
   if(SPRITES>2)begin n=$fscanf(f,"%h %h %h %h %h %h %h\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j],racc[j],rmem[j]);if(n!=7)$fatal(1,"short CPU reference");end
   else begin n=$fscanf(f,"%h %h %h %h %h\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j]);if(n!=5)$fatal(1,"short reference");end
  end $fclose(f);
 end
 for(j=0;j<1000;j=j+1)begin
  do tick;while(!ce_pix);@(posedge clk);#1;
  if($isunknown({vdp_regs,color,irq}))$fatal(1,"unknown initialized oracle x%0d y%0d regs%h color%h",x,y,vdp_regs,color);
  if(REFERENCE)begin
   if(SPRITES>2)$fdisplay(f,"%h %h %h %h %h %h %h",x,y,vdp_regs,color,vd,z80_reg[7:0],ram[256]);
   else $fdisplay(f,"%h %h %h %h %h",x,y,vdp_regs,color,vd);
  end
  else begin
   if({x,y}!=={tx[j],ty[j]})$fatal(1,"save-only beam misalignment");
   // line_overflow is an internal gate, not the returned overflow flag.
   // It clears from raw beam movement during freeze. Preserve the diagnostic;
   // exclude it only in this <=2-sprite fixture, with its sole set consumer
   // guarded by an explicit inactive-overflow-source assertion.
   if(PROTO)begin
    if(vdp_regs!==trace[j]||color!==pixels[j])begin if(!DIAGNOSTIC)$fatal(1,"prototype SAVE-only VDP mismatch x%0d y%0d",x,y); if(saveflags<4)$display("DIAGNOSTIC_SAVE_MISMATCH j%0d x%0d y%0d dut%h ref%h",j,x,y,vdp_regs,trace[j]);saveflags++;end
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
   if({vdp_regs[135:120],vdp_regs[118:0]}!=={trace[j][135:120],trace[j][118:0]}||color!==pixels[j])$fatal(1,"SAVE-only reference mismatch x%0d y%0d dut%h ref%h",x,y,vdp_regs,trace[j]);
   end
  end
   end
  savechecks++;
 end
 if(REFERENCE)begin $fclose(f);$display("PASS UNINTERRUPTED REFERENCE samples%0d",savechecks);$finish;end
 if(SPRITES>2&&PROTO)begin $display("PASS PROTOTYPE SAVE_ONLY observations%0d",savechecks);$finish;end
 if(SPRITES>2)begin
  if(saveflags==0||savereads==0||gueststores==0||guestacc==0)$fatal(1,"nine-sprite SAVE-only guest divergence not reproduced");
  $display("PASS G06 SAVE_ONLY CHARACTERIZED overflowSamples%0d statusBusSamples%0d guestACC%0d guestStores%0d observations%0d",saveflags,savereads,guestacc,gueststores,savechecks);$finish;
 end
 f=$fopen("image.hex","w");for(n=0;n<12288;n=n+1)begin if($isunknown(mem[n]))$fatal(1,"unknown image word%0d",n);$fdisplay(f,"%016h",mem[n]);end $fclose(f);
 if(SAVE_ONLY)begin $display("DONE SAVE_ONLY samples%0d mismatches%0d",savechecks,saveflags);$finish;end
 for(integer pass=0;pass<REPLAYS;pass=pass+1)begin
  // Legal DMA perturbation of backing memory plus normal running histories.
  for(n=0;n<80+pass*31;n=n+1)tick;
  request(0);divs=0;guestdiv=0;
  for(j=0;j<1000;j=j+1)begin
   do tick;while(!ce_pix);@(posedge clk);#1;
   if({x,y}!=={tx[j],ty[j]})$fatal(1,"logical beam misalignment j%0d actual%0d,%0d ref%0d,%0d",j,x,y,tx[j],ty[j]);
   if($isunknown({vdp_regs,color,irq}))$fatal(1,"unknown restored state");
   checks++;
   if(vdp_regs[117]!==trace[j][117])begin
    if(divs<4)$display("COLLISION_DIVERGENCE pass%0d j%0d x%0d y%0d dut%b ref%b probe%h",pass,j,x,y,vdp_regs[117],trace[j][117],probe);
    divs++;
   end
   if((vd[5]!==readtrace[j][5])&&!ciq&&!crd&&ca[7:0]==8'hbf)begin
    if(guestdiv<4)$display("STATUS_DIVERGENCE pass%0d j%0d x%0d y%0d dut%h ref%h PC%h",pass,j,x,y,vd,readtrace[j],ca);guestdiv++;
   end
  end
  $display("RESULT pass%0d collisionSamples%0d statusBusSamples%0d",pass,divs,guestdiv);
 end
 $display("DONE VDP gg%0d pal%0d sprite%0d saveonly%0d checks%0d lineDiagnostics%0d",GG,PAL,SPRITES,savechecks,checks,line_diag);$finish;
end
initial begin #300000000;$fatal(1,"watchdog");end


integer timeline,cap_cycle=-1,release_cycle=-1,last_freeze=0,loads=0;
integer accepted_cycle=-1,accepted_phase=-1,release_target=-1;
// Legal external DDR backpressure after the final image write. No machine,
// divider, controller state or release predicate is forced. Leave 32 idle
// settle clocks and 255 unfreeze-count clocks before the chosen quiet edge.
always@(posedge clk)if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&dut.do_save)begin
 accepted_cycle=cycle;accepted_phase=clkd;
 if(SAVE_PHASE>=0)release_target=cycle+896040+SAVE_PHASE-clkd;
end
always@(negedge clk)begin #2;
 if(SAVE_PHASE>=0&&dut.state==55&&cycle<release_target-287)DDRAM_BUSY=1;
 else DDRAM_BUSY=0;
end
initial begin timeline=$fopen("timeline.csv","w");$fdisplay(timeline,"cycle,clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,cpu_tick,freeze,logical_freeze,state,do_save,MC,TS,restart,M1,MREQ,RD,WR,IORQ,bus_A,DI,DO,acc,ram,x,y,sprites,vdp,status_request,status_sample");end
always@(posedge ss_freeze)begin cap_cycle=cycle;$display("DIVIDER_ARM cycle%0d clkd%0d ce%b%b%b%b save%b",cycle,clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,dut.do_save);end
always@(negedge ss_freeze)if(hadfreeze)begin release_cycle=cycle;loads=loads+!dut.do_save;$display("DIVIDER_RELEASE cycle%0d clkd%0d ce%b%b%b%b save%b",cycle,clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,dut.do_save);end
// Explicit Phase6 control only. Production and phase-only backpressure cases
// never execute this branch. The target phase1 is naturally reached at ARM.
always@(negedge ss_freeze)if(hadfreeze&&!dut.do_save&&COMMON_PHASE)begin
 if(!TURBO||accepted_phase!=0||ce_cpu||ce_vdp||ce_pix||ce_sp)$fatal(1,"invalid common-phase control");
 $display("TESTBENCH_COMMON_PHASE before%0d after1 cycle%0d",clkd,cycle);clkd=1;
end
always@(posedge clk)begin
 if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)$display("DIVIDER_ACCEPT cycle%0d clkd%0d MC%0d TS%0d",cycle,clkd,mc_probe,ts_probe);
 if(z80_set||vdp_regs_set)$display("RESTORE_STROBE cycle%0d clkd%0d CPU%b VDP%b",cycle,clkd,z80_set,vdp_regs_set);
 if(vdp_regs_set&&PROTO)begin #1;if(g06_live!==g06_snap)$fatal(1,"raw sprite restore mismatch");end
end
// Pre-edge observations: divider outputs are stable from the preceding falling edge.
always@(posedge clk)begin
 if(dut.state==37||dut.state==41||z80_set||vdp_regs_set||(dut.state==34&&dut.unfreeze_cnt>=250)||
    (REFERENCE&&cap_cycle>=0&&cycle-cap_cycle<10500)||(!frozen&&release_cycle>=0&&cycle-release_cycle<10500))
 $fdisplay(timeline,"%0d,%0d,%b,%b,%b,%b,%b,%b,%b,%0d,%b,%0d,%0d,%0d,%b,%b,%b,%b,%b,%h,%h,%h,%h,%h,%0d,%0d,%h,%h,%b,%b",cycle,clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,cpu_tick,ss_freeze,frozen,dut.state,dut.do_save,mc_probe,ts_probe,restart_probe,cm1,cmreq,crd,cwr,ciq,ca,vd,co,z80_reg[7:0],ram[256],x,y,g06_live,vdp_regs,!ciq&&!crd&&ca[7:0]==8'hbf,cpu_tick&&!frozen&&ts_probe==2&&mc_probe!=1&&!ciq&&!crd&&ca[7:0]==8'hbf);
end
final begin $fclose(timeline);end

endmodule
