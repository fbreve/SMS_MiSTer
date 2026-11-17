const fs=require('fs'),p=require('path'),d=p.join(__dirname,'scan'),src=p.join(__dirname,'fixture');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
const start=s.indexOf(' while(!(frame>=1&&vb&&x>=REQUEST_X&&y==REQUEST_Y)))');
// Keep the real initialization, then replace only the experiment driver.
const a=s.indexOf(' while(!(frame>=1&&vb&&x>=REQUEST_X&&y==REQUEST_Y))tick;');
const b=s.indexOf('\ninitial begin #300000000;');if(a<0||b<0)throw Error('driver anchors');
s=s.slice(0,a)+`
 while(!vb)tick;
 repeat(200000)tick;
 if(boundaries<100||status_reads<10)$fatal(1,"insufficient natural scan");
 $display("PASS BOUNDARY_SCAN eligible%0d clear%0d incr%0d write%0d irqMismatch%0d statusReads%0d irqVectors%0d handler%0d phases%h",boundaries,pending_clear,pending_incr,pending_write,irq_bad,status_reads,vectors,ram[257],phase_mask);
 $finish;
end
`+s.slice(b);
s=s.replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;');
s=s.replace('integer boundaries=0,pending_clear=0,pending_incr=0,pending_write=0;','integer boundaries=0,pending_clear=0,pending_incr=0,pending_write=0,irq_bad=0,status_reads=0,vectors=0;reg[29:0]phase_mask=0;reg expected_irq;\nalways@(posedge clk)if(!setup)begin if(ce_vdp&&!ciq&&!crd&&ca[0])status_reads++;if(cpu_tick&&!cm1&&ca==16\'h0038)vectors++;end');
s=s.replace(' boundaries++;if(vdp_regs[103])',' expected_irq=!((vdp_regs[115]&&vdp_regs[8]||vdp_regs[116]&&vdp_regs[3])&&vdp_regs[114:112]==0);if(irq!==expected_irq)irq_bad++;phase_mask[clkd]=1;\n if(vdp_regs[103]||audit[2]||audit[3])$display("PENDING_ELIGIBLE cycle%0d xy%0d,%0d audit%h regs%h",cycle,x,y,audit,vdp_regs);\n boundaries++;if(vdp_regs[103])');
const decl=s.match(/integer boundaries=0[^\n]+/)[0];s=s.replace(decl,'').replace('initial begin\n $readmemh',decl+'\ninitial begin\n $readmemh');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
let base=fs.readFileSync(p.join(src,'rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
for(const[turbo,pal]of [[0,0],[1,0],[1,1]]){let rom=Array(65536).fill(0);rom[0]=0xc3;rom[1]=0;rom[2]=1;for(let i=0;i<0x8b;i++)rom[0x100+i]=base[i];let a=0x18b;const emit=(...b)=>b.forEach(x=>rom[a++]=x),out=(val,r)=>emit(0x3e,val,0xd3,0xbf,0x3e,0x80|r,0xd3,0xbf);out(0x14,0);out(0x60,1);out(0,10);emit(0xed,0x56,0xfb);let loop=a;emit(0xdb,0xbf,0x32,0,0xc1,0xc3,loop&255,loop>>8);rom[0x38]=0xc3;rom[0x39]=0;rom[0x3a]=3;const handler=[0xf5,0x3a,1,0xc1,0x3c,0x32,1,0xc1,0xdb,0xbf,0xf1,0xfb,0xed,0x4d];for(let i=0;i<handler.length;i++)rom[0x300+i]=handler[i];
let dir=p.join(d,`t${turbo}_p${pal}`);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gTURBO=${turbo} -gPAL=${pal} -gIRQ_ENABLE=1 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Natural status-IN/real IRQ handler accepted-boundary scans prepared');
