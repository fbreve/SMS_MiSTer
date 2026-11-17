const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,repo=p.resolve(d,'../..');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
let expectedChecks=0;
const rows=f=>{const lines=fs.readFileSync(f,'utf8').trim().split(/\r?\n/),keys=lines.shift().split(',');return lines.map(s=>Object.fromEntries(s.split(',').map((v,i)=>[keys[i],i<3?Number(v):parseInt(v,16)])));};
const sm=n=>(n&512)?-(n&511):(n&511);
const smpack=n=>(n<0?512:0)|Math.floor(Math.abs(n)/2);
for(let c=0;c<4;c++)for(let m=0;m<(c===3?7:6);m++){
 const a=rows(p.join(d,`trace_${c}_${m}_gap1.csv`)),edge=a.find(x=>x.raw===2),commit=a.find(x=>x.raw===3);assert(edge&&commit);
 if(c===0){const li=(edge.word100_fault>>>21)&1023,expected=smpack(sm(edge.out_q1)+sm(li));assert.equal((edge.word100_fault>>>11)&1023,expected,'feedback average consumes injected q');assert.equal(commit.word57_fault,expected,'feedback RAM commits the independent average');assert.equal(commit.word57_ref,smpack(sm(li)),'reference average uses zero pre-write data');expectedChecks+=3;
 }else if(c===1){assert.equal((edge.word101_fault>>>6)&16383,sm(edge.out_q2)&16383,'mixer consumes injected sign/magnitude');expectedChecks++;
 }else if(c===2){assert.equal(edge.word80_fault&15,(edge.reg_q>>>20)&15,'instrument cache consumes injected q');expectedChecks++;
 }else{const q=(edge.reg_q&0xffff00)|0x81,packed=(((q>>>16)&255)<<14)|(q&16383);assert.equal((edge.word83_fault>>>5)&0x3fffff,packed,'RMW copies injected unaffected fields');assert.equal(commit.word0_fault,packed,'RMW commits independent channel RAM expectation');assert.equal(commit.word0_ref,0x81,'reference RMW pre-write data');expectedChecks+=3;}
}
const runs=[];for(const f of fs.readdirSync(p.join(d,'logs')).filter(x=>/^case\d+_mode\d+.*\.out$/.test(x))){const txt=fs.readFileSync(p.join(d,'logs',f),'utf8'),summary=txt.split(/\r?\n/).find(x=>x.includes('PASS FAULT_PROBE')||x.includes('PASS COHERENT_FAULT')||x.includes('PASS INITIALIZATION')||x.includes('PASS PROPOSED_GUARD'));assert(summary,`no PASS in ${f}`);const diffs=[...txt.matchAll(/DIFF_SUMMARY word=(\d+) first_raw=(\d+) last_raw=(\d+) remains=(true|false)/g)].map(m=>({word:+m[1],first:+m[2],last:+m[3],remains:m[4]==='true'}));runs.push({log:f,summary,differences:diffs});}
const before=JSON.parse(fs.readFileSync(p.join(d,'preservation_before.json')));
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,stdio:['ignore','pipe','ignore']});
assert.equal(git(repo,'rev-parse','master').toString().trim(),before.master);
for(const t of before.trees){assert.equal(git(t.path,'rev-parse','HEAD').toString().trim(),t.head);assert.equal(hash(git(t.path,'diff','HEAD','--binary')),t.diff);assert.equal(git(t.path,'status','--porcelain','--untracked-files=no').toString(),t.status);}
const paths=['controller','outputgenerator','temporalmixer','slotcounter'].map(n=>'rtl/VM2413/'+n+'.vhd').concat('rtl/opll_snapshot.sv');
const compatibilityDiff=git(repo,'diff','--ignore-space-at-eol','--ignore-blank-lines','7fcd5e12847eedf9e97a44dc937c3dbac3205f7c','9873761503510e4b2c7e06600bf5515344235c2f','--',...paths).toString();assert.equal(compatibilityDiff,'','known v19 producer differs beyond line endings');
const wrapperSource=git(repo,'show','9873761503510e4b2c7e06600bf5515344235c2f:rtl/system.vhd').toString('latin1');
const prodWrapper=wrapperSource.slice(wrapperSource.indexOf('\tfm: work.opll'),wrapperSource.indexOf('FM_gated <='));
for(const lib of ['reference','candidate']){const w=fs.readFileSync(p.join(d,lib+'_wrapper.vhd'),'latin1');const wb=w.slice(w.indexOf('\tfm: entity work.opll'),w.indexOf('FM_gated <=')).replace('fm: entity work.opll','fm: work.opll');assert.equal(wb.replace(/\s/g,''),prodWrapper.replace(/\s/g,''),'wrapper differs from actual committed production wrapper');}
const priorities=fs.readdirSync(p.join(d,'logs')).filter(x=>x.endsWith('.priority'));for(const f of priorities){const txt=fs.readFileSync(p.join(d,'logs',f),'utf8');assert(/Priority=Idle/.test(txt)&&/samples=[1-9]\d* exit=0/.test(txt),f);}
const result={baseline:'9873761503510e4b2c7e06600bf5515344235c2f',independentConsumerAssertions:expectedChecks,wrapperComparison:'PASS both wrapper bodies match committed production source',preservation:'PASS all existing worktree HEADs, tracked diffs/status, and master unchanged',knownProducerCompatibility:{reference:'7fcd5e12847eedf9e97a44dc937c3dbac3205f7c',paths,diffBeyondLineEndings:false},priorityLogs:priorities.length,runs};
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(result,null,2)+'\n');
const walk=(dir)=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()&&!e.name.startsWith('ghdl_')&&e.name!=='validator_work'?walk(p.join(dir,e.name)):e.isFile()?[p.join(dir,e.name)]:[]);
fs.writeFileSync(p.join(d,'artifact_hashes.json'),JSON.stringify(Object.fromEntries(walk(d).filter(f=>!f.endsWith('artifact_hashes.json')).map(f=>[p.relative(d,f).replaceAll('\\','/'),hash(fs.readFileSync(f))])),null,2));
console.log(`PASS independent consumer assertions=${expectedChecks}; runs=${runs.length}; preservation and known-v19 producer compatibility; verified Idle logs=${priorities.length}`);
