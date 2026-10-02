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
wire [5:0] live_rgb={color_in[11:10],color_in[7:6],color_in[3:2]};
wire [5:0] prev_rgb;

// Port A replaces the previous field with the live field. Port B observes
// OLD_DATA on a same-address read/write collision, i.e. the opposite eye.
dpram #(.widthad_a(16),.width_a(6),.mixed_port_rdwr("OLD_DATA")) framebuffer
(
 .clock_a(clk_sys), .address_a(fb_addr),
 .wren_a(ce_pix&&active&&active_area&&(mode!=MODE_ORIGINAL)),
 .data_a(live_rgb), .q_a(),
 .clock_b(clk_sys), .address_b(fb_addr),
 .wren_b(1'b0), .data_b(6'd0), .q_b(prev_rgb)
);

reg eye_d=0;
reg pair_valid=0;
reg [2:0] mode_d=MODE_ORIGINAL;
always @(posedge clk_sys) begin
 eye_d<=eye;
 mode_d<=mode;
 if(reset||!active||(mode==MODE_ORIGINAL)||(mode!=mode_d))
  pair_valid<=0;
 else if(eye!=eye_d)
  pair_valid<=1;
end

wire [3:0] live_r={color_in[3:2],color_in[3:2]};
wire [3:0] live_g={color_in[7:6],color_in[7:6]};
wire [3:0] live_b={color_in[11:10],color_in[11:10]};
wire [3:0] prev_r={prev_rgb[1:0],prev_rgb[1:0]};
wire [3:0] prev_g={prev_rgb[3:2],prev_rgb[3:2]};
wire [3:0] prev_b={prev_rgb[5:4],prev_rgb[5:4]};

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

function automatic [3:0] clip_q6;
 input integer v; integer q;
 begin
  q=(v+32)/64;
  if(q<0) clip_q6=0; else if(q>15) clip_q6=15; else clip_q6=q[3:0];
 end
endfunction

// Latest fixed-point TriOviz/Dubois-style matrix from the DDR development
// branch, retained verbatim while returning storage to FPGA RAM.
integer trio_rs,trio_gs,trio_bs;
reg [3:0] trio_r,trio_g,trio_b;
always @(*) begin
 trio_rs=(-4*rr)+(-10*rg)+(-2*rb)+(34*lr)+(45*lg)+(2*lb);
 trio_gs=(18*rr)+(43*rg)+(9*rb)+(-1*lr)+(-1*lg)+(-4*lb);
 trio_bs=(-1*rr)+(-2*rg)+(1*rb)+(1*lr)+(5*lg)+(60*lb);
 trio_r=clip_q6(trio_rs); trio_g=clip_q6(trio_gs); trio_b=clip_q6(trio_bs);
end
wire [11:0] trioviz={trio_b,trio_g,trio_r};

// Corrected ColorCode amber/blue weighting: 11% R + 22% G + 67% B.
integer cc_sum;
reg [3:0] cc_b;
always @(*) begin
 cc_sum=11*rr+22*rg+67*rb;
 if(cc_sum<50) cc_b=4'd0;
 else if(cc_sum<150) cc_b=4'd1;
 else if(cc_sum<250) cc_b=4'd2;
 else if(cc_sum<350) cc_b=4'd3;
 else if(cc_sum<450) cc_b=4'd4;
 else if(cc_sum<550) cc_b=4'd5;
 else if(cc_sum<650) cc_b=4'd6;
 else if(cc_sum<750) cc_b=4'd7;
 else if(cc_sum<850) cc_b=4'd8;
 else if(cc_sum<950) cc_b=4'd9;
 else if(cc_sum<1050) cc_b=4'd10;
 else if(cc_sum<1150) cc_b=4'd11;
 else if(cc_sum<1250) cc_b=4'd12;
 else if(cc_sum<1350) cc_b=4'd13;
 else if(cc_sum<1450) cc_b=4'd14;
 else cc_b=4'd15;
end
wire [11:0] colorcode={cc_b,lg,lr};

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
