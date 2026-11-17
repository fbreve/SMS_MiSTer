`timescale 1ns/1ps
module miter;
reg clk=0;always #5 clk=~clk;
reg rc=0,dc=0,rrst=0,drst=0,valid=0;
reg[8:0] sx=0,sy=0;
reg[3:0] name_base=14,fg=15,over=3;
reg[2:0] pt=0;reg[7:0] ct=255,scroll=5;
reg disable_scroll=0,m1=0,m2=0,m3=0,m4=1,quirk=0,extnt=0;
wire sm1=m1&m2,sm3=m3&m2;
wire[13:0]ra,da;reg[7:0]rd,dd;wire[4:0]rcolor,dcolor;wire rp,dp;
wire[138:0]rs,ds;reg[138:0]snapshot;
reg[7:0]salt=0;reg[31:0]rng=32'h91ad7c25;
function[7:0]pattern(input[13:0]a);pattern=((a*37)^(a>>3)^salt^8'ha7)&255;endfunction
always@(posedge clk)begin rd<=pattern(ra);dd<=pattern(da);end
vdp_background refbg(.clk_sys(clk),.ce_pix(rc),.reset(sx==488),.screen_x(sx),.screen_y(sy),.table_address(name_base),.pt_address(pt),.ct_address(ct),.scroll_x_latched(scroll),.disable_hscroll(disable_scroll),.mode_M1_raw(m1),.mode_M2_raw(m2),.mode_M3_raw(m3),.smode_M1(sm1),.smode_M3(sm3),.smode_M4(m4),.ysj_quirk(quirk),.legacy_ext_nt(extnt),.y(sy[7:0]),.text_fg_color(fg),.overscan(over),.ss_restore(rrst),.ss_bg_out(rs),.ss_bg_in(139'd0),.ss_bg_valid(1'b0),.vram_A(ra),.vram_D(rd),.color(rcolor),.\priority (rp));
vdp_background dutbg(.clk_sys(clk),.ce_pix(dc),.reset(sx==488),.screen_x(sx),.screen_y(sy),.table_address(name_base),.pt_address(pt),.ct_address(ct),.scroll_x_latched(scroll),.disable_hscroll(disable_scroll),.mode_M1_raw(m1),.mode_M2_raw(m2),.mode_M3_raw(m3),.smode_M1(sm1),.smode_M3(sm3),.smode_M4(m4),.ysj_quirk(quirk),.legacy_ext_nt(extnt),.y(sy[7:0]),.text_fg_color(fg),.overscan(over),.ss_restore(drst),.ss_bg_out(ds),.ss_bg_in(snapshot),.ss_bg_valid(valid),.vram_A(da),.vram_D(dd),.color(dcolor),.\priority (dp));
task host;begin @(negedge clk);#1;end endtask
task advance;begin if(sx==511)begin sx=0;sy=sy+1;end else sx=sx+1;end endtask
task random_controls;begin
 rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};
 {m4,m3,m2,m1}=rng[3:0];scroll=rng[15:8];name_base=rng[7:4];pt=rng[18:16];ct=rng[31:24];fg=rng[23:20];over=rng[27:24];disable_scroll=rng[19];quirk=rng[28];extnt=rng[29];
end endtask
integer comparisons=0,cases=0;reg[239:0]positions_seen=0;
task pixel(input bit refenable,input bit check);begin
 host;rc=refenable;dc=1;@(posedge clk);#1;
 if(check)begin
  if($isunknown({rs,ds,ra,da,rcolor,dcolor,rp,dp}))$fatal(1,"unknown component state");
  if(rs!==ds||{ra,rcolor,rp}!=={da,dcolor,dp})$fatal(1,"139-bit sufficiency mismatch case%0d xy%0d,%0d R%h D%h",cases,sx,sy,rs,ds);
  if(rs[22:15]>=240)$fatal(1,"semantic text position out of range");positions_seen[rs[22:15]]=1;comparisons++;
 end
 host;rc=0;dc=0;repeat(8)host;advance;
end endtask
initial begin
 snapshot=0;repeat(3)host;rrst=1;drst=1;host;rrst=0;drst=0;
 // Legal reset initializes both modules; then naturally execute shared P.
 repeat(3000)pixel(1,1);
 {m4,m3,m2,m1}=4'b0001;repeat(1024)pixel(1,1);
 for(cases=0;cases<128;cases++)begin
  for(integer k=0;k<80+(cases%173);k++)begin if(k%23==0)random_controls;pixel(1,1);end
  while(sx>256)pixel(1,1);
  begin reg[8:0] oldx,oldy;reg[47:0] inputs_saved;
   snapshot=rs;oldx=sx;oldy=sy;inputs_saved={name_base,pt,ct,scroll,disable_scroll,m1,m2,m3,m4,quirk,extnt,fg,over,salt};
   // Distinct Q advances only DUT, with changed input registers and RAM bytes.
   for(integer k=0;k<50+(cases%67);k++)begin if(k%17==0)begin random_controls;salt=rng[23:16];end pixel(0,0);end
   sx=oldx;sy=oldy;{name_base,pt,ct,scroll,disable_scroll,m1,m2,m3,m4,quirk,extnt,fg,over,salt}=inputs_saved;
   host;valid=1;drst=1;host;drst=0;valid=0;repeat(10)host;
   if(rs!==ds)$fatal(1,"encoding is not sufficient immediately after restore");
   for(integer k=0;k<1024;k++)begin if(k%37==0)random_controls;pixel(1,1);end
  end
 end
 // All240 encoded positions are reached by normal text progression, then
 // independently restored after a distinct naturally clocked DUT history.
 {m4,m3,m2,m1}=4'b0001;
 for(integer target=0;target<240;target++)begin
  reg[8:0]oldx,oldy;reg[7:0]old_salt;
  while(rs[22:15]!=target)pixel(1,1);
  snapshot=rs;oldx=sx;oldy=sy;old_salt=salt;salt=salt^8'ha5;
  repeat(20)pixel(0,0);
  sx=oldx;sy=oldy;salt=old_salt;host;valid=1;drst=1;host;drst=0;valid=0;repeat(10)host;
  repeat(16)pixel(1,1);
 end
 if(!(&positions_seen))$fatal(1,"did not exercise every semantic text position");
 $display("PASS BG139_MITER cases%0d exactPixelStates%0d semanticPositions240 restoresAll240 omittedTextPatternBits2",cases+240,comparisons);$finish;
end
initial begin #100000000;$fatal(1,"component watchdog");end
endmodule
