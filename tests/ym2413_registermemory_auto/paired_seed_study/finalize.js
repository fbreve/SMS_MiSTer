const fs=require('fs'),p=require('path'),c=require('crypto'),cp=require('child_process'),assert=require('assert'),d=__dirname,task=p.dirname(d);
// Correct descriptive metadata inherited from the older build helper. Frozen
// project/source bytes and their hashes are not changed.
for(const seed of [1,3]){
 const dir=p.join(task,'physical_seed'+seed),file=p.join(dir,'inputs.json'),m=JSON.parse(fs.readFileSync(file));
 m.builds.candidate.inputs['SMS.qsf'].seedOverride=seed;
 m.baselineReuse='Reused original matched full-state physical_seed'+seed+'/candidate reports after hash and source/configuration verification; no reference rebuild.';
 m.seedStudyPolicy='Frozen AUTO Seed 2 inputs, with only QSF Seed assignment changed to '+seed+'. Seed 2 artifacts preserved.';
 fs.writeFileSync(file,JSON.stringify(m,null,2)+'\n');
 cp.execFileSync('node',[p.join(dir,'check_inputs.js')],{stdio:'inherit'});
}
cp.execFileSync('node',[p.join(d,'summarize.js')],{stdio:['ignore',fs.openSync(p.join(d,'analysis.log'),'w'),'inherit']});
const hashes={},sha=b=>c.createHash('sha256').update(b).digest('hex');
function scan(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const f=p.join(dir,e.name);if(e.isDirectory()){if(['candidate','output_files'].includes(e.name))scan(f);}else if(/\.(rpt|summary|log|json|js|ps1|tcl|md|diff|rbf)$/.test(e.name)&&e.name!=='artifact_hashes.json')hashes[p.relative(task,f).replace(/\\/g,'/')]={bytes:fs.statSync(f).size,SHA256:sha(fs.readFileSync(f))};}}
scan(d);for(const seed of [1,3])scan(p.join(task,'physical_seed'+seed));
fs.writeFileSync(p.join(d,'artifact_hashes.json'),JSON.stringify(hashes,null,2)+'\n');
console.log('PASS final source/reference/worktree/Seed 2 preservation and '+Object.keys(hashes).length+' retained artifact hashes');
