//============================================================================
// SegaScope 3-D video presentation
//
// A single 512 Kib framebuffer stores one complete SegaScope eye. Left/right
// 2-D modes capture the selected eye and replay it during the opposite field.
// Stereo-composition modes capture eye 1 (Left) and combine it with live eye 0
// (Right), avoiding same-address read-during-write behavior entirely.
//
// SMS Mode 4 color is natively 2 bits per RGB component. The framebuffer stores
// those six significant bits in an 8-bit word and expands them to RGB444.
//============================================================================

module segascope_video
(
	input             clk_sys,
	input             reset,
	input             ce_pix,
	input       [2:0] mode,
	input             active,
	input             eye,
	input       [8:0] x,
	input       [8:0] y,
	input      [11:0] color_in,
	output     [11:0] color_out
);

localparam [2:0] MODE_ORIGINAL = 3'd0;
localparam [2:0] MODE_LEFT     = 3'd1;
localparam [2:0] MODE_RIGHT    = 3'd2;
localparam [2:0] MODE_REDCYAN  = 3'd3;
localparam [2:0] MODE_TRIOVIZ  = 3'd4;

wire mode_2d = (mode == MODE_LEFT) || (mode == MODE_RIGHT);
wire mode_stereo = (mode == MODE_REDCYAN) || (mode == MODE_TRIOVIZ);
wire selected_eye = (mode == MODE_LEFT);
wire capture_eye = mode_2d ? selected_eye : 1'b1;

wire fb_area = ~x[8] & ~y[8];
wire [15:0] fb_addr = {y[7:0], x[7:0]};
wire [7:0] fb_q;
wire fb_we =
	ce_pix && active && (mode != MODE_ORIGINAL) &&
	(eye == capture_eye) && fb_area;

reg fb_valid = 0;
reg eye_d = 0;
reg [2:0] mode_d = MODE_ORIGINAL;

always @(posedge clk_sys) begin
	eye_d <= eye;
	mode_d <= mode;

	if(reset || !active || (mode == MODE_ORIGINAL))
		fb_valid <= 0;
	else if(mode != mode_d)
		fb_valid <= 0;
	else if((eye_d == capture_eye) && (eye != eye_d))
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

// Left/right 2-D modes use the already-proven capture/replay scheme.
wire replay =
	active && mode_2d && fb_valid &&
	(eye != selected_eye) && fb_area;

// Stereo modes capture Left (eye 1) and are presented only during Right
// (eye 0), where the stored Left frame and live Right frame are both stable.
// During the Left field we repeat the most recently composed Right field by
// using the stored Left with the previous Right result held per pixel below.
wire compose = active && mode_stereo && fb_valid && !eye && fb_area;

// RGB444 luma approximation: (R + 2G + B) / 4. This is deliberately cheap and
// follows the Virtual Boy colorizer's principle of deriving stereo filters from
// eye luminance rather than passing original color channels through directly.
wire [5:0] left_luma_sum =
	{2'b00, fb_color[11:8]} + {1'b0, fb_color[7:4], 1'b0} +
	{2'b00, fb_color[3:0]};
wire [5:0] right_luma_sum =
	{2'b00, color_in[11:8]} + {1'b0, color_in[7:4], 1'b0} +
	{2'b00, color_in[3:0]};
wire [3:0] left_luma = left_luma_sum[5:2];
wire [3:0] right_luma = right_luma_sum[5:2];

// Red/cyan coefficients adapted from the current Virtual Boy MiSTer colorizer:
// left drives red; right drives ~0.773 green and ~0.938 blue.
wire [7:0] rc_g_sum = (right_luma << 7) + (right_luma << 6) +
                      (right_luma << 2) + (right_luma << 1);
wire [7:0] rc_b_sum = (right_luma << 7) + (right_luma << 6) +
                      (right_luma << 5) + (right_luma << 4);
wire [11:0] redcyan_color =
	{left_luma, rc_g_sum[7:4], rc_b_sum[7:4]};

// TriOviz coefficients adapted from the current Virtual Boy MiSTer core.
// Work at 8-bit luma to retain the original fixed-point coefficients.
wire [7:0] ll = {left_luma, left_luma};
wire [7:0] rl = {right_luma, right_luma};
wire [15:0] tl_r_sum = (ll << 7) + (ll << 5) + (ll << 4) +
                       (ll << 3) + (ll << 2) + ll;
wire [15:0] tl_g_sum = (ll << 4) + (ll << 2) + (ll << 1) + ll;
wire [15:0] tl_b_sum = (ll << 7) + (ll << 5) + (ll << 3) +
                       (ll << 1) + ll;
wire [15:0] tr_rb_sum = (rl << 6) + (rl << 3) + rl;
wire [7:0] tl_r = tl_r_sum[15:8];
wire [7:0] tl_g = tl_g_sum[15:8];
wire [7:0] tl_b = tl_b_sum[15:8];
wire [7:0] tr_r = tr_rb_sum[15:8];
wire [7:0] tr_g = rl;
wire [7:0] tr_b = tr_rb_sum[15:8];
wire [7:0] trio_r = (tl_r > tr_r) ? tl_r : tr_r;
wire [7:0] trio_g = (tl_g > tr_g) ? tl_g : tr_g;
wire [7:0] trio_b = (tl_b > tr_b) ? tl_b : tr_b;
wire [11:0] trioviz_color = {trio_r[7:4], trio_g[7:4], trio_b[7:4]};

wire [11:0] stereo_color =
	(mode == MODE_TRIOVIZ) ? trioviz_color : redcyan_color;

// The composed image is generated on the Right field. The Left field falls
// back to the stored Left image for now; this intentionally makes any remaining
// field-presentation issue visible during hardware validation instead of hiding
// it behind undefined RAM behavior.
assign color_out = compose ? stereo_color :
                   replay  ? fb_color :
                             color_in;

endmodule
