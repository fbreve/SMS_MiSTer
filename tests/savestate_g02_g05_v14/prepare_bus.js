const fs=require('fs'),p=require('path'),d=p.join(__dirname,'bus'),src=p.join(__dirname,'fixture');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
fs.writeFileSync(p.join(d,'header.svh'),fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('ON_IO=0;','ON_IO=0,QUICK=0;'));
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8').replace('next_frame=frame+1','next_frame=frame+(QUICK?0:1)').replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;');
// For the exact failed pilot, retain original request timing and full warmup.
// Quick clone/stall cases use the same P as one another and a current-window
// request after legal legacy normalization; idle settlement is explicit.
s=s.replaceAll('x>=REQUEST_X&&y==REQUEST_Y','x>=REQUEST_X&&(!QUICK||x<256)&&y==REQUEST_Y');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
let cases=[];for(const id of ['normal','clone','stalled']){let cfg={SLOTS:id==='normal'?64:8,QUICK:id==='normal'?0:1,TURBO:id==='normal'?0:1,CLONE:id==='normal'?0:1,STALL:id==='stalled'?1:0};for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+id);fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(src,'dut_bus_normal/rom.hex'),p.join(dir,'rom.hex'));let args=Object.entries(cfg).map(([k,v])=>'-g'+k+'='+v).join(' ');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb ${args} -gREFERENCE=${ref} -gWARMUP=1 -gEXT_REFERENCE=1 -gON_IO=2 -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}cases.push({id,cfg});}fs.writeFileSync(p.join(d,'cases.json'),JSON.stringify(cases,null,2));
console.log('Correctable exact original bus pilot plus clone/stall pair prepared');
