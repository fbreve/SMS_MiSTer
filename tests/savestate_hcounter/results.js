const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const dir=__dirname,root=path.resolve(dir,'../..');
const read=f=>{const b=fs.readFileSync(path.join(dir,f));return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8');};
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'utf8'});
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const changes=git('diff','--name-only').trim().split(/\r?\n/).filter(Boolean);
if(JSON.stringify(changes.sort())!==JSON.stringify(['SMS.sv','rtl/savestates.sv','rtl/system.vhd','rtl/vdp.vhd'].sort()))throw Error('Unexpected production scope');
for(const f of ['after.log','after_gg.log','controller.log','integration.log']){
 const s=read(f);if(!s.includes('PASS')||/\*\* (Failure|Fatal|Error)/.test(s))throw Error('Test failure '+f);
}
if(!read('integration.log').includes('PASS integrated System E: two real VDPs'))throw Error('Integration incomplete');
if(!read('before.log').includes('REPRODUCED BEFORE FIX')||!read('before_expected_failure.log').includes('HCounter mismatch actual=48 expected=0'))throw Error('Missing baseline evidence');
for(const [f,marker]of [['regression.log','PASS md_gap_tb'],['regression_psg.log','PASS PSG replay: 128 cases']]){const s=read(f);if(!s.includes(marker)||/\*\* (Failure|Fatal|Error)/.test(s))throw Error('Regression failure '+f);}
const hashes={head:git('rev-parse','HEAD').trim(),branch:git('branch','--show-current').trim(),files:{}};
hashes.testInputs={};
for(const f of fs.readdirSync(dir).filter(f=>/\.(js|sv|vhd|do|ps1)$/.test(f)&&f!=='savestates_sim.sv'))hashes.testInputs[f]=sha(fs.readFileSync(path.join(dir,f)));
for(const f of changes){
 const current=fs.readFileSync(path.join(root,f)),built=fs.readFileSync(path.join(dir,'candidate',f));
 if(!current.equals(built))throw Error('Candidate compiled source differs '+f);
 hashes.files[f]={before:sha(fs.readFileSync(path.join(dir,'baseline',f))),after:sha(current)};
}
const build={};
for(const variant of ['baseline','candidate']){
 const log=read(variant+'/compile.log');
 const fit=read(variant+'/output_files/SMS.fit.summary'),sta=read(variant+'/output_files/SMS.sta.summary');
 if(!/Fitter Status : Successful/.test(fit)||!log.includes('Quartus Prime Full Compilation was successful'))throw Error('Build incomplete '+variant);
 const timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:Number(m[2]),tns:Number(m[3])}));
 if(!timing.length)throw Error('Missing timing '+variant);
 const val=label=>{const m=fit.match(new RegExp(label+'[^:\\r\\n]*:\\s*([\\d,]+)'));return m?Number(m[1].replaceAll(',','')):null;};
 const critical=[...new Set(log.split(/\r?\n/).filter(l=>l.includes('Critical Warning')).map(l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replaceAll('/'+variant+'/', '/BUILD/')))];
 build[variant]={alms:val('Logic utilization'),registers:val('Total registers'),memoryBits:val('Total block memory bits'),timing,criticalWarnings:critical};
 fs.copyFileSync(path.join(dir,variant,'output_files/SMS.fit.summary'),path.join(dir,variant+'_fit.summary'));
 fs.copyFileSync(path.join(dir,variant,'output_files/SMS.sta.summary'),path.join(dir,variant+'_sta.summary'));
}
const minimum=(v,type)=>Math.min(...build[v].timing.filter(t=>t.type.startsWith(type)).map(t=>t.slack));
const result={hashes,build,delta:{alms:build.candidate.alms-build.baseline.alms,registers:build.candidate.registers-build.baseline.registers,memoryBits:build.candidate.memoryBits-build.baseline.memoryBits},newCriticalWarnings:build.candidate.criticalWarnings.filter(s=>!build.baseline.criticalWarnings.includes(s)),worstSlack:{baselineSetup:minimum('baseline','Setup'),baselineHold:minimum('baseline','Hold'),candidateSetup:minimum('candidate','Setup'),candidateHold:minimum('candidate','Hold')},negativeTiming:build.candidate.timing.filter(t=>t.slack<0||t.tns<0)};
fs.writeFileSync(path.join(dir,'results.json'),JSON.stringify(result,null,2));
fs.writeFileSync(path.join(dir,'production.diff'),git('diff','--','SMS.sv','rtl'));
fs.writeFileSync(path.join(dir,'git_status.txt'),git('status','--short'));
fs.writeFileSync(path.join(dir,'diff_stat.txt'),git('diff','--stat'));
console.log(JSON.stringify({delta:result.delta,worstSlack:result.worstSlack,negativeTiming:result.negativeTiming,newCriticalWarnings:result.newCriticalWarnings},null,2));
