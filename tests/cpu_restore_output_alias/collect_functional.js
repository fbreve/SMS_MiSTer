const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255?'utf16le':'utf8');};
const rows=[{dir:'imports',marker:'PASS IMPORT ALL loads22'},{dir:'images',marker:'PASS CRAM IMAGE ALL images16 loads48'},{dir:'errors',marker:'PASS ALIAS ERRORS ALL timeouts2 recoveries3 reset_private'},...Array.from({length:8},(_,i)=>({dir:'malformed_parallel/s'+i,marker:'PASS ALIAS MALFORMED SHARD'+i+' rejected'})),...require('./native_manifest.json')];
for(const x of require('./g01_cases.json'))rows.push({dir:'native_g01/p'+x.args.PROGRAM,marker:'PASS G01 TRACE',args:x.args});
for(const x of require('./nmi_cases.json'))rows.push({dir:'native_nmi/'+x.name,marker:'PASS F16 fixed',args:x});
for(const n of['s0_c0','s0_c1','s1_c0','s1_c1'])rows.push({dir:'native_pause/'+n,marker:'PASS G12 LOAD_RUNNING'});
const evidence=[],pending=[],failed=[];let total={cycles:0,consumes:0,inactive:0,writes:0,reads:0};
for(const item of rows){const file=p.join(d,item.dir,'simulation.log');if(!fs.existsSync(file)){pending.push(item.dir);continue;}const s=read(file);
 if(/\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open/.test(s)){failed.push(item.dir);continue;}
 const m=s.match(/ALIAS MITER cycles(\d+) consumes(\d+) inactive(\d+) writes(\d+) reads(\d+)/);
 if(!s.includes(item.marker)||!m||!/End time:/.test(s)||!/Errors: 0/.test(s)){pending.push(item.dir);continue;}
 const counters=Object.fromEntries(Object.keys(total).map((k,i)=>[k,+m[i+1]]));assert(counters.consumes>0,item.dir+' must consume real DIR');for(const k of Object.keys(total))total[k]+=counters[k];
 const folder=p.dirname(file),sourceDir=/^(native_|malformed_parallel)/.test(item.dir)?p.dirname(folder):folder;
 const compiled={};for(const f of fs.readdirSync(sourceDir)){const q=p.join(sourceDir,f);if(fs.statSync(q).isFile()&&/\.(sv|svh|vhd|v|do)$/.test(f))compiled[f]=sha(fs.readFileSync(q));}
 const baselineName=fs.existsSync(p.join(sourceDir,'savestates_integrated.sv'))?'savestates_integrated.sv':'savestates_sim.sv';
 assert.equal(compiled[baselineName],sha(fs.readFileSync(p.join(d,'baseline_sim.sv'))),item.dir+' exact v19 controller');
 assert.equal(compiled['candidate_sim.sv'],sha(fs.readFileSync(p.join(d,'candidate_sim.sv'))),item.dir+' exact isolated candidate');
 const fixtures={};for(const f of fs.readdirSync(folder)){const q=p.join(folder,f);if(fs.statSync(q).isFile()&&/\.(do|dat|hex|bin)$/.test(f))fixtures[f]=sha(fs.readFileSync(q));}
 evidence.push({...item,counters,compiled,fixtures,logSHA:sha(fs.readFileSync(file)),passes:s.split(/\r?\n/).filter(l=>/PASS|NATIVE_ENABLE_ORDER|TRANSPORT_DURATION|normalized|ACCEPT_REG/.test(l))});
}
console.log(JSON.stringify({passed:evidence.length,pending,failed,total},null,2));
if(process.argv.includes('--final')){
 assert.equal(failed.length,0,'unexplained functional mismatch');assert.equal(pending.length,0,'all functional gates must complete');require('./verify');require('./source_bridge');
 const rejected=new Set();let rejects=0;for(let i=0;i<8;i++){const s=read(p.join(d,'malformed_parallel/s'+i+'/simulation.log'));for(const m of s.matchAll(/REJECT word([0-9a-f]+) bit(\d+)/g)){rejects++;rejected.add(m[1]+':'+m[2]);}}assert.equal(rejects,321);assert.equal(rejected.size,321,'all focused malformed cases exactly once');
 const bridge=require('./source_bridge.json');const image=fs.readFileSync(p.join(d,'images/images.hex'),'utf8').trim().split(/\r?\n/);assert.equal(image.length,16*12288);assert(image.every(x=>/^[0-9a-f]{16}$/.test(x)));
 const tags=evidence.find(x=>x.dir==='imports').passes;assert(tags.some(x=>/version18/.test(x))&&tags.some(x=>/version-1/.test(x)));
 const groups=new Set(evidence.filter(x=>x.dir.startsWith('native_nmi/')).flatMap(x=>x.passes.map(l=>(l.match(/normalized([01]{3})/)||[])[1]).filter(Boolean)));assert.equal(groups.size,8,'all NMI history triplets');
 const sourceFiles=['candidate/rtl/savestates.sv','baseline_sim.sv','candidate_sim.sv','consumer_proof.md','miter_controller.svh'];const sourceHashes=Object.fromEntries(sourceFiles.map(f=>[f,sha(fs.readFileSync(p.join(d,f)))]));
 const gate={passed:true,head:require('./provenance.json').head,candidateSHA:bridge.candidateSHA,sourceHashes,evidence,total,fullImageWords:image.length,fullImageSHA:sha(fs.readFileSync(p.join(d,'images/images.hex'))),nmiTriplets:[...groups].sort(),note:'Every controller output except unused DIR payload compared every host edge; all230 DIR bits compared at every DIRSet; real consumer outputs/state compared without masks. Full images proved by identical accepted write transactions and known complete image words.'};
 fs.writeFileSync(p.join(d,'functional_gate.json'),JSON.stringify(gate,null,2)+'\n');console.log('PASS complete source-bound functional gate. Physical trial is now eligible.');
}
