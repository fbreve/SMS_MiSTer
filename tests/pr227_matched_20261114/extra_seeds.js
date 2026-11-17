const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),os=require('os');
const out=__dirname,hash=b=>crypto.createHash('sha256').update(b).digest('hex');
async function main(){
 const first=JSON.parse(fs.readFileSync(path.join(out,'measurements.json'))).filter(r=>r.seed===1);
 if(first.length!==2||first.some(r=>!r.fitSuccessful||!r.timingSuccessful||r.metrics.worstSetup<0||r.metrics.worstHold<0||r.metrics.setupTNS!==0||r.metrics.holdTNS!==0))throw Error('Seed-1 pair not complete with passing constrained setup/hold timing');
 if(fs.existsSync('Z:/'))throw Error('Z: occupied');
 const jobs=[];
 for(const seed of [2,3])for(const label of ['baseline','candidate']){
  const dir=path.join(out,`seed${seed}`,label);if(fs.existsSync(dir))throw Error('Refusing to overwrite '+dir);fs.mkdirSync(dir,{recursive:true});
  cp.execFileSync('tar',['-xf',path.join(out,label+'.tar'),'-C',dir]);
  const depdir=path.join(dir,'mist/mist-modules');fs.mkdirSync(depdir,{recursive:true});cp.execFileSync('tar',['-xf',path.join(out,'dependency_'+label+'.tar'),'-C',depdir]);
  let qsf=fs.readFileSync(path.join(out,'seed1',label,'SMS.qsf'),'utf8');qsf=qsf.replace('set_global_assignment -name SEED 1','set_global_assignment -name SEED '+seed);fs.writeFileSync(path.join(dir,'SMS.qsf'),qsf);
  fs.copyFileSync(path.join(out,'seed1',label,'fixed_build_id.tcl'),path.join(dir,'fixed_build_id.tcl'));
  const files={};function walk(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,e.name);if(e.isDirectory())walk(p);else files[path.relative(dir,p).replaceAll('\\','/')]=hash(fs.readFileSync(p));}}walk(dir);
  fs.writeFileSync(path.join(out,`seed${seed}_${label}_inputs.json`),JSON.stringify({seed,label,buildDate:'261114',revision:JSON.parse(fs.readFileSync(path.join(out,label+'_inputs.json'))).revision,files},null,2));
  jobs.push({seed,label});
 }
 fs.writeFileSync(path.join(out,'extra_environment.json'),JSON.stringify({totalMemory:os.totalmem(),freeMemory:os.freemem(),cpus:os.cpus().length,parallelBuilds:4},null,2));
 cp.execFileSync('subst.exe',['Z:',out]);
 try {await Promise.all(jobs.map(({seed,label})=>new Promise((resolve,reject)=>{
  const stem=`seed${seed}_${label}`,start=new Date().toISOString(),stdout=fs.openSync(path.join(out,stem+'.stdout.log'),'wx'),stderr=fs.openSync(path.join(out,stem+'.stderr.log'),'wx');
  const child=cp.spawn('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe',['--flow','compile',`Z:/seed${seed}/${label}/SMS`],{cwd:`Z:/seed${seed}/${label}`,stdio:['ignore',stdout,stderr]});
  child.on('error',reject);child.on('close',exitCode=>{fs.closeSync(stdout);fs.closeSync(stderr);fs.writeFileSync(path.join(out,stem+'.status.json'),JSON.stringify({seed,label,start,finish:new Date().toISOString(),exitCode},null,2));console.log(stem,exitCode);resolve();});
 })));}finally{cp.execFileSync('subst.exe',['Z:','/D']);}
}
main().catch(e=>{console.error(e);process.exitCode=1;});
