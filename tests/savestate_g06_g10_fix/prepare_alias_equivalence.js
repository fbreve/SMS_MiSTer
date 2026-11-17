// Bridge the synthesis-language-only output alias correction to all prior runs.
const fs=require('fs'),p=require('path'),assert=require('assert'),here=__dirname,r=p.resolve(here,'../..'),d=p.join(here,'alias_equivalence');
const old=fs.readFileSync(p.join(d,'before.vhd'),'utf8'),current=fs.readFileSync(p.join(r,'rtl/vdp_sprites.vhd'),'utf8');
const strip=s=>s.replace(/--[^\n]*/g,'').replace(/\s/g,'');
const reversed=current.replace(/\tsignal color_reg : std_logic_vector\(3 downto 0\);\n\tsignal collide_reg, overflow_reg : std_logic;\n/,'').replace(' color <= color_reg;\n collide <= collide_reg;\n overflow <= overflow_reg;\n','').replaceAll('color_reg','color').replaceAll('collide_reg','collide').replaceAll('overflow_reg','overflow');
assert.equal(strip(reversed),strip(old),'Correction must be only register renaming and output aliases');
fs.writeFileSync(p.join(d,'old_sprites.vhd'),old.replaceAll('vdp_sprites','old_sprites'));
fs.writeFileSync(p.join(d,'new_sprites.vhd'),current);
fs.writeFileSync(p.join(d,'miter.sv'),`\
module miter;
reg clk=0;always #5 clk=~clk;
reg cv=0,cp=0,cs=0,sp64=0,tall=0,wide=0,shift=0,m1=0,m3=0,m4=1,set=0,valid=0;
reg[6:0]table_address=0;reg[2:0]high=0;reg[7:0]data=0;reg[8:0]x=0,y=0;
reg[4763:0]payload=0;wire[4763:0]a,b;wire[13:0]aa,ba;wire ac,bc,ao,bo;wire[3:0]acol,bcol;
old_sprites #(.MAX_SPPL(63)) old_inst(.clk_sys(clk),.ce_vdp(cv),.ce_pix(cp),.ce_sp(cs),.sp64(sp64),.table_address(table_address),.char_high_bits(high),.tall(tall),.wide(wide),.shift(shift),.smode_M1(m1),.smode_M3(m3),.smode_M4(m4),.vram_A(aa),.vram_D(data),.x(x),.y(y),.collide(ac),.overflow(ao),.color(acol),.ss_sprite_out(a),.ss_sprite_in(payload),.ss_sprite_valid(valid),.ss_regs_set(set));
vdp_sprites #(.MAX_SPPL(63)) new_inst(.clk_sys(clk),.ce_vdp(cv),.ce_pix(cp),.ce_sp(cs),.sp64(sp64),.table_address(table_address),.char_high_bits(high),.tall(tall),.wide(wide),.shift(shift),.smode_M1(m1),.smode_M3(m3),.smode_M4(m4),.vram_A(ba),.vram_D(data),.x(x),.y(y),.collide(bc),.overflow(bo),.color(bcol),.ss_sprite_out(b),.ss_sprite_in(payload),.ss_sprite_valid(valid),.ss_regs_set(set));
reg[31:0]rng=32'h9e3779b9;integer i,j;task randomize_word;begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};end endtask
initial begin
 for(i=0;i<50000;i=i+1)begin
  @(negedge clk);randomize_word();cv=i%5==0;cp=i%10==0;cs=i%2==0;
  if(cp)begin if(x==511)begin x=0;y=y+1;end else x=x+1;end
  // Frequent real restore strobes, random complete64-slot payloads, legacy
  // normalization and all input mode bits; no forcing internal registers.
  set=i%257==0;valid=rng[0];sp64=rng[1];tall=rng[2];wide=rng[3];shift=rng[4];m1=rng[5];m3=rng[6];m4=rng[7];
  table_address=rng[14:8];high=rng[17:15];data=aa[7:0]^rng[25:18];
  if(set)for(j=0;j<4764;j=j+1)begin randomize_word();payload[j]=rng[0];end
  @(posedge clk);#1;if({a,aa,ac,ao,acol}!=={b,ba,bc,bo,bcol})$fatal(1,"output alias mismatch clock%0d",i);
 end
 $display("PASS OUTPUT ALIAS EQUIVALENCE hostclocks50000 slots64 snapshotbits4764");$finish;
end
endmodule
`);
fs.writeFileSync(p.join(d,'run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib miter_work
vcom -work miter_work -2008 -quiet ../../../rtl/vdp_sprite_shifter.vhd new_sprites.vhd
vcom -work miter_work -2008 -quiet old_sprites.vhd
vlog -work miter_work -sv -quiet miter.sv
vsim -c -t 1ps miter_work.miter
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
console.log('PASS source-level exact rename proof; miter prepared');
