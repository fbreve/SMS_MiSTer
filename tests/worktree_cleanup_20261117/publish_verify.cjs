const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const root=path.resolve(__dirname,'../..');
function git(dir,args,input){const r=cp.spawnSync('git',['-c','http.lowSpeedLimit=1000','-c','http.lowSpeedTime=60','-C',dir,...args],{input,encoding:'utf8',maxBuffer:256*1024*1024});if(r.status!==0)throw Error(args.join(' ')+': '+r.stderr);return r.stdout.trim();}
const commits=require('./commits.json'),evidence=require('./evidence_commit.json');if(commits.length!==20)throw Error('Incomplete archive commits');
const refs=[...commits,evidence];
if(process.argv[2]!=='verify-only'){
const before=git(root,['ls-remote','--heads','origin']);fs.writeFileSync(path.join(__dirname,'remote_heads_before.txt'),before+'\n');
console.log(git(root,['push','--atomic','origin',...refs.map(r=>r.commit+':refs/heads/'+r.branch)]));}
const remote=git(root,['ls-remote','--heads','origin']);fs.writeFileSync(path.join(__dirname,'remote_heads_after.txt'),remote+'\n');
for(const r of refs)if(!remote.split('\n').includes(r.commit+'\trefs/heads/'+r.branch))throw Error('Remote ref mismatch '+r.branch);
// Fresh object database, fetched only from GitHub: no local alternates or hard links.
const verify=path.join(__dirname,'remote_verification.git');if(process.argv[2]!=='verify-only'){if(fs.existsSync(verify))throw Error('Existing verification directory');fs.mkdirSync(verify);git(verify,['init','--bare']);
git(verify,['fetch','--depth=2','--no-tags','https://github.com/fbreve/SMS_MiSTer.git',...refs.map(r=>'refs/heads/'+r.branch+':refs/heads/'+r.branch)]);
}
for(const r of refs){const tree=git(verify,['rev-parse',r.commit+'^{tree}']);if(tree!==r.tree)throw Error('Remote tree mismatch '+r.branch);}
// Compare every retained file against its remote Git blob, including ignored sources.
let checked=0;
for(const r of commits){const listing=git(verify,['ls-tree','-rz',r.commit]);const blobs=new Map(listing.split('\0').filter(Boolean).map(s=>{const m=s.match(/^\d+ blob ([a-f0-9]+)\t([\s\S]+)$/);return m?[m[2],m[1]]:['',''];}));const retained=r.retained.filter(f=>!f.deleted);const hashes=git(root,['hash-object','--stdin-paths'],retained.map(f=>JSON.stringify(path.join(root,r.worktree,f.path).replaceAll('\\','/'))).join('\n')+'\n').split('\n');retained.forEach((f,i)=>{if(blobs.get(f.path)!==hashes[i])throw Error('Remote file mismatch '+f.path);checked++;});git(verify,['cat-file','-e',r.originalHead+'^{commit}']);}
const external=require('./external_evidence_manifest.json');
const remoteFiles=git(verify,['ls-tree','-r',evidence.commit]);const remoteBlobs=new Map(remoteFiles.split('\n').map(s=>{const m=s.match(/^\d+ blob ([a-f0-9]+)\t(.+)$/);return m?[m[2],m[1]]:['',''];}));for(const f of external){if(remoteBlobs.get(f.path)!==f.blob)throw Error('Evidence mismatch '+f.path);checked++;}
git(verify,['fsck','--full','--no-reflogs']);
fs.writeFileSync(path.join(__dirname,'remote_verification.json'),JSON.stringify({verifiedAt:new Date().toISOString(),freshFetch:true,depth:2,checkedFiles:checked,refs:refs.map(r=>({branch:r.branch,commit:r.commit,tree:r.tree})),repository:verify},null,2));console.log('Remote verified files:',checked);
