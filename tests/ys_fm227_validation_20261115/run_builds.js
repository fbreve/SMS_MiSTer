const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');const root=p.resolve(__dirname,'../..'),out=p.join(__dirname,'physical_r2'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const gate=JSON.parse(fs.readFileSync(p.join(__dirname,'r2/functional_gate.json')));assert.equal(gate.status,'PASS');assert.equal(sha(fs.readFileSync(p.join(root,'rtl/savestates.sv'))),gate.identity.productionSHA256);
const results=[],gateSHA=sha(fs.readFileSync(p.join(__dirname,'r2/functional_gate.json')));
function record(){fs.writeFileSync(p.join(out,'build_status.json'),JSON.stringify({functionalGateSHA256:gateSHA,method:'seed1 gated; seeds2/3 parallel as in the matched FM-baseline campaign',results},null,2));}
async function compile(seed){
 const manifest=JSON.parse(fs.readFileSync(p.join(out,`seed${seed}_candidate_inputs.json`)));for(const [f,h]of Object.entries(manifest.files))assert.equal(sha(fs.readFileSync(p.join(out,`seed${seed}/candidate`,f))),h,f);
 const name='seed'+seed,stdout=fs.openSync(p.join(out,name+'.stdout.log'),'wx'),stderr=fs.openSync(p.join(out,name+'.stderr.log'),'wx'),status={seed,start:new Date().toISOString(),status:'running'};results.push(status);record();console.log('START',name,status.start);
 await new Promise((resolve,reject)=>{const child=cp.spawn('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe',['--flow','compile',`Z:/seed${seed}/candidate/SMS`],{cwd:`Z:/seed${seed}/candidate`,stdio:['ignore',stdout,stderr],windowsHide:true});child.on('error',e=>{status.error=e.message;reject(e);});child.on('exit',code=>{status.exit=code;resolve();});}).finally(()=>{fs.closeSync(stdout);fs.closeSync(stderr);status.finish=new Date().toISOString();fs.writeFileSync(p.join(out,name+'.status.json'),JSON.stringify(status,null,2));record();});return status;
}
function collectAndQualify(){
 cp.execFileSync(process.execPath,[p.join(__dirname,'collect_physical.js')],{cwd:root,stdio:'ignore'});cp.execFileSync(process.execPath,[p.join(__dirname,'compare_physical.js')],{cwd:root,stdio:'inherit'});
 const pairs=JSON.parse(fs.readFileSync(p.join(out,'comparison.json'))).pairs;
 for(const status of results){const q=pairs.find(q=>q.seed===status.seed);status.qualified=status.exit===0&&!!q&&q.fitSuccessful&&q.timingAnalysisCompleted&&q.setupHoldPass&&q.otherNegativeTiming.length===0;status.status=status.qualified?'qualified':'not_qualified';fs.writeFileSync(p.join(out,`seed${status.seed}.status.json`),JSON.stringify(status,null,2));}record();
}
(async()=>{assert(!fs.existsSync('Z:/'),'Z: occupied; do not replace existing mapping');cp.execFileSync('subst.exe',['Z:',out]);
 try{
  const first=await compile(1);assert.equal(first.exit,0,'Quartus failed seed1');collectAndQualify();assert(first.qualified,'physical qualification failed seed1');console.log('QUALIFIED seed1; starting paired seeds2/3');
  const additional=await Promise.allSettled([compile(2),compile(3)]);collectAndQualify();for(const q of additional)if(q.status==='rejected')throw q.reason;if(results.some(q=>!q.qualified))process.exitCode=1;
 }finally{cp.execFileSync('subst.exe',['Z:','/D']);}
})().catch(e=>{console.error(e);process.exitCode=1;});
