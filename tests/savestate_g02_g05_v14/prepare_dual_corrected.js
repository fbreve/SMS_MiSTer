const fs=require('fs'),p=require('path'),d=p.join(__dirname,'dual_corrected'),src=p.join(__dirname,'dual');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let h=fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('ON_IO=0;','ON_IO=0,COLLISION_CASE=0;');fs.writeFileSync(p.join(d,'header.svh'),h);
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8').replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;').replace("8'd167","(COLLISION_CASE?8'd191:8'd167)");
s=s.replace("init_we?(init_d^8'h5a):vram2_WD",'init_we?pattern2(init_a%16384):vram2_WD');
s=s.replace('task request(input bit saveop);',`function[7:0]pattern2(input integer n);integer off;begin
 pattern2=pattern(n)^8'h5a;
 if(COLLISION_CASE)begin
  if(n>=14'h2000&&n<14'h2040)pattern2=n%4==1?8'hff:0;
  if(n>=14'h3f00&&n<14'h3f40)pattern2=n-14'h3f00<2?191:208;
  if(n>=14'h3f80&&n<16384)pattern2=n[0]?0:40;
 end
end endfunction
task request(input bit saveop);`);
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
for(const id of['bus','collision'])for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+id);fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(src,id==='bus'?'reference_bus/rom.hex':'reference_status/rom.hex'),p.join(dir,'rom.hex'));fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gGG=0 -gREQUEST_Y=192 -gWARMUP=1 -gEXT_REFERENCE=1 -gREFERENCE=${ref} -gCOLLISION_CASE=${id==='collision'?1:0} -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED -g/vdp_tb/vdp2/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Isolatable dual bus and independently timed dual collision fixtures prepared');
