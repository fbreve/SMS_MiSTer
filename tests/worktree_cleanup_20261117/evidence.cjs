const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const root=path.resolve(__dirname,'../..'),audit=require('./before.json'),inventory=require('./files_before.json');
const index=path.join(__dirname,'evidence.index'),env={...process.env,GIT_INDEX_FILE:index};
function git(args,input){const r=cp.spawnSync('git',['-C',root,...args],{env,input,encoding:'utf8',maxBuffer:128*1024*1024});if(r.status!==0)throw Error(args.join(' ')+': '+r.stderr);return r.stdout.trim();}
const exclude=/(^|\/)(tools|uv_cache|db|incremental_db|output_files|game_sources|obj_dir|work|candidate_work|reference_work|test_work|fast_work|\.git)\//;
const selected=inventory.filter(x=>!x.symlink&&!audit.repositories.some(r=>x.path.startsWith(r.relative+'/'))&&!exclude.test(x.path)&&x.bytes<=2*1024*1024&&(
 /\.(md|json|js|cjs|mjs|py|ps1|sh|bat|cmd|do|tcl|patch|diff|svh|vh|sdc|qsf|qpf|yml|yaml|toml)$/i.test(x.path)||
 (/\.(vhd|v|sv|csv|txt|rpt|summary)$/i.test(x.path)&&x.path.split('/').length<=4&&x.bytes<=512*1024)
));
// Publish audit/verification manifests and scripts, never ZIP payloads or temporary indexes.
function addAudit(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const full=path.join(dir,e.name);if(e.isDirectory()){if(e.name!=='raw_archives')addAudit(full);}else if(/\.(json|md|txt|cjs|ps1|patch)$/.test(e.name)&&!['files_before.json','commits.json'].includes(e.name))selected.push({path:path.relative(root,full).replaceAll('\\','/'),bytes:fs.statSync(full).size});}}
addAudit(__dirname);
const unique=[...new Map(selected.map(f=>[f.path,f])).values()];
console.log('Evidence files',unique.length,'bytes',unique.reduce((a,f)=>a+f.bytes,0));
if(process.argv[2]!=='commit')process.exit();
if(fs.existsSync(index))throw Error('Existing evidence index');
const base=audit.registered.match(/HEAD ([a-f0-9]+)/)[1];git(['read-tree',base]);
const manifest=[];let lines='';
for(let i=0;i<unique.length;i+=300){const batch=unique.slice(i,i+300);const hashes=git(['hash-object','-w','--stdin-paths'],batch.map(f=>JSON.stringify(f.path)).join('\n')+'\n').split('\n');batch.forEach((f,j)=>{lines+='100644 '+hashes[j]+'\t'+f.path+'\n';manifest.push({...f,blob:hashes[j],sha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(root,f.path))).digest('hex')});});}
git(['update-index','--index-info'],lines);
const manifestPath=path.join(__dirname,'external_evidence_manifest.json');fs.writeFileSync(manifestPath,JSON.stringify(manifest,null,2));const blob=git(['hash-object','-w','--',manifestPath]);git(['update-index','--add','--cacheinfo','100644',blob,'experiments/archive_20261117/external_evidence_manifest.json']);
const tree=git(['write-tree']);const commit=git(['commit-tree',tree,'-p',base,'-m','archive: preserve experiment reports, scripts, patches and FM/Ys evidence']);const branch='archive/20261117/consolidated-evidence';git(['update-ref','refs/heads/'+branch,commit,'0000000000000000000000000000000000000000']);fs.writeFileSync(path.join(__dirname,'evidence_commit.json'),JSON.stringify({branch,commit,tree,files:manifest.length,bytes:unique.reduce((a,f)=>a+f.bytes,0)},null,2));fs.unlinkSync(index);console.log(branch,commit);
