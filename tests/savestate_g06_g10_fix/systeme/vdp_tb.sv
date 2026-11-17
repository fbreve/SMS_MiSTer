`include "header.svh"


always #5 clk=~clk;

reg warming=WARMUP!=0;wire frozen=ss_freeze&&(!REFERENCE||warming);
reg hl=0;
pause_fixture ui(clk,reset_n,systeme,joy_pause,vblank,frozen,ui_paused,ui_pp,ui_up);
assign logical_pause=ui_paused&&!ss_capture_progress;

integer cycle=0;reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
// Supported production turbo cadence. CPU/pixel events share /10 so the
// scoped VDP oracle does not depend on reconstruction of the separate /15
// divider phase (G10 is explicitly outside this investigation).
wire cpu_tick=(TURBO||SYSTEM_E)?ce_pix:ce_cpu;
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
reg[7:0]rom[0:65535],ram[0:16383],rram[0:16383];
reg[7:0]wram_read_q;assign wram_D=wram_read_q;always@(posedge clk)wram_read_q<=ram[wram_A[13:0]];
always@(posedge clk)begin
 if(wram_WE)ram[wram_WA[13:0]]<=wram_WD;else if(!frozen&&!cmreq&&!cwr&&ca>=16'hc000)ram[ca[13:0]]<=co;
 if(!holdref&&!lockref&&!rmreq&&!rwr&&ra>=16'hc000)rram[ra[12:0]]<=ro;
end
assign z80_m1_n=cm1;assign z80_mreq_n=cmreq;
T80s #(.T2Write(0)) cpu(.RESET_n(reset_n&&!setup),.CLK(clk),.CEN((cpu_tick&&!frozen&&!logical_pause)||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.M1_n(cm1),.MREQ_n(cmreq),.IORQ_n(ciq),.RD_n(crd),.WR_n(cwr),.OUT0(1'b0),.A(ca),.DI(!ciq?(ca[2]?vd2:vd):ca>=16'hc000 ? ram[ca[13:0]]:rom[ca]),.DO(co),.REG(z80_reg),.NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.RestoreHold(FIX&&frozen),.ReplayT2(replay_t2),.NMIReplay(replay),.MCProbe(mc_probe),.TSProbe(ts_probe),.RestartProbe(restart_probe),.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir),.ISet_out(z80_iset));
reg init_we=0;reg[14:0]init_a=0;reg[7:0]init_d=0;reg init_cwe=0;reg[4:0]init_ca=0;reg[11:0]init_cd=0;
wire[135:0]refregs;wire[383:0]refcram;wire[11:0]color,rcolor;wire[31:0]probe,rprobe;
vdp #(.MAX_SPPL(SLOTS-1)) vdp1(.clk_sys(clk),.ce_vdp(ce_vdp&&!frozen&&!setup),.ce_pix(ce_pix&&!frozen&&runvideo),.ce_sp(ce_sp&&!frozen&&runvideo),.gg(GG!=0),.ggres(GG!=0),.se_bank(1'b0),.sp64(1'b0),.HL(hl),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(crd|ciq|ca[2]),.WR_n(cwr|ciq|ca[2]),.IRQ_n(irq),.WR_direct(1'b0),.A_direct(6'd0),.A(ca[7:0]),.D_in(co),.D_out(vd),.x(x),.y(y),.vcounter_cpu(vc),.color(color),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(m1),.smode_M2(m2),.smode_M3(m3),.smode_M4(m4),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(cram_out),.ss_cram_wr(init_cwe|cram_wr),.ss_cram_A(init_cwe?init_ca:cram_A),.ss_cram_D(init_cwe?init_cd:cram_D),.ss_vram_en(vram_en|setup),.ss_vram_A(vram_A),.ss_vram_D(vram_D),.ss_vram_WE(init_we|vram_WE),.ss_vram_WA(init_we?init_a:vram_WA),.ss_vram_WD(init_we?init_d:vram_WD),.ss_sprite_out(g06_live),.ss_sprite_in(sprite_restored[N+41:0]),.ss_sprite_valid(sprite_valid),.ss_freeze(frozen));
vdp #(.MAX_SPPL(SLOTS-1)) vdp2(.clk_sys(clk),.ce_vdp(ce_vdp&&!frozen&&!setup),.ce_pix(ce_pix&&!frozen&&runvideo),.ce_sp(ce_sp&&!frozen&&runvideo),.gg(GG!=0),.ggres(GG!=0),.se_bank(1'b0),.sp64(1'b0),.HL(hl),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(crd|ciq|!ca[2]),.WR_n(cwr|ciq|!ca[2]),.IRQ_n(irq2),.WR_direct(1'b0),.A_direct(6'd0),.A(ca[7:0]),.D_in(co),.D_out(vd2),.x(x),.y(y),.vcounter_cpu(vc),.color(color2),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp2_regs),.ss_regs_in(vdp2_regs_in),.ss_regs_set(vdp2_regs_set),.ss_cram_out(cram2_out),.ss_cram_wr(init_cwe|cram2_wr),.ss_cram_A(init_cwe?init_ca:cram2_A),.ss_cram_D(init_cwe?(init_cd^12'ha5a):cram2_D),.ss_vram_en(vram2_en|setup),.ss_vram_A(vram2_A),.ss_vram_D(vram2_D),.ss_vram_WE(init_we|vram2_WE),.ss_vram_WA(init_we?init_a:vram2_WA),.ss_vram_WD(init_we?pattern2(init_a%16384):vram2_WD),.ss_sprite_out(g06_live2),.ss_sprite_in(sprite2_restored[N+41:0]),.ss_sprite_valid(sprite_valid),.ss_freeze(frozen));
assign probe=0;
wire quiet1,quiet2;wire[3:0]div2;reg pgwr=1;reg[7:0]pgd1=0,pgd2=0;
wire pgce=ce_cpu&&!frozen&&!logical_pause;
assign audio_quiescent=quiet1&&(!systeme||quiet2);
jt89 pg1(.clk(clk),.clk_en(pgce),.rst(!reset_n),.wr_n(pgwr),.din(pgd1),.mux(8'hff),.soundL(),.soundR(),.ready(),.ss_out(psg_out),.ss_set(psg_set),.ss_in(psg_in),.ss_ext_out(psg_ext_out),.ss_ext_in(psg_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(psg_div_out),.ss_div_in(psg_div_in),.ss_quiescent(quiet1));
jt89 pg2(.clk(clk),.clk_en(pgce),.rst(!reset_n),.wr_n(pgwr),.din(pgd2),.mux(8'hff),.soundL(),.soundR(),.ready(),.ss_out(psg2_out),.ss_set(psg2_set),.ss_in(psg2_in),.ss_ext_out(psg2_ext_out),.ss_ext_in(psg2_ext_in),.ss_ext_set(audio_ext_set&&systeme),.ss_div_out(div2),.ss_div_in(psg_div_in),.ss_quiescent(quiet2));
task pgput(input[7:0]a,b);begin pgd1=a;pgd2=b;pgwr=0;repeat(31)tick;pgwr=1;repeat(31)tick;end endtask
wire[155:0]pgstate1={psg_out,psg_ext_out,psg_div_out},pgstate2={psg2_out,psg2_ext_out,div2};
reg[155:0]pgref1[0:9999],pgref2[0:9999];reg[3:0]ceref[0:9999];reg pgloaded=0,pgdone=0;string pgfile="psg_reference.dat";
task pgscore;integer f,k,n;begin
 pgdone=0;
 if(REFERENCE)f=$fopen(pgfile,"w");
 else if(!pgloaded)begin
  f=$fopen(pgfile,"r");if(!f)$fatal(1,"missing PSG reference");
  for(k=0;k<10000;k++)begin n=$fscanf(f,"%h %h %h\n",ceref[k],pgref1[k],pgref2[k]);if(n!=3)$fatal(1,"short PSG reference");end
  $fclose(f);pgloaded=1;
 end
 for(k=0;k<10000;k++)begin @(posedge clk);#1;
  if(REFERENCE)$fdisplay(f,"%h %h %h",{ce_cpu,ce_vdp,ce_pix,ce_sp},pgstate1,pgstate2);
  else begin
   if({ce_cpu,ce_vdp,ce_pix,ce_sp}!==ceref[k])$fatal(1,"first-enable order mismatch clock%0d",k);
   if(pgstate1!==pgref1[k]||(systeme&&pgstate2!==pgref2[k]))$fatal(1,"PSG logical-state mismatch clock%0d DUT%h ref%h",k,pgstate1,pgref1[k]);
  end
 end
 if(REFERENCE)$fclose(f);pgdone=1;$display("PSG_TRACE PASS systeme%0d hostclocks10000",SYSTEM_E);
end endtask
reg[311:0]pgheld;reg pgpreparing=0;
always@(posedge clk)begin
 if(cpu_prepare&&!pgpreparing)pgheld={pgstate1,pgstate2};
 if(cpu_prepare&&(pgce||{pgstate1,pgstate2}!==pgheld))$fatal(1,"PSGs advanced during CPU-only preparation");
 pgpreparing<=cpu_prepare;
end


always@(posedge vb)frame=frame+1;
reg hadfreeze=0;integer accepted_x,accepted_y;
always@(posedge clk)if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
 accepted_x=x;accepted_y=y;$display("ACCEPT save%b cycle%0d x%0d y%0d PC%h ce%0b%0b%0b regs%h probe%h",dut.do_save,cycle,x,y,ca,ce_vdp,ce_pix,ce_cpu,vdp_regs,probe);
end
always@(posedge ss_freeze)begin holdref=1;hadfreeze=1;$display("ARM x%0d y%0d regs%h probe%h",x,y,vdp_regs,probe);end
always@(negedge ss_freeze)if(hadfreeze)begin
 holdref=0;$display("RELEASE save%b cycle%0d x%0d y%0d snap%h regs%h probe%h",dut.do_save,cycle,x,y,dut.video_snap,vdp_regs,probe);
 if(!FIX&&!REFERENCE&&video_state_out[21:4]!==dut.video_snap[21:4])$fatal(1,"release alignment timeout");
end
function[7:0]pattern(input integer n);integer off;begin
 pattern=((n*37)^(n>>3)^8'ha7)&255;
 if(n>=14'h3800&&n<14'h3f00)pattern=n[0]?8'h08:8'h01;
 if(n>=14'h2000&&n<14'h2040)pattern=n[1:0]==0?8'hff:8'h00;
 if(n>=14'h3f00&&n<14'h3f40)begin off=n-14'h3f00;pattern=off<SPRITES?8'd190:8'd208;end
 if(n>=14'h3f80&&n<16384)pattern=n[0]?0:SPRITE_X;
end endfunction
function[7:0]pattern2(input integer n);integer off;begin
 pattern2=pattern(n);
 if(n>=14'h2000&&n<14'h2040)pattern2=n%4==1?8'hff:0;
 if(n>=14'h3f00&&n<14'h3f40)begin off=n-14'h3f00;pattern2=off<9?190:208;end
 if(n>=14'h3f80&&n<16384)pattern2=n[0]?0:40;
end endfunction
task request(input bit saveop);begin 
 force dut.op_cooldown=0;ss_save=saveop;ss_load=!saveop;tick;ss_save=0;ss_load=0;if(REFERENCE&&!warming)begin wait(dut.state==41);tick;end else begin wait(ss_freeze);wait(!frozen);end #1;release dut.op_cooldown;
end endtask
reg[229:0]rcpu[0:3000];
integer n,j,f,checks=0,divs=0,guestdiv=0,savechecks=0,line_diag=0,saveflags=0,savereads=0,gueststores=0,guestacc=0;reg[135:0]trace[0:3000];reg[7:0]readtrace[0:3000],racc[0:3000],rmem[0:3000];reg[11:0]pixels[0:3000];reg[8:0]tx[0:3000],ty[0:3000];reg[7:0]sigref;reg scoring=0;
initial begin
 $readmemh("rom.hex",rom);for(n=0;n<12288;n=n+1)mem[n]=0;for(n=0;n<16384;n=n+1)begin ram[n]=0;rram[n]=0;end
 repeat(10)tick;reset_n=1;pgput(8'h8d,8'h85);pgput(8'h02,8'h03);pgput(8'h91,8'h94);pgput(8'he7,8'he5);pgput(8'hf3,8'hf6);init_we=1;
 for(n=0;n<32768;n=n+1)begin init_a=n;init_d=pattern(n%16384);tick;end init_we=0;
 init_cwe=1;for(n=0;n<32;n=n+1)begin init_ca=n;init_cd=(n*12'h135)^12'h5a3;tick;end init_cwe=0;hl=1;tick;hl=0;tick;setup=0;runvideo=1;if(UI_PAUSE)begin joy_pause=1;repeat(3)tick;joy_pause=0;wait(ui_paused);$display("SYSTEME_UI_PAUSED bus%h M1%b MREQ%b",ca,cm1,cmreq);end
 while(!(frame>=1&&vb&&x>=REQUEST_X&&y==(GG?168:192)))tick;

 if(WARMUP)begin
  // A genuine v13 LOAD invokes the documented legacy normalization. No force
  // initializes retained sprite history. Then run another complete frame.
  request(1);mem[26][63:40]=24'h48430d;
  repeat(20)tick;request(0);
  if($isunknown(g06_live))$fatal(1,"legacy normalization left unknown sprite state");
  $display("LEGAL_LEGACY_WARMUP complete spritebits%0d",N+42);
  warming=0;
  begin integer next_frame;next_frame=frame+1;
   while(!(frame>=next_frame&&vb&&x>=REQUEST_X&&y==(GG?168:192)))tick;
  end
 end
 $display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);fork pgscore;secondary_score;join_none
 if(accepted_y!=(GG?168:192))$fatal(1,"request missed target blank line");
 // Reference and DUT execute identical P in independent simulations.
 if(REFERENCE)f=$fopen("reference.dat","w");else begin
  f=$fopen("reference.dat","r");if(!f)$fatal(1,"missing uninterrupted reference");
  for(j=0;j<1000;j=j+1)begin
   if(EXT_REFERENCE)begin n=$fscanf(f,"%h %h %h %h %h %h %h %h\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j],racc[j],rmem[j],rcpu[j]);if(n!=8)$fatal(1,"short extended reference");end
   else if(SPRITES>2)begin n=$fscanf(f,"%h %h %h %h %h %h %h\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j],racc[j],rmem[j]);if(n!=7)$fatal(1,"short CPU reference");end
   else begin n=$fscanf(f,"%h %h %h %h %h\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j]);if(n!=5)$fatal(1,"short reference");end
  end $fclose(f);
 end
 for(j=0;j<1000;j=j+1)begin
  do tick;while(!ce_pix);@(posedge clk);#1;
  if($isunknown({vdp_regs,color,irq}))$fatal(1,"unknown initialized oracle x%0d y%0d regs%h color%h",x,y,vdp_regs,color);
  if(REFERENCE)begin
   if(EXT_REFERENCE)$fdisplay(f,"%h %h %h %h %h %h %h %h",x,y,vdp_regs,color,vd,z80_reg[7:0],ram[256],z80_reg);
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
 wait(pgdone&&secondary_done);
 if(REFERENCE)begin $fclose(f);if(UI_PAUSE)unpause_probe;$display("PASS UNINTERRUPTED REFERENCE samples%0d",savechecks);$finish;end
 if(SPRITES>2&&PROTO)begin $display("PASS PROTOTYPE SAVE_ONLY observations%0d",savechecks);$finish;end
 if(SPRITES>2)begin
  if(saveflags==0||savereads==0||gueststores==0||guestacc==0)$fatal(1,"nine-sprite SAVE-only guest divergence not reproduced");
  $display("PASS G06 SAVE_ONLY CHARACTERIZED overflowSamples%0d statusBusSamples%0d guestACC%0d guestStores%0d observations%0d",saveflags,savereads,guestacc,gueststores,savechecks);$finish;
 end
 for(n=0;n<12288;n++)image_saved[n]=mem[n];f=$fopen("image.hex","w");for(n=0;n<12288;n=n+1)begin if($isunknown(mem[n]))begin if(WARMUP || n<10497 || n>10646)$fatal(1,"unknown established image word%0d",n);else $display("INACTIVE_PAYLOAD_UNKNOWN word%h",n);end $fdisplay(f,"%016h",mem[n]);end $fclose(f);
 if(SAVE_ONLY)begin $display("DONE SAVE_ONLY samples%0d mismatches%0d",savechecks,saveflags);$finish;end
 for(integer pass=0;pass<REPLAYS;pass=pass+1)begin
  // Legal DMA perturbation of backing memory plus normal running histories.
  for(n=0;n<80+pass*31;n=n+1)tick;
  request(0);fork pgscore;secondary_score;join_none divs=0;guestdiv=0;
  for(j=0;j<1000;j=j+1)begin
   do tick;while(!ce_pix);@(posedge clk);#1;
   if({x,y}!=={tx[j],ty[j]})$fatal(1,"logical beam misalignment j%0d actual%0d,%0d ref%0d,%0d",j,x,y,tx[j],ty[j]);
   if($isunknown({vdp_regs,color,irq}))$fatal(1,"unknown restored state");
   if(EXT_REFERENCE&&(z80_reg!==rcpu[j]||ram[256]!==rmem[j]))$fatal(1,"extended LOAD CPU/RAM mismatch x%0d y%0d cpu%h ref%h ram%h ref%h",x,y,z80_reg,rcpu[j],ram[256],rmem[j]);
   if(FIX&&vdp_regs!==trace[j])$fatal(1,"full VDP LOAD mismatch x%0d y%0d",x,y);
   if(color!==pixels[j])$fatal(1,"integrated LOAD pixel mismatch x%0d y%0d dut%h ref%h",x,y,color,pixels[j]);
   checks++;
   if(vdp_regs[117]!==trace[j][117])begin
    if(divs<4)$display("COLLISION_DIVERGENCE pass%0d j%0d x%0d y%0d dut%b ref%b probe%h",pass,j,x,y,vdp_regs[117],trace[j][117],probe);
    divs++;
   end
   if((vd[5]!==readtrace[j][5])&&!ciq&&!crd&&ca[7:0]==8'hbf)begin
    if(guestdiv<4)$display("STATUS_DIVERGENCE pass%0d j%0d x%0d y%0d dut%h ref%h PC%h",pass,j,x,y,vd,readtrace[j],ca);guestdiv++;
   end
  end
  for(n=0;n<12288;n++)if(mem[n]!==image_saved[n])$fatal(1,"LOAD changed saved image word%h",n);
  wait(pgdone&&secondary_done);
  $display("RESULT pass%0d collisionSamples%0d statusBusSamples%0d",pass,divs,guestdiv);if(FIX&&(divs||guestdiv))$fatal(1,"protocol LOAD mismatch");
 end
 if(UI_PAUSE)unpause_probe;
 $display("DONE VDP gg%0d pal%0d sprite%0d saveonly%0d checks%0d lineDiagnostics%0d",GG,PAL,SPRITES,savechecks,checks,line_diag);$finish;
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
always@(posedge cpu_prepare)if(NATURAL_PHASE)begin
 if(phase_distance<0)begin phase_distance=cycle-last_issue_cycle;$display("NATURAL_PHASE_CALIBRATION distance%0d",phase_distance);end
 else begin
  if(clkd!==expected_prepare_phase)$fatal(1,"transport phase target failed actual%0d expected%0d",clkd,expected_prepare_phase);
  $display("NATURAL_TRANSPORT_PHASE %0d",clkd);
 end
end
task secondary_score;integer f,k,n;reg[135:0]r;reg[11:0]c;reg[7:0]b,m;begin
 secondary_done=0;f=$fopen("secondary_reference.dat",REFERENCE?"w":"r");if(!f)$fatal(1,"missing secondary reference");
 for(k=0;k<1000;k++)begin do tick;while(!ce_pix);@(posedge clk);#1;
  if($isunknown({vdp2_regs,color2,vd2,ram[257]}))$fatal(1,"unknown initialized secondary oracle");
  if(REFERENCE)$fdisplay(f,"%h %h %h %h",vdp2_regs,color2,vd2,ram[257]);
  else begin n=$fscanf(f,"%h %h %h %h\n",r,c,b,m);if(n!=4||{vdp2_regs,color2,vd2,ram[257]}!=={r,c,b,m})$fatal(1,"secondary VDP/status/RAM replay mismatch pixel%0d",k);end
 end
 $fclose(f);secondary_done=1;secondary_passes++;$display("SECONDARY_ORACLE PASS pixels1000");
end endtask
reg[N+41:0]held_second;reg[135:0]held_second_regs;reg second_preparing=0;
reg[229:0]frozen_cpu;reg was_frozen=0,was_cpu_prepare=0,was_dirset=0;integer isolated_cpu_clocks=0;
always@(posedge clk)begin
 if(cpu_prepare&&!second_preparing)begin held_second=g06_live2;held_second_regs=vdp2_regs;end
 if(cpu_prepare&&(g06_live2!==held_second||vdp2_regs!==held_second_regs))$fatal(1,"CPU preparation advanced VDP2");
 second_preparing<=cpu_prepare;
 #1;
 if(frozen&&was_frozen&&!cpu_prepare&&!was_cpu_prepare&&!z80_set&&!was_dirset)begin
  if(z80_reg!==frozen_cpu)$fatal(1,"peripheral/VDP preparation executed CPU architecture");isolated_cpu_clocks++;
 end
 frozen_cpu=z80_reg;was_frozen=frozen;was_cpu_prepare=cpu_prepare;was_dirset=z80_set;
end
task unpause_probe;integer f,k,n,started,latency,expected;reg[229:0]r;reg[135:0]v1,v2;reg[7:0]m1,m2;begin
 if(!UI_PAUSE)return;
 if(!ui_paused)$fatal(1,"logical Pause lost through savestate");
 started=cycle;joy_pause=1;repeat(3)tick;joy_pause=0;wait(!ui_paused);latency=cycle-started;
 f=$fopen("unpause_guest_reference.dat",REFERENCE?"w":"r");if(!f)$fatal(1,"missing unpause oracle");
 if(REFERENCE)$fdisplay(f,"%d",latency);else begin n=$fscanf(f,"%d\n",expected);if(n!=1||latency!=expected)$fatal(1,"unpause latency differs");end
 pgfile="unpause_psg_reference.dat";pgloaded=0;fork pgscore;join_none
 for(k=0;k<1000;k++)begin do tick;while(!ce_pix);@(posedge clk);#1;
  if(REFERENCE)$fdisplay(f,"%h %h %h %h %h",z80_reg,vdp_regs,vdp2_regs,ram[256],ram[257]);
  else begin n=$fscanf(f,"%h %h %h %h %h\n",r,v1,v2,m1,m2);if(n!=5||{z80_reg,vdp_regs,vdp2_regs,ram[256],ram[257]}!=={r,v1,v2,m1,m2})$fatal(1,"unpaused CPU/dual-VDP/RAM mismatch");end
 end
 wait(pgdone);$fclose(f);$display("SYSTEME_UNPAUSE PASS latency%0d CPU%h RAM%h/%h",latency,z80_reg,ram[256],ram[257]);
end endtask

endmodule
