const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/phase_memory_auto');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const git=(...args)=>cp.execFileSync('git',args,{cwd:root,encoding:'utf8'}).trim();
const write=(f,v)=>fs.writeFileSync(p.join(d,f),JSON.stringify(v,null,2)+'\n');
assert(!fs.existsSync(p.join(d,'baseline')),'Never overwrite a prepared seed-2 pair');
assert.equal(git('branch','--show-current'),'experiment/phasememory-auto-inference');
assert.equal(git('rev-parse','HEAD'),'8443a0d19a88aff7a5900011bccf386daf146945');
const manifest=JSON.parse(fs.readFileSync(p.join(prior,'input_manifest.json')));
const functional=JSON.parse(fs.readFileSync(p.join(prior,'functional_results.json')));
assert(Object.values(functional.simulations).every(x=>x.pass),'Seed-1 functional qualification missing');
const preserved={};
function files(folder){return fs.readdirSync(folder,{withFileTypes:true}).flatMap(x=>x.isDirectory()?files(p.join(folder,x.name)):[p.join(folder,x.name)]);}
for(const f of fs.readdirSync(prior)){const file=p.join(prior,f);if(fs.statSync(file).isFile())preserved[p.relative(root,file).replaceAll('\\','/')]=hash(file);}
for(const variant of ['baseline','candidate'])for(const f of files(p.join(prior,variant,'output_files')).filter(x=>/\.(rpt|summary)$/.test(x)))preserved[p.relative(root,f).replaceAll('\\','/')]=hash(f);
const refs=Object.fromEntries(['master','investigate/cram-memory-inference','investigate/synthesis-structure','experiment/phasememory-auto-inference'].map(x=>[x,git('rev-parse',x)]));
write('preservation_before.json',{refs,files:preserved,productionPhaseSHA256:hash(p.join(root,'rtl/VM2413/phasememory.vhd')),initialStatus:git('status','--short'),initialDiff:git('diff','--','rtl/VM2413/phasememory.vhd')});
const inputs={};
for(const [file,h] of Object.entries(manifest.inputs)){if(file.startsWith('releases/'))continue;
 inputs[file]={};
 for(const variant of ['baseline','candidate']){
  const source=p.join(prior,variant,file);assert.equal(hash(source),h[variant],variant+'/'+file+' differs from qualified seed-1 source');
  let bytes=fs.readFileSync(source);
  if(file==='SMS.qsf'){
   let text=bytes.toString();assert.equal((text.match(/^set_global_assignment -name SEED 1\r?$/gm)||[]).length,1);
   bytes=Buffer.from(text.replace(/^set_global_assignment -name SEED 1(\r?)$/m,'set_global_assignment -name SEED 2$1'));
  }
  const dest=p.join(d,variant,file);fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,bytes);inputs[file][variant]=hash(dest);
 }
}
const generated={};for(const file of ['build_id.v','jtag.cdf']){
 generated[file]={};for(const variant of ['baseline','candidate']){fs.copyFileSync(p.join(prior,variant,file),p.join(d,variant,file));generated[file][variant]=hash(p.join(d,variant,file));}
 assert.equal(generated[file].baseline,generated[file].candidate);
}
assert.deepEqual(Object.keys(inputs).filter(k=>inputs[k].baseline!==inputs[k].candidate),['rtl/VM2413/phasememory.vhd']);
assert.equal(hash(p.join(root,'rtl/VM2413/phasememory.vhd')),inputs['rtl/VM2413/phasememory.vhd'].candidate);
write('input_manifest.json',{baseline:manifest.baseline,seed:2,buildDate:manifest.buildDate,source:'Qualified seed-1 exact source copies; only SMS.qsf SEED1→2 in both',inputs,generated,functionalEvidence:'../phase_memory_auto/functional_results.json',functionalEvidenceSHA256:hash(p.join(prior,'functional_results.json'))});
let build=fs.readFileSync(p.join(prior,'build.ps1'),'utf8');
build=build.replace("if(Get-Process quartus_map,quartus_fit,quartus_sta,quartus_asm -ErrorAction SilentlyContinue)","if(Get-Process quartus_map,quartus_fit,quartus_sta,quartus_asm -ErrorAction SilentlyContinue | Where-Object { -not $_.HasExited })");
fs.writeFileSync(p.join(d,'build.ps1'),build);
console.log(JSON.stringify({inputs:Object.keys(inputs).length,seed:2,buildDate:manifest.buildDate,sourceDelta:['rtl/VM2413/phasememory.vhd'],preserved:Object.keys(preserved).length,refs},null,2));
