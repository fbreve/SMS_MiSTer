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

// The source channels are RGB222 expanded by replication, hence each 4-bit
// channel is exactly 5 times its 2-bit value. Use the 2-bit values and
// shift/add constant arithmetic. This is mathematically identical to the
// latest color equations but avoids inferring six pixel-rate DSP multipliers.
wire [1:0] lr2=lr[3:2],lg2=lg[3:2],lb2=lb[3:2];
wire [1:0] rr2=rr[3:2],rg2=rg[3:2],rb2=rb[3:2];

function automatic signed [13:0] sx2;
 input [1:0] v;
 begin sx2={12'd0,v}; end
endfunction

reg signed [13:0] trio_wr,trio_wg,trio_wb;
reg signed [13:0] trio_rs,trio_gs,trio_bs;
reg signed [13:0] trio_nr,trio_ng,trio_nb;
reg [3:0] trio_r,trio_g,trio_b;
always @(*) begin
 // Coefficients are unchanged. Multiply the weighted RGB222 sum by five
 // because RGB444 replication maps 0,1,2,3 to 0,5,10,15.
 trio_wr=(-(sx2(rr2)<<<2))-((sx2(rg2)<<<3)+(sx2(rg2)<<<1))-(sx2(rb2)<<<1)
             +(sx2(lr2)<<<5)+(sx2(lr2)<<<1)
             +(sx2(lg2)<<<5)+(sx2(lg2)<<<3)+(sx2(lg2)<<<2)+sx2(lg2)
             +(sx2(lb2)<<<1);
 trio_wg=((sx2(rr2)<<<4)+(sx2(rr2)<<<1))
             +(sx2(rg2)<<<5)+(sx2(rg2)<<<3)+(sx2(rg2)<<<1)+sx2(rg2)
             +(sx2(rb2)<<<3)+sx2(rb2)-sx2(lr2)-sx2(lg2)-(sx2(lb2)<<<2);
 trio_wb=-sx2(rr2)-(sx2(rg2)<<<1)+sx2(rb2)+sx2(lr2)
             +(sx2(lg2)<<<2)+sx2(lg2)
             +(sx2(lb2)<<<5)+(sx2(lb2)<<<4)+(sx2(lb2)<<<3)+(sx2(lb2)<<<2);
 trio_rs=(trio_wr<<<2)+trio_wr;
 trio_gs=(trio_wg<<<2)+trio_wg;
 trio_bs=(trio_wb<<<2)+trio_wb;
 trio_nr=trio_rs+14'sd32; trio_ng=trio_gs+14'sd32; trio_nb=trio_bs+14'sd32;
 if(trio_nr<=0) trio_r=0; else if(trio_nr>=14'sd960) trio_r=15; else trio_r=trio_nr>>>6;
 if(trio_ng<=0) trio_g=0; else if(trio_ng>=14'sd960) trio_g=15; else trio_g=trio_ng>>>6;
 if(trio_nb<=0) trio_b=0; else if(trio_nb>=14'sd960) trio_b=15; else trio_b=trio_nb>>>6;
end
wire [11:0] trioviz={trio_b,trio_g,trio_r};

// Corrected ColorCode weighting remains exactly 11% R + 22% G + 67% B.
// Since all expanded channels are 5*x, divide the original thresholds by 5.
reg [9:0] cc_sum;
reg [3:0] cc_b;
always @(*) begin
 cc_sum=(rr2<<<3)+(rr2<<<1)+rr2
       +(rg2<<<4)+(rg2<<<2)+(rg2<<<1)
       +(rb2<<<6)+(rb2<<<1)+rb2;
 if(cc_sum<10) cc_b=4'd0;
 else if(cc_sum<30) cc_b=4'd1;
 else if(cc_sum<50) cc_b=4'd2;
 else if(cc_sum<70) cc_b=4'd3;
 else if(cc_sum<90) cc_b=4'd4;
 else if(cc_sum<110) cc_b=4'd5;
 else if(cc_sum<130) cc_b=4'd6;
 else if(cc_sum<150) cc_b=4'd7;
 else if(cc_sum<170) cc_b=4'd8;
 else if(cc_sum<190) cc_b=4'd9;
 else if(cc_sum<210) cc_b=4'd10;
 else if(cc_sum<230) cc_b=4'd11;
 else if(cc_sum<250) cc_b=4'd12;
 else if(cc_sum<270) cc_b=4'd13;
 else if(cc_sum<290) cc_b=4'd14;
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
