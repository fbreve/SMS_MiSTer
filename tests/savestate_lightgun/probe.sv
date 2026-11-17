`timescale 1ns/1ps
module probe;reg clk=0;always #5 clk=~clk;reg[3:0]div=0;wire ce_pix=div==0;always@(negedge clk)div=div==9?0:div+1;wire[21:0]state;wire[21:0]state_in=0;wire state_set=0;wire[8:0]x,y;wire hb,vb;parameter PAL=0,BORDER=0;
video live_video(.clk(clk),.ce_pix(ce_pix),.pal(PAL[0]),.border(BORDER[0]),.ggres(1'd0),.mask_column(1'd0),.cut_mask(1'd0),.smode_M1(1'd0),.smode_M2(1'd0),.smode_M3(1'd0),.smode_M4(1'b1),.video_state_out(state),.video_state_in(state_in),.video_state_set(state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
wire sensor;gun_fixture gun(.CLK(clk),.hold(1'b0),.RESET(1'b0),.MOUSE(25'd0),.MOUSE_XY(1'b0),.JOY_X(8'h7f),.JOY_Y(8'h7c),.JOY(12'd0),.HDE(!hb),.VDE(!vb),.CE_PIX(ce_pix),.BTN_MODE(1'b0),.SIZE(2'd0),.SENSOR_DELAY(8'd34),.TARGET(),.SENSOR(sensor),.TRIGGER());integer frame=0;always@(posedge vb)begin frame=frame+1;$display("FRAME%0d xy%0d/%0d hcnt%0d vcnt%0d vtotal%0d point%0d/%0d sensor%b",frame,x,y,gun.beam.hcnt,gun.beam.vcnt,gun.beam.vtotal,gun.x,gun.y,sensor);end
initial begin wait(frame==3);wait(x==0);#1;$display("FIRST SAVE x%0d y%0d Sensor%b time%0d",x,y,sensor,gun.beam.sensor_time);$finish;end
initial begin #50000000;$fatal(1,"probe watchdog f%0d xy%0d/%0d",frame,x,y);end
endmodule
