`include "header.svh"


always #5 clk=~clk;

reg warming=WARMUP!=0;wire frozen=ss_freeze&&(!REFERENCE||warming);
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
always@(negedge clk)if(STALL)DDRAM_BUSY<=((cycle%97)<(STALL==1?83:51));
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
vdp #(.MAX_SPPL(SLOTS-1)) vdp1(.audit(audit),.clk_sys(clk),.ce_vdp(ce_vdp&&!frozen&&!setup),.ce_pix(ce_pix&&!frozen&&runvideo),.ce_sp(ce_sp&&!frozen&&runvideo),.gg(GG!=0),.ggres(GG!=0),.se_bank(1'b0),.sp64(1'b0),.HL(hl),.mask_line_irq(1'b0),.capture_cpu_edges(CLONE!=0),.legacy_ext_nt(1'b0),.RD_n(crd|ciq),.WR_n(cwr|ciq),.IRQ_n(irq),.WR_direct(1'b0),.A_direct(6'd0),.A(ca[7:0]),.D_in(co),.D_out(vd),.x(x),.y(y),.vcounter_cpu(vc),.color(color),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(m1),.smode_M2(m2),.smode_M3(m3),.smode_M4(m4),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdp_regs),.ss_regs_in(vdp_regs_in),.ss_regs_set(vdp_regs_set),.ss_cram_out(cram_out),.ss_cram_wr(init_cwe|cram_wr),.ss_cram_A(init_cwe?init_ca:cram_A),.ss_cram_D(init_cwe?init_cd:cram_D),.ss_vram_en(vram_en|setup),.ss_vram_A(vram_A),.ss_vram_D(vram_D),.ss_vram_WE(init_we|vram_WE),.ss_vram_WA(init_we?init_a:vram_WA),.ss_vram_WD(init_we?init_d:vram_WD),.ss_sprite_out(g06_live),.ss_sprite_in(sprite_restored[N+41:0]),.ss_sprite_valid(sprite_valid),.ss_freeze(frozen));
assign probe=0;assign psg_out=0;assign psg2_out=0;assign psg_ext_out=0;assign psg2_ext_out=0;assign psg_div_out=0;assign audio_quiescent=1;
assign vdp2_regs=0;
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
 if(n>=14'h3f00&&n<14'h3f40)begin off=n-14'h3f00;pattern=off<SPRITES?8'd167:8'd208;end
 if(n>=14'h3f80&&n<16384)pattern=n[0]?0:SPRITE_X;
end endfunction
task request(input bit saveop);begin if(PAUSE_CAPTURE)begin while(cm1||cmreq)tick;logical_pause=1;end
 force dut.op_cooldown=0;ss_save=saveop;ss_load=!saveop;tick;ss_save=0;ss_load=0;if(REFERENCE&&!warming)begin wait(dut.state==41);tick;end else begin wait(ss_freeze);wait(!frozen);end #1;release dut.op_cooldown;if(PAUSE_CAPTURE)logical_pause=0;
end endtask
reg[229:0]rcpu[0:SAMPLES-1];
integer n,j,f,checks=0,divs=0,guestdiv=0,savechecks=0,line_diag=0,saveflags=0,savereads=0,gueststores=0,guestacc=0;reg[135:0]trace[0:SAMPLES-1];reg[7:0]readtrace[0:SAMPLES-1],racc[0:SAMPLES-1],rmem[0:SAMPLES-1];reg[11:0]pixels[0:SAMPLES-1];reg[8:0]tx[0:SAMPLES-1],ty[0:SAMPLES-1];reg[7:0]sigref;reg scoring=0;reg[63:0] audit_trace[0:SAMPLES-1];reg irq_trace[0:SAMPLES-1];integer visible=0;
integer boundaries=0,pending_clear=0,pending_incr=0,pending_write=0,irq_bad=0,status_reads=0,vectors=0;reg[29:0]phase_mask=0;reg expected_irq;
initial begin
 $readmemh("rom.hex",rom);for(n=0;n<12288;n=n+1)mem[n]=0;for(n=0;n<8192;n=n+1)begin ram[n]=0;rram[n]=0;end
 repeat(10)tick;reset_n=1;init_we=1;
 for(n=0;n<32768;n=n+1)begin init_a=n;init_d=pattern(n%16384);tick;end init_we=0;
 init_cwe=1;for(n=0;n<32;n=n+1)begin init_ca=n;init_cd=(n*12'h135)^12'h5a3;tick;end init_cwe=0;hl=1;tick;hl=0;tick;setup=0;runvideo=1;

 while(!vb)tick;
 repeat(200000)tick;
 if(boundaries<100||status_reads<10)$fatal(1,"insufficient natural scan");
 $display("PASS BOUNDARY_SCAN eligible%0d clear%0d incr%0d write%0d irqMismatch%0d statusReads%0d irqVectors%0d handler%0d phases%h",boundaries,pending_clear,pending_incr,pending_write,irq_bad,status_reads,vectors,ram[257],phase_mask);
 $finish;
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
always@(posedge cpu_prepare)if(NATURAL_PHASE)begin
 if(phase_distance<0)begin phase_distance=cycle-last_issue_cycle;$display("NATURAL_PHASE_CALIBRATION distance%0d",phase_distance);end
 else begin
  if(clkd!==expected_prepare_phase)$fatal(1,"transport phase target failed actual%0d expected%0d",clkd,expected_prepare_phase);
  $display("NATURAL_TRANSPORT_PHASE %0d",clkd);
 end
end

always@(posedge clk)if(!setup)begin if(ce_vdp&&!ciq&&!crd&&ca[0])status_reads++;if(cpu_tick&&!cm1&&ca==16'h0038)vectors++;end
always@(posedge clk)if(!setup&&!frozen&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
 expected_irq=!((vdp_regs[115]&&vdp_regs[8]||vdp_regs[116]&&vdp_regs[3])&&vdp_regs[114:112]==0);if(irq!==expected_irq)irq_bad++;phase_mask[clkd]=1;
 if(vdp_regs[103]||audit[2]||audit[3])$display("PENDING_ELIGIBLE cycle%0d xy%0d,%0d audit%h regs%h",cycle,x,y,audit,vdp_regs);
 boundaries++;if(vdp_regs[103])pending_clear++;if(audit[2])pending_incr++;if(audit[3])pending_write++;
 if(dut.state==37)$display("BOUNDARY T cycle%0d xy%0d,%0d MC%0d TS%0d phase%0d ce_vdp%b audit%h reset%b",cycle,x,y,mc_probe,ts_probe,clkd,ce_vdp,audit,vdp_regs[103]);
end
reg[6:0]old_state=0;
always@(posedge clk)begin
 if(dut.state!=old_state&&(dut.state>=45||cpu_prepare||phase_set))$display("RESTART cycle%0d state%0d prep%b phaseSet%b ce%b%b%b%b",cycle,dut.state,cpu_prepare,phase_set,ce_cpu,ce_vdp,ce_pix,ce_sp);
 old_state<=dut.state;
end
final $display("AUDIT_COUNTS eligible%0d pendingClear%0d pendingIncr%0d pendingWrite%0d visiblePixels%0d",boundaries,pending_clear,pending_incr,pending_write,visible);
endmodule
