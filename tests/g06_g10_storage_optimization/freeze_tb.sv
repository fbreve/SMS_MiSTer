// Baseline-only investigation probe. No replacement RTL or state forcing.
module freeze_tb;
reg clk=0;always #5 clk=~clk;
reg cv=0,cp=0,cs=0,set_regs=0;
reg sp64=0,tall=0,wide=0,shift=0,m1=0,m3=0,m4=1;
reg[8:0] x=0,y=223;
wire[13:0] a0,a1;
wire[4763:0] q0,q1;
wire[3:0] color0,color1;
wire coll0,coll1,ov0,ov1;
function[7:0] mem(input[13:0] a,input bit owner);
begin
 if(m4 && a[13:8]==6'h3f && !a[7])mem=8'd217;
 else if(!m4 && a[13:8]==6'h3f && a[1:0]==0)mem=8'd217;
 else mem=a[7:0]^(owner?8'hb5:8'h6a);
end endfunction
vdp_sprites #(.MAX_SPPL(63)) v0(.clk_sys(clk),.ce_vdp(cv),.ce_pix(cp),.ce_sp(cs),.sp64(sp64),.table_address(7'h7f),.char_high_bits(3'd3),.tall(tall),.wide(wide),.shift(shift),.smode_M1(m1),.smode_M3(m3),.smode_M4(m4),.vram_A(a0),.vram_D(mem(a0,0)),.x(x),.y(y),.collide(coll0),.overflow(ov0),.color(color0),.ss_sprite_out(q0),.ss_sprite_in(4764'd0),.ss_sprite_valid(1'b0),.ss_regs_set(set_regs));
vdp_sprites #(.MAX_SPPL(63)) v1(.clk_sys(clk),.ce_vdp(cv),.ce_pix(cp),.ce_sp(cs),.sp64(sp64),.table_address(7'h7f),.char_high_bits(3'd3),.tall(tall),.wide(wide),.shift(shift),.smode_M1(m1),.smode_M3(m3),.smode_M4(m4),.vram_A(a1),.vram_D(mem(a1,1)),.x(x),.y(y),.collide(coll1),.overflow(ov1),.color(color1),.ss_sprite_out(q1),.ss_sprite_in(4764'd0),.ss_sprite_valid(1'b0),.ss_regs_set(set_regs));
reg[4763:0] saved0,saved1;
integer holds=0,nonzero=0,distinct=0;
integer duration,phase;
initial begin
 repeat(2)@(negedge clk);
 for(integer mode=0;mode<16;mode++)begin
  {sp64,tall,wide,shift}=mode;m4=mode[0];m1=mode[1];m3=mode[2];
  // Legal legacy normalization, followed by ordinary evaluator execution.
  set_regs=1;@(negedge clk);set_regs=0;x=256;y=223;
  for(integer k=0;k<12000;k++)begin
   cv=(k%5==0);cp=(k%10==0);cs=(k%2==0);
   @(negedge clk);
   if(cp)begin if(x==511)begin x=0;y=y+1;end else x=x+1;end
  end
  // Four physical capture phase labels; no historical register is deposited.
  for(integer ph=0;ph<4;ph++)begin
   case(ph)0:phase=0;1:phase=10;2:phase=20;3:phase=25;endcase
   cv=0;cp=0;cs=0;set_regs=0;
   @(negedge clk);saved0=q0;saved1=q1;
   if($isunknown({saved0,saved1}))$fatal(1,"unknown baseline mode%0d",mode);
   if(saved0!=0)nonzero++;
   if(saved0!=saved1)distinct++;
   case(ph)0:duration=75;1:duration=4800;2:duration=50000;3:duration=150000;endcase
   for(integer k=0;k<duration;k++)begin
    // Raw presentation continues over scanner-start/stop boundaries.
    x=(k+phase)%512;y=192+((k/512)%64);
    @(negedge clk);
    if(q0!==saved0||q1!==saved1)$fatal(1,"frozen record changed mode%0d phase%0d k%0d",mode,phase,k);
    holds++;
   end
   $display("PASS FREEZE mode%0d phase%0d clocks%0d nonzero%b independent%b",mode,phase,duration,saved0!=0,saved0!=saved1);
  end
 end
 if(nonzero==0||distinct==0)$fatal(1,"degenerate fixture nonzero%0d distinct%0d",nonzero,distinct);
 $display("PASS FREEZE ALL checks%0d configurations64 nonzero%0d distinct%0d",holds,nonzero,distinct);$finish;
end
endmodule
