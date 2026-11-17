`timescale 1ns/1ps
module direct_tb;
reg clk=0;always #5 clk=~clk;
reg freeze=0,setstate=0;reg[45:0]statein=0;wire[45:0]stateout;
reg[24:0]mouse=0;reg mousexy=0;reg[7:0]jx=8'h7f,jy=8'h7c;reg[11:0]joy=0;reg btn=0;reg[1:0]size=0;
integer h=0,v=0,div=0,i,k,checks=0;reg[31:0]rng=32'h12345678;
wire pix=div==9,hde=h<256,vde=v<192;wire s,bs,t,bt,tr,btr;
always@(negedge clk)begin div=div==9?0:div+1;if(div==0)begin h=h==341?0:h+1;if(h==0)v=v==261?0:v+1;end end
direct_gun dut(.CLK(clk),.RESET(1'b0),.SS_FREEZE(freeze),.SS_STATE_SET(setstate),.SS_STATE_VALID(1'b1),.SS_STATE_IN(statein),.SS_STATE_OUT(stateout),.MOUSE(mouse),.MOUSE_XY(mousexy),.JOY_X(jx),.JOY_Y(jy),.JOY(joy),.HDE(hde),.VDE(vde),.CE_PIX(pix),.BTN_MODE(btn),.SIZE(size),.SENSOR_DELAY(8'd34),.SENSOR(s),.TRIGGER(tr),.TARGET(t));
baseline_gun base(.CLK(clk),.RESET(1'b0),.MOUSE(mouse),.MOUSE_XY(mousexy),.JOY_X(jx),.JOY_Y(jy),.JOY(joy),.HDE(hde),.VDE(vde),.CE_PIX(pix),.BTN_MODE(btn),.SIZE(size),.SENSOR_DELAY(8'd34),.SENSOR(bs),.TRIGGER(btr),.TARGET(bt));
wire[45:0]basestate={base.beam.vcnt,base.beam.vtotal,base.beam.hde_d,base.beam.old_hde,base.offscreen,base.beam.sensor_pend,base.beam.sensor_time,bs};
wire[73:0]allstate={dut.hcnt,dut.vcnt,dut.vtotal,dut.hde_d,dut.old_hde,dut.old_vde,dut.x,dut.y,dut.offscreen,dut.sensor_pend,dut.sensor_time,s};
wire[73:0]baseall={base.beam.hcnt,base.beam.vcnt,base.beam.vtotal,base.beam.hde_d,base.beam.old_hde,base.beam.old_vde,base.x,base.y,base.offscreen,base.beam.sensor_pend,base.beam.sensor_time,bs};
task tick;begin @(posedge clk);#1;end endtask
reg[45:0]held;reg[73:0]heldall;reg[8:0]cursorx,cursory;integer tests=0;
initial begin
// Production baseline and candidate, identical host clocks and external inputs.
repeat(2800000)tick;
for(i=0;i<1000000;i=i+1)begin
 rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};
 if(i%29==0)begin jx=rng[7:0];jy=rng[15:8];joy=rng[27:16];btn=rng[28];size=rng[30:29];end
 if(i%1009==0)begin mousexy=rng[19];mouse={~mouse[24],rng[23:0]};end
 tick;
 if({stateout,s,t,tr,dut.lg_x,dut.lg_y,dut.beam.old_ms}!=={basestate,bs,bt,btr,base.lg_x,base.lg_y,base.beam.old_ms})$fatal(1,"ordinary cycle changed %0d",i);
 if(allstate!==baseall)$fatal(1,"ordinary temporal state changed");
 checks=checks+1;
end
// Legal saved pulse states, plus current aim/button/mouse changes while held.
for(k=0;k<8;k=k+1)begin
 freeze=1;mousexy=0;btn=0;joy=0;jx=8'h7d;jy=8'h7c;
 statein={9'd192,9'd191,16'd0,1'b0,1'b0,1'b0,(k[0]?8'd51:8'd255),k[0]};
 setstate=1;tick;setstate=0;tick;held=stateout;heldall=allstate;
 for(i=0;i<4000;i=i+1)begin
  if(i==100)begin joy[4]=1;jx=8'h00;jy=8'h80;end
  if(i==200)begin joy[4]=0;jx=8'h7d;jy=8'h7c;end
  if(i==300)begin mousexy=k[1];btn=k[1];mouse={1'b1,8'd0,8'd3,8'd1};end
  if(i==400)begin mouse[24]=0;mouse[0]=0;end
  if(i==500&&k[2])begin joy[4]=1;jx=8'h00;jy=8'h80;end
  tick;
  if(stateout!==held)$fatal(1,"temporal advance during freeze k%0d",k);
  if(allstate!==heldall)$fatal(1,"omitted temporal state advanced during freeze");
  if(tr!==(btn?mouse[0]:(joy[4]|joy[9])))$fatal(1,"current trigger frozen");
  if(dut.beam.old_ms!==mouse[24])$fatal(1,"host mouse strobe not consumed");
 end
 cursorx=dut.lg_x;cursory=dut.lg_y;
 if(mousexy)begin repeat(32)tick;if(dut.lg_x!==cursorx||dut.lg_y!==cursory)$fatal(1,"historical mouse event replayed");end
 freeze=0;tick;
 if(tr!==(btn?mouse[0]:(joy[4]|joy[9])))$fatal(1,"resume did not sample current button");
 tests=tests+1;
end
$display("PASS F11 ordinary baseline cycles=%0d external input cases=%0d held observations=32000",checks,tests);$finish;
end
initial begin #60000000;$fatal(1,"direct watchdog");end
endmodule
