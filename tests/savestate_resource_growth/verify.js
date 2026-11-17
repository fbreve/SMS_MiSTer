const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:64*1024*1024}),norm=b=>b.toString().replace(/\r\n/g,'\n'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const rows=JSON.parse(fs.readFileSync(p.join(d,'measurements.json'))),inputs=Object.keys(JSON.parse(fs.readFileSync(p.join(root,'tests/savestate_g12_sdram_fix/build_inputs.json'))).inputs.candidate),current=p.join(root,'tests/savestate_g12_sdram_fix/quartus_candidate');
const selected=rows.map(r=>({...r,b:r.builds.find(b=>b.tree===({'g06_g10_fix':'quartus','g05_background_fix':'quartus_v15','g08_release_fix':'quartus_v16','g12_sdram_fix':'quartus_candidate'}[r.checkpoint]||'candidate'))}));
selected.unshift({checkpoint:'historical',commit:git('rev-parse','8443a0d').toString().trim(),b:rows[0].builds[0],origin:'hcounter'});
const result=[];
for(const r of selected){const tree=p.join(root,'tests/savestate_'+(r.origin||r.checkpoint),r.b.tree),names=new Set(git('ls-tree','-r','--name-only',r.commit).toString().trim().split(/\r?\n/)),entry={checkpoint:r.checkpoint,commit:r.commit,verified:[],missing:[],mismatches:[],environmentDifferences:[]};
 for(const f of inputs){const local=p.join(tree,f);if(!fs.existsSync(local)){entry.missing.push(f);continue;}const b=fs.readFileSync(local);if(names.has(f)){if(norm(b)===norm(git('show',r.commit+':'+f)))entry.verified.push(f);else entry.mismatches.push(f);}else if(norm(b)!==norm(fs.readFileSync(p.join(current,f))))entry.environmentDifferences.push(f);}
 result.push(entry);console.log(r.checkpoint,'verified',entry.verified.length,'missing',JSON.stringify(entry.missing),'mismatch',JSON.stringify(entry.mismatches),'envdiff',JSON.stringify(entry.environmentDifferences));
}
fs.writeFileSync(p.join(d,'source_verification.json'),JSON.stringify(result,null,2));
const baseline=JSON.parse(fs.readFileSync(p.join(d,'tracked_baseline.json'))),changes=[];for(const[f,h]of Object.entries(baseline))if(sha(fs.readFileSync(p.join(root,f)))!==h)changes.push(f);
fs.writeFileSync(p.join(d,'integrity.json'),JSON.stringify({head:git('rev-parse','HEAD').toString().trim(),trackedFiles:Object.keys(baseline).length,changes,diff:git('diff','--stat').toString(),staged:git('diff','--cached','--stat').toString()},null,2));
