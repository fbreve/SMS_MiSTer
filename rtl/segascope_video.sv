//============================================================================
// SegaScope 3-D video presentation
//
// One 512 Kib single-port RAM is shared by every presentation mode.
// Left/Right use 65536x8 RGB222. Full-color Red/Cyan and TriOviz pack only
// the channels required by their filters. ColorCode/Custom pack two 4-bit
// luminances. Side-by-Side stores both eyes as RGB222 at 128x256 each.
//============================================================================

module segascope_video
(
 input clk_sys, input reset, input ce_pix,
 input [2:0] mode, input [2:0] left_color, input [2:0] right_color,
 input active, input eye,
 input [8:0] x, input [8:0] y,
 input [11:0] color_in, output [11:0] color_out
);

localparam [2:0] MODE_ORIGINAL=3'd0, MODE_LEFT=3'd1, MODE_RIGHT=3'd2,
                 MODE_REDCYAN=3'd3, MODE_TRIOVIZ=3'd4,
                 MODE_COLORCODE=3'd5, MODE_SBS=3'd6, MODE_CUSTOM=3'd7;

wire mode_2d=(mode==MODE_LEFT)||(mode==MODE_RIGHT);
wire mode_filter=(mode==MODE_REDCYAN)||(mode==MODE_TRIOVIZ)||
                 (mode==MODE_COLORCODE)||(mode==MODE_CUSTOM);
wire mode_sbs=(mode==MODE_SBS);
wire mode_pair=mode_filter||mode_sbs;
wire selected_eye=(mode==MODE_LEFT);
wire fb_area=~x[8]&~y[8];
wire [15:0] pix_addr={y[7:0],x[7:0]};

