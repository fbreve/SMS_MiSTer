module paddle_fixture(input clk_sys,hold,ss_freeze,ss_set,ss_valid,jp_region,paddle_joy,input[31:0]ss_in,input[7:0]paddle_0,paddle_1,joy0_x,joy1_x,input joya_th_out,joyb_th_out,output[31:0]state,output[9:0]pins);
wire ss_paddle_set=ss_set,ss_paddle_valid=ss_valid;wire[31:0]ss_paddle_in=ss_in;
wire en16khz;reg[11:0]cnt_en16khz;
reg  [3:0] paddle_0_nib,   paddle_1_nib;
reg  [3:0] paddle_0_nib_q, paddle_1_nib_q;
reg        paddle_0_tr,    paddle_1_tr;

reg        joya_th_out_q,  joyb_th_out_q;
wire       joya_th_rise,   joyb_th_rise;
wire       joya_th_fall,   joyb_th_fall;

always_ff @(posedge clk_sys) begin
if (!hold) begin
	if (jp_region) begin
		// Japanese paddle (HPD-200)
		if (en16khz) begin
			if (paddle_0_tr) begin
				if (paddle_joy) begin
					{paddle_0_nib_q, paddle_0_nib} <= {~joy0_x[7], joy0_x[6:0]};
					{paddle_1_nib_q, paddle_1_nib} <= {~joy1_x[7], joy1_x[6:0]};
				end else begin
					{paddle_0_nib_q, paddle_0_nib} <= paddle_0;
					{paddle_1_nib_q, paddle_1_nib} <= paddle_1;
				end
				paddle_0_tr  <= 1'b0;
				paddle_1_tr  <= 1'b0;
			end else begin
				paddle_0_nib <= paddle_0_nib_q;
				paddle_1_nib <= paddle_1_nib_q;
				paddle_0_tr  <= 1'b1;
				paddle_1_tr  <= 1'b1;
			end
		end
	end else begin
		// Export paddle (Non-existent but implemented in some games?)
		joya_th_out_q <= joya_th_out;
		joyb_th_out_q <= joyb_th_out;

		if (joya_th_fall) begin
			if (paddle_joy) begin
				{paddle_0_nib_q, paddle_0_nib} <= {~joy0_x[7], joy0_x[6:0]};
			end else begin
				{paddle_0_nib_q, paddle_0_nib} <= paddle_0;
			end
			paddle_0_tr  <= 1'b0;
		end else if (joya_th_rise) begin
			paddle_0_nib <= paddle_0_nib_q;
			paddle_0_tr  <= 1'b0;
		end

		if (joyb_th_fall) begin
			if (paddle_joy) begin
				{paddle_1_nib_q, paddle_1_nib} <= {~joy1_x[7], joy1_x[6:0]};
			end else begin
				{paddle_1_nib_q, paddle_1_nib} <= paddle_1;
			end
			paddle_1_tr  <= 1'b0;
		end else if (joyb_th_rise) begin
			paddle_1_nib <= paddle_1_nib_q;
			paddle_1_tr  <= 1'b0;
		end
	end
end
end

assign joya_th_rise = ~joya_th_out_q &  joya_th_out;
assign joyb_th_rise = ~joyb_th_out_q &  joyb_th_out;
assign joya_th_fall =  joya_th_out_q & ~joya_th_out;
assign joyb_th_fall =  joyb_th_out_q & ~joyb_th_out;




always_ff @(posedge clk_sys) begin
if (!hold) begin
	cnt_en16khz <= cnt_en16khz + 1'd1;
	if (cnt_en16khz == 3355) cnt_en16khz <= 0;
end
end
assign en16khz = cnt_en16khz == 0;
assign state={cnt_en16khz,joyb_th_out_q,joya_th_out_q,paddle_1_tr,paddle_0_tr,paddle_1_nib_q,paddle_1_nib,paddle_0_nib_q,paddle_0_nib};assign pins={paddle_1_tr,paddle_1_nib,paddle_0_tr,paddle_0_nib};
endmodule
