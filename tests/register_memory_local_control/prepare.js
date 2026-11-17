// Controlled localized experiment: QII_AUTO_PACKED_REGISTERS OFF on RegisterMemory:u_register_memory in Seed 2.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/register_memory_auto_seed2');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
assert(!fs.existsSync(p.join(d,'candidate')),'Never overwrite an attempted experiment');

// Verify prior test directories are untouched
const old=JSON.parse(fs.readFileSync(p.join(root,'tests/register_memory_impl_control/preservation_before.json')));
for(const [f,h]of Object.entries(old.files)){
  if(f.startsWith('tests/'))assert.equal(hash(p.join(root,f)),h,'Prior test evidence changed '+f);
}

const m=JSON.parse(fs.readFileSync(p.join(prior,'input_manifest.json'))),inputs={};
const qsfLine='\n# Localized RegisterMemory output register unpacking experiment (Seed 2)\nset_instance_assignment -name QII_AUTO_PACKED_REGISTERS OFF -to "emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory"\n';

for(const [f,h]of Object.entries(m.inputs)){
  const source=p.join(prior,'candidate',f);
  assert.equal(hash(source),h.candidate,source);
  let bytes=fs.readFileSync(source);
  if(f==='SMS.qsf'){
    let s=bytes.toString();
    assert(/^set_global_assignment -name SEED 2\r?$/m.test(s));
    s+=qsfLine;
    bytes=Buffer.from(s);
  }
  const target=p.join(d,'candidate',f);
  fs.mkdirSync(p.dirname(target),{recursive:true});
  fs.writeFileSync(target,bytes);
  inputs[f]={baseline:h.baseline,candidate:hash(target)};
}

for(const f of ['build_id.v','jtag.cdf']){
  fs.copyFileSync(p.join(prior,'candidate',f),p.join(d,'candidate',f));
}

// Apply exact same changes to the worktree on branch experiment/registermemory-local-control
const wt=p.join(d,'worktree');
fs.copyFileSync(p.join(d,'candidate/rtl/VM2413/registermemory.vhd'),p.join(wt,'rtl/VM2413/registermemory.vhd'));
const wtQsf=fs.readFileSync(p.join(wt,'SMS.qsf'),'utf8')+qsfLine;
fs.writeFileSync(p.join(wt,'SMS.qsf'),wtQsf);

const manifest={
  ...m,
  inputs,
  experiment:'QII_AUTO_PACKED_REGISTERS OFF on emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory (Seed 2)',
  source:'../register_memory_auto_seed2/input_manifest.json',
  sourceSHA256:hash(p.join(prior,'input_manifest.json'))
};
fs.writeFileSync(p.join(d,'input_manifest.json'),JSON.stringify(manifest,null,2)+'\n');
console.log({seed:2,files:Object.keys(inputs).length,experiment:manifest.experiment});
