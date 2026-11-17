const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const name=process.argv[2]||'A',dir=p.join(d,'quartus_'+name),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
function measure(folder){
 const fit=read(p.join(folder,'output_files/SMS.fit.summary')),rpt=read(p.join(folder,'output_files/SMS.fit.rpt')),map=read(p.join(folder,'output_files/SMS.map.rpt')),sta=fs.existsSync(p.join(folder,'output_files/SMS.sta.summary'))?read(p.join(folder,'output_files/SMS.sta.summary')):'',ms=read(p.join(folder,'output_files/SMS.map.summary'));
 const n=(re,s=fit)=>{const m=s.match(re);assert(m,'missing metric '+re);return +m[1].replaceAll(',','');};
 const out={needed:n(/Logic utilization[^:]*:\s*([\d,]+)/),placed:n(/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/,rpt),registers:n(/Total registers\s*:\s*([\d,]+)/),synthesisRegisters:n(/Total registers\s*:\s*([\d,]+)/,ms),M10K:n(/Total RAM Blocks\s*:\s*([\d,]+)/),memoryBits:n(/Total block memory bits\s*:\s*([\d,]+)/),DSP:n(/Total DSP Blocks\s*:\s*([\d,]+)/),recoverable:n(/\[B\] Estimate of ALMs recoverable[^;]*;\s*([\d,]+)/,rpt),unavailable:n(/\[C\] Estimate of ALMs unavailable[^;]*;\s*([\d,]+)/,rpt),logicALUT:n(/Combinational ALUT usage for logic\s*;\s*([\d,]+)/,rpt),routingALUT:n(/Combinational ALUT usage for route-throughs\s*;\s*([\d,]+)/,rpt)};
 out.timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));
 out.setup=out.timing.length?Math.min(...out.timing.filter(x=>x.type.startsWith('Setup')).map(x=>x.slack)):null;out.hold=out.timing.length?Math.min(...out.timing.filter(x=>x.type.startsWith('Hold')).map(x=>x.slack)):null;out.violations=out.timing.length?out.timing.filter(x=>x.slack<0||x.tns<0).length:null;
 out.fitSuccessful=/Fitter Status\s*:\s*Successful/.test(fit);out.complete=out.fitSuccessful&&out.timing.length>0;out.provisional=!out.complete;
 const files=fs.readdirSync(p.join(folder,'output_files')).filter(f=>/\.(rpt|summary)$/.test(f)).map(f=>p.join(folder,'output_files',f));
 for(const f of ['compile.log','map.log','fit.log','asm.log','sta.log'])if(fs.existsSync(p.join(folder,f)))files.push(p.join(folder,f));
 const all=files.map(read).join('\n');out.warningLines=[...new Set(all.split(/\r?\n/).map(l=>l.trim()).filter(l=>/^(Critical )?Warning(?: \(\d+\))?:/.test(l)))];
 out.warningTypes=[...new Set(out.warningLines.map(l=>(l.match(/Warning \((\d+)\)/)||[])[1]||'unnumbered'))].sort();out.criticalWarnings=out.warningLines.filter(l=>l.startsWith('Critical')).length;
 out.unconstrainedInfo=[...new Set([...all.matchAll(/Design is not fully constrained for (setup|hold) requirements/g)].map(m=>m[1]))];
 const at=rpt.indexOf('; Non-Global High Fan-Out Signals');out.fanout=rpt.slice(at,at+12000).split(/\r?\n/).filter(l=>/;\s*\d+\s*;/.test(l));
 out.ramLines=map.split(/\r?\n/).filter(l=>/M10K block/.test(l)&&/sprite_memory|fm_snapshot|VoiceMemory|EnvelopeMemory/i.test(l));out.buildDate=read(p.join(folder,'build_id.v')).trim();
 out.fitterSeed=n(/Fitter Initial Placement Seed\s*;\s*(\d+)/,rpt);
 assert.equal(out.placed-out.recoverable+out.unavailable,out.needed);out.hashes={fit:sha(fit),sta:sha(sta),map:sha(map)};return out;
}
const manifest=require('./build_'+name+'_inputs.json');for(const[f,h]of Object.entries(manifest.inputs)){
 const actual=sha(fs.readFileSync(p.join(dir,f)));
 if(name==='early'&&f==='SMS.qsf'&&actual!==h){const proof=require('./qsf_export_verification.json');assert(proof.pass);assert.equal(proof.originalSHA,h);assert.equal(proof.expandedSHA,actual);}else assert.equal(actual,h,'built source '+f);
}assert.equal(sha(fs.readFileSync(p.join(dir,'build_id.v'))),manifest.buildIdSHA,'fixed build date');
const stages={};for(const stage of ['map','fit','asm','sta']){const file=p.join(dir,stage+'.log');stages[stage]=!fs.existsSync(file)?'NOT RUN':new RegExp('(?:Analysis & Synthesis|Fitter|Assembler|Timing Analyzer|TimeQuest Timing Analyzer) was successful','i').test(read(file))?'PASSED':'FAILED';}
assert(stages.map==='PASSED');assert(stages.fit==='PASSED'||/Fitter was unsuccessful/.test(read(p.join(dir,'fit.log'))),'fit must be terminal');
const baseline=measure(p.join(root,'tests/savestate_f01_opll_fix/quartus_final')),candidate=measure(dir),totals={needed:41910,placed:41910,registers:167640,M10K:553,memoryBits:5662720,DSP:112},delta={},percent={};
candidate.complete=candidate.complete&&Object.values(stages).every(x=>x==='PASSED');candidate.provisional=!candidate.complete;
assert.equal(baseline.fitterSeed,1);assert.equal(candidate.fitterSeed,manifest.seed,'actual reported fitter seed');
assert.equal(candidate.buildDate,baseline.buildDate);for(const k of ['needed','placed','registers','synthesisRegisters','M10K','memoryBits','DSP','recoverable','unavailable','logicALUT','routingALUT','setup','hold','violations'])delta[k]=candidate[k]===null?null:candidate[k]-baseline[k];for(const[k,v]of Object.entries(totals))percent[k]=100*candidate[k]/v;
const normalize=l=>l.replace(/(?:[A-Z]:)?[\\/][^\s"]*?(?:savestate_g06_sequential_architecture|savestate_f01_opll_fix)[\\/]quartus_[^\\/\s"]+[\\/]/gi,'BUILD/').replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Warning \(12241\): \d+ hierarchies/,'Warning (12241): COUNT hierarchies');
const bw=baseline.warningLines.map(normalize),cw=candidate.warningLines.map(normalize);
const warningDetails={newTypes:candidate.warningTypes.filter(x=>!baseline.warningTypes.includes(x)),removedTypes:baseline.warningTypes.filter(x=>!candidate.warningTypes.includes(x)),newMessages:cw.filter(x=>!bw.includes(x)),removedMessages:bw.filter(x=>!cw.includes(x))};
const result={name,sourceHashesVerified:true,stages,baseline,candidate,totals,delta,percent,warningDetails,snapshotInferred:candidate.M10K===490&&candidate.memoryBits===3827650&&candidate.ramLines.some(l=>/sprite_memory/.test(l)&&/9600/.test(l)),placedRecovered:baseline.placed-candidate.placed,historicalRecoveredPercent:100*(baseline.placed-candidate.placed)/5458,savedPerExtraM10K:(baseline.placed-candidate.placed)/(candidate.M10K-baseline.M10K),M10KRemaining:553-candidate.M10K,seed:manifest.seed,usablePlacedRecovered:candidate.complete&&candidate.violations===0?baseline.placed-candidate.placed:null,classification:candidate.complete?'COMPLETED - REVIEW TIMING':'FIT FAILED - ALL FIT RESOURCE COUNTS PROVISIONAL; NO USABLE PLACED GAIN PROVEN'};
if(name==='final'){const early=require('./early_results.json');result.deltaFromEarly=Object.fromEntries(Object.keys(delta).map(k=>[k,candidate[k]-early.candidate[k]]));}
fs.writeFileSync(p.join(d,name+'_results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({name,candidate:Object.fromEntries([...Object.keys(totals),'setup','hold','violations'].map(k=>[k,candidate[k]])),delta,warningDetails,snapshotInferred:result.snapshotInferred},null,2));
