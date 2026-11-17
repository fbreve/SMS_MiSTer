const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>fs.readFileSync(p.join(d,f),'utf8');
const base=JSON.parse(read('baseline.json')),gate=JSON.parse(read('pre_edit_gate.json')),bridge=JSON.parse(read('final_source_bridge.json'));assert(gate.pass);
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),base.head);
assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');
assert.equal(cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'SMS.sv');
for(const[f,h]of Object.entries(base.files))if(f!=='SMS.sv')assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'unrelated source '+f);
const top=fs.readFileSync(p.join(root,'SMS.sv'),'utf8'),eol=top.includes('\r\n')?'\r\n':'\n';
const proposed=['\t// Private CPU replay uses /15 even in System E/turbo. Align the ROM','\t// acceptance slot with its T1 so the restored read completes before T2.','\t.clkref((ss_cpu_prepare || !(systeme || turbo)) ? ce_cpu : ce_pix),'].join(eol);
assert.equal(sha(top.replace(proposed,'\t.clkref(systeme ? ce_pix : turbo ? ce_pix : ce_cpu),')),base.files['SMS.sv'],'unexpected top change');assert.equal(sha(top),bridge.topSha256);
const logs=new Map();for(const item of gate.logs){assert.equal(sha(read(item.file)),item.sha256,'pre-edit evidence changed '+item.file);logs.set(item.file,item);}
function log(f,marker){const s=read(f);assert(s.includes(marker)&&s.includes('# End time:')&&!/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]/.test(s),'failed/incomplete '+f);logs.set(f,{file:f,sha256:sha(s)});return s;}
function image(f){const a=read(f).split(/\r?\n/).filter(x=>x&&!x.startsWith('//'));assert(a.length===12288&&a.every(x=>/^[\da-f]{16}$/i.test(x)),'unknown image '+f);assert.equal(Number((BigInt('0x'+a[0x1a])>>40n)&0xffffffn),0x484310);const b=Buffer.alloc(98304);a.forEach((x,i)=>b.writeBigUInt64LE(BigInt('0x'+x),i*8));return sha(b);}
for(const suite of ['final_matrix','final_protocol']){
 assert.equal(read(suite+'/savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')));
 assert(read(suite+'/audio_tb.sv').includes('.clkref('+bridge.simulationExpression+')'));
 assert.equal(read(suite+'/sdram.v'),read('baseline/sdram.v'));
}
const cases=[...JSON.parse(read('final_matrix/cases.json')),...JSON.parse(read('final_matrix/focused_cases.json'))];let loads=0,comparisons=0;const records=[];
for(const c of cases){const prefix='final_matrix/'+c.id;log(prefix+'/reference.log','PASS MATRIX REFERENCE');const s=log(prefix+'/replay.log',`PASS MATRIX replays${c.args.REPLAYS} N${c.args.N}`);
 const suffix=[...s.matchAll(/PASS SUFFIX pass(\d+) samples(\d+)/g)];assert.equal(suffix.length,c.args.REPLAYS+1);assert(suffix.every(m=>+m[2]===c.args.N));
 const m=s.match(/G12_LEDGER accepted(\d+) returned(\d+) physical(\d+) flight([01])/);assert(m);assert.equal(+m[1],+m[2]+ +m[4]);assert(+m[3]>=+m[2]&&+m[3]<=+m[1]);
 if(c.args.TRANSFER)assert.equal((s.match(/PASS SHARED_TRANSFER/g)||[]).length,c.args.REPLAYS);
 loads+=c.args.REPLAYS;comparisons+=(c.args.REPLAYS+1)*c.args.N;records.push({id:c.id,loads:c.args.REPLAYS,sha256:image(prefix+'/image.hex'),ledger:{accepted:+m[1],returned:+m[2],physical:+m[3],flight:+m[4]}});
}
const protocolCases=[];
for(const saved of [0,1])for(const current of [0,1])protocolCases.push({saved,current,delay:8,fast:1,tac:1});
for(const delay of [0,1,6,7,9,10,14,15,20,24,29])protocolCases.push({saved:1,current:0,delay,fast:1,tac:1});
for(const tac of [0,7])protocolCases.push({saved:1,current:0,delay:8,fast:1,tac});
protocolCases.push({saved:1,current:0,delay:8,fast:0,tac:1});
const protocol=[];for(const c of protocolCases){const prefix=`final_protocol/s${c.saved}_c${c.current}_d${c.delay}_f${c.fast}`+(c.tac===1?'':`_t${c.tac}`),s=log(prefix+'/simulation.log','PASS G12 LOAD_RUNNING');assert(s.includes('PASS_REISSUE'));protocol.push({...c,log:prefix+'/simulation.log',image:image(prefix+'/image.hex')});if(c.saved===1)assert.equal(image(prefix+'/image.hex'),gate.witnessImage);}
const a=records.find(c=>c.id==='history_0'),b=records.find(c=>c.id==='history_1');assert.equal(a.sha256,b.sha256);
const omitted=[0,1].map(n=>read(`final_matrix/history_${n}/replay.log`).match(/G12_ACCEPT[^\n]+retainedAddr([\da-f]+) retainedData([\da-f]+)/i).slice(1));assert.notEqual(omitted[0][0],omitted[1][0]);assert.notEqual(omitted[0][1],omitted[1][1]);
const required=['savestate_g12_sdram','savestate_g_closure','savestate_systeme_pause_fix','savestate_g01_cpu_restart_fix','savestate_g06_g10_fix','savestate_g08_release_fix'];
const result={pass:true,head:base.head,format:16,productionFiles:['SMS.sv'],sourceBridge:bridge,preEditGateSha256:sha(read('pre_edit_gate.json')),preEdit:{cases:gate.integrationCases,loads:gate.integrationLoads,comparisons:gate.comparisons},final:{integrationCases:cases.length,integrationLoads:loads,exactHostClockComparisons:comparisons,protocolCases:protocol.length,protocolLoads:protocol.length,g01Cases:10,g01Loads:30,g01Comparisons:364030},cases:records,protocol,historyPair:{sha256:a.sha256,omitted,futuresEqual:true},guestDivergences:0,uniqueCanonicalRuntimeLogs:logs.size,logs:[...logs.values()],reportsRead:Object.fromEntries(required.map(n=>[n,sha(fs.readFileSync(p.join(root,'tests',n,'review.md')))]))};
fs.writeFileSync(p.join(d,'simulation_results.json'),JSON.stringify(result,null,2));console.log(JSON.stringify({pass:true,final:result.final,uniqueCanonicalRuntimeLogs:logs.size}));
