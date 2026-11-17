const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),rev='8443a0d19a88aff7a5900011bccf386daf146945';
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:64*1024*1024});
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const before={head:git('rev-parse','HEAD').toString().trim(),branch:git('branch','--show-current').toString().trim(),refs:git('show-ref').toString(),diff:git('diff','--binary').toString(),indexDiff:git('diff','--cached','--binary').toString(),files:{}};
function protect(dir){for(const e of fs.readdirSync(p.join(root,dir),{withFileTypes:true})){const f=p.posix.join(dir,e.name);if(e.isDirectory()){if(!['.git','db','incremental_db','work','node_modules'].includes(e.name)&&!e.name.endsWith('_work'))protect(f);}else if(e.isFile()&&(/\.(md|json|js|ps1|sv|v|vhd|qsf|qip|sdc|do|csv|summary|diff|tcl)$/.test(e.name)||f.endsWith('/.git')))before.files[f]=hash(fs.readFileSync(p.join(root,f)));}}
protect('tests');protect('rtl');
fs.writeFileSync(p.join(__dirname,'preservation_before.json'),JSON.stringify(before,null,2));
for(const candidate of ['B','C']){
 const dir=p.join(__dirname,candidate),branch=`experiment/psg-${candidate.toLowerCase()}-${candidate==='B'?'minimal':'controls'}`;
 assert(!fs.existsSync(dir));git('worktree','add','-b',branch,dir,rev);
}
console.log('Protected files:',Object.keys(before.files).length);
