`timescale 1ns/1ps
module lifecycle_tb;
wire downloading;
reg old_downloading = 0;
reg bk_ena = 0;
reg  bk_loading = 0;
reg  bk_state   = 0;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg RESET=0,eject_rom=0,cart_download=0,eeprom_active=0,OSD_STATUS=0;
reg ss_freeze=0,eeprom_ss_set=0,eeprom_full=0,ss_sc_ram_restored=0,ss_busy=0;
reg[127:0]status=0;wire reset_active;assign reset_active=RESET|status[0]|cart_download|bk_loading|eject_rom;
reg img_mounted=0,img_readonly=0;reg[63:0]img_size=0;
reg[31:0]sd_lba=0;reg sd_ack=0,sd_rd=0,sd_wr=0;
reg[8:0]sd_buff_addr=0;reg sd_buff_wr=0;reg[7:0]sd_buff_dout=0;wire[7:0]sd_buff_din;
reg[14:0]nvram_a=0;reg[7:0]nvram_d=0;reg nvram_we=0;wire[7:0]nvram_q;
reg ss_cpu_prepare=0,ss_nvram_refill=0,ss_nvram_WE=0;reg[14:0]ss_nvram_A=0,ss_nvram_WA=0;reg[7:0]ss_nvram_WD=0;
reg ioctl_wr=0;reg[24:0]ioctl_addr=0;reg[7:0]ioctl_dout=0;
reg [31:0] ss_game_id = 32'h00000000;
reg        cart_download_r = 1'b0;
always @(posedge clk_sys) begin
	cart_download_r <= cart_download;
	if (~cart_download_r & cart_download)
		ss_game_id <= 32'h811C9DC5;
	else if (ioctl_wr & cart_download)
		ss_game_id <= {ss_game_id[30:0], ss_game_id[31]} ^ {24'd0, ioctl_dout} ^ {7'd0, ioctl_addr[0], ioctl_addr[8], ioctl_addr[16]};
end

wire bk_save_write = nvram_we & ~ss_freeze;
reg bk_pending;

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







dpram #(.widthad_a(15), .init_file("../../rtl/nvram_ff.mif")) nvram_inst
(
	.clock_a     (clk_sys),
	.address_a   ((ss_freeze && !ss_cpu_prepare) ? (ss_nvram_WE ? ss_nvram_WA : (ss_nvram_refill ? nvram_a : ss_nvram_A)) : nvram_a),
	.wren_a      (ss_freeze ? ss_nvram_WE : nvram_we),
	.data_a      (ss_freeze ? ss_nvram_WD : nvram_d),
	.q_a         (nvram_q),
	.clock_b     (clk_sys),
	.address_b   ({sd_lba[5:0],sd_buff_addr[8:0]}),
	.wren_b      (sd_buff_wr & sd_ack),
	.data_b      (sd_buff_dout),
	.q_b         (sd_buff_din)
);

always @(posedge clk_sys) begin
	old_downloading <= downloading;
	if (eject_rom) bk_ena <= 0;
	if(~old_downloading & downloading) bk_ena <= 0;

	// Save file always mounted in the end of downloading state.
	if(downloading && img_mounted && !img_readonly) bk_ena <= 1;

	// After download completes: enable bk for EEPROM games whenever active
	if(!downloading && eeprom_active) bk_ena <= 1;
end

wire bk_load    = status[6];
wire bk_save    = status[7] | (bk_pending & OSD_STATUS && status[25]);


reg  bk_load_wait = 0, bk_save_wait = 0;
wire bk_queued_load = bk_load_wait & ~reset_active;
wire bk_queued_save = bk_save_wait & ~reset_active;

reg osd_btn = 0;
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

assign downloading=cart_download;
task tick;begin @(negedge clk_sys);#1;end endtask
task getbyte(input[14:0]addr,input[7:0]value);begin nvram_a=addr;repeat(3)tick;if(nvram_q!==value)$fatal(1,"lifecycle RAM %h got%h expected%h",addr,nvram_q,value);end endtask
task guestbyte(input[14:0]addr,input[7:0]value);begin nvram_a=addr;nvram_d=value;nvram_we=1;tick;nvram_we=0;tick;end endtask
task download(input bit changed,input bit mount,input bit nonempty);begin
 cart_download=1;tick;ioctl_wr=1;
 for(integer j=0;j<64;j++)begin ioctl_addr=j;ioctl_dout=(changed&&j==12)?8'h5a:j;tick;end
 ioctl_wr=0;img_mounted=mount;img_size=nonempty?32768:0;repeat(2)tick;img_mounted=0;cart_download=0;repeat(3)tick;
end endtask
task sector_ack;begin sd_ack=1;repeat(2)tick;sd_ack=0;repeat(3)tick;end endtask
task persistent_load(input[7:0]value);begin
 for(integer sector=0;sector<64;sector++)begin
  wait(sd_rd);sd_ack=1;tick;
  for(integer b=0;b<512;b++)begin sd_buff_addr=b;sd_buff_dout=value;sd_buff_wr=1;tick;end
  sd_buff_wr=0;sd_ack=0;repeat(3)tick;
 end
 if(bk_state)$fatal(1,"persistence did not finish");
end endtask
reg[31:0]id_a;integer count;
initial begin
 repeat(4)tick;getbyte(0,8'hff);getbyte(32767,8'hff);
 guestbyte(0,8'h31);guestbyte(16384,8'h72);
 RESET=1;repeat(3)tick;RESET=0;status[0]=1;repeat(3)tick;status[0]=0;
 getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS resets retain both banks");
 download(0,0,0);id_a=ss_game_id;getbyte(0,8'h31);getbyte(16384,8'h72);
 download(0,0,0);if(ss_game_id!==id_a)$fatal(1,"same image id");getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS same ROM reload retained before access");
 download(1,0,0);if(ss_game_id===id_a)$fatal(1,"different image id");getbyte(0,8'h31);getbyte(16384,8'h72);if(bk_ena)$fatal(1,"unmounted bk_ena");$display("PASS different ROM stale SRAM retained before access");
 eject_rom=1;tick;eject_rom=0;getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS eject retains both banks");
 download(1,1,0);if(!bk_ena||bk_state)$fatal(1,"empty mounted save semantics");getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS empty mounted save retains stale SRAM");
 img_readonly=1;download(1,1,1);if(bk_ena||bk_state)$fatal(1,"readonly mounted save semantics");img_readonly=0;getbyte(0,8'h31);getbyte(16384,8'h72);$display("PASS readonly mount does not establish replacement");
 download(1,1,1);if(!bk_state||!bk_loading)$fatal(1,"auto persistent load missing");persistent_load(8'h65);getbyte(0,8'h65);getbyte(32767,8'h65);$display("PASS persistent load full32768");
 // SAVE/LOAD arbitration: queue while SS busy; LOAD intentionally requested by
 // host is allowed to supersede savestate bytes only after SS completes.
 ss_busy=1;status[6]=1;repeat(3)tick;status[6]=0;repeat(2)tick;
 if(bk_state||!bk_load_wait)$fatal(1,"queued persistent load arbitration");
 ss_freeze=1;ss_nvram_WE=1;ss_nvram_WA=0;ss_nvram_WD=8'h99;tick;ss_nvram_WE=0;ss_freeze=0;getbyte(0,8'h99);
 ss_busy=0;repeat(3)tick;persistent_load(8'h44);getbyte(0,8'h44);$display("PASS explicitly queued persistent LOAD overwrites after SS");
 status[7]=1;repeat(3)tick;status[7]=0;count=0;
 while(bk_state)begin if(!sd_wr)$fatal(1,"expected persistent write");sector_ack;count++;end
 if(count!=64)$fatal(1,"persistent sector count %0d",count);getbyte(0,8'h44);getbyte(32767,8'h44);$display("PASS persistent write64sectors RAM unchanged");
 $display("PASS LIFECYCLE COMPLETE");$finish;
end
initial begin #20000000;$fatal(1,"lifecycle watchdog");end
endmodule
