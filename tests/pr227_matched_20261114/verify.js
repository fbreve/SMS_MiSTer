const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const out=__dirname,root=path.resolve(out,'../..'),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const result={time:new Date().toISOString(),preservationChanges:[],inputChanges:[],sharedConfigurationDifferences:[],toolHashes:{}};
const before=JSON.parse(fs.readFileSync(path.join(out,'preservation_before.json')));
for(const [p,h]of Object.entries(before))if(!fs.existsSync(path.join(root,p))||hash(fs.readFileSync(path.join(root,p)))!==h)result.preservationChanges.push(p);
const manifests={};for(const label of ['baseline','candidate']){
 const m=manifests[label]=JSON.parse(fs.readFileSync(path.join(out,label+'_inputs.json')));
 for(const [p,h]of Object.entries(m.files))if(hash(fs.readFileSync(path.join(out,'seed1',label,p)))!==h)result.inputChanges.push(label+'/'+p);
}
for(const [p,h]of Object.entries(manifests.baseline.files))if(/\.(qsf|qip|sdc|tcl|qsys|ip|sip)$/i.test(p)&&manifests.candidate.files[p]!==h)result.sharedConfigurationDifferences.push(p);
result.additionalSeedDifferences=[];
for(const seed of [2,3])for(const label of ['baseline','candidate']){
 const mp=path.join(out,`seed${seed}_${label}_inputs.json`);if(!fs.existsSync(mp))continue;
 const m=JSON.parse(fs.readFileSync(mp));for(const [p,h]of Object.entries(m.files)){
  if(hash(fs.readFileSync(path.join(out,`seed${seed}`,label,p)))!==h)result.inputChanges.push(`seed${seed}/${label}/${p}`);
  if(manifests[label].files[p]!==h&&p!=='SMS.qsf')result.additionalSeedDifferences.push(`seed${seed}/${label}/${p}`);
 }
 const text=fs.readFileSync(path.join(out,`seed${seed}`,label,'SMS.qsf'),'utf8').replace('set_global_assignment -name SEED '+seed,'set_global_assignment -name SEED 1');
 if(hash(text)!==manifests[label].files['SMS.qsf'])result.additionalSeedDifferences.push(`seed${seed}/${label}/SMS.qsf contains more than seed change`);
}
for(const name of ['quartus_sh','quartus_map','quartus_fit','quartus_asm','quartus_sta'])result.toolHashes[name]=hash(fs.readFileSync(`C:/intelFPGA_lite/17.0/quartus/bin64/${name}.exe`));
result.gitStatus=cp.execFileSync('git',['status','--short'],{cwd:root}).toString();
result.originalQsfIdentical=manifests.baseline.originalQsfSHA256===manifests.candidate.originalQsfSHA256;
fs.writeFileSync(path.join(out,'integrity.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result,null,2));
if(result.preservationChanges.length||result.inputChanges.length||result.additionalSeedDifferences.length)process.exitCode=1;
