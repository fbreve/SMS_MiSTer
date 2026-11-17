const fs=require('fs'),p=require('path'),d=__dirname;
const src=p.join(d,'reg_g10'),dst=p.join(d,'reg_g10_full');fs.mkdirSync(dst,{recursive:true});
for(const f of fs.readdirSync(src))if(fs.statSync(p.join(src,f)).isFile()&&/\.(sv|vhd|do)$/.test(f))fs.copyFileSync(p.join(src,f),p.join(dst,f));
fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
let c=fs.readFileSync(p.join(dst,'savestates_sim.sv'),'utf8');c=c.replace('(TB_FAST?20\'d0:20\'d0)',"(TB_FAST?20'd0:20'd900000)");
if(!c.includes("20'd900000"))throw Error('production flush missing');fs.writeFileSync(p.join(dst,'savestates_sim.sv'),c);
const out=p.join(dst,'dut_full_flush');fs.mkdirSync(out,{recursive:true});for(const f of fs.readdirSync(p.join(src,'dut_full_flush')))if(/\.(do|dat|hex)$/.test(f))fs.copyFileSync(p.join(src,'dut_full_flush',f),p.join(out,f));
