//============================================================================
// SegaScope 3-D video presentation
//
// Left/Right 2-D modes keep the hardware-proven 8-bit selected-eye framebuffer.
// Stereo filters use a separate 512 Kib luma store organized as:
//   address[16] = eye (1 Left, 0 Right)
//   address[15:0] = {y[7:0],x[7:0]}
// ce_pix is asserted once every ten clk_sys cycles, so the single-port stereo
// RAM is time-multiplexed: write current eye on the pixel edge, then read the
// opposite eye on the following clock. The result is latched well before the
// next pixel.
//============================================================================

module segascope_video
(
 input clk_sys, input reset, input ce_pix,
 input [2:0] mode, input active, input eye,
 input [8:0] x, input [8:0] y,
 input [11:0] color_in, output [11:0] color_out
);

localparam [2:0] MODE_ORIGINAL=3'd0, MODE_LEFT=3'd1, MODE_RIGHT=3'd2,
                 MODE_REDCYAN=3'd3, MODE_TRIOVIZ=3'd4;
wire mode_2d=(mode==MODE_LEFT)||(mode==MODE_RIGHT);
wire mode_stereo=(mode==MODE_REDCYAN)||(mode==MODE_TRIOVIZ);
wire selected_eye=(mode==MODE_LEFT);
wire fb_area=~x[8]&~y[8];
wire [15:0] pix_addr={y[7:0],x[7:0]};

// ---- Proven Left/Right framebuffer: unchanged 8-bit RGB222 storage ----------
wire [7:0] fb_q;
wire fb_we=ce_pix&&active&&mode_2d&&(eye==selected_eye)&&fb_area;
spram #(.widthad_a(16),.width_a(8)) framebuffer (
 .clock(clk_sys),.address(pix_addr),.wren(fb_we),
 .data({color_in[11:10],color_in[7:6],color_in[3:2],2'b00}),.q(fb_q)
);
wire [11:0] fb_color={fb_q[7:6],fb_q[7:6],fb_q[5:4],fb_q[5:4],
                      fb_q[3:2],fb_q[3:2]};

reg fb_valid=0, eye_d=0;
reg [2:0] mode_d=MODE_ORIGINAL;
always @(posedge clk_sys) begin
 eye_d<=eye; mode_d<=mode;
 if(reset||!active||!mode_2d||(mode!=mode_d)) fb_valid<=0;
 else if((eye!=eye_d)&&(eye_d==selected_eye)) fb_valid<=1;
end
wire replay=active&&mode_2d&&fb_valid&&(eye!=selected_eye)&&fb_area;

// ---- Dual-eye luma presentation store for stereo filters -------------------
wire [5:0] live_luma_sum={2'b00,color_in[11:8]}+
                          {1'b0,color_in[7:4],1'b0}+
                          {2'b00,color_in[3:0]};
wire [3:0] live_luma=live_luma_sum[5:2];

wire [3:0] stereo_q;
reg [3:0] opposite_luma=0;
reg [3:0] current_luma=0;
reg [15:0] current_addr=0;
reg current_eye=0;
reg [1:0] stereo_phase=0;

localparam [1:0] ST_IDLE=2'd0, ST_READ=2'd1, ST_CAPTURE=2'd2;

// On ce_pix the RAM port writes the live eye directly. The pixel address, eye
// and luma are latched at the same edge. ST_READ then presents the opposite-eye
// address for a complete RAM clock. ST_CAPTURE samples q one clock later.
wire stereo_write = ce_pix && active && mode_stereo && fb_area;
wire [16:0] stereo_ram_addr = stereo_write ?
 {eye,pix_addr} : {~current_eye,current_addr};

spram #(.widthad_a(17),.width_a(4)) stereo_luma (
 .clock(clk_sys),.address(stereo_ram_addr),.wren(stereo_write),
 .data(live_luma),.q(stereo_q)
);

always @(posedge clk_sys) begin
 if(reset||!active||!mode_stereo) begin
  stereo_phase<=ST_IDLE;
 end else begin
  case(stereo_phase)
   ST_IDLE: if(stereo_write) begin
    current_luma<=live_luma;
    current_addr<=pix_addr;
    current_eye<=eye;
    stereo_phase<=ST_READ;
   end
   ST_READ: stereo_phase<=ST_CAPTURE;
   ST_CAPTURE: begin
    opposite_luma<=stereo_q;
    stereo_phase<=ST_IDLE;
   end
   default: stereo_phase<=ST_IDLE;
  endcase
 end
end

reg left_seen=0,right_seen=0;
always @(posedge clk_sys) begin
 if(reset||!active||!mode_stereo||(mode!=mode_d)) begin
  left_seen<=0; right_seen<=0;
 end else if(ce_pix&&fb_area) begin
  if(eye) left_seen<=1; else right_seen<=1;
 end
end
wire stereo_valid=left_seen&&right_seen;

// Current/opposite ownership is fixed by SegaScope eye state.
wire [3:0] left_luma = current_eye ? current_luma : opposite_luma;
wire [3:0] right_luma= current_eye ? opposite_luma : current_luma;
wire [7:0] ll={left_luma,left_luma}, rl={right_luma,right_luma};

wire [15:0] rc_g_sum=({8'd0,rl}<<7)+({8'd0,rl}<<6)+
                         ({8'd0,rl}<<2)+({8'd0,rl}<<1);
wire [15:0] rc_b_sum=({8'd0,rl}<<7)+({8'd0,rl}<<6)+
                         ({8'd0,rl}<<5)+({8'd0,rl}<<4);
wire [11:0] redcyan_color={left_luma,rc_g_sum[15:12],rc_b_sum[15:12]};

wire [15:0] tl_r_sum=({8'd0,ll}<<7)+({8'd0,ll}<<5)+({8'd0,ll}<<4)+
                         ({8'd0,ll}<<3)+({8'd0,ll}<<2)+{8'd0,ll};
wire [15:0] tl_g_sum=({8'd0,ll}<<4)+({8'd0,ll}<<2)+
                         ({8'd0,ll}<<1)+{8'd0,ll};
wire [15:0] tl_b_sum=({8'd0,ll}<<7)+({8'd0,ll}<<5)+
                         ({8'd0,ll}<<3)+({8'd0,ll}<<1)+{8'd0,ll};
wire [15:0] tr_rb_sum=({8'd0,rl}<<6)+({8'd0,rl}<<3)+{8'd0,rl};
wire [7:0] tl_r=tl_r_sum[15:8],tl_g=tl_g_sum[15:8],tl_b=tl_b_sum[15:8];
wire [7:0] tr_r=tr_rb_sum[15:8],tr_g=rl,tr_b=tr_rb_sum[15:8];
wire [7:0] trio_r=(tl_r>tr_r)?tl_r:tr_r;
wire [7:0] trio_g=(tl_g>tr_g)?tl_g:tr_g;
wire [7:0] trio_b=(tl_b>tr_b)?tl_b:tr_b;
wire [11:0] trioviz_color={trio_r[7:4],trio_g[7:4],trio_b[7:4]};
wire [11:0] stereo_color=(mode==MODE_TRIOVIZ)?trioviz_color:redcyan_color;

// Hold the completed composition for the full pixel period.
reg [11:0] stereo_pixel=0;
always @(posedge clk_sys)
 if(active&&mode_stereo&&stereo_valid&&(stereo_phase==ST_IDLE)&&!ce_pix)
  stereo_pixel<=stereo_color;

assign color_out=(active&&mode_stereo&&stereo_valid&&fb_area)?stereo_pixel:
                 replay?fb_color:color_in;
endmodule
