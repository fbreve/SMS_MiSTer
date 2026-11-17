const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const root = path.resolve(__dirname, '../..');
const out = __dirname;
function git(dir, args) { const r=cp.spawnSync('git',['-c','core.quotepath=false','-C',dir,...args],{encoding:'utf8',maxBuffer:128*1024*1024}); if(r.status!==0) throw Error(args.join(' ')+': '+r.stderr); return r.stdout; }
const files=[], repositories=[];
function walk(dir) { for(const e of fs.readdirSync(dir,{withFileTypes:true})) { const p=path.join(dir,e.name); if(e.name==='.git') {if(e.isDirectory() || fs.readFileSync(p,'utf8').startsWith('gitdir:')) repositories.push({path:dir,kind:e.isDirectory()?'clone':'worktree'}); continue;} if(e.isSymbolicLink()) {files.push({path:path.relative(root,p).replaceAll('\\','/'),bytes:0,symlink:true});continue;} if(e.isDirectory())walk(p);else files.push({path:path.relative(root,p).replaceAll('\\','/'),bytes:fs.statSync(p).size}); } }
walk(path.join(root,'tests'));
const registered=git(root,['worktree','list','--porcelain']);
for(const r of repositories) { r.relative=path.relative(root,r.path).replaceAll('\\','/');r.head=git(r.path,['rev-parse','HEAD']).trim();r.branch=git(r.path,['branch','--show-current']).trim();r.status=git(r.path,['status','--porcelain=v1','--untracked-files=all']).split('\n').filter(Boolean);r.tracked=git(r.path,['ls-files','-z']).split('\0').filter(Boolean);r.untracked=git(r.path,['ls-files','--others','--exclude-standard','-z']).split('\0').filter(Boolean);r.ignored=git(r.path,['ls-files','--others','--ignored','--exclude-standard','-z']).split('\0').filter(Boolean);r.localOnly=git(r.path,['rev-list','HEAD','--not','--remotes=origin']).trim().split('\n').filter(Boolean);r.bytes=files.filter(f=>f.path.startsWith(r.relative+'/')).reduce((a,f)=>a+f.bytes,0); }
const disk=cp.spawnSync('powershell',['-NoProfile','-Command','Get-PSDrive C | Select-Object Used,Free | ConvertTo-Json'],{encoding:'utf8'}).stdout;
fs.writeFileSync(path.join(out,'before.json'),JSON.stringify({date:new Date().toISOString(),root,disk:JSON.parse(disk),testsBytes:files.reduce((a,f)=>a+f.bytes,0),registered,repositories},null,2));
fs.writeFileSync(path.join(out,'files_before.json'),JSON.stringify(files));
console.log(JSON.stringify({testsBytes:files.reduce((a,f)=>a+f.bytes,0),disk:JSON.parse(disk),repositories:repositories.map(r=>({path:r.relative,kind:r.kind,head:r.head,branch:r.branch,status:r.status,ignored:r.ignored.length,bytes:r.bytes,localOnly:r.localOnly.length}))},null,2));

