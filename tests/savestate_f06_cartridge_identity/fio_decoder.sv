// Production FIO block extracted verbatim; unrelated video/PS2 not instantiated.
module fio_decoder(input clk_sys,inout[45:0]HPS_BUS,output reg ioctl_download=0,
 output reg[15:0]ioctl_index,output reg ioctl_wr,output reg[26:0]ioctl_addr,
 output reg[7:0]ioctl_dout,output reg[31:0]ioctl_file_ext);
localparam WIDE=0,DW=7;
wire fp_enable=HPS_BUS[35],io_strobe=HPS_BUS[33];wire[15:0]io_din=HPS_BUS[31:16];
reg ioctl_upload=0,ioctl_rd;wire[7:0]ioctl_din=0;
localparam FIO_FILE_TX      = 8'h53;
localparam FIO_FILE_TX_DAT  = 8'h54;
localparam FIO_FILE_INDEX   = 8'h55;
localparam FIO_FILE_INFO    = 8'h56;

reg [15:0] fp_dout;
always@(posedge clk_sys) begin : fio_block
	reg [15:0] cmd;
	reg  [2:0] cnt;
	reg        has_cmd;
	reg        wr;
	reg  [1:0] req_io;
	reg        skip_add;

	ioctl_rd <= 0;
	ioctl_wr <= wr;
	wr <= 0;

	if(~fp_enable) begin
		if(has_cmd && (cmd == FIO_FILE_TX)) begin
			{ioctl_upload, ioctl_download} <= req_io;
			{ioctl_rd, skip_add} <= req_io;
		end
		has_cmd <= 0;
	end
	else begin
		if(io_strobe) begin

			if(!has_cmd) begin
				cmd <= io_din;
				has_cmd <= 1;
				cnt <= 0;
				req_io <= 0;
			end else begin

				case(cmd)
					FIO_FILE_INFO:
						if(~cnt[1]) begin
							case(cnt)
								0: ioctl_file_ext[31:16] <= io_din;
								1: ioctl_file_ext[15:00] <= io_din;
							endcase
							cnt <= cnt + 1'd1;
						end

					FIO_FILE_INDEX:
						begin
							ioctl_index <= io_din[15:0];
						end

					FIO_FILE_TX:
						begin
							cnt <= cnt + 1'd1;
							case(cnt)
								0:	if(io_din[7:0]) begin
										ioctl_addr <= 0;
										req_io <= (io_din[7:0] == 8'hAA) ? 2'b10 : 2'b01;
									end
									else begin
										if(ioctl_download) ioctl_addr <= ioctl_addr + (WIDE ? 2'd2 : 2'd1);
										ioctl_download <= 0;
										ioctl_upload <= 0;
									end
								1: ioctl_addr[15:0]  <= io_din;
								2: ioctl_addr[26:16] <= io_din[10:0];
							endcase
						end

					FIO_FILE_TX_DAT:
						begin
							if(!skip_add) ioctl_addr <= ioctl_addr + (WIDE ? 2'd2 : 2'd1);
							skip_add <= 0;
							
							if(ioctl_download) begin
								ioctl_dout <= io_din[DW:0];
								wr <= 1;
							end
							else begin
								fp_dout <= ioctl_din;
								ioctl_rd <= 1;
							end
						end
				endcase
			end
		end
	end
end


endmodule
