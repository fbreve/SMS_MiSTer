const fs=require('fs'),p=require('path'),d=p.join(__dirname,'irq'),src=p.join(__dirname,'fixture');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replaceAll('x>=REQUEST_X&&y==REQUEST_Y','x>=REQUEST_X&&x<256&&y==REQUEST_Y').replace('next_frame=frame+1','next_frame=frame').replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;');
s=s.replace(',rmem[0:SAMPLES-1]','').replace('reg scoring=0;','reg[15:0]rmem[0:SAMPLES-1];reg scoring=0;').replaceAll('ram[256]','{ram[257],ram[256]}');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
for(const turbo of [0,1])for(const ref of [1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+'t'+turbo);fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(__dirname,`scan/t${turbo}_p0/rom.hex`),p.join(dir,'rom.hex'));fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gGG=1 -gREQUEST_Y=168 -gREQUEST_X=100 -gWARMUP=1 -gEXT_REFERENCE=1 -gREFERENCE=${ref} -gIRQ_ENABLE=1 -gTURBO=${turbo} -gON_IO=1 -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Real enabled IRQ / handler A+RAM / repeated-LOAD discriminators prepared');
