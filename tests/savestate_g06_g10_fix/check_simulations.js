// Fail closed: ModelSim's process exit status alone does not detect $fatal.
const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),cp=require('child_process');
const d=__dirname,r=p.resolve(d,'../..');
const read=f=>{const b=fs.readFileSync(p.join(d,f));return b[0]===255&&b[1]===254?b.toString('utf16le').slice(1):b.toString();};
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const rows=[];
const refreshed=JSON.parse(read('ring_regression_sources.json'));
assert.equal(sha(p.join(r,'rtl/savestates.sv')),refreshed.productionSHA256);
for(const entry of Object.values(refreshed.families))assert.equal(sha(p.join(d,entry.file)),entry.sha256,'Refreshed controller source changed '+entry.file);
function check(file,pattern,group){const s=read(file);assert(!/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]/.test(s),file+' contains an error');assert(pattern.test(s),file+' incomplete');rows.push({group,file,sha256:sha(p.join(d,file))});return s;}
for(const [dir,pat,prefix]of [['matrix_g01',/PASS G01 TRACE/,'case_'],['matrix_nmi',/PASS F16 fixed/,'case_'],['pause_known',/PASS FIXED/,'']]){
 const cases=JSON.parse(read(dir+'/cases.json'));
 for(const c of cases){const file=`${dir}/${prefix}${c.id}.log`;check(file,pat,dir);assert(fs.statSync(p.join(d,file)).mtimeMs>=fs.statSync(p.join(d,refreshed.families[dir].file)).mtimeMs,'Pre-ring log still present '+file);}
}
for(const c of JSON.parse(read('sprites/cases.json'))){check(`sprites/reference_${c.id}/simulation.log`,/PASS UNINTERRUPTED REFERENCE/,'sprite references');check(`sprites/dut_${c.id}/simulation.log`,/DONE VDP.*checks(?:3000|75000)/,'sprite cases');}
for(const [file,pat,group]of [
 ['candidate/known64_turbo/simulation.log',/DONE VDP.*checks3000/,'known64'],
 ['candidate/known64_natural13_turbo/simulation.log',/DONE VDP.*checks13000/,'known64 natural phase'],
 ['candidate/native13_normal/simulation.log',/DONE VDP.*checks13000/,'normal native phase'],
 ['candidate_g01/ldir_v14.log',/PASS G01 TRACE/,'full flush G01'],
 ['candidate_nmi/sms_edge0_v14.log',/PASS F16 fixed/,'full flush F16'],
 ['psg/dual_psg_replay/simulation.log',/DONE VDP.*checks3000/,'dual PSG'],
 ['systeme/reference_ui0_t0/simulation.log',/PASS UNINTERRUPTED REFERENCE/,'System E references'],
 ['systeme/reference_ui1_t0/simulation.log',/PASS UNINTERRUPTED REFERENCE/,'System E references'],
 ['systeme/dual_systeme_running/simulation.log',/DONE VDP.*checks3000/,'System E'],
 ['systeme/dual_systeme_paused/simulation.log',/DONE VDP.*checks3000/,'System E'],
 ['systeme/dual_systeme_64_running/simulation.log',/DONE VDP.*checks3000/,'System E64'],
 ['format/simulation.log',/PASS V14 FORMAT rejected170 accepted15/,'format'],
 ['stalls/overflow_stall1/simulation.log',/PASS PROTOTYPE SAVE_ONLY observations1000/,'SAVE stalls'],
 ['stalls/overflow_stall2/simulation.log',/PASS PROTOTYPE SAVE_ONLY observations1000/,'SAVE stalls'],
 ['search/history0_64/simulation.log',/PASS NATURAL G06 SEARCH/,'G06 natural64'],
 ['search/history1_64/simulation.log',/PASS NATURAL G06 SEARCH/,'G06 natural64']
 ,['alias_equivalence/simulation.log',/PASS OUTPUT ALIAS EQUIVALENCE/,'synthesis alias equivalence']
 ,['distinct_q/dut/simulation.log',/DONE VDP[\s\S]*PASS DISTINCT_Q three pairwise different accepted guest states/,'distinct Q collision']
 ,['transport_equivalence/simulation.log',/PASS TRANSPORT STREAM EQUIVALENCE outputs91 format185 profiles16 loads48 physicalbits9556/,'sequential transfer equivalence']
])check(file,pat,group);
const phase=read('candidate/known64_natural13_turbo/simulation.log');
const qlog=read('distinct_q/dut/simulation.log');
const qstates=[...qlog.matchAll(/DISTINCT_Q accepted\d+ x\d+ y\d+ PC[0-9a-f]+ CPU([0-9a-f]+) VDP([0-9a-f]+)/gi)].map(m=>m[1]+m[2]);
assert.equal(qstates.length,3,'Three accepted Q states missing');assert.equal(new Set(qstates).size,3,'CPU/VDP Q states must differ even without the beam');
assert.equal(sha(p.join(d,'distinct_q/dut/image.hex')),sha(p.join(d,'candidate/known64_turbo/image.hex')),'Distinct-Q run must use the same complete known image');
const phases=[...new Set([...phase.matchAll(/NATURAL_TRANSPORT_PHASE (\d+)/g)].map(m=>+m[1]))].sort((a,b)=>a-b);
assert.deepEqual(phases,[1,3,7,9,11,13,17,19,21,23,27,29]);
const image0=p.join(d,'search/history0_64/image.hex'),image1=p.join(d,'search/history1_64/image.hex');
const suffix0=p.join(d,'search/history0_64/suffix.dat'),suffix1=p.join(d,'search/history1_64/suffix.dat');
assert.equal(sha(image0),sha(image1),'Natural64 complete images differ');assert.equal(sha(suffix0),sha(suffix1),'Natural64 futures differ');
const manifest=JSON.parse(read('build_sources.json'));
assert.equal(sha(p.join(r,'rtl/vdp_sprites.vhd')),sha(p.join(d,'alias_equivalence/new_sprites.vhd')),'Alias miter source changed');
for(const [f,h]of Object.entries(manifest)){assert.equal(sha(p.join(r,f)),h,'Current production source changed '+f);assert.equal(sha(p.join(d,'quartus',f)),h,'Build source changed '+f);}
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:r}).toString().trim(),'8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a');
const counts={};for(const row of rows)counts[row.group]=(counts[row.group]||0)+1;
const result={status:'PASS',checkedAt:new Date().toISOString(),logCount:rows.length,counts,legalPhases:phases,natural64:{imageSha256:sha(image0),suffixSha256:sha(suffix0)},logs:rows};
fs.writeFileSync(p.join(d,'simulation_results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({...result,logs:undefined},null,2));
