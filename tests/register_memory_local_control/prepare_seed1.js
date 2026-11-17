// Prepare Seed 1 build for the same localized RegisterMemory QSF directive: QII_AUTO_PACKED_REGISTERS OFF on RegisterMemory:u_register_memory
const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),prior=p.join(root,'tests/register_memory_auto');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
assert(!fs.existsSync(p.join(d,'candidate_seed1')),'Never overwrite an attempted experiment');

const m=JSON.parse(fs.readFileSync(p.join(prior,'input_manifest.json'))),inputs={};
const qsfLine='\n# Localized RegisterMemory output register unpacking experiment (Seed 1)\nset_instance_assignment -name QII_AUTO_PACKED_REGISTERS OFF -to "emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory"\n';

for(const [f,h]of Object.entries(m.inputs)){if(f.startsWith('releases/'))continue;
  const source=p.join(prior,'candidate',f);
  assert.equal(hash(source),h.candidate,source);
  let bytes=fs.readFileSync(source);
  if(f==='SMS.qsf'){
    let s=bytes.toString();
    assert(/^set_global_assignment -name SEED 1\r?$/m.test(s));
    s+=qsfLine;
    bytes=Buffer.from(s);
  }
  const target=p.join(d,'candidate_seed1',f);
  fs.mkdirSync(p.dirname(target),{recursive:true});
  fs.writeFileSync(target,bytes);
  inputs[f]={baseline:h.baseline,candidate:hash(target)};
}

for(const f of ['build_id.v','jtag.cdf']){
  fs.copyFileSync(p.join(prior,'candidate',f),p.join(d,'candidate_seed1',f));
}

fs.writeFileSync(p.join(d,'input_manifest_seed1.json'),JSON.stringify({...m,inputs,experiment:'QII_AUTO_PACKED_REGISTERS OFF on emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory (Seed 1)'},null,2)+'\n');
console.log({seed:1,files:Object.keys(inputs).length});

