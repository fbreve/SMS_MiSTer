const fs=require('fs'),p=require('path'),d=p.join(__dirname,'pair'),src=p.join(__dirname,'fixture');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let h=fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('ON_IO=0;','ON_IO=0,HISTORY=0;');fs.writeFileSync(p.join(d,'header.svh'),h);
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replace('reg hl=0;','reg hl=0;reg history_done=0;');s=s.replace('.DI(!ciq?vd:',".DI(!ciq?(ca[7:0]==8'hdc ? (history_done?8'd0:(HISTORY?8'hc3:8'h03)):vd):");
s=s.replaceAll('x>=REQUEST_X&&y==REQUEST_Y','x>=REQUEST_X&&x<256&&y==REQUEST_Y').replace('next_frame=frame+1','next_frame=frame');
s=s.replace('$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);','$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);history_done=1;');
s=s.replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;');
s=s.replace('ARM x%0d y%0d regs%h probe%h",x,y,vdp_regs,probe','ARM x%0d y%0d regs%h probe%h audit%h",x,y,vdp_regs,probe,audit');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
let rom=fs.readFileSync(p.join(src,'rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
let a=0x8b;const emit=(...b)=>b.forEach(x=>rom[a++]=x),out=(port,val)=>emit(0x3e,val,0xd3,port);
out(0xbf,1);out(0xbf,0xc0);emit(0xdb,0xdc,0xd3,0xbe);
out(0xbf,0x3c);out(0xbf,1);emit(0xdb,0xbe,0xdb,0xbe,0xaf);let loop=a;emit(0xdb,0xbf,0x32,0,0xc1,0xc3,0x8b,0);
for(const hist of [0,1])for(const ref of [1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+'h'+hist);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=64 -gGG=0 -gREQUEST_Y=192 -gREQUEST_X=200 -gWARMUP=1 -gEXT_REFERENCE=1 -gHISTORY=${hist} -gREFERENCE=${ref} -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Natural SMS CRAM upper-bit-alias G03 full-image candidate prepared');

