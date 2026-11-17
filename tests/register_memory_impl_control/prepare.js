// First and only implementation experiment: matched seed-2 physical synthesis EXTRA.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/register_memory_auto_seed2');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
assert(!fs.existsSync(p.join(d,'baseline')),'Never overwrite an attempted experiment');
const old=JSON.parse(fs.readFileSync(p.join(root,'tests/register_memory_timing/preservation_before.json'))),files={...old.files};
for(const [f,h]of Object.entries(files))assert.equal(hash(p.join(root,f)),h,'Prior evidence changed '+f);
for(const e of fs.readdirSync(p.join(root,'tests/register_memory_timing'),{withFileTypes:true}))if(e.isFile()){const f='tests/register_memory_timing/'+e.name;files[f]=hash(p.join(root,f));}
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:64*1024*1024});
for(const f of git('ls-files').toString().trim().split('\n'))if(fs.existsSync(p.join(root,f))&&fs.statSync(p.join(root,f)).isFile())files[f]=hash(p.join(root,f));
const preserved={files,refs:git('show-ref','--heads').toString(),status:git('status','--short').toString()};
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify(preserved,null,2)+'\n');
const m=JSON.parse(fs.readFileSync(p.join(prior,'input_manifest.json'))),inputs={};
for(const [f,h]of Object.entries(m.inputs)){if(f.startsWith('releases/'))continue;
 inputs[f]={};for(const v of ['baseline','candidate']){
  const source=p.join(prior,v,f);assert.equal(hash(source),h[v],source);let bytes=fs.readFileSync(source);
  if(f==='SMS.qsf'){let s=bytes.toString();assert(!/^set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT\s/m.test(s));assert(/^set_global_assignment -name SEED 2\r?$/m.test(s));s+='\n# Isolated implementation-control experiment, both matched seed-2 variants.\nset_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT EXTRA\n';bytes=Buffer.from(s);}
  const target=p.join(d,v,f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,bytes);inputs[f][v]=hash(target);
 }
}
assert.deepEqual(Object.keys(inputs).filter(f=>inputs[f].baseline!==inputs[f].candidate),['rtl/VM2413/registermemory.vhd']);
for(const v of ['baseline','candidate'])for(const f of ['build_id.v','jtag.cdf'])fs.copyFileSync(p.join(prior,v,f),p.join(d,v,f));
const manifest={...m,inputs,experiment:'PHYSICAL_SYNTHESIS_EFFORT NORMAL -> EXTRA, both variants',source:'../register_memory_auto_seed2/input_manifest.json',sourceSHA256:hash(p.join(prior,'input_manifest.json')),generated:Object.fromEntries(['build_id.v','jtag.cdf'].map(f=>[f,hash(p.join(d,'baseline',f))]))};
fs.writeFileSync(p.join(d,'input_manifest.json'),JSON.stringify(manifest,null,2)+'\n');
fs.copyFileSync(p.join(prior,'build.ps1'),p.join(d,'build.ps1'));
console.log({seed:2,files:Object.keys(inputs).length,onlyControl:'PHYSICAL_SYNTHESIS_EFFORT EXTRA in both QSF copies',protectedFiles:Object.keys(files).length,sourceDifference:['rtl/VM2413/registermemory.vhd'],databasesCopied:false});
