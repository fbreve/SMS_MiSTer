const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');
const root=__dirname,reference=p.join(root,'physical_seed1'),original=JSON.parse(fs.readFileSync(p.join(reference,'inputs.json')));
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
for(const seed of [2,3]) {
 const dest=p.join(root,'physical_seed'+seed);assert(!fs.existsSync(dest),'Refuse existing seed directory');fs.mkdirSync(dest);
 const m=JSON.parse(JSON.stringify(original));m.seed=seed;m.seed1InputsSHA256=hash(fs.readFileSync(p.join(reference,'inputs.json')));m.seedStudyPolicy='Exact frozen Seed 1 inputs; sole input change is QSF SEED assignment. No RTL or test edits.';
 for(const v of ['baseline','candidate'])for(const [file,info]of Object.entries(m.builds[v].inputs)) {if(file.startsWith('releases/'))continue;
  let bytes=fs.readFileSync(p.join(reference,v,file));assert.equal(hash(bytes),info.SHA256,'Seed 1 input changed: '+v+'/'+file);
  if(file==='SMS.qsf'){const text=bytes.toString();assert.equal((text.match(/set_global_assignment -name SEED 1/g)||[]).length,1);bytes=Buffer.from(text.replace('set_global_assignment -name SEED 1','set_global_assignment -name SEED '+seed));info.seed1SHA256=info.SHA256;info.SHA256=hash(bytes);info.seedOverride=seed;}
  const target=p.join(dest,v,file);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,bytes);
 }
 fs.writeFileSync(p.join(dest,'inputs.json'),JSON.stringify(m,null,2)+'\n');
 for(const script of ['build.ps1','query.ps1','check_inputs.js','report_hashes.js','settings.tcl','paths.tcl','collect.js']) {
  let text=fs.readFileSync(p.join(reference,script),'utf8');if(script==='collect.js')text=text.replace('seed:1,buildDate:','seed:inputs.seed,buildDate:').replace("m.actualSeed[1]==='1','Not Seed 1 '","m.actualSeed[1]===String(inputs.seed),'Wrong actual seed '");fs.writeFileSync(p.join(dest,script),text);
 }
 console.log('Prepared isolated seed '+seed+'; only frozen input delta: SMS.qsf SEED');
}
