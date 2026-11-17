const fs=require('fs'),p=require('path'),d=p.join(__dirname,'ops'),src=p.join(__dirname,'bus');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
fs.writeFileSync(p.join(d,'header.svh'),fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('QUICK=0;','QUICK=0,TARGET_PC=0;'));
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replace('integer accepted_x,accepted_y;','integer accepted_x,accepted_y;reg[15:0]accepted_pc;').replace('accepted_x=x;accepted_y=y;','accepted_x=x;accepted_y=y;accepted_pc=ca;');
s=s.replace('if(ON_IO)begin while(ciq||((ON_IO==1)?crd:cwr))tick;end',`if(TARGET_PC)begin
  while(!(vb&&x<230&&z80_reg[79:64]==TARGET_PC&&!ciq&&(!crd||!cwr)))tick;
  $display("EARLIEST_IO_REQUEST nextPC%h xy%0d,%0d RD%b WR%b D%h audit%h reset%b phase%0d",z80_reg[79:64],x,y,crd,cwr,co,audit,vdp_regs[103],clkd);
 end
 if(ON_IO)begin while(ciq||((ON_IO==1)?crd:cwr))tick;end`);
s=s.replace('if(accepted_y!=REQUEST_Y)', 'if(TARGET_PC&&accepted_pc!=TARGET_PC)$fatal(1,"did not capture earliest intended fetch: actual%h target%h",accepted_pc,TARGET_PC);\n if(!TARGET_PC&&accepted_y!=REQUEST_Y)');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
const defs=[['write_address',0x208],['vram_write',0x20c],['partial_control',0x214],['read_setup',0x218],['first_read',0x21a],['next_read',0x21f],['cram_low',0x22e],['cram_high',0x232]];
for(const[id,target]of defs)for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+id);fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(src,'reference_normal/rom.hex'),p.join(dir,'rom.hex'));fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gQUICK=1 -gREQUEST_X=40 -gWARMUP=1 -gEXT_REFERENCE=1 -gREFERENCE=${ref} -gTARGET_PC=${target} -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
fs.writeFileSync(p.join(d,'cases.json'),JSON.stringify(defs.map(([id,target])=>({id,targetPC:target})),null,2));
console.log('Eight earliest post-transaction SAVE/LOAD cases prepared');
