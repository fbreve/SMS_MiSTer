const fs=require('fs'),p=require('path'),c=require('crypto'),cp=require('child_process'),assert=require('assert'),d=__dirname,phys=p.join(d,'physical_seed2'),r=JSON.parse(fs.readFileSync(p.join(phys,'results.json'))),m=JSON.parse(fs.readFileSync(p.join(phys,'inputs.json')));
const sha=b=>c.createHash('sha256').update(b).digest('hex'),read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const autoDir=p.resolve(d,'../ym2413_registermemory_auto/physical_seed2'),ar=JSON.parse(read(p.join(autoDir,'results.json'))),am=JSON.parse(read(p.join(autoDir,'inputs.json')));
for(const [f,v]of Object.entries(am.builds.candidate.inputs)){
 const bytes=fs.readFileSync(p.join(autoDir,'candidate',f));assert.equal(sha(bytes),v.SHA256);
 let expected=bytes.toString('latin1');if(f==='rtl/VM2413/registermemory.vhd')expected=expected.replace('attribute ramstyle of regs_array : signal is "AUTO";','attribute ramstyle of regs_array : signal is "MLAB";');
 assert.equal(fs.readFileSync(p.join(phys,'candidate',f)).toString('latin1'),expected,'AUTO matched configuration '+f);
}
for(const [f,h]of Object.entries(ar.builds.candidate.reportHashes))assert.equal(sha(fs.readFileSync(p.join(autoDir,'candidate/output_files',f))),h,'AUTO reference changed '+f);
assert.deepEqual(r.expandedSettingDifferences,{onlyBaseline:[],onlyCandidate:[]});assert.deepEqual(r.fitterSettingDifferences,{onlyBaseline:[],onlyCandidate:[]});
assert.deepEqual(r.otherMemoryDifferences,{onlyReference:[],onlyCandidate:[]});
const rm=r.memoryImplementation.candidate,row=rm.registerMemory[0],get=k=>row[rm.header.indexOf(k)];assert.equal(rm.registerMemory.length,1);assert.equal(get('M10K blocks'),'0');assert(+get('MLAB cells')>0);
assert.equal(get('Mode'),'Simple Dual Port');assert.equal(get('Implementation Port B Width'),'22');
for(const [label,f]of [['reference','reference/registermemory.vhd'],['candidate','candidate/registermemory.vhd'],['bankTB','bank_tb.vhd']])assert.equal(sha(fs.readFileSync(p.join(d,'smoke',f))),m.smokeInputs[label]);
let idleInvocations=0;for(const name of ['compile_reference','compile_candidate','compile_tb','bank']){
 assert.equal(read(p.join(d,'smoke',name+'.exitcode')).trim(),'0');const log=read(p.join(d,'smoke',name+'.priority.log'));assert(/Priority=Idle ParentPriority=Idle/.test(log));assert(+log.match(/VerifiedIdleSamples=(\d+)/)[1]>0);idleInvocations++;
}
assert(read(p.join(d,'smoke/bank.stdout.log')).includes('PASS BANK ALL cycles=16174 independent_checks=48524 channels=9'));
const vendor=read(p.join(d,'smoke/collision_valid.log'));assert(vendor.includes('PASS VENDOR MLAB OLD_DATA'));assert(!/\*\* (Fatal|Error|Failure):/.test(vendor));
const wt=p.join(d,'worktree'),git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:wt,stdio:['ignore','pipe','pipe']});
assert.equal(git('rev-parse','HEAD').toString().trim(),m.baseline);assert.equal(git('branch','--show-current').toString().trim(),m.candidate.branch);assert.equal(git('diff','--cached').toString(),'');assert.equal(git('diff','--name-only',m.baseline).toString().trim(),'rtl/VM2413/registermemory.vhd');
assert.equal(git('diff',m.baseline,'--','SMS.sv','files.qip','rtl/','sys/').toString(),fs.readFileSync(p.join(d,'production.diff'),'utf8'));
const metrics=['neededALMs','placedALMs','fittedRegisters','mappedRegisters','MLABcells','MLABbits','memoryALMs','M10K','memoryBits','logicALUTs','routingALUTs','setupSlack','setupTNS','holdSlack','holdTNS'];
const b=r.builds.candidate,full=r.builds.baseline,a=ar.builds.candidate;
const preservation=JSON.parse(read(p.join(d,'preservation_before.json'))),gitat=(cwd,...args)=>cp.execFileSync('git',['--no-optional-locks',...args],{cwd,stdio:['ignore','pipe','pipe']});
for(const [w,v]of Object.entries(preservation.worktrees)){assert.equal(gitat(w,'rev-parse','HEAD').toString().trim(),v.HEAD);assert.equal(sha(gitat(w,'diff','--binary','HEAD')),v.diff);assert.equal(gitat(w,'status','--porcelain','--untracked-files=no').toString(),v.status);}
assert.equal(gitat(p.resolve(d,'../..'),'rev-parse','master').toString().trim(),preservation.master);
const toolEvidence={};for(const [name,file]of Object.entries({ghdl:p.resolve(d,'../ym2413_selfhealing_combined/tools/ghdl6/bin/ghdl.exe'),modelsim:'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',cyclonevAtoms:'C:/intelFPGA_lite/17.0/quartus/eda/sim_lib/cyclonev_atoms.v',generatedMLAB:p.join(phys,'candidate/db/dpram_iop1.tdf')}))toolEvidence[name]={file,SHA256:sha(fs.readFileSync(file))};
fs.writeFileSync(p.join(d,'simulation_tools.json'),JSON.stringify(toolEvidence,null,2)+'\n');
const comparison=Object.fromEntries(metrics.map(k=>[k,{logic:full[k],AUTO:a[k],MLAB:b[k],MLABminusLogic:+(b[k]-full[k]).toFixed(6),MLABminusAUTO:+(b[k]-a[k]).toFixed(6)}]));
r.comparison=comparison;r.smoke={PASS:true,idleInvocations,ghdlConcurrency:1,bankCycles:16174,independentChecks:48524,vendorCycles:12297,vendorChecks:24576,collisions:4105,disabledOutputCycles:586,scope:'RTL bank smoke and generated-primitive structural probe; no full post-fit simulation or hardware test'};
fs.writeFileSync(p.join(phys,'results.json'),JSON.stringify(r,null,2)+'\n');fs.writeFileSync(p.join(d,'results.json'),JSON.stringify({comparison,sourceHash:m.sourceHash,RBF:r.preservedRBF,critical:b.paths.setup[0],registerMemory:Object.fromEntries(rm.header.map((h,i)=>[h,row[i]])),smoke:r.smoke,preservation:r.preservation},null,2)+'\n');
const hashes={};function scan(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const f=p.join(dir,e.name);if(e.isDirectory()){if(['physical_seed2','candidate','output_files','smoke'].includes(e.name))scan(f);}else if(/\.(rpt|summary|log|json|js|ps1|tcl|md|diff|rbf|vhd|sv|do)$/.test(e.name)&&!['artifact_hashes.json','finalize.log'].includes(e.name))hashes[p.relative(d,f).replace(/\\/g,'/')]={bytes:fs.statSync(f).size,SHA256:sha(fs.readFileSync(f))};}}
scan(d);fs.writeFileSync(p.join(d,'artifact_hashes.json'),JSON.stringify(hashes,null,2)+'\n');console.log(JSON.stringify({PASS:true,comparison,critical:b.paths.setup[0],regMemory:Object.fromEntries(rm.header.map((h,i)=>[h,row[i]])),RBF:r.preservedRBF,preservation:r.preservation},null,2));
