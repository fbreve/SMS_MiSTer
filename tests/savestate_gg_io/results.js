const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');const dir=__dirname,root=path.resolve(dir,'../..');
const read=f=>{const b=fs.readFileSync(path.join(dir,f));return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8');};
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'utf8'});const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const expected=['SMS.sv','rtl/io.vhd','rtl/savestates.sv','rtl/system.vhd'];
if(JSON.stringify(git('diff','--name-only').trim().split(/\r?\n/).sort())!==JSON.stringify(expected.sort()))throw Error('Production scope changed');
for(const [f,marker]of [['after.log','PASS F02 local replay: 24'],['integration.log','PASS F02 DDRAM integration: 12'],['integration_stalls.log','PASS F02 DDRAM integration: 12'],['f07_controller.log','PASS controller case 7'],['f07_sms.log','PASS: F07 fixed'],['f07_gg.log','PASS: F07 fixed'],['f07_integration.log','PASS integrated System E'],['regression.log','PASS io_gap_tb (F02 fixed'],['psg.log','PASS PSG replay: 128']]){const s=read(f);if(!s.includes(marker)||/\*\* (Failure|Fatal|Error)/.test(s))throw Error('Failed/incomplete '+f);}
if(!read('before.log').includes('REPRODUCED F02 omissions: 24')||!read('before_expected_failure.log').includes('replay divergence'))throw Error('Missing pre-fix proof');
const previous=JSON.parse(read('F07_reference.json'));const baseline=previous.build;
const sources={};for(const f of ['SMS.sv','rtl/io.vhd','rtl/savestates.sv','rtl/system.vhd','rtl/vdp.vhd','SMS.qsf','files.qip']){
 const old=fs.readFileSync(path.join(dir,'baseline',f));
 if(sha(old)!==previous.sources[f])throw Error('F07 baseline not comparable '+f);
 const current=fs.readFileSync(path.join(root,f)),built=fs.readFileSync(path.join(dir,'candidate',f));if(!current.equals(built))throw Error('Compiled source changed '+f);
 sources[f]={F07:sha(old),F02:sha(current)};
}
const log=read('candidate/compile.log'),fit=read('candidate/output_files/SMS.fit.summary'),sta=read('candidate/output_files/SMS.sta.summary');
if(!log.includes('Quartus Prime Full Compilation was successful')||!fit.includes('Fitter Status : Successful'))throw Error('Build incomplete');
const timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));if(!timing.length)throw Error('Missing STA');
const val=(label,source=fit)=>{const m=source.match(new RegExp(label+'[^:\\r\\n]*:\\s*([\\d,]+)'));return m?Number(m[1].replaceAll(',','')):null;};
const critical=[...new Set(log.split(/\r?\n/).filter(l=>l.includes('Critical Warning')).map(l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)')))];
const min=(t,type)=>Math.min(...t.filter(x=>x.type.startsWith(type)).map(x=>x.slack));
const candidate={alms:val('Logic utilization'),registers:val('Total registers'),memoryBits:val('Total block memory bits'),ramBlocks:val('Total RAM Blocks'),dspBlocks:val('Total DSP Blocks'),timing,criticalWarnings:critical};
const baselineFit=read('F07_fit.summary');baseline.ramBlocks=val('Total RAM Blocks',baselineFit);baseline.dspBlocks=val('Total DSP Blocks',baselineFit);
const numberedWarnings=text=>[...new Set(text.split(/\r?\n/).filter(l=>/^\s*(Critical )?Warning \(\d+\):/.test(l)).map(l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Z:\/tests\/savestate_(?:hcounter|gg_io)\/candidate\//gi,'BUILD/')))];
const priorWarnings=previous.warnings;
const newWarnings=numberedWarnings(log).filter(l=>!priorWarnings.includes(l));
const hashes={};for(const f of fs.readdirSync(dir).filter(f=>(/\.(js|sv|vhd|do)$/.test(f)||f.endsWith('.sv.in'))&&f!=='savestates_sim.sv'))hashes[f]=sha(fs.readFileSync(path.join(dir,f)));
const result={base:git('rev-parse','HEAD').trim(),branch:git('branch','--show-current').trim(),sources,testInputs:hashes,baseline,candidate,delta:{alms:candidate.alms-baseline.alms,registers:candidate.registers-baseline.registers,memoryBits:candidate.memoryBits-baseline.memoryBits,ramBlocks:candidate.ramBlocks-baseline.ramBlocks,dspBlocks:candidate.dspBlocks-baseline.dspBlocks},worstSlack:{F07Setup:min(baseline.timing,'Setup'),F07Hold:min(baseline.timing,'Hold'),F02Setup:min(timing,'Setup'),F02Hold:min(timing,'Hold')},newWarnings,newCriticalWarnings:critical.filter(l=>!baseline.criticalWarnings.includes(l)),negativeTiming:timing.filter(t=>t.slack<0||t.tns<0)};
fs.writeFileSync(path.join(dir,'results.json'),JSON.stringify(result,null,2));
for(const v of ['fit','sta'])fs.copyFileSync(path.join(dir,'candidate/output_files/SMS.'+v+'.summary'),path.join(dir,'candidate_'+v+'.summary'));
fs.writeFileSync(path.join(dir,'production.diff'),git('diff'));
fs.writeFileSync(path.join(dir,'git_status.txt'),git('status','--short'));fs.writeFileSync(path.join(dir,'diff_stat.txt'),git('diff','--stat'));
console.log(JSON.stringify({delta:result.delta,worstSlack:result.worstSlack,newCriticalWarnings:result.newCriticalWarnings,negativeTiming:result.negativeTiming},null,2));
