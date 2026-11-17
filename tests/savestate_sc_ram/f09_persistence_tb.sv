`timescale 1ns/1ps
module persistence_tb;
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
wire storage_busy;
wire ss_busy;
reg eeprom_present = '0;
reg [127:0] eeprom_ext_out = '0;
wire [127:0] eeprom_ext_in;
wire eeprom_full;
wire nvram_refill;
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
savestates dut(.clk(clk),.reset_n(reset_n),.ss_save(ss_save),.ss_load(ss_load),.ss_slot(ss_slot),.ss_bios_mode(ss_bios_mode),.ss_game_id(ss_game_id),.ss_freeze(ss_freeze),.vblank(vblank),.x(x),.z80_reg(z80_reg),.z80_dir(z80_dir),.z80_set(z80_set),.z80_m1_n(z80_m1_n),.z80_mreq_n(z80_mreq_n),.z80_iset(z80_iset),.cpu_ce(cpu_ce),.vdp_ce(vdp_ce),.pix_ce(pix_ce),.sp_ce(sp_ce),.vdp_regs(vdp_regs),.vdp_regs_in(vdp_regs_in),.vdp_regs_set(vdp_regs_set),.cram_out(cram_out),.cram_A(cram_A),.cram_D(cram_D),.cram_wr(cram_wr),.vram_en(vram_en),.vram_A(vram_A),.vram_D(vram_D),.vram_WE(vram_WE),.vram_WA(vram_WA),.vram_WD(vram_WD),.psg_out(psg_out),.psg_in(psg_in),.psg_set(psg_set),.psg_ext_out(psg_ext_out),.psg2_ext_out(psg2_ext_out),.psg_ext_in(psg_ext_in),.psg2_ext_in(psg2_ext_in),.psg_div_out(psg_div_out),.psg_div_in(psg_div_in),.audio_control_out(audio_control_out),.audio_control_in(audio_control_in),.audio_quiescent(audio_quiescent),.audio_phase_out(audio_phase_out),.audio_phase_in(audio_phase_in),.audio_ext_set(audio_ext_set),.audio_phase_set(audio_phase_set),.mapper_out(mapper_out),.mapper_in(mapper_in),.mapper_set(mapper_set),.evolution_out(evolution_out),.evolution_in(evolution_in),.evolution_set(evolution_set),.storage_busy(storage_busy),.ss_busy(ss_busy),.eeprom_present(eeprom_present),.eeprom_ext_out(eeprom_ext_out),.eeprom_ext_in(eeprom_ext_in),.eeprom_full(eeprom_full),.nvram_refill(nvram_refill),.tap_out(tap_out),.tap_in(tap_in),.tap_set(tap_set),.tap_valid(tap_valid),.sc_ram_size(sc_ram_size),.sc_ram_restored(sc_ram_restored),.eeprom_out(eeprom_out),.eeprom_in(eeprom_in),.eeprom_set(eeprom_set),.wram_A(wram_A),.wram_D(wram_D),.wram_WE(wram_WE),.wram_WA(wram_WA),.wram_WD(wram_WD),.nvram_A(nvram_A),.nvram_D(nvram_D),.nvram_WE(nvram_WE),.nvram_WA(nvram_WA),.nvram_WD(nvram_WD),.systeme(systeme),.vdp2_regs(vdp2_regs),.vdp2_regs_in(vdp2_regs_in),.vdp2_regs_set(vdp2_regs_set),.cram2_out(cram2_out),.cram2_A(cram2_A),.cram2_D(cram2_D),.cram2_wr(cram2_wr),.vram2_en(vram2_en),.vram2_A(vram2_A),.vram2_D(vram2_D),.vram2_WE(vram2_WE),.vram2_WA(vram2_WA),.vram2_WD(vram2_WD),.psg2_out(psg2_out),.psg2_in(psg2_in),.psg2_set(psg2_set),.md_out(md_out),.md_in(md_in),.md_set(md_set),.md_valid(md_valid),.gg_out(gg_out),.gg_in(gg_in),.gg_set(gg_set),.io_out(io_out),.io_in(io_in),.io_set(io_set),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.DDRAM_ADDR(DDRAM_ADDR),.DDRAM_DIN(DDRAM_DIN),.DDRAM_BE(DDRAM_BE),.DDRAM_WE(DDRAM_WE),.DDRAM_DOUT(DDRAM_DOUT),.DDRAM_DOUT_READY(DDRAM_DOUT_READY),.DDRAM_RD(DDRAM_RD),.DDRAM_BURSTCNT(DDRAM_BURSTCNT),.DDRAM_BUSY(DDRAM_BUSY));
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
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
task tick;begin @(negedge clk);#1;end endtask
task operation(input bit saving);begin
 force dut.op_cooldown=0; // UI cooldown only; all transfer/restore FSM stages run normally
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
wire clk_sys=clk;reg[127:0]status=0;reg RESET=0,OSD_STATUS=0;
reg old_downloading=0,downloading=0,bk_ena=1,bk_pending=0,reset_active=0;
reg bk_loading=0,bk_state=0,bk_load_wait=0,bk_save_wait=0,osd_btn=0;
reg[63:0]img_size=0;reg[31:0]sd_lba=0;reg sd_rd=0,sd_wr=0,sd_ack=0,nvram_we=0;
wire eeprom_active=eeprom_present;wire eeprom_ss_set=eeprom_set;
wire ss_sc_ram_restored=sc_ram_restored;
wire bk_save_write=nvram_we & ~ss_freeze;
wire bk_load=status[6];wire bk_save=status[7]|(bk_pending&OSD_STATUS&&status[25]);
wire bk_queued_load=bk_load_wait&~reset_active,bk_queued_save=bk_save_wait&~reset_active;
assign storage_busy=bk_state|sd_ack|sd_rd|sd_wr;
always @(posedge clk)old_downloading<=downloading;
always @(posedge clk_sys) begin
	if (~old_downloading & downloading)
		bk_pending <= 1'b0;
	else if (eeprom_active && ss_freeze && eeprom_ss_set && eeprom_full)
		bk_pending <= 1'b1;
	else if (bk_ena && ss_sc_ram_restored)
		bk_pending <= 1'b1;
	else if (bk_ena && ~OSD_STATUS && bk_save_write)
		bk_pending <= 1'b1;
	else if (bk_state)
		bk_pending <= 1'b0;
end
always @(posedge clk_sys) begin

	reg old_load = 0, old_save = 0, old_ack;
	integer timeout = 0;
	reg     last_rst = 0;

	if (RESET) last_rst = 0;
	if (status[0]) last_rst = 1;

	if (last_rst & ~status[0]) begin
		osd_btn <= 0;
		if(timeout < 24000000) begin
			timeout <= timeout + 1;
			osd_btn <= 1;
		end
	end

	old_load <= bk_load & bk_ena;
	old_save <= bk_save & bk_ena;
	if (reset_active) begin
		bk_load_wait <= 0;
		bk_save_wait <= 0;
	end else if (ss_busy) begin
		if (~old_load & bk_load & bk_ena) bk_load_wait <= 1;
		if (~old_save & bk_save & bk_ena) bk_save_wait <= 1;
	end
	old_ack  <= sd_ack;

	if(~old_ack & sd_ack) {sd_rd, sd_wr} <= 0;

	if(!bk_state && !ss_busy) begin
		if(bk_queued_load | bk_queued_save | (~old_load & bk_load) | (~old_save & bk_save)) begin
			bk_state <= 1;
			bk_loading <= bk_queued_load | bk_load;
			sd_lba <= 0;
			sd_rd <=  bk_queued_load | bk_load;
			sd_wr <= ~(bk_queued_load | bk_load);
			bk_load_wait <= 0;
			bk_save_wait <= 0;
		end
		if(old_downloading & ~downloading & |img_size & bk_ena) begin
			bk_state <= 1;
			bk_loading <= 1;
			sd_lba <= 0;
			sd_rd <= 1;
			sd_wr <= 0;
		end 
	end else if (bk_state) begin
		if(old_ack & ~sd_ack) begin
			if(&sd_lba[5:0]) begin
				bk_loading <= 0;
				bk_state <= 0;
			end else begin
				sd_lba <= sd_lba + 1'd1;
				sd_rd  <=  bk_loading;
				sd_wr  <= ~bk_loading;
			end
		end
	end
end


integer transfers=0,requests=0;reg prevrequest=0;
always @(posedge ss_freeze)$display("TRACE freeze time%0t busy%0d",$time,ss_busy);
always @(posedge bk_save_wait)$display("TRACE queued save time%0t",$time);
always @(posedge clk)begin
 if(ss_freeze&&storage_busy)$fatal(1,"SD transfer overlaps savestate memory ownership");
 if((sd_rd||sd_wr)&&!prevrequest)requests<=requests+1;
 prevrequest<=sd_rd||sd_wr;
end
task service;begin
 wait(bk_state);for(integer sector=0;sector<64;sector=sector+1)begin
 wait(sd_rd||sd_wr);repeat(2)tick;sd_ack=1;repeat(3)tick;sd_ack=0;repeat(3)tick;
 end
 if(bk_state)$fatal(1,"backup did not finish");transfers=transfers+1;
end endtask
initial begin
 reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;
 ss_game_id=32'h12345678;video_state_out=22'h12345;eeprom_present=1;
 // Existing SD write must finish before a queued savestate freezes RAM.
 status[7]=1;tick;status[7]=0;wait(bk_state);
 fork operation(1);service;join
 $display("PASS persistence existing SD before save");
 if(requests!=64)$fatal(1,"initial backup sector count");
 // A one-clock manual save pulse during savestate is retained until release.
 fork
 operation(1);
 begin wait(ss_freeze);status[7]=1;tick;tick;status[7]=0;$display("TRACE manual save queue%0d busy%0d",bk_save_wait,ss_busy);end
 join
 $display("TRACE second save ended bk%0d queue%0d",bk_state,bk_save_wait);
 service;if(bk_save_wait)$fatal(1,"queued save not consumed");
 $display("PASS persistence queued save");
 // Likewise for a read/backup-load request.
 fork
 operation(1);
 begin wait(ss_freeze);status[6]=1;tick;tick;status[6]=0;end
 join
 wait(bk_loading);service;if(bk_load_wait)$fatal(1,"queued load not consumed");
 $display("PASS persistence queued load");
 // A full EEPROM restore marks the coherent image dirty; automatic backup
 // begins only after the complete savestate operation, never during DMA.
 OSD_STATUS=1;status[25]=1;operation(0);
 if(!eeprom_full)$fatal(1,"full restore setup missing");service;
 $display("PASS persistence restore autosave");
 // Ordinary guest dirty tracking and subsequent autosave remain functional.
 OSD_STATUS=0;nvram_we=1;tick;nvram_we=0;tick;
 if(!bk_pending)$fatal(1,"normal write not marked dirty");OSD_STATUS=1;service;
 if(transfers!=5||requests!=320)$fatal(1,"persistence operation count %0d/%0d",transfers,requests);
 OSD_STATUS=0;eeprom_present=0;sc_ram_size=1;
 operation(1);OSD_STATUS=1;operation(0);service;
 if(transfers!=6||requests!=384)$fatal(1,"SC restored dirty persistence failed");
 $display("PASS SC full restore marks dirty and persists only after SS release: 64 sectors");
 OSD_STATUS=0;status[25]=0;
 fork
 operation(1);
 begin wait(ss_freeze);status[7]=1;repeat(2)tick;status[7]=0;tick;reset_active=1;tick;reset_active=0;end
 join
 if(bk_state||bk_load_wait||bk_save_wait)$fatal(1,"reset did not cancel queued request");
 $display("PASS persistence: existing SD/save exclusion, queued one-clock save/load, restored dirty autosave, normal guest write; 320 sectors");$finish;
end
initial begin #100000000;$fatal(1,"watchdog state%0d bk%0d busy%0d freeze%0d req%0d transfers%0d sd%0d%0d queue%0d%0d",dut.state,bk_state,ss_busy,ss_freeze,requests,transfers,sd_rd,sd_wr,bk_load_wait,bk_save_wait);end
endmodule
