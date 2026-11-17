const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex'),preserved={files:{},refs:cp.execFileSync('git',['show-ref','--heads'],{cwd:root,encoding:'utf8'})};
assert(!fs.existsSync(p.join(d,'scratch')),'Do not overwrite query copies');
function protect(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const f=p.join(dir,e.name);if(e.isDirectory()){if(e.name!=='worktree'&&!e.name.endsWith('_work'))protect(f);}else preserved.files[p.relative(root,f).replaceAll('\\','/')]=hash(f);}}
for(const dir of ['register_memory_auto','register_memory_auto_seed2','phase_memory_auto','phase_memory_auto_seed2'])protect(p.join(root,'tests',dir));
for(const file of ['rtl/VM2413/phasememory.vhd','tests/register_memory_auto/worktree/rtl/VM2413/registermemory.vhd'])preserved.files[file]=hash(p.join(root,file));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify(preserved,null,2)+'\n');
const provenance=[];
for(const [seed,folder]of [[1,'register_memory_auto'],[2,'register_memory_auto_seed2']]){
 const prior=p.join(root,'tests',folder),m=JSON.parse(fs.readFileSync(p.join(prior,'input_manifest.json')));
 for(const v of ['baseline','candidate']){
  const dest=p.join(d,'scratch','seed'+seed,v);fs.mkdirSync(dest,{recursive:true});
  for(const [f,h]of Object.entries(m.inputs)){if(f.startsWith('releases/'))continue;assert.equal(hash(p.join(prior,v,f)),h[v]);const target=p.join(dest,f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.copyFileSync(p.join(prior,v,f),target);}
  for(const f of ['build_id.v','jtag.cdf'])fs.copyFileSync(p.join(prior,v,f),p.join(dest,f));
  fs.cpSync(p.join(prior,v,'db'),p.join(dest,'db'),{recursive:true});fs.mkdirSync(p.join(dest,'output_files'));
  provenance.push({seed,variant:v,source:p.relative(root,p.join(prior,v)).replaceAll('\\','/'),copiedDatabase:true,sourceInputs:Object.keys(m.inputs).length});
 }
}
fs.writeFileSync(p.join(d,'provenance.json'),JSON.stringify(provenance,null,2)+'\n');console.log(provenance);
