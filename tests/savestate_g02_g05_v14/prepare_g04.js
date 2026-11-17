const fs=require('fs'),p=require('path'),d=p.join(__dirname,'g04'),src=p.join(__dirname,'fixture');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let h=fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('ON_IO=0;','ON_IO=0,NEAR=0;');fs.writeFileSync(p.join(d,'header.svh'),h);
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8').replaceAll('x>=REQUEST_X&&y==REQUEST_Y','x>=REQUEST_X&&x<256&&y==REQUEST_Y').replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;');
s=s.replace("pattern=n[0]?0:SPRITE_X;","pattern=n[0]?0:SPRITE_X+((NEAR&&((n-14'h3f80)/2)%2)?8:0);");
s=s.replace('ARM x%0d y%0d regs%h probe%h",x,y,vdp_regs,probe','ARM x%0d y%0d regs%h probe%h audit%h CPU%h",x,y,vdp_regs,probe,audit,z80_reg');
s=s.replace(/\nendmodule\s*$/,`
reg[229+136:0]q_sig[0:2];integer q_seen=0;
always@(posedge ss_freeze)if(!dut.do_save&&!warming)begin
 for(integer z=0;z<q_seen;z++)if(q_sig[z]==={z80_reg,vdp_regs})$fatal(1,"G04 perturbation histories converged");
 q_sig[q_seen]={z80_reg,vdp_regs};q_seen++;
 $display("G04_DISTINCT_Q index%0d CPU%h VDP%h",q_seen,z80_reg,vdp_regs);
end
endmodule
`);fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
const defs=[['pending64',{SLOTS:64,REQUEST_X:120}],['near',{REQUEST_X:120,NEAR:1}],['late',{REQUEST_X:248,SPRITE_X:248}],['overflow',{REQUEST_X:120,SPRITES:9}],['stalled',{REQUEST_X:120,STALL:1,TURBO:0}]];
let cases=[];for(const[id,opts]of defs){const cfg={SLOTS:8,GG:1,PAL:0,REQUEST_Y:168,REQUEST_X:120,SPRITE_X:120,SPRITES:2,REPLAYS:3,PROTO:1,TURBO:1,FIX:1,EXT_REFERENCE:1,WARMUP:1,...opts};for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+id);fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(src,'rom.hex'),p.join(dir,'rom.hex'));let args=Object.entries({...cfg,REFERENCE:ref}).map(([k,v])=>'-g'+k+'='+v).join(' ');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb ${args} -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}cases.push({id,cfg});}fs.writeFileSync(p.join(d,'cases.json'),JSON.stringify(cases,null,2));
console.log('Pending collision-delay / near / line-boundary / overflow / stalled G04 cases prepared');
