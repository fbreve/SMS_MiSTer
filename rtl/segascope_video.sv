//============================================================================
// SegaScope 3-D video presentation
//
// Captures the selected SegaScope eye and replays it during the opposite-eye
// field. This turns the original alternating-shutter output into a stable 2-D
// left- or right-eye view while leaving non-SegaScope software untouched.
//
// SMS Mode 4 color is natively 2 bits per RGB component. Store those six
// significant bits in an 8-bit framebuffer and expand them back to RGB444 on
// replay, keeping the framebuffer at 512 Kib.
//============================================================================

module segascope_video
(
	input             clk_sys,
	input             reset,
	input             ce_pix,
	input       [1:0] mode,
	input             active,
	input             eye,
	input       [8:0] x,
	input       [8:0] y,
	input      [11:0] color_in,
	output     [11:0] color_out
);

wire selected_eye = (mode == 2'd1);
wire fb_area = ~x[8] & ~y[8];
wire [15:0] fb_addr = {y[7:0], x[7:0]};
wire [7:0] fb_q;
wire fb_we =
	ce_pix && active && (mode != 2'd0) &&
	(eye == selected_eye) && fb_area;

reg fb_valid = 0;
reg eye_d = 0;
reg [1:0] mode_d = 0;

always @(posedge clk_sys) begin
	eye_d <= eye;
	mode_d <= mode;

	if(reset || !active || (mode == 2'd0))
		fb_valid <= 0;
	else if(mode != mode_d)
		fb_valid <= 0;
	else if((eye_d == selected_eye) && (eye != eye_d))
		fb_valid <= 1;
end

// Capture and replay use the same raster address, so a single-port RAM is
// sufficient. This avoids instantiating and then synthesizing away the unused
// second port of the generic dual-port framebuffer.
spram #(.widthad_a(16), .width_a(8)) framebuffer
(
	.clock   (clk_sys),
	.address (fb_addr),
	.wren    (fb_we),
	.data    ({color_in[11:10], color_in[7:6], color_in[3:2], 2'b00}),
	.q       (fb_q)
);

wire replay =
	active && (mode != 2'd0) && fb_valid &&
	(eye != selected_eye) && fb_area;

wire [11:0] fb_color = {fb_q[7:6], fb_q[7:6],
                        fb_q[5:4], fb_q[5:4],
                        fb_q[3:2], fb_q[3:2]};

assign color_out = replay ? fb_color : color_in;

endmodule
