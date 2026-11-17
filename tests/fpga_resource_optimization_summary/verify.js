const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),hash=f=>crypto.createHash('sha256').update(fs.readFileSync(p.join(root,f))).digest('hex');
const git=a=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:root}).toString().trim();
const old=JSON.parse(fs.readFileSync(p.join(root,'tests/sprite_cache_netlist_connectivity/provenance.json')));
const files=new Map(Object.entries(old.retained));
for(const r of old.tracked)files.set(r.file,r.sha256);
for(const r of old.inputs)files.set('tests/savestate_g08_fm/quartus_early/'+r.file,r.sha256);
const reports=['structural_resource_audit','savestate_resource_growth','savestates_internal_cost_audit','savestate_sprite_resource_optimization','savestate_g06_sequential_architecture','g06_g10_storage_optimization','sprite_restore_architecture_feasibility','cpu_restore_output_alias','cpu_restore_alias_timing_diagnosis','cpu_restore_alias_seed2_pair','cram_memory_inference','non_savestate_optimization_audit','sprite_cache_selector_netlist_diagnosis','sprite_cache_netlist_connectivity','savestate_format_consolidation','savestate_f01_opll_architecture','savestate_f01_opll_fix','savestate_f06_sega_sram_fix','savestate_g08_fm'];
for(const dir of reports){const folder=p.join(root,'tests',dir);if(!fs.existsSync(folder))continue;for(const f of fs.readdirSync(folder)){const rel='tests/'+dir+'/'+f;if(fs.statSync(p.join(root,rel)).isFile()&&/\.(md|json|js)$/.test(f)&&!files.has(rel))files.set(rel,hash(rel));}}
const outFile=p.join(__dirname,'preservation_before.json'),after=process.argv.includes('--after');
const before=after?JSON.parse(fs.readFileSync(outFile)):null;
const checks=after?Object.entries(before.hashes):[...files];
for(const [f,h]of checks)assert.equal(hash(f),h,f);
assert.equal(git(['rev-parse','HEAD']),old.head);assert.equal(git(['branch','--show-current']),old.branch);assert.equal(git(['diff','--stat']),'');assert.equal(git(['diff','--cached','--stat']),'');assert.equal(git(['status','--short']),old.status);
let normalized=0;for(const r of old.inputs){if(/\.(bak|orig)$/.test(r.file))continue;const b=cp.execFileSync('git',['show','HEAD:'+r.file],{cwd:root}).toString().replaceAll('\r\n','\n');assert.equal(fs.readFileSync(p.join(root,'tests/savestate_g08_fm/quartus_early',r.file),'utf8').replaceAll('\r\n','\n'),b,r.file);normalized++;}
const baseline=require('../cpu_restore_output_alias/measure')(p.join(root,'tests/savestate_g08_fm/quartus_early'));
assert.deepEqual([baseline.needed,baseline.placed,baseline.synthesisRegisters,baseline.registers,baseline.logicALUT,baseline.routingALUT,baseline.M10K,baseline.setup,baseline.hold],[37117,38599,46327,48880,46835,18266,488,.104,.239]);
const result={passed:true,head:old.head,branch:old.branch,version:'v19 / 0x484313',tracked:old.tracked.length,buildInputs:old.inputs.length,normalizedHeadMatches:normalized,priorLedgerEntries:Object.keys(old.retained).length,verifiedFiles:checks.length,hashes:Object.fromEntries(checks),baseline,diffStat:git(['diff','--stat']),stagedDiffStat:git(['diff','--cached','--stat']),status:git(['status','--short']),newToolOrSimulationRuns:false};
fs.writeFileSync(after?p.join(__dirname,'preservation_after.json'):outFile,JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({passed:true,phase:after?'after':'before',verifiedFiles:checks.length,tracked:result.tracked,buildInputs:result.buildInputs,normalizedHeadMatches:normalized,head:result.head,branch:result.branch,status:result.status,needed:baseline.needed,placed:baseline.placed,setup:baseline.setup,hold:baseline.hold}));
