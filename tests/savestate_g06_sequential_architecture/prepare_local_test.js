const fs=require('fs'),p=require('path'),d=__dirname;
for(const f of ['vdp_sprites','vdp_sprite_shifter']){
 let s=fs.readFileSync(p.join(d,'baseline/rtl',f+'.vhd'),'utf8').replace(/\bvdp_sprites\b/g,'vdp_sprites_reference').replace(/\bvpd_sprite_shifter\b/g,'vpd_sprite_shifter_reference');
 fs.writeFileSync(p.join(d,f+'_reference.vhd'),s);
}
fs.writeFileSync(p.join(d,'local_compile.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib local_work
vcom -work local_work -2008 candidate_A/rtl/sprite_state_pkg.vhd candidate_A/rtl/vdp_sprite_shifter.vhd candidate_A/rtl/vdp_sprites.vhd vdp_sprite_shifter_reference.vhd vdp_sprites_reference.vhd
vlog -work local_work -sv candidate_A/rtl/sprite_snapshot.sv local_tb.sv
vsim -t 1ps -voptargs=+acc local_work.local_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
