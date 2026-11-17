const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),baseline='9873761503510e4b2c7e06600bf5515344235c2f';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:root,stdio:['pipe','pipe','pipe']});
assert.equal(git('rev-parse','HEAD').toString().trim(),baseline);assert.equal(git('branch','--show-current').toString().trim(),'experiment/ym2413-selfhealing-mix');
const changed=git('diff','--name-only','--','rtl/','sys/','SMS.sv','files.qip').toString().trim().split('\n');assert.deepEqual(changed,['rtl/VM2413/temporalmixer.vhd']);
const normal=b=>b.toString('latin1').replace(/\r\n/g,'\n');assert.equal(normal(fs.readFileSync(p.join(root,changed[0]))),normal(git('show',baseline+':'+changed[0])).replace('mix <= ss_v_mix;','-- Accumulator-only experiment: mix is cleared by its normal end-of-cycle update.'));
const crossA=normal(fs.readFileSync(p.join(d,'cross_engine/modelsim70.csv'))),crossB=normal(fs.readFileSync(p.join(d,'cross_engine/ghdl70.csv')));assert.equal(crossA,crossB);
const result={status:'PASS',baseline,branch:'experiment/ym2413-selfhealing-mix',format:{words:104,version:17},clock:{hostPeriodPs:18684,FMhostPeriods:15,PALhostPeriods:1070460,NTSChostPeriods:896040},crossEngine:{phase:70,normalizedTraceSHA256:hash(Buffer.from(crossA)),rows:crossA.trim().split('\n').length},cases:[],sources:{},simulator:{}};
const files=git('ls-files','--','SMS.sv','files.qip','rtl/VM2413/','rtl/opll_snapshot.sv','rtl/savestates.sv','rtl/system.vhd','rtl/video.vhd','tests/ym2413_fullstate/').toString().trim().split('\n');
for(const f of files)result.sources[f]=hash(fs.readFileSync(p.join(root,f)));
for(const f of ['acc_tb.vhd','acc_native_tb.vhd','acc_run.do','acc_campaign.ps1','acc_one.ps1','native_campaign.ps1','native_one.ps1','native_compile.ps1','prepare_native.js','instrument_oracle.js','candidate_wrapper.vhd','reference_wrapper.vhd','acc_compile.do','collect_acc.js','verify_preservation.js','negative_control.ps1','ACCUMULATOR_EXPERIMENT.md'])result.sources['tests/ym2413_fullstate/'+f]=hash(fs.readFileSync(p.join(d,f)));
for(const folder of ['candidate','reference','native_candidate','native_reference'])for(const f of fs.readdirSync(p.join(d,folder)).filter(f=>f.endsWith('.vhd')))result.sources['tests/ym2413_fullstate/'+folder+'/'+f]=hash(fs.readFileSync(p.join(d,folder,f)));
result.simulator.GHDL={version:'6.0.0',archiveSHA256:hash(fs.readFileSync(p.resolve(root,'../tools/ghdl-mcode-6.0.0-mingw64.zip'))),executableSHA256:hash(fs.readFileSync(p.resolve(root,'../tools/ghdl6/bin/ghdl.exe')))};
result.simulator.ModelSim={version:'10.5b',executableSHA256:hash(fs.readFileSync('C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'))};
const control=fs.readFileSync(p.join(d,'negative_control/restored_mix.log'));assert.notEqual(+fs.readFileSync(p.join(d,'negative_control/restored_mix.exitcode'),'utf8').replace(/^\uFEFF/,''),0);assert(control.toString(control[0]===255&&control[1]===254?'utf16le':'utf8').includes('poison did not survive omitted restore'));result.negativeControl={status:'PASS: incorrect restoration rejected before unfreeze',logSHA256:hash(control)};
for(let shift=0;shift<72;shift++){
 const prefix=p.join(d,'native_runs/shift'+shift),log=fs.readFileSync(prefix+'.log'),text=log.toString(log[0]===255&&log[1]===254?'utf16le':'utf8');assert.equal(+fs.readFileSync(prefix+'.exitcode','utf8').replace(/^\uFEFF/,''),0);assert(!/assertion (failure|error)/.test(text));assert(text.includes('PASS ACC_NATIVE ALL checkpoints=28'));
 const passes=[...text.matchAll(/PASS ACC shift=(\d+) pass=(\d+) reset_ce=(\d+) full_ce=(\d+) total_ce=(\d+) PALedges=(\d+) NTSCedges=(\d+) hosts=(\d+)/g)].map(m=>({pass:+m[2],resetCE:+m[3],fullCE:+m[4],totalCE:+m[5],PALedges:+m[6],NTSCedges:+m[7],hosts:+m[8]}));assert.equal(passes.length,4);
 const poisons=[...text.matchAll(/POISON shift=\d+ pass=(\d+) kind_id=(\d+) saved=(\d+) injected=(\d+)/g)].map(m=>({pass:+m[1],kind:+m[2],saved:+m[3],injected:+m[4]}));assert.equal(poisons.length,4);
 const stimulus=[...text.matchAll(/PASS STIMULUS shift=\d+ pass=(\d+) egstate=(\d+)/g)].map(m=>({pass:+m[1],egstate:+m[2]}));assert.equal(stimulus.length,4);
 const video={PAL:[],NTSC:[]};for(const m of text.matchAll(/VIDEO (PAL|NTSC) pass=(\d+) edge=(\d+) host=(\d+)/g))video[m[1]].push({pass:+m[2],edge:+m[3],host:+m[4]});
 const reset=(70-shift+72)%72+1,full=reset+72;
 passes.forEach((x,i)=>{assert.equal(x.pass,i);assert.equal(x.resetCE,reset);assert.equal(x.fullCE,full);assert(x.PALedges>=6&&x.NTSCedges>=6);assert(x.totalCE>full+5*71364);});
 poisons.forEach((x,i)=>{assert.equal(x.pass,i);assert.notEqual(x.injected,x.saved);if(i===2)assert((x.injected^x.saved)&8192);});
 for(const [mode,list]of Object.entries(video))for(let pass=0;pass<4;pass++){
  const events=list.filter(e=>e.pass===pass);assert(events.length>=6);events.forEach((e,i)=>{assert.equal(e.edge,i+1);if(i)assert.equal(e.host-events[i-1].host,mode==='PAL'?1070460:896040);});
 }
 const trace=fs.readFileSync(p.join(d,'native_audio_'+shift+'.csv')),s=trace.toString();let start=0,pass=0,lastCE=0,rows=0;const boundaries=[];
 for(let end=s.indexOf('\n');end>=0;end=s.indexOf('\n',start)){
  const line=s.slice(start,end).trim();start=end+1;if(!line)continue;const [phase,k,ce,c,r,cm,rm,host,pal,ntsc]=line.split(',').map(Number);assert.equal(phase,shift);
  if(k!==pass){assert.equal(k,pass+1);assert.equal(lastCE,passes[pass].totalCE);pass=k;lastCE=0;}
  assert.equal(ce,++lastCE);assert.equal(host,(ce-1)*15+1);
  if(ce<reset)assert.equal((cm-rm+16384)%16384,(poisons[pass].injected-poisons[pass].saved+16384)%16384);else assert.equal(cm,rm);
  if(ce<reset||ce>=full)assert.equal(c,r);else assert.notEqual(c,r);
  if(ce===reset||ce===full){assert(pal<2&&ntsc<2);boundaries.push({pass,kind:ce===reset?'accumulator_reset':'full_convergence',CE:ce,host,PALedges:pal,NTSCedges:ntsc});}
  rows++;
 }
 assert.equal(pass,3);assert.equal(lastCE,passes[3].totalCE);assert.equal(rows,passes.reduce((sum,x)=>sum+x.totalCE,0));
 result.cases.push({shift,passes,poisons,stimulus,video,boundaries,traceRows:rows,traceSHA256:hash(trace),logSHA256:hash(log)});
 console.log('PASS independent trace/frame verification shift='+shift);
}
result.loads=288;result.traceRows=result.cases.reduce((s,c)=>s+c.traceRows,0);result.convergence={resetMinCE:1,resetMaxCE:72,fullMinCE:73,fullMaxCE:144};result.poisonValues=[...new Set(result.cases.flatMap(c=>c.poisons.map(x=>x.injected)))].sort((a,b)=>a-b);result.envelopeStates=[...new Set(result.cases.flatMap(c=>c.stimulus.map(x=>x.egstate)))].sort();
fs.writeFileSync(p.join(d,'acc_results.json'),JSON.stringify(result,null,2)+'\n');fs.writeFileSync(p.join(d,'production.diff'),git('diff','--','rtl/'));console.log(JSON.stringify({status:result.status,phases:72,loads:288,traceRows:result.traceRows,convergence:result.convergence,distinctPoisons:result.poisonValues.length,envelopeStates:result.envelopeStates},null,2));
