//============================================================================
// SegaScope 3-D video presentation
//
// A single 32768x20 dual-port RAM uses the Cyclone V M10K native x20 width.
// Normal modes pack two 8-bit presentation pixels per word. Side-by-side
// packs three native RGB222 pixels per word, fitting two complete 256x192
// eyes (98,304 pixels) in 32,768 words without reducing spatial/color detail.
//============================================================================
module segascope_video
(
 input clk_sys, input reset, input ce_pix,
 input [2:0] mode, input [2:0] left_color, input [2:0] right_color,
 input pal, input active, input eye,
 input [8:0] x, input [8:0] y,
 input [11:0] color_in, output [11:0] color_out,
 output reg sbs_ce, output sbs_hs, output sbs_vs,
 output sbs_hblank, output sbs_vblank, output [11:0] sbs_color
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
wire active_area=(x<9'd256)&&(y<9'd192);

// SMS color bus is {BBBB,GGGG,RRRR}; keep semantic names explicit.
wire [1:0] live_r=color_in[3:2];
wire [1:0] live_g=color_in[7:6];
wire [1:0] live_b=color_in[11:10];
wire [5:0] live_rgb={live_b,live_g,live_r};
wire [5:0] live_luma_sum={2'b00,color_in[11:8]}+
                          {1'b0,color_in[7:4],1'b0}+
                          {2'b00,color_in[3:0]};
wire [3:0] live_luma=live_luma_sum[5:2];

// ---- Shared 32768x20 dual-port presentation RAM ---------------------------
// Port A captures the source raster. Port B independently scans SBS.
wire [19:0] ram_qa,ram_qb;
reg [14:0] normal_ram_addr_a=0,sbs_ram_addr_a=0;
reg [19:0] normal_ram_data_a=0,sbs_ram_data_a=0;
reg normal_ram_we_a=0,sbs_ram_we_a=0;
reg [14:0] ram_addr_b=0;
wire [14:0] ram_addr_a=mode_sbs?sbs_ram_addr_a:normal_ram_addr_a;
wire [19:0] ram_data_a=mode_sbs?sbs_ram_data_a:normal_ram_data_a;
wire ram_we_a=mode_sbs?sbs_ram_we_a:normal_ram_we_a;

dpram #(.widthad_a(15),.width_a(20),.mixed_port_rdwr("OLD_DATA"))
framebuffer (
 .clock_a(clk_sys),.address_a(ram_addr_a),.wren_a(ram_we_a),
 .data_a(ram_data_a),.q_a(ram_qa),
 .clock_b(clk_sys),.address_b(ram_addr_b),.wren_b(1'b0),
 .data_b(20'd0),.q_b(ram_qb)
);

// Normal modes use 256x192 only: two 8-bit pixels per 20-bit word.
wire [14:0] normal_addr={y[7:0],x[7:1]};
wire normal_half=x[0];
wire [7:0] normal_q=normal_half?ram_qa[15:8]:ram_qa[7:0];

reg [1:0] cap_phase=0;
localparam [1:0] CAP_IDLE=2'd0,CAP_READ=2'd1,CAP_WRITE=2'd2;
reg [14:0] cap_addr=0;
reg cap_half=0,cap_eye=0;
reg [5:0] cap_rgb=0;
reg [3:0] cap_luma=0;
reg [2:0] cap_mode=0;

wire capture_normal=ce_pix&&active&&active_area&&
                    (mode_filter||(mode_2d&&(eye==selected_eye)));

function automatic [1:0] cc_blue;
 input [1:0] r,g,b;
 reg [8:0] sum;
 begin
  // ColorCode patent example: B = 0.15R + 0.15G + 0.70B.
  // Threshold the weighted 2-bit result directly; no divider is needed.
  sum=(r*9'd15)+(g*9'd15)+(b*9'd70);
  if(sum<9'd50) cc_blue=2'd0;
  else if(sum<9'd150) cc_blue=2'd1;
  else if(sum<9'd250) cc_blue=2'd2;
  else cc_blue=2'd3;
 end
endfunction

wire [1:0] cap_r=cap_rgb[1:0],cap_g=cap_rgb[3:2],cap_b=cap_rgb[5:4];
wire [7:0] old_payload=cap_half?ram_qa[15:8]:ram_qa[7:0];
reg [7:0] new_payload;
always @(*) begin
 new_payload=old_payload;
 case(cap_mode)
  MODE_LEFT,MODE_RIGHT: new_payload={cap_b,cap_g,cap_r,2'b00};
  MODE_REDCYAN:
   if(cap_eye) new_payload={old_payload[7:6],old_payload[5:4],cap_r,2'b00};
   else        new_payload={cap_b,cap_g,old_payload[3:2],2'b00};
  MODE_TRIOVIZ:
   if(cap_eye) new_payload={cap_b,old_payload[5:4],cap_r,2'b00};
   else        new_payload={old_payload[7:6],cap_g,old_payload[3:2],2'b00};
  MODE_COLORCODE:
   if(cap_eye) new_payload={old_payload[7:6],cap_g,cap_r,2'b00};
   else        new_payload={cc_blue(cap_r,cap_g,cap_b),old_payload[5:0]};
  MODE_CUSTOM:
   if(cap_eye) new_payload={cap_luma,old_payload[3:0]};
   else        new_payload={old_payload[7:4],cap_luma};
  default: new_payload=old_payload;
 endcase
end

always @(posedge clk_sys) begin
 normal_ram_we_a<=0;
 if(reset||!active||mode_sbs) begin
  cap_phase<=CAP_IDLE;
 end else case(cap_phase)
  CAP_IDLE: if(capture_normal) begin
   cap_addr<=normal_addr; cap_half<=normal_half; cap_eye<=eye;
   cap_rgb<=live_rgb; cap_luma<=live_luma; cap_mode<=mode;
   normal_ram_addr_a<=normal_addr; cap_phase<=CAP_READ;
  end
  CAP_READ: begin
   cap_phase<=CAP_WRITE;
  end
  CAP_WRITE: begin
   normal_ram_addr_a<=cap_addr;
   normal_ram_data_a<=cap_half?{4'd0,new_payload,ram_qa[7:0]}:
                            {4'd0,ram_qa[15:8],new_payload};
   normal_ram_we_a<=1;
   cap_phase<=CAP_IDLE;
  end
  default: cap_phase<=CAP_IDLE;
 endcase
end

// Pair validity is reset on mode changes and becomes true after both semantic
// eye states have appeared.
reg left_seen=0,right_seen=0;
reg [2:0] mode_d=MODE_ORIGINAL;
always @(posedge clk_sys) begin
 mode_d<=mode;
 if(reset||!active||!mode_pair||(mode!=mode_d)) begin
  left_seen<=0; right_seen<=0;
 end else if(ce_pix&&active_area) begin
  if(eye) left_seen<=1; else right_seen<=1;
 end
end
wire pair_valid=left_seen&&right_seen;

// Reconstruct the current normal-mode pair from live current eye + stored
// opposite-eye payload during CAP_READ.
wire [7:0] pair_payload=old_payload;
wire [1:0] rc_left_r =cap_eye?cap_r:pair_payload[3:2];
wire [1:0] rc_right_g=cap_eye?pair_payload[5:4]:cap_g;
wire [1:0] rc_right_b=cap_eye?pair_payload[7:6]:cap_b;
wire [11:0] redcyan_color={rc_right_b,rc_right_b,
                           rc_right_g,rc_right_g,
                           rc_left_r,rc_left_r};

wire [1:0] trio_left_r =cap_eye?cap_r:pair_payload[3:2];
wire [1:0] trio_left_b =cap_eye?cap_b:pair_payload[7:6];
wire [1:0] trio_right_g=cap_eye?pair_payload[5:4]:cap_g;
wire [11:0] trioviz_color={trio_left_b,trio_left_b,
                           trio_right_g,trio_right_g,
                           trio_left_r,trio_left_r};

// Full-color ColorCode: left eye supplies original R/G; right eye supplies
// the blue plane from weighted RGB (15%,15%,70%).
wire [1:0] cc_left_r=cap_eye?cap_r:pair_payload[3:2];
wire [1:0] cc_left_g=cap_eye?cap_g:pair_payload[5:4];
wire [1:0] cc_right_b=cap_eye?pair_payload[7:6]:cc_blue(cap_r,cap_g,cap_b);
wire [11:0] colorcode_color={cc_right_b,cc_right_b,
                             cc_left_g,cc_left_g,
                             cc_left_r,cc_left_r};

wire [3:0] left_luma=cap_eye?cap_luma:pair_payload[7:4];
wire [3:0] right_luma=cap_eye?pair_payload[3:0]:cap_luma;
function automatic [11:0] eye_color;
 input [2:0] sel; input [3:0] luma;
 begin
  case(sel)
   3'd0: eye_color={4'd0,4'd0,luma}; // R
   3'd1: eye_color={luma,4'd0,luma}; // Magenta
   3'd2: eye_color={luma,4'd0,4'd0}; // B
   3'd3: eye_color={luma,luma,4'd0}; // Cyan
   3'd4: eye_color={4'd0,luma,4'd0}; // Green
   3'd5: eye_color={4'd0,luma,luma}; // Yellow
   3'd6: eye_color={luma,luma,luma}; // White
   default: eye_color={4'd0,4'd0,luma};
  endcase
 end
endfunction
wire [11:0] custom_left=eye_color(left_color,left_luma);
wire [11:0] custom_right=eye_color(right_color,right_luma);
wire [3:0] custom_b=(custom_left[11:8]>custom_right[11:8])?
                     custom_left[11:8]:custom_right[11:8];
wire [3:0] custom_g=(custom_left[7:4]>custom_right[7:4])?
                     custom_left[7:4]:custom_right[7:4];
wire [3:0] custom_r=(custom_left[3:0]>custom_right[3:0])?
                     custom_left[3:0]:custom_right[3:0];
wire [11:0] custom_color={custom_b,custom_g,custom_r};

wire [11:0] filter_color=(cap_mode==MODE_REDCYAN)?redcyan_color:
                         (cap_mode==MODE_TRIOVIZ)?trioviz_color:
                         (cap_mode==MODE_COLORCODE)?colorcode_color:
                         custom_color;
reg [11:0] filter_pixel=0;
always @(posedge clk_sys)
 if(active&&mode_filter&&pair_valid&&(cap_phase==CAP_READ))
  filter_pixel<=filter_color;

// Left/Right replay: selected eye stays live; opposite eye replays stored RGB.
reg [11:0] replay_pixel=0;
reg replay_valid=0,eye_d=0;
always @(posedge clk_sys) begin
 eye_d<=eye;
 if(reset||!active||!mode_2d||(mode!=mode_d)) replay_valid<=0;
 else if((eye!=eye_d)&&(eye_d==selected_eye)) replay_valid<=1;
 if(active&&mode_2d&&(cap_phase==CAP_READ)) begin
  replay_pixel<={old_payload[7:6],old_payload[7:6],
                 old_payload[5:4],old_payload[5:4],
                 old_payload[3:2],old_payload[3:2]};
 end
end
wire replay=active&&mode_2d&&replay_valid&&(eye!=selected_eye)&&active_area;
assign color_out=(active&&mode_filter&&pair_valid&&active_area)?filter_pixel:
                 replay?replay_pixel:color_in;

// ---- Full-resolution side-by-side -----------------------------------------
// Linear stereo index: left eye first, then right. 3 RGB222 pixels are packed
// into each 20-bit word. Division by 3 uses exact reciprocal multiplication
// for the 17-bit range 0..98303: floor(n/3)=(n*43691)>>17.
wire [16:0] sbs_capture_index=(eye?17'd0:17'd49152)+
                              {y[7:0],8'd0}+{9'd0,x[7:0]};
wire [32:0] sbs_cap_mult=sbs_capture_index*16'd43691;
wire [14:0] sbs_cap_word=sbs_cap_mult[31:17];
wire [16:0] sbs_cap_base={1'b0,sbs_cap_word,1'b0}+{2'b00,sbs_cap_word};
wire [1:0] sbs_cap_slot=sbs_capture_index-sbs_cap_base;

reg [1:0] sbs_cap_phase=0;
reg [14:0] sbs_cap_addr=0;
reg [1:0] sbs_cap_slot_q=0;
reg [5:0] sbs_cap_rgb=0;
always @(posedge clk_sys) begin
 sbs_ram_we_a<=0;
 if(reset||!active||!mode_sbs) begin
  sbs_cap_phase<=0;
 end else case(sbs_cap_phase)
  0: if(ce_pix&&active_area) begin
   sbs_cap_addr<=sbs_cap_word; sbs_cap_slot_q<=sbs_cap_slot;
   sbs_cap_rgb<=live_rgb; sbs_ram_addr_a<=sbs_cap_word; sbs_cap_phase<=1;
  end
  1: sbs_cap_phase<=2;
  2: begin
   sbs_ram_addr_a<=sbs_cap_addr;
   case(sbs_cap_slot_q)
    0: sbs_ram_data_a<={ram_qa[19:6],sbs_cap_rgb};
    1: sbs_ram_data_a<={ram_qa[19:12],sbs_cap_rgb,ram_qa[5:0]};
    default: sbs_ram_data_a<={2'b00,sbs_cap_rgb,ram_qa[11:0]};
   endcase
   sbs_ram_we_a<=1; sbs_cap_phase<=0;
  end
 endcase
end

// 2x SMS dot clock: 684 samples/line, 262 NTSC or 313 PAL lines/frame.
// Active area is 512x192: full 256-pixel left eye followed by full right eye.
reg [2:0] sbs_div=0;
reg [9:0] sbs_x=0;
reg [8:0] sbs_y=0;
always @(posedge clk_sys) begin
 sbs_ce<=0;
 if(reset||!active||!mode_sbs) begin
  sbs_div<=0; sbs_x<=0; sbs_y<=0;
 end else if(sbs_div==3'd4) begin
  sbs_div<=0; sbs_ce<=1;
  if(sbs_x==10'd683) begin
   sbs_x<=0;
   if((!pal&&sbs_y==9'd261)||(pal&&sbs_y==9'd312)) sbs_y<=0;
   else sbs_y<=sbs_y+1'd1;
  end else sbs_x<=sbs_x+1'd1;
 end else sbs_div<=sbs_div+1'd1;
end

assign sbs_hblank=(sbs_x>=10'd512);
assign sbs_vblank=(sbs_y>=9'd192);
assign sbs_hs=(sbs_x>=10'd560)&&(sbs_x<10'd608);
assign sbs_vs=pal?((sbs_y>=9'd243)&&(sbs_y<9'd246)):
                  ((sbs_y>=9'd221)&&(sbs_y<9'd224));

wire [16:0] sbs_read_index=(sbs_x<10'd256?17'd0:17'd49152)+
                            {sbs_y[7:0],8'd0}+{9'd0,sbs_x[7:0]};
wire [32:0] sbs_read_mult=sbs_read_index*16'd43691;
wire [14:0] sbs_read_word=sbs_read_mult[31:17];
wire [16:0] sbs_read_base={1'b0,sbs_read_word,1'b0}+{2'b00,sbs_read_word};
wire [1:0] sbs_read_slot=sbs_read_index-sbs_read_base;
always @(posedge clk_sys)
 if(mode_sbs&&sbs_x<10'd512&&sbs_y<9'd192) ram_addr_b<=sbs_read_word;

wire [5:0] sbs_rgb=(sbs_read_slot==0)?ram_qb[5:0]:
                    (sbs_read_slot==1)?ram_qb[11:6]:ram_qb[17:12];
assign sbs_color=(sbs_hblank||sbs_vblank)?12'd0:
                 {sbs_rgb[5:4],sbs_rgb[5:4],
                  sbs_rgb[3:2],sbs_rgb[3:2],
                  sbs_rgb[1:0],sbs_rgb[1:0]};
endmodule
