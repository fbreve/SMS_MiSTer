const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const manifest=[],sha=b=>crypto.createHash('sha256').update(b).digest('hex');
for(const [family,oldFamily,cases]of[
 ['phases','reg_g10',['dut_phases','dut_deterministic','dut_full_flush']],
 ['background','reg_g05',['dut_h0']],['dual','reg_dual',['dut_collision']],['pending','reg_g04',['dut_pending']]
]){
 const src=p.join(d,'../savestate_f01_opll_fix',oldFamily),dst=p.join(d,family);fs.mkdirSync(dst,{recursive:true});
 for(const f of fs.readdirSync(src))if(fs.statSync(p.join(src,f)).isFile()&&/\.(sv|svh|vhd|v|do|hex)$/.test(f))fs.copyFileSync(p.join(src,f),p.join(dst,f));
 fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
 cp.execFileSync('node',[p.join(d,'generate_receivers.js'),dst,dst],{cwd:root});
 fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(p.join(d,'candidate_A/rtl/savestates.sv')));
 let tb=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8'),header=fs.readFileSync(p.join(dst,'header.svh'),'utf8');
 const second=tb.includes('vdp2('),wires=`wire[7:0]sp_addr;wire sp_second,sp_read,sp_write;wire[31:0]sp_wdata,sp_data1,sp_data2;wire[31:0]sp_rdata=sp_second?sp_data2:sp_data1;\n`+(second?'':"assign sp_data2=32'd0;\n");
 assert(header.includes('savestates dut('));header=header.replace('savestates dut(',wires+`savestates dut(.sprite_state_addr(sp_addr),.sprite_state_second(sp_second),.sprite_state_read(sp_read),.sprite_state_write(sp_write),.sprite_state_wdata(sp_wdata),.sprite_state_rdata(sp_rdata),`);
 for(const id of (second?[1,2]:[1])){const select=id===1?'!sp_second':'sp_second';tb=tb.replace('vdp'+id+'(',`vdp${id}(.ss_state_addr(sp_addr),.ss_state_read(sp_read&&${select}),.ss_state_write(sp_write&&${select}),.ss_state_wdata(sp_wdata),.ss_state_rdata(sp_data${id}),`);}
 fs.writeFileSync(p.join(dst,'header.svh'),header);fs.writeFileSync(p.join(dst,'vdp_tb.sv'),tb);
 let compile=fs.readFileSync(p.join(dst,'compile.do'),'utf8').replace('vcom -work vdp_work -2008 -quiet','vcom -work vdp_work -2008 -quiet rtl/sprite_state_pkg.vhd').replace('savestates_sim.sv','../candidate_A/rtl/sprite_snapshot.sv savestates_sim.sv');fs.writeFileSync(p.join(dst,'compile.do'),compile);
 for(const name of cases){const from=p.join(src,name),out=p.join(dst,name),inputs={};fs.mkdirSync(out,{recursive:true});
  for(const f of fs.readdirSync(from))if(f==='run.do'||/\.(dat|hex)$/.test(f)){const b=fs.readFileSync(p.join(from,f));fs.writeFileSync(p.join(out,f),b);inputs[f]=sha(b);}
  manifest.push({family,name,inputs});
 }
}
fs.writeFileSync(p.join(d,'related_cases.json'),JSON.stringify(manifest,null,2));console.log('Prepared '+manifest.length+' phase/background/dual/pending scenarios.');
