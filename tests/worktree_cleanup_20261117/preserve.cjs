const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const root=path.resolve(__dirname,'../..'),audit=require('./before.json'),files=require('./files_before.json');
function run(args,opts={}){const r=cp.spawnSync('git',['-c','core.quotepath=false','-C',root,...args],{encoding:'utf8',maxBuffer:128*1024*1024,...opts});if(r.status!==0)throw Error(args.join(' ')+': '+r.stderr);return r.stdout.trim();}
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const generated=p=>/(^|\/)(db|incremental_db|output_files|candidate_work|reference_work|test_work|fast_work|ghdl_candidate|ghdl_reference|ghdl_work|work)\//.test(p)||/\.(qdb|qpg|qtl|cf|pyc|rbf|sof|exe|dll|o|obj|vvp|wlf|vcd|fst)$/i.test(p)||/(^|\/)(_info|_vmake)$/.test(p);
const allowed=p=>/\.(vhd|vhdl|v|sv|svh|vh|js|cjs|mjs|py|ps1|sh|bat|cmd|tcl|do|qsf|qpf|sdc|md|txt|json|csv|diff|patch|hex|mif|ini|exitcode|log|rpt|summary|f|yml|yaml|toml|xml)$/i.test(p)||/(^|\/)(\.gitignore|Makefile|LICENSE)$/.test(p);
const result=[];
for(const r of audit.repositories){
 const name=r.relative.slice(6).replaceAll('/','-'),branch='archive/20261117/'+name;
 const changed=run(['-C',r.path,'diff','--name-only','HEAD','-z']).split('\0').filter(Boolean);
 const unique=[...new Set([...changed,...r.untracked,...r.ignored])];
 const retained=[],raw=[],discard=[];
 for(const p of unique){const full=path.join(r.path,p);if(!fs.existsSync(full)){retained.push({path:p,deleted:true});continue;}const bytes=fs.statSync(full).size;const entry={path:p,bytes,sha256:sha(full)};
 if(changed.includes(p)){if(generated(p)||bytes>5*1024*1024)throw Error('Review tracked binary/large change '+full);retained.push(entry);}
 else if(generated(p))discard.push({...entry,reason:'regenerable simulator/build output'});
 else if(allowed(p)&&bytes<=2*1024*1024&&(!/\.log$/i.test(p)||bytes<=256*1024))retained.push(entry);
 else raw.push(entry);
 }
 const meta=path.join(__dirname,'experiments',name);fs.mkdirSync(meta,{recursive:true});
 const record={name,branch,originalHead:r.head,originalBranch:r.branch,worktree:r.relative,retained,raw,discard};
 fs.writeFileSync(path.join(meta,'manifest.json'),JSON.stringify(record,null,2));
 fs.writeFileSync(path.join(meta,'working-tree.patch'),run(['-C',r.path,'diff','--binary','HEAD'])+'\n');
 result.push(record);
}
fs.writeFileSync(path.join(__dirname,'plan.json'),JSON.stringify(result,null,2));
console.log(result.map(r=>({name:r.name,publish:r.retained.length,archive:r.raw.length,rawBytes:r.raw.reduce((a,x)=>a+x.bytes,0),generated:r.discard.length})));
if(process.argv[2]!=='commit')process.exit();
// Use a private index: the main and experimental checkout indexes/branches stay unchanged.
for(const r of result){const env={...process.env,GIT_INDEX_FILE:path.join(__dirname,'archive.index')};if(fs.existsSync(env.GIT_INDEX_FILE))fs.unlinkSync(env.GIT_INDEX_FILE);
 run(['read-tree',r.originalHead],{env});
 for(const f of r.retained){if(f.deleted){run(['update-index','--force-remove','--',f.path],{env});continue;}const blob=run(['hash-object','-w','--',path.join(root,r.worktree,f.path)]);run(['update-index','--add','--cacheinfo','100644',blob,f.path],{env});}
 const mp='experiments/archive_20261117/'+r.name+'/manifest.json';const blob=run(['hash-object','-w','--',path.join(__dirname,'experiments',r.name,'manifest.json')]);run(['update-index','--add','--cacheinfo','100644',blob,mp],{env});
 const tree=run(['write-tree'],{env});r.tree=tree;r.commit=run(['commit-tree',tree,'-p',r.originalHead,'-m','archive: preserve '+r.name+' experiment and reproducibility evidence']);run(['update-ref','refs/heads/'+r.branch,r.commit,'0000000000000000000000000000000000000000']);
 fs.writeFileSync(path.join(__dirname,'commits.json'),JSON.stringify(result,null,2));console.log(r.branch,r.commit);
}
fs.unlinkSync(path.join(__dirname,'archive.index'));
