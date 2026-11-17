// Focused G05 discriminator: legal CPU mode expansion can expose the saved
// blank row before a horizontal reset. All future controller input is aligned
// to the accepted logical boundary/release, never to transport wall time.
const fs=require('fs'),p=require('path'),d=p.join(__dirname,'mode_switch'),src=p.join(__dirname,'fixture');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
for(const f of ['vdp.vhd','vdp_main.vhd'])fs.copyFileSync(p.join(__dirname,'rich/rtl',f),p.join(d,'rtl',f));
let h=fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('ON_IO=0;','ON_IO=0;');fs.writeFileSync(p.join(d,'header.svh'),h);
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replaceAll('x>=REQUEST_X&&y==REQUEST_Y','x>=REQUEST_X&&x<256&&y==REQUEST_Y').replace('next_frame=frame+1','next_frame=frame').replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;');
s=s.replace('reg hl=0;','reg hl=0;reg future_input=0;');
s=s.replace('.DI(!ciq?vd:',".DI(!ciq?(ca[7:0]==8'hdc ? {7'd0,future_input}:vd):");
s=s.replace('$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);','$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);future_input=1;');
s=s.replace('  request(0);divs=0;guestdiv=0;','  future_input=0;request(0);future_input=1;divs=0;guestdiv=0;');
s=s.replaceAll('((y<((GG)?168:192)&&x<256)&&color!==pixels[j])','(!vb&&x>0&&x<=256&&color!==pixels[j])');
s=s.replace('$fatal(1,"integrated LOAD pixel mismatch x%0d y%0d dut%h ref%h",x,y,color,pixels[j]);','$display("G05_VISIBLE_PIXEL_DIVERGENCE pass%0d j%0d xy%0d,%0d dut%h ref%h mode%h CPU%h",pass,j,x,y,color,pixels[j],vdp_regs[12:0],z80_reg);');
// Characterize, do not waive: retain every visible mismatch and require positive
// guest display divergence for the diagnostic conclusion marker.
s=s.replace('reg scoring=0;','reg scoring=0;integer pixel_divs=0;');
s=s.replace('request(0);future_input=1;divs=0;guestdiv=0;','request(0);future_input=1;divs=0;guestdiv=0;pixel_divs=0;');
s=s.replace('   checks++;','   if(!vb&&x>0&&x<=256&&color!==pixels[j])pixel_divs++;\n   if(!vb&&x>0&&x<=256&&audit[63:32]!==audit_trace[j][63:32])$fatal(1,"mode-change background fetch/palette/priority mismatch");\n   checks++;');
s=s.replace('if(FIX&&(divs||guestdiv))$fatal(1,"protocol LOAD mismatch");','if(divs)$fatal(1,"unrelated collision mismatch");if(pixel_divs)$display("CONFIRMED_G05 visiblePixels%0d pass%0d",pixel_divs,pass);');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
let base=fs.readFileSync(p.join(src,'rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
// Entry JP 0100 avoids all interrupt vectors; initial DI and register setup
// copied unchanged. Original polling loop is replaced with controller wait.
let rom=new Array(65536).fill(0);rom[0]=0xc3;rom[1]=0;rom[2]=1;
for(let i=0;i<0x8b;i++)rom[0x100+i]=base[i];
let code=[0xdb,0xdc,0xe6,1,0x28,0xfa,0x3e,6,0xd3,0xbf,0x3e,0x80,0xd3,0xbf,0x3e,0x48,0xd3,0xbf,0x3e,0x81,0xd3,0xbf,0xdb,0xbf,0x32,0x00,0xc1,0xc3,0xa1,0x01];
for(let i=0;i<code.length;i++)rom[0x18b+i]=code[i];
for(const ref of [1,0]){let dir=p.join(d,ref?'reference':'dut');fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gGG=0 -gREQUEST_Y=192 -gSLOTS=8 -gREFERENCE=${ref} -gWARMUP=1 -gEXT_REFERENCE=1 -gSAMPLES=42000 -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Prepared natural CPU 192-to-240 expansion discriminator');

