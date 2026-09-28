//============================================================================
// SegaScope 3-D video presentation
//
// The 512 Kib presentation store is split into two 4-bit banks. In Left/Right
// 2-D modes the banks together hold the selected eye's native RGB222 color.
// In stereo-composition modes bank A stores Left-eye luma and bank B stores
// Right-eye luma. This keeps both eyes simultaneously without increasing the
// framebuffer bit count and avoids same-address read-during-write dependencies.
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
wire fb_area = ~x[8] & ~y[8];
wire [15:0] fb_addr = {y[7:0], x[7:0]};

// RGB444 luma approximation: (R + 2G + B) / 4.
wire [5:0] live_luma_sum =
	{2'b00, color_in[11:8]} + {1'b0, color_in[7:4], 1'b0} +
	{2'b00, color_in[3:0]};
wire [3:0] live_luma = live_luma_sum[5:2];

wire [3:0] fb_a_q;
wire [3:0] fb_b_q;

// In 2-D modes both banks capture the selected eye and together store RGB222:
// A={R[1:0],G[1:0]}, B={B[1:0],00}.
// In stereo modes A belongs exclusively to Left (eye 1), B to Right (eye 0).
wire fb_a_we = ce_pix && active && fb_area &&
	(mode_2d ? (eye == selected_eye) : (mode_stereo && eye));
wire fb_b_we = ce_pix && active && fb_area &&
	(mode_2d ? (eye == selected_eye) : (mode_stereo && !eye));

wire [3:0] fb_a_data =
	mode_2d ? {color_in[11:10], color_in[7:6]} : live_luma;
wire [3:0] fb_b_data =
	mode_2d ? {color_in[3:2], 2'b00} : live_luma;

spram #(.widthad_a(16), .width_a(4)) framebuffer_a
(
	.clock   (clk_sys),
	.address (fb_addr),
	.wren    (fb_a_we),
	.data    (fb_a_data),
	.q       (fb_a_q)
);

spram #(.widthad_a(16), .width_a(4)) framebuffer_b
(
	.clock   (clk_sys),
	.address (fb_addr),
	.wren    (fb_b_we),
	.data    (fb_b_data),
	.q       (fb_b_q)
);

reg left_valid = 0;
reg right_valid = 0;
reg eye_d = 0;
reg [2:0] mode_d = MODE_ORIGINAL;

always @(posedge clk_sys) begin
	eye_d <= eye;
	mode_d <= mode;

	if(reset || !active || (mode == MODE_ORIGINAL) || (mode != mode_d)) begin
		left_valid <= 0;
		right_valid <= 0;
	end
	else if(eye != eye_d) begin
		if(mode_2d) begin
			if(eye_d == selected_eye) begin
				left_valid <= 1;
				right_valid <= 1;
			end
		end
		else if(mode_stereo) begin
			if(eye_d)
				left_valid <= 1;
			else
				right_valid <= 1;
		end
	end
end

wire fb_valid_2d = left_valid && right_valid;
wire stereo_valid = left_valid && right_valid;

wire [11:0] fb_color = {
	fb_a_q[3:2], fb_a_q[3:2],
	fb_a_q[1:0], fb_a_q[1:0],
	fb_b_q[3:2], fb_b_q[3:2]
};

wire replay =
	active && mode_2d && fb_valid_2d &&
	(eye != selected_eye) && fb_area;

// For the eye currently being generated use live luma; for the opposite eye
// use its dedicated RAM. The RAM being read is therefore never the RAM being
// written on that field.
wire [3:0] left_luma  = eye ? live_luma : fb_a_q;
wire [3:0] right_luma = eye ? fb_b_q    : live_luma;

// Red/cyan coefficients adapted from the current Virtual Boy MiSTer colorizer.
// Convert 4-bit SMS luma to 8-bit before applying its fixed-point coefficients.
wire [7:0] ll = {left_luma, left_luma};
wire [7:0] rl = {right_luma, right_luma};

wire [15:0] rc_g_sum = (rl << 7) + (rl << 6) + (rl << 2) + (rl << 1);
wire [15:0] rc_b_sum = (rl << 7) + (rl << 6) + (rl << 5) + (rl << 4);
wire [11:0] redcyan_color =
	{left_luma, rc_g_sum[15:12], rc_b_sum[15:12]};

// TriOviz/Inficolor coefficients ported from the current Virtual Boy MiSTer
// colorizer. Each eye's luma is mapped to its filter response; output channels
// take the stronger contribution from the two eyes.
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
wire [11:0] trioviz_color =
	{trio_r[7:4], trio_g[7:4], trio_b[7:4]};

wire [11:0] stereo_color =
	(mode == MODE_TRIOVIZ) ? trioviz_color : redcyan_color;
wire stereo_present =
	active && mode_stereo && stereo_valid && fb_area;

assign color_out = stereo_present ? stereo_color :
                   replay         ? fb_color :
                                    color_in;

endmodule
