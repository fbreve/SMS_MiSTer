const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'../savestate_f01_opll_fix'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const rows=require('../savestate_f01_opll_fix/regression_manifest.json');
const ctrl=adapter('rtl/savestates.sv');
for(const family of new Set(rows.map(r=>r.family))){
 const from=p.join(src,family),to=p.join(d,family);fs.mkdirSync(to,{recursive:true});
 for(const file of fs.readdirSync(from))if(fs.statSync(p.join(from,file)).isFile()&&/\.(sv|svh|v|vhd|hex|do)$/.test(file)){
  let b=fs.readFileSync(p.join(from,file));if(/\.(sv|svh)$/.test(file))b=Buffer.from(b.toString().replaceAll("24'h484311","24'h484312"));fs.writeFileSync(p.join(to,file),b);
 }
 if(fs.existsSync(p.join(from,'rtl')))fs.cpSync(p.join(from,'rtl'),p.join(to,'rtl'),{recursive:true});
 for(const r of rows.filter(r=>r.family===family)){const dst=p.join(to,r.name);fs.mkdirSync(dst,{recursive:true});for(const f of fs.readdirSync(p.join(from,r.name)))if(/\.(do|dat|hex|bin)$/.test(f))fs.copyFileSync(p.join(from,r.name,f),p.join(dst,f));}
 fs.writeFileSync(p.join(to,family==='reg_g01'?'savestates_integrated.sv':'savestates_sim.sv'),ctrl.replace('900000','0'));
}
fs.writeFileSync(p.join(d,'regression_manifest.json'),JSON.stringify(rows,null,2));
fs.copyFileSync(p.join(d,'../savestate_format_consolidation/regress.ps1'),p.join(d,'regress.ps1'));
for(const family of ['format','imports']){
 const dst=p.join(d,family);fs.mkdirSync(dst,{recursive:true});
 for(const f of fs.readdirSync(p.join(src,family)))if(/\.(sv|do)$/.test(f))fs.copyFileSync(p.join(src,family,f),p.join(dst,f));
 fs.writeFileSync(p.join(dst,'savestates_sim.sv'),ctrl);
 const name=family==='format'?'format_tb.sv':'imports_tb.sv';let s=fs.readFileSync(p.join(dst,name),'utf8');
 s=s.replace("mem['h1a][63:40]!==24'h484311","mem['h1a][63:40]!==24'h484312").replace('assign replay=0;','assign replay=0;assign restart_out=0;');
 fs.writeFileSync(p.join(dst,name),s);
}
// Use actual F01 RTL and retained independent raw-FM oracles, no regenerated
// expectations. The former setup script changes only its source-root argument.
let script=fs.readFileSync(p.join(d,'../savestate_format_consolidation/prepare_f01.js'),'utf8').replace("p.join(d,'candidate/rtl/savestates.sv')","p.join(d,'../../rtl/savestates.sv')");
fs.writeFileSync(p.join(d,'prepare_f01.js'),script);
require('./prepare_f01.js');
console.log('Prepared '+rows.length+' inherited component regressions, format/imports, real F01 seeds1/10');
