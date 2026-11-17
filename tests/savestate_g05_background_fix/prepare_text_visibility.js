// Real-CPU mode change while registered GG VBlank is still asserted.
const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'prototype'),name=process.argv[2]||'text_visibility',dst=p.join(d,name);fs.mkdirSync(dst,{recursive:true});
for(const f of ['header.svh','vdp_tb.sv','compile.do','T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv'])fs.copyFileSync(p.join(src,f),p.join(dst,f));fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
let t=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8').replaceAll('!vb&&x>0&&x<=256','y<192&&x>0&&x<=256');
t=t.replace('if(accepted_y!=REQUEST_Y)',`if(!vdp_regs[9]||vdp_regs[6]||vdp_regs[5]||y!=30||!vb)$fatal(1,"did not reach visible-text/registered-blank boundary");
 if(accepted_y!=REQUEST_Y)`);
fs.writeFileSync(p.join(dst,'vdp_tb.sv'),t);
const original=fs.readFileSync(p.join(d,'baseline/dut_h0/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
let rom=Array(65536).fill(0),a=0x100;rom[0]=0xc3;rom[1]=0;rom[2]=1;for(let i=0x100;i<0x18b;i++)rom[a++]=original[i];
// The copied initialization's R0/R1 become a GG224 viewport (blank until40).
for(const [r,val] of [[0,6],[1,0x50],...(name==='text_visible_fg'?[[7,0xf3]]:[])]){let found=false;for(let i=0x100;i<0x18b;i++)if(rom[i]===0x3e&&rom[i+2]===0xd3&&rom[i+3]===0xbf&&rom[i+4]===0x3e&&rom[i+5]===(0x80|r)){rom[i+1]=val;found=true;break;}if(!found)throw Error('R'+r);}
const emit=(...b)=>b.forEach(v=>rom[a++]=v),waitLoop=bytes=>{const s=a;emit(...bytes,0x20,0);rom[a-1]=(s-a)&255;};
let s=a;emit(0xdb,0xdc,0xe6,1,0x28,0);rom[a-1]=(s-a)&255;
waitLoop([0xdb,0x7e,0xfe,29]);
emit(0x3e,0,0xd3,0xbf,0x3e,0x80,0xd3,0xbf); // raw text, moves blank end40->24 after24 passed
const loop=a;emit(0xdb,0xbf,0x32,0,0xc1,0xc3,loop&255,loop>>8);
for(const [name,ref,omit]of [['reference_early',1,0],['dut_early',0,0],['dut_omit3',0,3]]){let dir=p.join(dst,name);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gGG=1 -gREQUEST_Y=30 -gREQUEST_X=80 -gWARMUP=1 -gEXT_REFERENCE=1 -gHISTORY=0 -gREFERENCE=${ref} -gSPRITES=0 -gSAMPLES=2000 -gREPLAYS=3 -gPROTOTYPE_OMIT=${omit} -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
fs.writeFileSync(p.join(dst,'program.json'),JSON.stringify({loop,end:a},null,2));
