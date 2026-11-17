const fs=require('fs'),p=require('path'),d=__dirname,old=p.join(d,'../savestate_evolution_pending_fix');
for(const n of ['resource_analysis.js','quartus_results.js']){
 let s=fs.readFileSync(p.join(old,n),'utf8').replaceAll('savestate_evolution_selector_fix/candidate','savestate_evolution_pending_fix/candidate');
 if(n==='quartus_results.js')s=s.replace("sha(path.join(build,p))===h","(p==='SMS.qsf'?require('./verify_qsf')():sha(path.join(build,p))===h)");
 if(n==='resource_analysis.js')s=s.replace(/interpretation:'[^']*'/,"interpretation:'F16 adds a three-bit snapshot, validation/hold controls and two restart phase FFs. Entity-level register and ALM deltas reconcile synthesis changes with physical packing; existing Evolution payload mux retained unchanged.'");
 if(n==='resource_analysis.js')s=s.replace('const result={synthesisRegisters:',"for(const [k,name] of Object.entries({cpuWrapper:'|T80s:z80_inst',cpu:'|T80:u0'}))synthesisEntities[k]={baseline:synthesisEntity(roots.baseline,name),candidate:synthesisEntity(roots.candidate,name)};\nconst result={expectedNewLogicalRegisters:{snapshot:3,valid:1,paddingCheck:1,loadHold:1,restartPhase:2,total:8},synthesisRegisters:");
 if(n==='resource_analysis.js')s=s.replace('function payloadMux(root)',`const mergeName='emu:emu|savestates:savestates_inst|cur_bios_mode';
const mergeReasons=root=>read(path.join(root,'output_files/SMS.map.rpt')).split(/\\r?\\n/).map(l=>l.split(';').map(x=>x.trim())).find(c=>c[1]===mergeName&&/Merged with/.test(c[2]||''));
const bm=mergeReasons(roots.baseline),cm=mergeReasons(roots.candidate);if(!bm||!bm[2].includes('cur_magic[0]')||cm)throw Error('Unexpected register merge evidence');
const biosAssignments=root=>read(path.join(root,'rtl/savestates.sv')).split(/\\r?\\n/).filter(l=>/cur_(bios_mode|magic)\\s*<=/.test(l)).map(l=>l.trim().replace(/\\s+/g,' '));
if(JSON.stringify(biosAssignments(roots.baseline))!==JSON.stringify(biosAssignments(roots.candidate)))throw Error('BIOS assignments changed');
result.registerMergeEvidence={name:mergeName,baseline:bm[2],candidate:'retained separately',unchangedAssignments:biosAssignments(roots.baseline),additionalMappedRegisters:1};
if(result.synthesisDelta!==9||synthesisEntities.savestates.candidate.registers-synthesisEntities.savestates.baseline.registers!==7||synthesisEntities.cpuWrapper.candidate.registers-synthesisEntities.cpuWrapper.baseline.registers!==2)throw Error('Logical +8 and unmerged +1 ledger');
function payloadMux(root)`);
 fs.writeFileSync(p.join(d,n),s);
}
