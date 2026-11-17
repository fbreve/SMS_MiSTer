module routing_fixture #(parameter T=57000)(input clk_sys,reset_active,ce_cpu,ss_freeze,ss_set,ss_valid,hold,th,enabled,raw_serial,input[18:0]ss_in,input[31:0]players,input[6:0]physical,input pause_combo,input[9:0]paddle_pins,input paddle_enabled,output[18:0]state,output reg[7:0]joya,joyb,joyser,output reg[6:0]USER_OUT);
wire[127:0]status={113'd0,enabled,14'd0};wire joya_th_out=th;wire joyb_th_out=1'b1;wire joya_tr_out=1'b1,joyb_tr_out=1'b1;
wire[7:0]joy[0:3];assign {joy[3],joy[2],joy[1],joy[0]}=players;
wire[6:0]USER_IN=physical;wire swap=0,gg_link=0,gun_en=0,gun_port=0,gun_sensor=0,gun_trigger=0,paddle_en=paddle_enabled;wire[6:0]gg_user_out=0;wire[3:0]paddle_0_nib=paddle_pins[3:0],paddle_1_nib=paddle_pins[8:5];wire paddle_0_tr=paddle_pins[4],paddle_1_tr=paddle_pins[9];
reg joyser_th,joya_th,joyb_th;reg[1:0]jcnt=0;
reg old_th;reg[15:0]tmr;wire ss_tap_set=ss_set,ss_tap_valid=ss_valid;wire[18:0]ss_tap_in=ss_in;
assign state={old_th,jcnt,tmr};
always @(posedge clk_sys) begin : protocol

if (!hold) begin
	if (raw_serial) begin
		joyser[3] <= USER_IN[1];//up
		joyser[2] <= USER_IN[0];//down
		joyser[1] <= USER_IN[5];//left
		joyser[0] <= USER_IN[3];//right
		joyser[4] <= USER_IN[2];//trigger / button1
		joyser[5] <= USER_IN[6];//button2
		joyser_th <= USER_IN[4];//sensor

		if (!ss_freeze) begin
			if (tmr) tmr <= tmr - 1'd1;
			if (!USER_IN[0] & !USER_IN[2] & !USER_IN[6] & pause_combo) begin //D 1 2 combo
				tmr <= T;
			end
		end
		joyser[6] <= !tmr;
		joyser[7] <= 1'b0;

		joya <= swap ? ~joy[1] : joyser;
		joyb <= swap ? joyser : ~joy[0];
		joya_th <=  swap ? 1'b1 : joyser_th;
		joyb_th <=  swap ? joyser_th : 1'b1;

		USER_OUT <= {swap ? joyb_tr_out : joya_tr_out, 1'b1, swap ? joyb_th_out : joya_th_out, 4'b1111 };

	end else begin
		joya <= ~joy[jcnt];
		joyb <= status[14] ? 8'hFF : ~joy[1];
		joya_th <=  1'b1;
		joyb_th <=  1'b1;

		if(ce_cpu && !ss_freeze) begin
			if(tmr > T) jcnt <= 0;
			else if(joya_th_out) tmr <= tmr + 1'd1;

			old_th <= joya_th_out;
			if(old_th & ~joya_th_out) begin
				tmr <= 0;
			//first clock doesn't count as capacitor has not discharged yet
			if(tmr < T) jcnt <= jcnt + 1'd1;
			end
		end

		if(reset_active | ~status[14]) jcnt <= 0;

		USER_OUT <= gg_link ? gg_user_out : 7'b1111111;
	end

	if(gun_en) begin
		if(gun_port) begin
			joyb_th <= ~gun_sensor;
			joyb <= {3'b111, ~gun_trigger ,4'b1111};
		end else begin
			joya_th <= ~gun_sensor;
			joya <= {3'b111, ~gun_trigger ,4'b1111};
			joyb <= raw_serial ? joyser : ~joy[0];
			joyb_th <= raw_serial ? joyser_th : 1'b1;
		end
	end

	if (paddle_en) begin
		{joya[0], joya[1], joya[2], joya[3], joya[5]} <= {paddle_0_nib, paddle_0_tr};
		{joyb[0], joyb[1], joyb[2], joyb[3], joyb[5]} <= {paddle_1_nib, paddle_1_tr};
	end
	// Restore after IO TH settles; pin caches reconstruct before release.
	if (ss_tap_set) begin
		if (ss_tap_valid) {old_th,jcnt,tmr} <= ss_tap_in;
		else begin
			jcnt <= 0;
			tmr <= (T+1);
			old_th <= joya_th_out;
		end
	end
end
end
endmodule
