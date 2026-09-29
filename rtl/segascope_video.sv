//============================================================================
// SegaScope 3-D video presentation - DDR backed stereo framebuffers
//
// Four RGB444 frame banks live in MiSTer DDR (two ping-pong banks per eye).
// Each pixel occupies a 16-bit slot, so four pixels form one 64-bit DDR word
// and one 256-pixel scanline is exactly 64 words. Display reads fetch a whole
// stereo line (128 words) into small on-chip line caches.
//============================================================================
module segascope_video
#(parameter [28:0] DDR_BASE_ADDR=29'h06080000)
(
 input clk_sys, input reset, input ce_pix,
 input [2:0] mode, input [2:0] left_color, input [2:0] right_color,
 input pal, input active, input eye,
 input [8:0] x, input [8:0] y,
 input [11:0] color_in, output [11:0] color_out,
 output reg sbs_ce, output sbs_hs, output sbs_vs,
 output sbs_hblank, output sbs_vblank, output [11:0] sbs_color,

 input ddr_grant, input ddr_busy,
 output [7:0] ddr_burst, output [28:0] ddr_addr,
 output [63:0] ddr_din, output [7:0] ddr_be,
 output ddr_rd, output ddr_we,
 input [63:0] ddr_dout, input ddr_ready
);

localparam [2:0] MODE_ORIGINAL=3'd0, MODE_LEFT=3'd1, MODE_RIGHT=3'd2,
                 MODE_REDCYAN=3'd3, MODE_TRIOVIZ=3'd4,
                 MODE_COLORCODE=3'd5, MODE_SBS=3'd6, MODE_CUSTOM=3'd7;
wire mode_sbs=(mode==MODE_SBS);
wire mode_filter=(mode==MODE_REDCYAN)||(mode==MODE_TRIOVIZ)||
                 (mode==MODE_COLORCODE)||(mode==MODE_CUSTOM);
wire active_area=(x<9'd256)&&(y<9'd192);

// SMS color bus is {BBBB,GGGG,RRRR}.

// ---- DDR capture ----------------------------------------------------------
// Ping-pong each semantic eye. A completed bank is published only after the
// queued writes from that eye have drained.
reg left_cap_bank=0,right_cap_bank=0,left_disp_bank=0,right_disp_bank=0;
reg left_done_toggle=0,right_done_toggle=0,left_done_bank=0,right_done_bank=0;
reg eye_d=0;

function automatic [28:0] frame_base;
 input which_eye; input bank;
 begin
  // left0,left1,right0,right1, each 12288 64-bit words (96 KiB).
  if(which_eye) frame_base=DDR_BASE_ADDR+(bank?29'd12288:29'd0);
  else          frame_base=DDR_BASE_ADDR+(bank?29'd36864:29'd24576);
 end
endfunction

reg [63:0] pack=0;
reg pack_active=0;
reg [7:0] pack_y=0;
reg pack_eye=0,pack_bank=0;

