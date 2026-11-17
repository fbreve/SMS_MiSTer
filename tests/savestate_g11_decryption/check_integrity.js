const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),d=__dirname,root=p.resolve(d,'../..');
const baseline=JSON.parse(fs.readFileSync(p.join(d,'baseline.json')));
const git=(...args)=>cp.execFileSync('git',args,{cwd:root,encoding:'utf8'}).trim();
const changed=[];for(const [file,expected]of Object.entries(baseline.files)){
 const actual=crypto.createHash('sha256').update(fs.readFileSync(p.join(root,file))).digest('hex');
 if(actual!==expected)changed.push(file);
}
const result={head:git('rev-parse','HEAD'),branch:git('branch','--show-current'),trackedFilesChecked:Object.keys(baseline.files).length,changedTrackedFiles:changed,diffStat:git('diff','--stat'),stagedStat:git('diff','--cached','--stat'),status:git('status','--short')};
result.pass=result.head===baseline.head&&result.branch==='investigate/savestate-g11-decryption'&&!changed.length&&!result.diffStat&&!result.stagedStat;
fs.writeFileSync(p.join(d,'integrity.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));if(!result.pass)process.exitCode=1;