wire [5:0] live_luma_sum={2'b00,color_in[11:8]}+
                          {1'b0,color_in[7:4],1'b0}+
                          {2'b00,color_in[3:0]};
wire [3:0] live_luma=live_luma_sum[5:2];

// ---- Shared 512 Kib presentation RAM ---------------------------------------
wire [7:0] fb_q;
reg [5:0] current_rgb=0;
reg [3:0] current_luma=0;
reg [15:0] current_addr=0;
reg current_eye=0;
reg [1:0] filter_phase=0;
localparam [1:0] ST_IDLE=2'd0, ST_CAPTURE=2'd1, ST_WRITE=2'd2;

wire fb_we_2d=ce_pix&&active&&mode_2d&&(eye==selected_eye)&&fb_area;
wire filter_start=ce_pix&&active&&mode_filter&&fb_area;
wire filter_we=active&&mode_filter&&(filter_phase==ST_WRITE);

// SBS uses two 128x256 RGB222 eye planes in the same 64K RAM.
// Native even X pixels are captured. The left half reads eye=1 and the right
// half eye=0, each stretched from 128 stored columns to 128 output columns.
wire sbs_we=ce_pix&&active&&mode_sbs&&fb_area&&!x[0];
wire [15:0] sbs_capture_addr={eye,y[7:0],x[7:1]};
wire [15:0] sbs_display_addr={~x[7],y[7:0],x[6:0]};

wire [7:0] redcyan_new_word=current_eye ?
                          {current_rgb[5:4],fb_q[5:0]} :
                          {fb_q[7:6],current_rgb[3:2],current_rgb[1:0],2'b00};
wire [7:0] trioviz_new_word=current_eye ?
                         {current_rgb[5:4],current_rgb[1:0],fb_q[3:0]} :
                         {fb_q[7:4],current_rgb[3:2],2'b00};
wire [7:0] luma_new_word=current_eye ?
                         {current_luma,fb_q[3:0]} :
                         {fb_q[7:4],current_luma};
wire [7:0] filter_new_word=(mode==MODE_REDCYAN) ? redcyan_new_word :
                            (mode==MODE_TRIOVIZ) ? trioviz_new_word :
                            luma_new_word;

wire [15:0] filter_addr=(filter_phase==ST_IDLE)?pix_addr:current_addr;
wire [15:0] fb_addr=mode_sbs ?
                     (sbs_we?sbs_capture_addr:sbs_display_addr) :
                     filter_addr;
wire [7:0] fb_data=fb_we_2d ?
                    {color_in[11:10],color_in[7:6],color_in[3:2],2'b00} :
                    sbs_we ?
                    {color_in[11:10],color_in[7:6],color_in[3:2],2'b00} :
                    filter_new_word;
wire fb_we=fb_we_2d||filter_we||sbs_we;

spram #(.widthad_a(16),.width_a(8)) framebuffer (
 .clock(clk_sys),.address(fb_addr),.wren(fb_we),.data(fb_data),.q(fb_q)
);

wire [11:0] fb_color={fb_q[7:6],fb_q[7:6],fb_q[5:4],fb_q[5:4],
                      fb_q[3:2],fb_q[3:2]};

reg fb_valid=0, eye_d=0;
reg [2:0] mode_d=MODE_ORIGINAL;
always @(posedge clk_sys) begin
 eye_d<=eye;
 mode_d<=mode;
 if(reset||!active||!mode_2d||(mode!=mode_d)) fb_valid<=0;
 else if((eye!=eye_d)&&(eye_d==selected_eye)) fb_valid<=1;
end
wire replay=active&&mode_2d&&fb_valid&&(eye!=selected_eye)&&fb_area;

// Filter modes read the old packed eye pair, compose from it, then replace
// only the channels/luminance belonging to the currently arriving eye.
always @(posedge clk_sys) begin
 if(reset||!active||!mode_filter) begin
  filter_phase<=ST_IDLE;
 end else begin
  case(filter_phase)
   ST_IDLE: if(filter_start) begin
    current_rgb<={color_in[11:10],color_in[7:6],color_in[3:2]};
    current_luma<=live_luma;
    current_addr<=pix_addr;
    current_eye<=eye;
    filter_phase<=ST_CAPTURE;
   end
   ST_CAPTURE: filter_phase<=ST_WRITE;
   ST_WRITE: filter_phase<=ST_IDLE;
   default: filter_phase<=ST_IDLE;
  endcase
 end
end

reg left_seen=0,right_seen=0;
always @(posedge clk_sys) begin
 if(reset||!active||!mode_pair||(mode!=mode_d)) begin
  left_seen<=0;
  right_seen<=0;
 end else if(ce_pix&&fb_area) begin
  if(eye) left_seen<=1; else right_seen<=1;
 end
end
wire pair_valid=left_seen&&right_seen;

// Full-color Red/Cyan: left red + right green/blue.
wire [1:0] rc_left_r=current_eye ? current_rgb[5:4] : fb_q[7:6];
wire [1:0] rc_right_g=current_eye ? fb_q[5:4] : current_rgb[3:2];
wire [1:0] rc_right_b=current_eye ? fb_q[3:2] : current_rgb[1:0];
wire [11:0] redcyan_color={rc_left_r,rc_left_r,
                           rc_right_g,rc_right_g,
                           rc_right_b,rc_right_b};

// Inficolor/TriOviz Alpha: left magenta (R+B) + right green.
wire [1:0] trio_left_r=current_eye ? current_rgb[5:4] : fb_q[7:6];
wire [1:0] trio_left_b=current_eye ? current_rgb[1:0] : fb_q[5:4];
wire [1:0] trio_right_g=current_eye ? fb_q[3:2] : current_rgb[3:2];
wire [11:0] trioviz_color={trio_left_r,trio_left_r,
                           trio_right_g,trio_right_g,
                           trio_left_b,trio_left_b};

// ColorCode follows the Virtual Boy core's amber-left / blue-right transform.
wire [3:0] left_luma=current_eye ? current_luma : fb_q[7:4];
wire [3:0] right_luma=current_eye ? fb_q[3:0] : current_luma;
wire [7:0] ll={left_luma,left_luma};
wire [15:0] cc_r_sum=({8'd0,ll}<<7)+({8'd0,ll}<<5)+
                      ({8'd0,ll}<<4)+({8'd0,ll}<<2);
wire [15:0] cc_g_sum=({8'd0,ll}<<7)+({8'd0,ll}<<4)+
                      ({8'd0,ll}<<3)+({8'd0,ll}<<1)+{8'd0,ll};
wire [11:0] colorcode_color={cc_r_sum[15:12],cc_g_sum[15:12],right_luma};

function automatic [11:0] eye_color;
 input [2:0] sel;
 input [3:0] luma;
 begin
  case(sel)
   3'd0: eye_color={luma,4'd0,4'd0};
   3'd1: eye_color={luma,4'd0,luma};
   3'd2: eye_color={4'd0,4'd0,luma};
   3'd3: eye_color={4'd0,luma,luma};
   3'd4: eye_color={4'd0,luma,4'd0};
   3'd5: eye_color={luma,luma,4'd0};
   3'd6: eye_color={luma,luma,luma};
   default: eye_color={luma,4'd0,4'd0};
  endcase
 end
endfunction

wire [11:0] custom_left=eye_color(left_color,left_luma);
wire [11:0] custom_right=eye_color(right_color,right_luma);
wire [3:0] custom_r=(custom_left[11:8]>custom_right[11:8])?
                     custom_left[11:8]:custom_right[11:8];
wire [3:0] custom_g=(custom_left[7:4]>custom_right[7:4])?
                     custom_left[7:4]:custom_right[7:4];
wire [3:0] custom_b=(custom_left[3:0]>custom_right[3:0])?
                     custom_left[3:0]:custom_right[3:0];
wire [11:0] custom_color={custom_r,custom_g,custom_b};

wire [11:0] filter_color=(mode==MODE_REDCYAN)?redcyan_color:
                         (mode==MODE_TRIOVIZ)?trioviz_color:
                         (mode==MODE_COLORCODE)?colorcode_color:
                         custom_color;

reg [11:0] filter_pixel=0;
always @(posedge clk_sys)
 if(active&&mode_filter&&pair_valid&&(filter_phase==ST_CAPTURE))
  filter_pixel<=filter_color;

// In SBS, q normally points at the display plane. If the current pixel also
// performs a capture write, latch the pre-write q on that edge. This introduces
// only a fixed one-pixel presentation delay while keeping one physical RAM.
reg [11:0] sbs_pixel=0;
always @(posedge clk_sys) begin
 if(reset||!active||!mode_sbs) sbs_pixel<=0;
 else if(ce_pix&&pair_valid) sbs_pixel<=fb_color;
end

assign color_out=(active&&mode_filter&&pair_valid&&fb_area)?filter_pixel:
                 (active&&mode_sbs&&pair_valid&&fb_area)?sbs_pixel:
                 replay?fb_color:color_in;
endmodule
