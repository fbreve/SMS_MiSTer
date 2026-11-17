const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),found=new Map;
function walk(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const f=p.join(dir,e.name);if(e.isDirectory()){if(!/^(db|incremental_db|work|pause_work|vdp_work)$/.test(e.name))walk(f);}else if(e.name==='replay.do')found.set(sha(fs.readFileSync(f)),f);}}
walk(p.join(d,'../savestate_g08_release_fix'));
const restored=[];for(const r of require('./regression_manifest.json'))for(const f of r.fixtures||[]){const to=p.join(d,r.family,r.name,f.file);if(!fs.existsSync(to)){assert.equal(f.file,'replay.do');const from=found.get(f.sha256);assert(from,'missing original '+f.sha256);fs.copyFileSync(from,to);restored.push({from,to,sha256:f.sha256});}}
fs.writeFileSync(p.join(d,'restored_manifest_scripts.json'),JSON.stringify(restored,null,2));console.log('Restored exact historical script bytes: '+restored.length);
