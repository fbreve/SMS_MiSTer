`timescale 1ns/1ps
module identity_tb;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg cart_download=0,ioctl_wr=0;reg[24:0]ioctl_addr=0;reg[7:0]ioctl_dout=0;wire[31:0]crc;
reg [31:0] ss_game_id = 32'h00000000;
reg        cart_download_r = 1'b0;
always @(posedge clk_sys) begin
	cart_download_r <= cart_download;
	if (~cart_download_r & cart_download)
		ss_game_id <= 32'h811C9DC5;
	else if (ioctl_wr & cart_download)
		ss_game_id <= {ss_game_id[30:0], ss_game_id[31]} ^ {24'd0, ioctl_dout} ^ {7'd0, ioctl_addr[0], ioctl_addr[8], ioctl_addr[16]};
end


mapper_detect detector(.clk_sys(clk_sys),.ROMCL(clk_sys),.ROMAD(ioctl_addr),.ROMDT(ioctl_dout),.ROMEN(ioctl_wr),.RESET_n(1'b1),.ss_freeze(1'b0),.bootloader_n(1'b0),.gg(1'b0),.A(16'd0),.WR_n(1'b0),.MREQ_n(1'b0),.mapper_lock(1'b0),.mapper_codies_force(1'b0),.mapper_dahjee_a_force(1'b0),.mapper_linear_force(1'b0),.mapper_zemina_force(1'b0),.mapper_evolution(1'b0),.mapper_4pak(1'b0),.mapper_codies(1'b0),.mapper_set(1'b0),.mapper_in(64'd0),.mapper_history_in(18'd0),.mapper_history_out(),.evolution_ss_in(96'd0),.mapper_manual_force_o(),.sega_mapper_write_seen_o(),.rom_size_pages_o(),.rom_crc32_o(crc),.detect_zemina_static_o(),.detect_codies_static_o(),.detect_castle_o(),.detect_dahjee_a_o(),.detect_linear_o(),.detect_wonderkid_o(),.detect_sega_locked_o(),.mapper_janggun_o(),.mapper_castle_o(),.mapper_nemesis_auto_o(),.mapper_wonderkid_o(),.mapper_linear_o(),.mapper_sega_locked_o(),.mapper_dahjee_a_o(),.mapper_eeprom_o(),.use_zem_o());
reg[7:0]a[0:32767],b[0:32767];reg[31:0]first_crc,first_sig;
task tick;begin @(negedge clk_sys);#1;end endtask
initial begin
 $readmemh("identity_a.hex",a);$readmemh("identity_b.hex",b);
 repeat(3)tick;
 for(integer pass=0;pass<2;pass++)begin
  cart_download=1;tick;ioctl_wr=1;
  for(integer j=0;j<32768;j++)begin ioctl_addr=j;ioctl_dout=pass?b[j]:a[j];tick;end
  ioctl_wr=0;cart_download=0;repeat(3)tick;
  if(pass==0)begin first_crc=crc;first_sig=ss_game_id;end
  else if(crc!==first_crc||ss_game_id!==first_sig)$fatal(1,"identity collision not reproduced");
 end
 if((crc^32'hffffffff)!==32'h703ab279||ss_game_id!==32'h811c9dc5)$fatal(1,"signature model mismatch");
 $display("PASS ACTUAL RTL IDENTITIES COLLIDE crc=%h rolling=%h",crc^32'hffffffff,ss_game_id);$finish;
end
endmodule
