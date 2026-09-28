//============================================================================
// SegaScope 3-D video presentation
//
// Captures SegaScope eye fields into stable display storage. The current
// left/right 2-D modes replay the selected eye during the opposite-eye field.
//
// SMS Mode 4 color is natively 2 bits per RGB component. Store those six
// significant bits in an 8-bit framebuffer and expand them back to RGB444 on
// replay, keeping the framebuffer at 512 Kib.
//
// The capture path is intentionally eye-agnostic: every active SegaScope field
// is written. During a field, the RAM therefore contains the preceding field
// (the opposite eye) at raster locations that have not yet been overwritten.
// This also provides the current/opposite-eye pair needed by future stereo
// combination modes without a second framebuffer.
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

// Capture every SegaScope field. At each raster position fb_q is the pixel
// from the preceding field until the current pixel is written, so it is also
// the opposite-eye pixel for stereo-combination modes.
wire fb_we = ce_pix && active && fb_area;

reg fb_valid = 0;
reg eye_d = 0;

always @(posedge clk_sys) begin
	eye_d <= eye;

	if(reset || !active)
		fb_valid <= 0;
	else if(eye != eye_d)
		fb_valid <= 1;
end

spram #(.widthad_a(16), .width_a(8)) framebuffer
(
	.clock   (clk_sys),
	.address (fb_addr),
	.wren    (fb_we),
	.data    ({color_in[11:10], color_in[7:6], color_in[3:2], 2'b00}),
	.q       (fb_q)
);

wire [11:0] fb_color = {fb_q[7:6], fb_q[7:6],
                        fb_q[5:4], fb_q[5:4],
                        fb_q[3:2], fb_q[3:2]};

// Left/right 2-D presentation:
// - selected field: pass the live pixel;
// - opposite field: replay the preceding selected field.
//
// Because every field is now captured, fb_q during the opposite field still
// contains the selected-eye pixel at each address until that address is
// overwritten later in the same raster.
wire replay =
	active && (mode != 2'd0) && fb_valid &&
	(eye != selected_eye) && fb_area;

assign color_out = replay ? fb_color : color_in;

endmodule
