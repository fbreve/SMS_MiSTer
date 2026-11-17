const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
assert(['FITS COMFORTABLY','FITS BUT REQUIRES CAUTION'].includes(require('./early_results.json').classification));
const rows=[];
for(const [source,ids]of[['modes',['gg_left_strong','gg_right_only','systeme_dual_decode','sms_normal_pending25']],['matrix',['pending_dual','pending_latency29']]]){
 const src=p.join(d,'../savestate_g08_release_fix',source),family='reg_audio_'+source,dst=p.join(d,family);fs.mkdirSync(dst,{recursive:true});
 for(const f of fs.readdirSync(src)){const q=p.join(src,f);if(fs.statSync(q).isFile()&&/\.(sv|svh|vhd|v|do|hex)$/.test(f))fs.copyFileSync(q,p.join(dst,f));}
 fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(p.join(root,'rtl/savestates.sv')));
 const file=p.join(dst,'audio_tb.sv');fs.writeFileSync(file,fs.readFileSync(file,'utf8').replace(/savestates\s+dut\s*\(/,"savestates dut(.fm_initialized(1'b1),.fm_state_rdata(32'd0),"));
 fs.writeFileSync(p.join(dst,'compile.do'),fs.readFileSync(p.join(dst,'compile.do'),'utf8').replace('savestates_sim.sv','../../../rtl/opll_snapshot.sv savestates_sim.sv'));
 for(const id of ids){const cd=p.join(dst,id);fs.mkdirSync(cd,{recursive:true});const files=[];
  for(const f of fs.readdirSync(p.join(src,id)))if(f==='replay.do'||/\.(dat|hex|bin)$/.test(f)){const b=fs.readFileSync(p.join(src,id,f));fs.writeFileSync(p.join(cd,f==='replay.do'?'run.do':f),b);files.push({file:f,sha256:crypto.createHash('sha256').update(b).digest('hex')});}
  if(!fs.existsSync(p.join(cd,'rom.hex')))fs.copyFileSync(p.join(src,'rom.hex'),p.join(cd,'rom.hex'));
  rows.push({family,name:id,library:'pause_work',marker:'PASS MATRIX',fixtures:files,covers:['G08.release','PSG']});
 }
}
fs.writeFileSync(p.join(d,'audio_regression_manifest.json'),JSON.stringify(rows,null,2));
const all=JSON.parse(fs.readFileSync(p.join(d,'regression_manifest.json')));fs.writeFileSync(p.join(d,'regression_manifest.json'),JSON.stringify([...all.filter(r=>!r.family.startsWith('reg_audio')), ...rows],null,2));
