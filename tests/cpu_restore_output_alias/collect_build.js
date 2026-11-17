const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,measure=require('./measure');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),name=process.argv[2]||'candidate1',dir=p.join(d,'quartus_'+name),manifest=require('./build_'+name+'_inputs.json');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255?'utf16le':'utf8');};
assert.equal(manifest.gateSHA,sha(fs.readFileSync(p.join(d,'functional_gate.json'))));
for(const[f,h]of Object.entries(manifest.inputs))assert.equal(sha(fs.readFileSync(p.join(dir,f))),h,'built input '+f);
assert.equal(sha(fs.readFileSync(p.join(dir,'build_id.v'))),manifest.buildIdSHA);
for(const stage of['map','fit','asm','sta'])assert(/(?:Analysis & Synthesis|Fitter|Assembler|Timing Analyzer|TimeQuest Timing Analyzer) was successful/i.test(read(p.join(dir,stage+'.log'))),'successful '+stage);
const baseDir=name==='candidate2'?p.join(d,'quartus_baseline2'):p.join(d,'../savestate_g08_fm/quartus_early');
const baseline=measure(baseDir),candidate=measure(dir),delta={};for(const k of['needed','placed','registers','synthesisRegisters','M10K','memoryBits','DSP','recoverable','unavailable','logicALUT','routingALUT','setup','hold','violations'])delta[k]=candidate[k]-baseline[k];
const normalize=s=>s.replace(/(?:[A-Z]:)?[\\/][^\s"]*?[\\/]quartus_[^\\/\s"]+[\\/]/gi,'BUILD/').replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Warning \(12241\): \d+ hierarchies/,'Warning (12241): COUNT hierarchies');
const baseCritical=baseline.warningLines.filter(x=>x.startsWith('Critical')).map(normalize),candidateCritical=candidate.warningLines.filter(x=>x.startsWith('Critical')).map(normalize);
const newCritical=candidateCritical.filter(x=>!baseCritical.includes(x));
function hierarchy(folder){const rpt=read(p.join(folder,'output_files/SMS.fit.rpt')),map=read(p.join(folder,'output_files/SMS.map.rpt'));return {fit:rpt.split(/\r?\n/).filter(l=>/\|savestates:savestates_inst\|\s*;/.test(l)),map:map.split(/\r?\n/).filter(l=>/\|savestates:savestates_inst\|\s*;/.test(l)),routing:rpt.split(/\r?\n/).filter(l=>/Average interconnect usage|Peak interconnect usage|Router estimated.*interconnect usage/.test(l))};}
const result={name,sourceHashesVerified:true,baselineSeed:name==='candidate2'?2:1,candidateSeed:manifest.seed,baseline,candidate,delta,newCritical,newWarningTypes:candidate.warningTypes.filter(x=>!baseline.warningTypes.includes(x)),baselineHierarchy:hierarchy(baseDir),candidateHierarchy:hierarchy(dir),packingIdentity:`${candidate.placed} - ${candidate.recoverable} + ${candidate.unavailable} = ${candidate.needed}`,bankDisappearance:'Requires separate fitted-register query before physicalGate can pass',physicalGate:false};
function routingTotal(rows,kind){const row=rows.find(x=>x.includes(kind+' interconnect usage'));assert(row,'final routing '+kind);const m=row.match(/;\s*([\d.]+)%\s*\//);assert(m);return +m[1];}
result.routingTotals={baselineAverage:routingTotal(result.baselineHierarchy.routing,'Average'),baselinePeak:routingTotal(result.baselineHierarchy.routing,'Peak'),candidateAverage:routingTotal(result.candidateHierarchy.routing,'Average'),candidatePeak:routingTotal(result.candidateHierarchy.routing,'Peak')};
fs.writeFileSync(p.join(d,name+'_results.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({name,delta,packingIdentity:result.packingIdentity,newCritical},null,2));
