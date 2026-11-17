const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),baseline='9873761503510e4b2c7e06600bf5515344235c2f';
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:root,stdio:['pipe','pipe','pipe']});
assert.equal(git('rev-parse','HEAD').toString().trim(),baseline);
const production=git('diff','--name-only','--','rtl/','SMS.sv','files.qip','sys/').toString().trim().split('\n');assert.deepEqual(production,['rtl/VM2413/temporalmixer.vhd']);
const original=git('show',baseline+':rtl/VM2413/temporalmixer.vhd').toString('latin1').replace(/\r\n/g,'\n'),actual=fs.readFileSync(p.join(root,production[0])).toString('latin1').replace(/\r\n/g,'\n');
assert.equal(actual,original.replace('when 102 =>\nss_v_mixout(13 downto 0) := ss_wdata(13 downto 0);\nmixout <= ss_v_mixout;','when 102 =>\nnull; -- Experiment: output is refreshed by the next normal mixer update.'));
const result={status:'PASS',baseline,branch:git('branch','--show-current').toString().trim(),format:{words:104,version:17},followEnabledClocks:142728,frameEnabledClocks:{NTSC:59736,PAL:71364},cases:[],sources:{},baselineResultsSHA256:sha(fs.readFileSync(p.resolve(root,'../baseline_validation/results.json')))};
result.simulator={executable:'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',SHA256:sha(fs.readFileSync('C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'))};
result.compiledSources={};for(const folder of ['candidate','reference'])for(const f of fs.readdirSync(p.join(d,folder)).filter(f=>f.endsWith('.vhd')))result.compiledSources[folder+'/'+f]=sha(fs.readFileSync(p.join(d,folder,f)));
for(const f of ['candidate_wrapper.vhd','reference_wrapper.vhd','heal_compile.do','heal_tb.vhd','heal_run.do','oracle.tcl','compile.do','source_identity.json'])result.compiledSources[f]=sha(fs.readFileSync(p.join(d,f)));
for(const f of [...git('ls-files','--','rtl/VM2413/','rtl/opll_snapshot.sv','rtl/savestates.sv','rtl/system.vhd','SMS.sv','files.qip','tests/ym2413_fullstate/').toString().trim().split('\n'),'tests/ym2413_fullstate/heal_tb.vhd','tests/ym2413_fullstate/heal_run.do','tests/ym2413_fullstate/heal_campaign.ps1','tests/ym2413_fullstate/heal_one.ps1'])result.sources[f]=sha(fs.readFileSync(p.join(root,f)));
for(let shift=0;shift<72;shift++){
 const prefix=p.join(d,'heal_runs/shift'+shift),log=fs.readFileSync(prefix+'.log'),text=log.toString();assert.equal(+fs.readFileSync(prefix+'.exitcode','utf8').replace(/^\uFEFF/,''),0);
 assert(!/\*\* (Fatal|Failure|Error):/.test(text));assert(text.includes('PASS HEAL oracle ALL checkpoints=18'));
 const passes=[...text.matchAll(/PASS HEAL shift=(\d+) pass=(\d+) convergence_ce=(\d+) first_equal_ce=(\d+) followed_ce=(\d+)/g)].map(m=>({pass:+m[2],convergence:+m[3],firstEqual:+m[4],follow:+m[5]}));assert.equal(passes.length,3);
 const stimulus=[...text.matchAll(/PASS STIMULUS shift=\d+ pass=(\d+) egstate=(\d+)/g)].map(m=>({pass:+m[1],egstate:+m[2]}));assert.equal(stimulus.length,3);
 const expected=(70-shift+72)%72+1;passes.forEach((x,i)=>{assert.equal(x.pass,i);assert.equal(x.convergence,expected);assert.equal(x.firstEqual,expected);assert.equal(x.follow,142728);});
 const trace=fs.readFileSync(p.join(d,'heal_audio_'+shift+'.csv')),traceText=trace.toString();let lastPass=0,lastCE=0,rows=0,lastEnd=0;
 for(let end=traceText.indexOf('\n');end>=0;end=traceText.indexOf('\n',lastEnd)){
  const line=traceText.slice(lastEnd,end).trim();lastEnd=end+1;if(!line)continue;const fields=line.split(',').map(Number);const [s,pass,ce,c,r]=fields;assert.equal(s,shift);
  if(pass!==lastPass){assert.equal(pass,lastPass+1);assert.equal(lastCE,142728+expected);lastPass=pass;lastCE=0;}
  assert.equal(ce,++lastCE);if(ce<expected)assert.notEqual(c,r);else assert.equal(c,r);rows++;
 }
 assert.equal(lastPass,2);assert.equal(lastCE,142728+expected);assert.equal(rows,3*(142728+expected));
 result.cases.push({shift,passes,stimulus,traceRows:rows,traceSHA256:sha(trace),logSHA256:sha(log),frames:{NTSC:expected/59736,PAL:expected/71364}});
}
result.loads=result.cases.length*3;result.convergence={minEnabledClocks:Math.min(...result.cases.map(c=>c.passes[0].convergence)),maxEnabledClocks:Math.max(...result.cases.map(c=>c.passes[0].convergence))};result.traceRows=result.cases.reduce((a,c)=>a+c.traceRows,0);
fs.writeFileSync(p.join(d,'heal_results.json'),JSON.stringify(result,null,2)+'\n');fs.writeFileSync(p.join(d,'production.diff'),git('diff','--','rtl/'),'utf8');
console.log(JSON.stringify({status:result.status,phases:result.cases.length,loads:result.loads,convergence:result.convergence,traceRows:result.traceRows,followPerLoad:result.followEnabledClocks,observedEnvelopeStates:[...new Set(result.cases.flatMap(c=>c.stimulus.map(x=>x.egstate)))]},null,2));
