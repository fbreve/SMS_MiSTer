const fs=require('fs'),p=require('path'),d=p.join(__dirname,'dual_irq'),src=p.join(__dirname,'dual_corrected');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8').replace(".INT_n(IRQ_ENABLE?(irq&irq2):1'b1)",".INT_n(IRQ_ENABLE?irq2:1'b1)");
s=s.replace('next_frame=frame+1','next_frame=frame').replaceAll('x>=REQUEST_X&&y==REQUEST_Y','x>=REQUEST_X&&x<256&&y==REQUEST_Y');
s=s.replace(',rmem[0:SAMPLES-1]','').replace('reg scoring=0;','reg[15:0]rmem[0:SAMPLES-1];reg scoring=0;').replaceAll('ram[256]','{ram[258],ram[256]}');
s=s.replace(/\nendmodule\s*$/,`
integer independent_irq_clocks=0;
always@(posedge clk)if(!setup&&!frozen&&irq!==irq2)independent_irq_clocks++;
final $display("DUAL_INDEPENDENT_IRQ clocks%0d handlerRAM%h",independent_irq_clocks,ram[258]);
endmodule
`);fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
const base=fs.readFileSync(p.join(__dirname,'fixture/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));let rom=Array(65536).fill(0),a=0x100;rom[0]=0xc3;rom[1]=0;rom[2]=1;for(let i=0;i<40;i++)rom[a++]=base[i];const emit=(...b)=>b.forEach(x=>rom[a++]=x),out=(port,val)=>emit(0x3e,val,0xd3,port);
for(const port of[0xbb,0xbf]){for(const[r,val]of[[0,0x14],[1,0x60],[2,14],[3,255],[4,0],[5,126],[6,4],[7,port===0xbb?3:6],[8,port===0xbb?5:19],[9,port===0xbb?0:23],[10,0]]){out(port,val);out(port,0x80|r);}out(port,0);out(port,0xc0);out(port-1,0x53);out(port-1,7);}
emit(0xed,0x56,0xfb);const poll=a;emit(0xdb,0xbb,0x32,0,0xc1,0xdb,0xbf,0x32,1,0xc1,0xc3,poll&255,poll>>8);
rom[0x38]=0xc3;rom[0x39]=0;rom[0x3a]=3;const handler=[0xf5,0x3a,2,0xc1,0x3c,0x32,2,0xc1,0xdb,0xbf,0xf1,0xfb,0xed,0x4d];for(let i=0;i<handler.length;i++)rom[0x300+i]=handler[i];
if(a>=0x300)throw Error('program overlaps handler');
for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+'enabled');fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gGG=0 -gREQUEST_Y=192 -gREQUEST_X=80 -gWARMUP=1 -gEXT_REFERENCE=1 -gIRQ_ENABLE=1 -gREFERENCE=${ref} -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED -g/vdp_tb/vdp2/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Dual independent IRQ/status with actual System E VDP2-only CPU routing prepared');
