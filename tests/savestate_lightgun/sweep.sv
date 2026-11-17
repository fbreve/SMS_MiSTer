`timescale 1ns/1ps
module sweep;parameter PX=255,PY=252,MODE=0;reg clk=0;always #5 clk=~clk;reg[4:0]div=0;reg ce_pix=0,ce_cpu=0;always@(negedge clk)begin ce_pix<=div==9||div==19||div==29;ce_cpu<=div==9||div==24;div<=div==29?0:div+1;end wire[21:0]state;wire[21:0]state_in=0;wire state_set=0;wire[8:0]x,y;wire hb,vb;parameter PAL=0,BORDER=0;
video live_video(.clk(clk),.ce_pix(ce_pix),.pal(PAL[0]),.border(BORDER[0]),.ggres(1'd0),.mask_column(1'd0),.cut_mask(1'd0),.smode_M1(MODE==1),.smode_M2(MODE!=0),.smode_M3(MODE==2),.smode_M4(1'b1),.video_state_out(state),.video_state_in(state_in),.video_state_set(state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
reg[7:0]jx=8'h7f,jy=8'h7c;wire sensor;gun_fixture gun(.CLK(clk),.hold(1'b0),.RESET(1'b0),.MOUSE(25'd0),.MOUSE_XY(1'b0),.JOY_X(jx),.JOY_Y(jy),.JOY(12'd0),.HDE(!hb),.VDE(!vb),.CE_PIX(ce_pix),.BTN_MODE(1'b0),.SIZE(2'd0),.SENSOR_DELAY(8'd34),.TARGET(),.SENSOR(sensor),.TRIGGER());integer frame=0,eligible=0,active=0,firstx=999,lastx=0,firsty=999,lasty=0,rises=0,falls=0,hderises=0,hdefalls=0;reg last_sensor=0,last_hde=0,eligible_sample;
always@(posedge vb)begin frame=frame+1;if(frame==3)begin jx=PX^128;jy=PY^128;end end
always@(posedge clk)begin
eligible_sample=frame==4&&ce_cpu&&vb&&x<256;#1;
if(frame==4)begin
if(sensor&&!last_sensor)rises=rises+1;if(!sensor&&last_sensor)falls=falls+1;
if(!hb&&!last_hde)hderises=hderises+1;if(hb&&last_hde)hdefalls=hdefalls+1;
end
if(eligible_sample)begin
eligible=eligible+1;
if(sensor)begin active=active+1;if(x<firstx)firstx=x;if(x>lastx)lastx=x;if(y<firsty)firsty=y;if(y>lasty)lasty=y;end
end
last_sensor=sensor;last_hde=!hb;
end
initial begin wait(frame==5);$display("PASS REACHABILITY PAL%0d BORDER%0d MODE%0d PX%0d PY%0d potentialCPUboundaries%0d sensorHigh%0d savedXrange%0d..%0d Yrange%0d..%0d sensorEdges%0d/%0d HDEedges%0d/%0d",PAL,BORDER,MODE,PX,PY,eligible,active,active?firstx:-1,active?lastx:-1,active?firsty:-1,active?lasty:-1,rises,falls,hderises,hdefalls);$finish;end
initial begin #90000000;$fatal(1,"sweep watchdog");end
endmodule
