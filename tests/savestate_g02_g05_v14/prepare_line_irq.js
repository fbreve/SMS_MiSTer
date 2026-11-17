const fs=require('fs'),p=require('path'),d=p.join(__dirname,'line_irq'),src=p.join(__dirname,'irq');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8').replace('next_frame=frame;','next_frame=frame+1;');
s=s.replace(' if(REFERENCE)begin $fclose(f);', ' if(REFERENCE&&ram[257]==0)$fatal(1,"no real line interrupt handler executed");\n if(REFERENCE)begin $fclose(f);');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
for(const ref of[1,0]){const name=(ref?'reference_':'dut_')+'active',dir=p.join(d,name);fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(src,(ref?'reference_':'dut_')+'t0/rom.hex'),p.join(dir,'rom.hex'));let run=fs.readFileSync(p.join(src,(ref?'reference_':'dut_')+'t0/run.do'),'utf8').replace(' -gSAMPLES=1000','').replace(' -gREPLAYS=3',' -gSAMPLES=5000 -gREPLAYS=3');fs.writeFileSync(p.join(dir,'run.do'),run);}
console.log('Full naturally executed frame before capture activates the line counter; 5000-pixel IRQ replay prepared');
