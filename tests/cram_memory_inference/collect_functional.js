const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),cp=require('child_process');
const d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>fs.readFileSync(p.join(d,f),'utf8');
const baseline=require('./baseline.json'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
cp.execFileSync(process.execPath,[p.join(d,'source_bridge.js')],{stdio:'inherit'});
const hashes={},logs=[];
function pass(file,marker){const s=read(file);assert(s.includes(marker),file+' marker');assert(/Errors: 0/.test(s),file+' completion');assert(!/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]|Failed to open (?:readmem|file)/.test(s),file+' error');logs.push({file,sha256:sha(s),marker});return s;}
const component=pass('component.log','PASS CRAM COMPONENT checks207492 same_address25051 priority_checks14461 scans206 loads3');
assert.equal(read('vdp_cram_candidate.vhd').replaceAll('vdp_cram_candidate','vdp_cram'),fs.readFileSync(p.join(root,'rtl/vdp_cram.vhd'),'utf8'));
const native=[];
for(const c of require('./native_manifest.json')){
 const s=pass('native_'+c.family+'/'+c.name+'/simulation.log',c.marker);assert(s.includes('PASS CRAM NATIVE SNAPSHOT'));
 // image.hex is exported by the DUT run, not consumed as an input.
 for(const f of c.fixtures.filter(f=>f.file!=='image.hex'))assert.equal(sha(fs.readFileSync(p.join(root,c.dir,f.file))),f.sha256,c.dir+'/'+f.file);
 const m=s.match(/saveonly(\d+) checks(\d+) lineDiagnostics0/);assert(m,c.name+' original suffix oracle');
 native.push({family:c.family,name:c.name,saveOnlyChecks:+m[1],loadChecks:+m[2],snapshotChecks:(s.match(/PASS CRAM NATIVE SNAPSHOT/g)||[]).length});
}
const phase=read('native_g10/dut_phases/simulation.log'),targets=[...phase.matchAll(/NATURAL_TRANSPORT_PHASE (\d+)/g)].map(m=>+m[1]);
assert.deepEqual(targets,[1,3,7,9,11,13,17,19,21,23,27,29]);
pass('baseline_g10/dut_phases/simulation.log','checks13000 lineDiagnostics0');
pass('baseline_g03/dut_bus/simulation.log','pendingWrite0');
pass('format/simulation.log','PASS V19 FORMAT rejected2098 accepted420');
pass('imports/simulation.log','PASS IMPORT ALL loads22');
for(const kind of ['candidate','reference']){
 pass('image_'+kind+'/simulation.log','PASS CRAM IMAGE ALL images16 loads48');
 assert(read('image_'+kind+'/simulation.log').includes('PASS CRAM LEGACY64 SYSTEME secondary_retained'));
}
const image=fs.readFileSync(p.join(d,'image_candidate/images.hex'));assert(image.equals(fs.readFileSync(p.join(d,'image_reference/images.hex'))),'complete v19 images differ');
const negative=read('pilots/image_negative/simulation.log');assert(/\*\* Fatal:.*legacy64 System E changed live secondary palette/.test(negative),'required negative witness');
const current=adapter(p.join(root,'rtl/savestates.sv'));
const canon=s=>s.replace(/\/\/[^\n]*/g,'').replace(/\/\*[\s\S]*?\*\//g,'').replace(/\s+/g,'');
assert.equal(canon(read('pilots/image_negative/savestates_sim.sv')),canon(current).replace('if(do_save||systeme)begincram_entry','if(do_save)begincram_entry'),'negative control isolates System E LOAD scan');
for(const sub of ['format','imports','image_candidate'])assert.equal(read(sub+'/savestates_sim.sv'),current,sub+' selected controller');
assert.equal(read('image_reference/savestates_sim.sv'),adapter(p.join(d,'baseline/rtl/savestates.sv')),'image reference is committed v19');
const changed=[];
for(const {file,sha256} of baseline.tracked){const h=sha(fs.readFileSync(p.join(root,file)));if(h!==sha256){changed.push(file);hashes[file]=h;}}
assert.deepEqual(changed.sort(),['SMS.sv','rtl/savestates.sv','rtl/system.vhd','rtl/vdp.vhd','rtl/vdp_cram.vhd'].sort());
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),baseline.head);
assert.equal(cp.execFileSync('git',['branch','--show-current'],{cwd:root,encoding:'utf8'}).trim(),baseline.branch);
assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');
const result={passed:true,head:baseline.head,branch:baseline.branch,format:19,sourceHashes:hashes,unchangedTracked:baseline.tracked.length-changed.length,logs,native,targets,component:{checks:207492,randomHostEdges:200000,sameAddress:25051,priorityChecks:14461,scans:206},wholeImages:{count:16,loads:48,legacy64SystemELoads:1,bytes:image.length,sha256:sha(image),exact:true},format:{rejected:2098,accepted:420},imports:22,sourceBridgeSHA:sha(read('source_bridge.json')),negativeControl:{expectedFailure:true,sha256:sha(negative)},limitations:['Finite directed/random simulation plus source-level contract proof; no claim of exhaustive formal verification.','Protocol metadata profiles exercise all four saved phase codes but are not all asserted naturally reachable CPU states.','Native copied VDPs have read-only observation taps; source_bridge.json verifies production transition logic.']};
fs.writeFileSync(p.join(d,'candidate_sources.json'),JSON.stringify(Object.entries(hashes).map(([file,sha256])=>({file,sha256})),null,2)+'\n');
fs.writeFileSync(p.join(d,'functional_gate.json'),JSON.stringify(result,null,2)+'\n');console.log('PASS FUNCTIONAL GATE: 16 native cases, component miter, complete images, legacy System E, format and imports.');
