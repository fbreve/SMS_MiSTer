const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),src=p.join(d,'../savestate_f01_opll_fix/reg_sprites'),dst=p.join(d,'sprites'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
fs.mkdirSync(dst,{recursive:true});
for(const f of fs.readdirSync(src))if(fs.statSync(p.join(src,f)).isFile()&&/\.(sv|svh|vhd|v|do|hex)$/.test(f))fs.copyFileSync(p.join(src,f),p.join(dst,f));
fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
cp.execFileSync('node',[p.join(d,'generate_receivers.js'),dst,dst],{cwd:root});
fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(p.join(d,'candidate_A/rtl/savestates.sv')));
let tb=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8');
const wires=`wire[7:0]sp_addr;wire sp_second,sp_read,sp_write;wire[31:0]sp_wdata,sp_rdata;\n`;
let header=fs.readFileSync(p.join(dst,'header.svh'),'utf8');
assert(header.includes('savestates dut('));header=header.replace('savestates dut(',wires+`savestates dut(.sprite_state_addr(sp_addr),.sprite_state_second(sp_second),.sprite_state_read(sp_read),.sprite_state_write(sp_write),.sprite_state_wdata(sp_wdata),.sprite_state_rdata(sp_rdata),`);
fs.writeFileSync(p.join(dst,'header.svh'),header);
assert(tb.includes('vdp1('));tb=tb.replace('vdp1(',`vdp1(.ss_state_addr(sp_addr),.ss_state_read(sp_read&&!sp_second),.ss_state_write(sp_write&&!sp_second),.ss_state_wdata(sp_wdata),.ss_state_rdata(sp_rdata),`);
fs.writeFileSync(p.join(dst,'vdp_tb.sv'),tb);
let compile=fs.readFileSync(p.join(dst,'compile.do'),'utf8').replace('vcom -work vdp_work -2008 -quiet','vcom -work vdp_work -2008 -quiet rtl/sprite_state_pkg.vhd').replace('savestates_sim.sv','../candidate_A/rtl/sprite_snapshot.sv savestates_sim.sv');fs.writeFileSync(p.join(dst,'compile.do'),compile);
const cases=require('../savestate_sprite_resource_optimization/sprites/cases.json'),manifest=[];
for(const c of cases){const name='dut_'+c.id,old=p.join(d,'../savestate_sprite_resource_optimization/sprites',name),out=p.join(dst,name);fs.mkdirSync(out,{recursive:true});const inputs={};
 for(const f of fs.readdirSync(old))if(f==='run.do'||/\.(dat|hex)$/.test(f)){const b=fs.readFileSync(p.join(old,f));fs.writeFileSync(p.join(out,f),b);inputs[f]=sha(b);}
 manifest.push({family:'sprites',name,args:c.cfg,inputs});
}
fs.writeFileSync(p.join(d,'sprite_cases.json'),JSON.stringify(manifest,null,2));console.log('Prepared '+cases.length+' actual VDP scenarios with unchanged retained ROM/oracles.');
