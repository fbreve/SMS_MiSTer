const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert'),d=__dirname,task=p.dirname(d);
cp.execFileSync('node',[p.join(task,'verify.js')],{stdio:'inherit'});
cp.execFileSync('node',[p.join(d,'summarize.js')],{stdio:['ignore',fs.openSync(p.join(d,'analysis.log'),'w'),'inherit']});
cp.execFileSync('node',[p.join(d,'write_report.js')],{stdio:'inherit'});
const hashes={},sha=b=>c.createHash('sha256').update(b).digest('hex');
const record=f=>{hashes[p.relative(task,f).replace(/\\/g,'/')]={bytes:fs.statSync(f).size,SHA256:sha(fs.readFileSync(f))};};
function scan(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const f=p.join(dir,e.name);if(e.isDirectory()){if(['candidate','output_files'].includes(e.name))scan(f);}else if(/\.(rpt|summary|log|json|js|ps1|tcl|md|diff|rbf)$/.test(e.name)&&!['artifact_hashes.json','finalize.log'].includes(e.name))record(f);}}
scan(d);for(const seed of [1,3]){scan(p.join(task,'physical_seed'+seed));record(p.join(task,'physical_seed'+seed+'/candidate/db/dpram_iop1.tdf'));}
for(const f of ['verify.js','prepare_multiseed.js','create_multiseed_helpers.js','create_summary.js'])record(p.join(task,f));
fs.writeFileSync(p.join(d,'artifact_hashes.json'),JSON.stringify(hashes,null,2)+'\n');
for(const [f,v]of Object.entries(hashes))assert.equal(sha(fs.readFileSync(p.join(task,f))),v.SHA256);
console.log('PASS final source/reference/Seed 2/worktree preservation and '+Object.keys(hashes).length+' artifact hashes');
