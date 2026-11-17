const fs=require('fs'),path=require('path'),cp=require('child_process');
const out=__dirname;
if(fs.existsSync('Z:/'))throw Error('Z: occupied');
cp.execFileSync('subst.exe',['Z:',out]);
try {
for(const label of ['baseline','candidate']){
 const stem='seed1_'+label+'_attempt3',start=new Date().toISOString();
 const stdout=fs.openSync(path.join(out,stem+'.stdout.log'),'wx'),stderr=fs.openSync(path.join(out,stem+'.stderr.log'),'wx');
 const result=cp.spawnSync('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe',['--flow','compile',`Z:/seed1/${label}/SMS`],{cwd:`Z:/seed1/${label}`,stdio:['ignore',stdout,stderr]});
 fs.closeSync(stdout);fs.closeSync(stderr);
 fs.writeFileSync(path.join(out,stem+'.status.json'),JSON.stringify({label,seed:1,start,finish:new Date().toISOString(),exitCode:result.status,error:result.error?.message},null,2));
 console.log(label,result.status);
}
} finally {cp.execFileSync('subst.exe',['Z:','/D']);}
