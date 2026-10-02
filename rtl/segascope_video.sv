//============================================================================
// SegaScope 3-D presentation: fixed-eye and anaglyph modes.
//
// One RGB222 frame is kept in FPGA RAM. SegaScope software alternates eyes
// every field, so the live VDP pixel is the current eye and RAM contains the
// corresponding pixel from the preceding (opposite) eye. The RAM is updated
// every field, giving a fresh stereo pair at the native ~60 Hz field rate.
// No DDR or side-by-side raster is used.
//============================================================================
module segascope_video
(
 input clk_sys, input reset, input ce_pix,
 input [2:0] mode, input [2:0] left_color, input [2:0] right_color,
 input active, input eye,
 input [8:0] x, input [8:0] y,
 input [11:0] color_in,
 output [11:0] color_out
);

localparam [2:0] MODE_ORIGINAL=3'd0, MODE_LEFT=3'd1, MODE_RIGHT=3'd2,
                 MODE_REDCYAN=3'd3, MODE_TRIOVIZ=3'd4,
                 MODE_COLORCODE=3'd5, MODE_CUSTOM=3'd6;

wire active_area=(x<9'd256)&&(y<9'd192);
wire [15:0] fb_addr={y[7:0],x[7:0]};
wire [7:0] fb_q;
wire fb_we=ce_pix&&active&&active_area&&(mode!=MODE_ORIGINAL);

// Same single-port organization used by the timing-clean pre-DDR implementation.
// At a raster location q still represents the preceding field until this clock
// edge writes the current field.
spram #(.widthad_a(16),.width_a(8)) framebuffer
(
 .clock(clk_sys), .address(fb_addr), .wren(fb_we),
 .data({color_in[11:10],color_in[7:6],color_in[3:2],2'b00}), .q(fb_q)
);

reg left_seen=0,right_seen=0;
reg [2:0] mode_d=MODE_ORIGINAL;
always @(posedge clk_sys) begin
 mode_d<=mode;
 if(reset||!active||(mode==MODE_ORIGINAL)||(mode!=mode_d)) begin
  left_seen<=0;
  right_seen<=0;
 end else if(ce_pix&&active_area) begin
  if(eye) left_seen<=1;
  else right_seen<=1;
 end
end
wire pair_valid=left_seen&&right_seen;

wire [3:0] live_r={color_in[3:2],color_in[3:2]};
wire [3:0] live_g={color_in[7:6],color_in[7:6]};
wire [3:0] live_b={color_in[11:10],color_in[11:10]};
wire [3:0] prev_r={fb_q[3:2],fb_q[3:2]};
wire [3:0] prev_g={fb_q[5:4],fb_q[5:4]};
wire [3:0] prev_b={fb_q[7:6],fb_q[7:6]};

// eye=1 is the semantic left eye used by the existing SegaScope implementation.
wire [3:0] lr=eye?live_r:prev_r;
wire [3:0] lg=eye?live_g:prev_g;
wire [3:0] lb=eye?live_b:prev_b;
wire [3:0] rr=eye?prev_r:live_r;
wire [3:0] rg=eye?prev_g:live_g;
wire [3:0] rb=eye?prev_b:live_b;

wire [11:0] left_px={lb,lg,lr};
wire [11:0] right_px={rb,rg,rr};
wire [11:0] redcyan={rb,rg,lr};

// Red/cyan is intentionally kept on the direct RGB channels. This is the
// lightweight anaglyph path that predates the expensive color transforms.
// TriOviz and ColorCode remain menu-compatible aliases for now; they are not
// evaluated here so they cannot lengthen the pixel combinational path.
wire [11:0] trioviz=redcyan;
wire [11:0] colorcode=redcyan;

wire [5:0] left_lsum={2'b0,lr}+{1'b0,lg,1'b0}+{2'b0,lb};
wire [5:0] right_lsum={2'b0,rr}+{1'b0,rg,1'b0}+{2'b0,rb};
wire [3:0] left_luma=left_lsum[5:2],right_luma=right_lsum[5:2];
function automatic [11:0] eye_color;
 input [2:0] sel; input [3:0] luma;
 begin
  case(sel)
   0: eye_color={4'd0,4'd0,luma};
   1: eye_color={luma,4'd0,luma};
   2: eye_color={luma,4'd0,4'd0};
   3: eye_color={luma,luma,4'd0};
   4: eye_color={4'd0,luma,4'd0};
   5: eye_color={4'd0,luma,luma};
   6: eye_color={luma,luma,luma};
   default: eye_color=0;
  endcase
 end
endfunction
wire [11:0] cl=eye_color(left_color,left_luma),cr=eye_color(right_color,right_luma);
wire [11:0] custom={
 (cl[11:8]>cr[11:8])?cl[11:8]:cr[11:8],
 (cl[7:4]>cr[7:4])?cl[7:4]:cr[7:4],
 (cl[3:0]>cr[3:0])?cl[3:0]:cr[3:0]};

wire [11:0] filtered=(mode==MODE_REDCYAN)?redcyan:
                     (mode==MODE_TRIOVIZ)?trioviz:
                     (mode==MODE_COLORCODE)?colorcode:custom;
wire selected_eye=(mode==MODE_LEFT);
wire [11:0] fixed_eye=(eye==selected_eye)?color_in:(selected_eye?left_px:right_px);

assign color_out=(!active||!active_area||mode==MODE_ORIGINAL||!pair_valid)?color_in:
                 ((mode==MODE_LEFT)||(mode==MODE_RIGHT))?fixed_eye:filtered;
endmodule