// Small write FIFO decouples the SMS pixel cadence from DDR latency.
reg [28:0] wf_addr[0:31];
reg [63:0] wf_data[0:31];
reg [5:0] wf_wr=0,wf_rd=0;
wire wf_empty=(wf_wr==wf_rd);
wire wf_full=((wf_wr-wf_rd)==6'd32);

always @(posedge clk_sys) begin
 eye_d<=eye;
 if(reset||!active||!ddr_grant) begin
  pack_active<=0; wf_wr<=0;
  left_cap_bank<=0; right_cap_bank<=0;
  left_done_toggle<=0; right_done_toggle<=0;
 end else begin
  // Eye changes occur at field boundaries. Start writing the new field into
  // the alternate bank; publish the old bank after all queued writes drain.
  if(eye!=eye_d) begin
   if(eye_d) begin
    left_done_bank<=left_cap_bank; left_done_toggle<=~left_done_toggle;
    left_cap_bank<=~left_cap_bank;
   end else begin
    right_done_bank<=right_cap_bank; right_done_toggle<=~right_done_toggle;
    right_cap_bank<=~right_cap_bank;
   end
  end

  if(ce_pix&&active_area) begin
   if(x[1:0]==0) begin
    pack_active<=!wf_full;
    if(!wf_full) begin
     pack<={48'd0,color_in};
     pack_y<=y[7:0]; pack_eye<=eye;
     pack_bank<=eye?left_cap_bank:right_cap_bank;
    end
   end else if(pack_active) begin
    case(x[1:0])
     1: pack[27:16]<=color_in;
     2: pack[43:32]<=color_in;
     3: begin
      wf_addr[wf_wr[4:0]]<=frame_base(pack_eye,pack_bank)+
                      ({21'd0,pack_y}<<6)+{23'd0,x[7:2]};
      wf_data[wf_wr[4:0]]<={4'd0,color_in,4'd0,pack[43:32],
                       4'd0,pack[27:16],4'd0,pack[11:0]};
      wf_wr<=wf_wr+1'd1;
      pack_active<=0;
     end
    endcase
   end
  end
 end
end

// ---- Stable stereo line cache -------------------------------------------
(* ramstyle = "M10K, no_rw_check" *) reg [63:0] left_line[0:63];
(* ramstyle = "M10K, no_rw_check" *) reg [63:0] right_line[0:63];
// SBS gets a second stereo line cache so DDR can fetch line N+1 while line N
// remains stable on screen.
(* ramstyle = "M10K, no_rw_check" *) reg [63:0] sbs_left_line[0:63];
(* ramstyle = "M10K, no_rw_check" *) reg [63:0] sbs_right_line[0:63];
reg [7:0] cache_y=0;
reg cache_valid=0;
reg [7:0] sbs_cache_y=0;
reg sbs_cache_valid=0;
reg sbs_display_secondary=0;
reg sbs_fill_secondary=0;
reg sbs_ready=0;
reg [7:0] sbs_ready_y=0;
reg sbs_ready_secondary=0;
reg sbs_prime_pending=0;
reg fetch_toggle=0;
reg [7:0] fetch_req_y=0;
reg [7:0] dma_fetch_y=0;
reg [7:0] returned=0;

reg [9:0] sbs_x=0;
reg [8:0] sbs_y=0;
reg [2:0] sbs_div=0;
wire [8:0] sbs_last_y=pal?9'd312:9'd261;

// Request the next line well before it is displayed. Normal modes use the
// source raster's horizontal blanking; SBS uses its own wider raster.
always @(posedge clk_sys) begin
 if(reset||!active||!ddr_grant) begin
  fetch_toggle<=0;
 end else begin
  if(!mode_sbs && ce_pix && x==9'd256 && y<9'd192) begin
   fetch_req_y <= (y==9'd191)?8'd0:y[7:0]+1'd1;
   fetch_toggle<=~fetch_toggle;
  end
  // With a second SBS cache, prefetch line N+1 as soon as line N starts.
  // This gives DDR almost a complete 684-pixel line period instead of only
  // horizontal blanking, without disturbing the line currently displayed.
  if(mode_sbs && sbs_ce && sbs_x==10'd0 && sbs_y<9'd192) begin
   fetch_req_y <= (sbs_y==9'd191)?8'd0:sbs_y[7:0]+1'd1;
   fetch_toggle<=~fetch_toggle;
  end
 end
end

// ---- DDR DMA -------------------------------------------------------------
localparam [1:0] DMA_IDLE=2'd0,DMA_READ_REQ=2'd1,DMA_READ_DATA=2'd2,DMA_WRITE=2'd3;
reg [1:0] dma=DMA_IDLE;
reg [28:0] read_base=0;
reg last_fetch_toggle=0,left_done_seen=0,right_done_seen=0;
reg left_publish_pending=0,right_publish_pending=0;
reg left_valid=0,right_valid=0;
wire [28:0] right_read_base=frame_base(1'b0,right_disp_bank)+({21'd0,dma_fetch_y}<<6);

assign ddr_burst=(dma==DMA_READ_REQ||dma==DMA_READ_DATA)?8'd64:8'd1;
assign ddr_addr=(dma==DMA_WRITE)?wf_addr[wf_rd[4:0]]:read_base;
assign ddr_din=wf_data[wf_rd[4:0]];
assign ddr_be=8'hFF;
assign ddr_rd=(dma==DMA_READ_REQ);
assign ddr_we=(dma==DMA_WRITE);

always @(posedge clk_sys) begin
 if(reset||!active||!ddr_grant) begin
  dma<=DMA_IDLE; returned<=0; wf_rd<=0; cache_valid<=0;
   sbs_cache_valid<=0; sbs_display_secondary<=0; sbs_fill_secondary<=0;
  sbs_ready<=0; sbs_prime_pending<=0;
  last_fetch_toggle<=fetch_toggle;
  left_done_seen<=left_done_toggle; right_done_seen<=right_done_toggle;
  left_publish_pending<=0; right_publish_pending<=0;
  left_disp_bank<=0; right_disp_bank<=0; left_valid<=0; right_valid<=0;
 end else begin
  if(left_done_toggle!=left_done_seen) left_publish_pending<=1;
  if(right_done_toggle!=right_done_seen) right_publish_pending<=1;

  // Make a completed SBS line visible only between scanlines. The request was
  // launched at x=0, so the fill has nearly a complete line period to finish.
  if(mode_sbs && sbs_ready &&
     ((sbs_vblank && sbs_ready_y==8'd0) ||
      (sbs_ce && sbs_x==10'd683 && !sbs_vblank &&
       sbs_ready_y==((sbs_y==9'd191)?8'd0:sbs_y[7:0]+1'd1)))) begin
   sbs_cache_y<=sbs_ready_y;
   sbs_display_secondary<=sbs_ready_secondary;
   sbs_cache_valid<=1;
   sbs_ready<=0;
  end

  case(dma)
   DMA_IDLE: begin
    // All reconstructed modes follow the rolling SegaScope cadence:
    // publish whichever eye just completed and combine it with the latest
    // completed opposite eye. SBS latches that rolling combination only during
    // vertical blank so its source banks never change halfway down a frame.
    if(wf_empty && mode_sbs && sbs_vblank &&
       (left_publish_pending || right_publish_pending)) begin
     if(left_publish_pending) begin
      left_disp_bank<=left_done_bank; left_done_seen<=left_done_toggle;
      left_publish_pending<=0; left_valid<=1;
     end
     if(right_publish_pending) begin
      right_disp_bank<=right_done_bank; right_done_seen<=right_done_toggle;
      right_publish_pending<=0; right_valid<=1;
     end
     sbs_cache_valid<=0; sbs_ready<=0; sbs_prime_pending<=1;
    end else if(wf_empty && !mode_sbs &&
                (left_publish_pending || right_publish_pending)) begin
     if(left_publish_pending) begin
      left_disp_bank<=left_done_bank; left_done_seen<=left_done_toggle;
      left_publish_pending<=0; left_valid<=1;
     end
     if(right_publish_pending) begin
      right_disp_bank<=right_done_bank; right_done_seen<=right_done_toggle;
      right_publish_pending<=0; right_valid<=1;
     end
     cache_valid<=0;
    end else if(mode_sbs && sbs_prime_pending) begin
     // After latching the latest rolling eye combination during vertical blank,
     // refill line 0 immediately so the next SBS frame starts valid.
     returned<=0; dma_fetch_y<=8'd0;
     sbs_fill_secondary<=~sbs_display_secondary;
     read_base<=frame_base(1'b1,left_disp_bank);
     sbs_prime_pending<=0;
     dma<=DMA_READ_REQ;
    end else if(fetch_toggle!=last_fetch_toggle) begin
     // Reads have priority so video timing never waits behind capture writes.
     last_fetch_toggle<=fetch_toggle; returned<=0; dma_fetch_y<=fetch_req_y;
     // SBS alternates between the primary and secondary line caches.
     // Normal presentation modes continue using the primary cache only.
     if(mode_sbs) sbs_fill_secondary<=sbs_cache_valid ? ~sbs_display_secondary : 1'b0;
     read_base<=frame_base(1'b1,left_disp_bank)+({21'd0,fetch_req_y}<<6);
     dma<=DMA_READ_REQ;
    end else if(!wf_empty) dma<=DMA_WRITE;
   end
   DMA_READ_REQ: if(!ddr_busy) dma<=DMA_READ_DATA;
   DMA_READ_DATA: if(ddr_ready) begin
    if(mode_sbs) begin
     if(returned<64) begin
      if(sbs_fill_secondary) sbs_left_line[returned[5:0]]<=ddr_dout;
      else left_line[returned[5:0]]<=ddr_dout;
     end else begin
      if(sbs_fill_secondary) sbs_right_line[returned[5:0]]<=ddr_dout;
      else right_line[returned[5:0]]<=ddr_dout;
     end
    end else begin
     if(returned<64) left_line[returned[5:0]]<=ddr_dout;
     else right_line[returned[5:0]]<=ddr_dout;
    end
    returned<=returned+1'd1;
    if(returned==8'd63) begin
     // DDR bursts cannot jump from left bank to right bank. Finish this burst,
     // then issue the right-eye 64-word burst.
     read_base<=right_read_base; dma<=DMA_READ_REQ;
    end
    if(returned==8'd127) begin
     if(mode_sbs) begin
      sbs_ready_y<=dma_fetch_y;
      sbs_ready_secondary<=sbs_fill_secondary;
      sbs_ready<=1;
     end else begin
      cache_y<=dma_fetch_y; cache_valid<=1;
     end
     dma<=DMA_IDLE;
    end
   end
   DMA_WRITE: if(!ddr_busy) begin
    wf_rd<=wf_rd+1'd1;
    dma<=DMA_IDLE;
   end
  endcase
 end
end

// The two eye banks are non-contiguous, so each cache fill is two 64-word bursts.

// ---- Stereo presentation -------------------------------------------------
wire pair_valid=left_valid&&right_valid;
wire cache_hit=pair_valid&&cache_valid&&(cache_y==y[7:0])&&active_area;
// The SBS counter advances on the clock that raises sbs_ce, while the
// consumer samples that pixel on the following clock. Prefetch x+1 so the
// synchronous M10K read has the next 64-bit word ready at every 4-pixel edge.
wire [9:0] sbs_prefetch_x=sbs_x+10'd1;
wire [5:0] line_rd_addr=mode_sbs?sbs_prefetch_x[7:2]:x[7:2];
reg [63:0] left_word=0,right_word=0;
always @(posedge clk_sys) begin
 if(mode_sbs && sbs_display_secondary) begin
  left_word<=sbs_left_line[line_rd_addr];
  right_word<=sbs_right_line[line_rd_addr];
 end else begin
  left_word<=left_line[line_rd_addr];
  right_word<=right_line[line_rd_addr];
 end
end
reg [11:0] left_px,right_px;
always @(*) begin
 case(x[1:0])
  0: begin left_px=left_word[11:0]; right_px=right_word[11:0]; end
  1: begin left_px=left_word[27:16]; right_px=right_word[27:16]; end
  2: begin left_px=left_word[43:32]; right_px=right_word[43:32]; end
  default: begin left_px=left_word[59:48]; right_px=right_word[59:48]; end
 endcase
end
wire [3:0] lr=left_px[3:0],lg=left_px[7:4],lb=left_px[11:8];
wire [3:0] rr=right_px[3:0],rg=right_px[7:4],rb=right_px[11:8];

wire [11:0] redcyan={rb,rg,lr};

function automatic [3:0] clip_q6;
 input integer v; integer q;
 begin
  // Matrix coefficients are Q6 and inputs are already full RGB444 (0..15).
  q=(v+32)/64;
  if(q<0) clip_q6=0; else if(q>15) clip_q6=15; else clip_q6=q[3:0];
 end
endfunction
integer trio_rs,trio_gs,trio_bs;
reg [3:0] trio_r,trio_g,trio_b;
always @(*) begin
 trio_rs=(-4*rr)+(-10*rg)+(-2*rb)+(34*lr)+(45*lg)+(2*lb);
 trio_gs=(18*rr)+(43*rg)+(9*rb)+(-1*lr)+(-1*lg)+(-4*lb);
 trio_bs=(-1*rr)+(-2*rg)+(1*rb)+(1*lr)+(5*lg)+(60*lb);
 trio_r=clip_q6(trio_rs); trio_g=clip_q6(trio_gs); trio_b=clip_q6(trio_bs);
end
wire [11:0] trioviz={trio_b,trio_g,trio_r};

integer cc_sum;
reg [3:0] cc_b;
always @(*) begin
 // Rounded (15*R + 15*G + 70*B) / 100, expressed as thresholds so
 // Quartus does not infer a general-purpose divider.
 cc_sum=15*rr+15*rg+70*rb;
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
assign color_out=!active||mode==MODE_ORIGINAL||!cache_hit ? color_in :
                 (mode==MODE_LEFT)?left_px :
                 (mode==MODE_RIGHT)?right_px :
                 mode_filter?filtered:color_in;

// ---- Side-by-side raster -------------------------------------------------
always @(posedge clk_sys) begin
 sbs_ce<=0;
 if(reset||!active||!mode_sbs) begin sbs_div<=0;sbs_x<=0;sbs_y<=0; end
 else if(sbs_div==3'd4) begin
  sbs_div<=0;sbs_ce<=1;
  if(sbs_x==10'd683) begin
   sbs_x<=0;
   if(sbs_y==sbs_last_y) sbs_y<=0; else sbs_y<=sbs_y+1'd1;
  end else sbs_x<=sbs_x+1'd1;
 end else sbs_div<=sbs_div+1'd1;
end
assign sbs_hblank=(sbs_x>=512);
assign sbs_vblank=(sbs_y>=192);
assign sbs_hs=(sbs_x>=560)&&(sbs_x<608);
assign sbs_vs=pal?((sbs_y>=243)&&(sbs_y<246)):((sbs_y>=221)&&(sbs_y<224));
wire sbs_cache_hit=pair_valid&&sbs_cache_valid&&(sbs_cache_y==sbs_y[7:0])&&(sbs_y<192);
reg [11:0] sbs_left,sbs_right;
always @(*) begin
 case(sbs_x[1:0])
  0: begin sbs_left=left_word[11:0]; sbs_right=right_word[11:0]; end
  1: begin sbs_left=left_word[27:16]; sbs_right=right_word[27:16]; end
  2: begin sbs_left=left_word[43:32]; sbs_right=right_word[43:32]; end
  default: begin sbs_left=left_word[59:48]; sbs_right=right_word[59:48]; end
 endcase
end
assign sbs_color=(!sbs_cache_hit||sbs_hblank||sbs_vblank)?12'd0:
                 (sbs_x<256?sbs_left:sbs_right);

endmodule
