module local_tb;
reg clk=0;always #5 clk=~clk;
reg cp=0,cv=0,cs=0,sp64=0,tall=0,wide=0,shift=0,m1=0,m3=0,m4=1;
reg[8:0]x=0,y=0;reg[7:0]vram=0;
wire[13:0]addr,refaddr;wire collide,overflow,refcollide,refoverflow;wire[3:0]color,refcolor;
wire[4763:0]record_out,refrecord;
reg[4763:0]saved=0;reg set_regs=0;
reg[7:0]sa=0;reg sr=0,sw=0;reg[31:0]sd=0;wire[31:0]sq;
wire[4799:0]padded={36'd0,saved};
vdp_sprites #(.MAX_SPPL(63),.SS_SEQUENTIAL(1)) dut(.clk_sys(clk),.ce_vdp(cv),.ce_pix(cp),.ce_sp(cs),.sp64(sp64),.table_address(7'h7f),.char_high_bits(3'd3),.tall(tall),.wide(wide),.shift(shift),.smode_M1(m1),.smode_M3(m3),.smode_M4(m4),.vram_A(addr),.vram_D(vram),.x(x),.y(y),.collide(collide),.overflow(overflow),.color(color),.ss_sprite_out(record_out),.ss_sprite_in(4764'd0),.ss_sprite_valid(1'b1),.ss_regs_set(set_regs),.ss_state_addr(sa),.ss_state_read(sr),.ss_state_write(sw),.ss_state_wdata(sd),.ss_state_rdata(sq));
vdp_sprites_reference #(.MAX_SPPL(63)) reference(.clk_sys(clk),.ce_vdp(cv),.ce_pix(cp),.ce_sp(cs),.sp64(sp64),.table_address(7'h7f),.char_high_bits(3'd3),.tall(tall),.wide(wide),.shift(shift),.smode_M1(m1),.smode_M3(m3),.smode_M4(m4),.vram_A(refaddr),.vram_D(vram),.x(x),.y(y),.collide(refcollide),.overflow(refoverflow),.color(refcolor),.ss_sprite_out(refrecord),.ss_sprite_in(saved),.ss_sprite_valid(1'b1),.ss_regs_set(set_regs));
reg[31:0]rng=32'h6e624eb7;
function[31:0]random32;begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};random32=rng;end endfunction
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
integer comparisons=0;
integer access_gap=0;
task compare;begin
if({record_out,addr,color,collide,overflow}!=={refrecord,refaddr,refcolor,refcollide,refoverflow})begin
 $display("LOCAL DEBUG addresses%h/%h fixed%h/%h",addr,refaddr,record_out[4763:4736],refrecord[4763:4736]);
 for(integer b=0;b<4764;b++)if(record_out[b]!==refrecord[b])begin $display("LOCAL DEBUG first bit%0d actual%b expected%b",b,record_out[b],refrecord[b]);break;end
 $fatal(1,"LOCAL equivalence check%0d beam%0d/%0d mode%b SP64%b",comparisons,x,y,m4,sp64);
end
comparisons++;
end endtask
task install;
begin
cp=0;cv=0;cs=0;sr=0;sw=0;
#1; // Let the independent expected-record concatenation settle before row0.
for(integer w=0;w<150;w++)begin sa=w;sd=padded[32*w+:32];sw=1;tick;sw=0;repeat(access_gap)tick;end
sw=0;set_regs=1;tick;set_regs=0;tick;compare;
for(integer w=0;w<150;w++)begin sa=w;sr=1;tick;if(sq!==padded[32*w+:32])$fatal(1,"LOCAL row%0d got%h expected%h",w,sq,padded[32*w+:32]);sr=0;repeat(access_gap)tick;end
sr=0;tick;
end endtask
initial begin
repeat(3)tick;
for(integer trial=0;trial<16;trial++)begin
 for(integer b=0;b<4764;b++)saved[b]=random32()&1;
 {sp64,tall,wide,shift}=trial;m4=trial[0];m1=trial[1];m3=trial[2];x=0;y=trial*13;access_gap=trial%3==0?0:trial%3==1?7:97;
 install;
 for(integer k=0;k<20000;k++)begin
  cv=k%5==0;cp=k%10==0;cs=k%2==0;
  vram=random32();
  tick;compare;
  if(cp)begin x=x+1;if(x==0)y=y+1;end
  if(k==10000)m4=~m4;
 end
 $display("PASS LOCAL trial%0d guest20000 full4764bits",trial);
end
$display("PASS LOCAL ALL trials16 checks%0d",comparisons);$finish;
end
endmodule
