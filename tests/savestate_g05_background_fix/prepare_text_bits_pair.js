// Natural positive collision candidate for the two unconsumed text-pattern
// bits. Both histories finish with identical VRAM and future inputs.
const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'prototype'),dst=p.join(d,'text_bits_pair');fs.mkdirSync(dst,{recursive:true});
for(const f of ['header.svh','vdp_tb.sv','compile.do','T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv'])fs.copyFileSync(p.join(src,f),p.join(dst,f));fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
let t=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8').replace("if(n>=14'h3800&&n<14'h3f00)pattern=n[0]?((n>>3)&31):((n>>1)*13)^(n>>5);","if(n>=14'h3800&&n<14'h3f00)pattern=0;");
if(!t.includes("if(n>=14'h3800&&n<14'h3f00)pattern=0;"))throw Error('name table anchor');
t=t.replace("ca[7:0]==8'hdd ? ((!history_done&&HISTORY)?8'd1:8'd0)","ca[7:0]==8'hdd ? ((!history_done&&HISTORY)?8'd3:8'd0)");
fs.writeFileSync(p.join(dst,'vdp_tb.sv'),t);
const original=fs.readFileSync(p.join(d,'baseline/dut_h0/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
let rom=Array(65536).fill(0),a=0x100;rom[0]=0xc3;rom[1]=0;rom[2]=1;for(let i=0x100;i<0x18b;i++)rom[a++]=original[i];
const emit=(...b)=>b.forEach(v=>rom[a++]=v),out=(val,r)=>emit(0x3e,val,0xd3,0xbf,0x3e,0x80|r,0xd3,0xbf);
out(0x50,1);let s=a;emit(0xdb,0xdc,0xe6,1,0x28,0);rom[a-1]=(s-a)&255;
emit(0xdb,0xdd,0x47); // B = past input 0 or3
emit(0x3e,0,0xd3,0xbf,0x3e,0x40,0xd3,0xbf); // VRAM write address0
const bytes=[];for(let row=0;row<8;row++){const value=((row*37)^(row>>3)^0xa7)&255;bytes.push(value);emit(0x3e,value&0xfc,0xb0,0xd3,0xbe);}
out(0,0); // enter text, glyph0 name table, font low bits depend on past input
s=a;emit(0xdb,0x7e,0xfe,190,0x20,0);rom[a-1]=(s-a)&255;
out(4,0); // ordinary mode holds the inactive text pattern indefinitely
emit(0x06,0,0x3e,0,0xd3,0xbf,0x3e,0x40,0xd3,0xbf);
for(const value of bytes)emit(0x3e,value,0xd3,0xbe); // identical final VRAM
const loop=a;emit(0xdb,0xbf,0x32,0,0xc1,0xc3,loop&255,loop>>8);
for(const hist of [0,1])for(const ref of [1,0]){const dir=p.join(dst,(ref?'reference_':'dut_')+'h'+hist);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=64 -gGG=0 -gREQUEST_Y=192 -gREQUEST_X=120 -gWARMUP=1 -gEXT_REFERENCE=1 -gHISTORY=${hist} -gREFERENCE=${ref} -gSPRITES=0 -gSAMPLES=42000 -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
fs.writeFileSync(p.join(dst,'program.json'),JSON.stringify({loop,end:a,commonFont:bytes},null,2));
