const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const root=path.resolve(__dirname,'../..'),audit=require('./before.json'),commits=require('./commits.json'),verification=require('./remote_verification.json');
const raw=JSON.parse(fs.readFileSync(path.join(__dirname,'raw_archive_verification.json'),'utf8').replace(/^\uFEFF/,''));
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
function git(args){const r=cp.spawnSync('git',['-c','core.quotepath=false','-C',root,...args],{encoding:'utf8',maxBuffer:128*1024*1024});if(r.status!==0)throw Error(args.join(' ')+': '+r.stderr);return r.stdout;}
const removals=[];
for(const r of commits){
 const full=path.resolve(root,r.worktree),boundary=path.resolve(root,'tests')+path.sep;
 if(!full.startsWith(boundary)||!fs.existsSync(path.join(full,'.git')))throw Error('Invalid target '+full);
 const remote=verification.refs.find(x=>x.branch===r.branch&&x.commit===r.commit);if(!remote)throw Error('Unverified publication '+r.branch);
 const original=audit.repositories.find(x=>x.relative===r.worktree);
 const status=git(['-C',full,'status','--porcelain=v1','--untracked-files=all']).split('\n').filter(Boolean);if(JSON.stringify(status)!==JSON.stringify(original.status))throw Error('Worktree changed since audit '+r.worktree);
 const ignored=git(['-C',full,'ls-files','--others','--ignored','--exclude-standard','-z']).split('\0').filter(Boolean);if(JSON.stringify(ignored)!==JSON.stringify(original.ignored))throw Error('Ignored files changed '+r.worktree);
 for(const f of [...r.retained,...r.raw,...r.discard]){if(f.deleted)continue;if(sha(path.join(full,f.path))!==f.sha256)throw Error('Changed file '+f.path);}
 if(r.raw.length){const archive=raw.find(x=>x.experiment===r.name);if(!archive?.verified||sha(archive.zip)!==archive.sha256)throw Error('Invalid raw archive '+r.name);}
 if(git(['-C',full,'rev-parse','HEAD']).trim()!==r.originalHead)throw Error('HEAD changed');
 git(['worktree','remove','--force',full]);
 removals.push({worktree:r.worktree,branch:r.branch,commit:r.commit,removedAt:new Date().toISOString(),bytes:original.bytes,rawArchived:r.raw.length});
 fs.writeFileSync(path.join(__dirname,'removals.json'),JSON.stringify(removals,null,2));console.log('Removed',r.worktree);
}
console.log(git(['worktree','list','--porcelain']));console.log(git(['status','--short']));
