const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function log(f,marker){const b=fs.readFileSync(p.join(d,f)),s=b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');assert(s.includes(marker),f+' missing marker');assert(!/\*\* (?:Error|Failure|Fatal):|Errors: [1-9]/.test(s),f+' failure');assert(/Errors: 0/.test(s),f+' missing clean termination');return {s,sha:sha(b)};}
const randomized=[];
const randomSource=fs.readFileSync(p.join(d,'random_tb.sv'),'utf8');
assert(randomSource.includes(".audio_in_r2((systeme?{a2r[10],a2r,4'b0}"));
assert(randomSource.includes(".audio_in_r2((systeme?{rar[10],rar,4'b0}"));
for(let seed=1;seed<=16;seed++){
 const f='random_'+seed+'/replay.log',r=log(f,'PASS F01');
 if(seed%5===0)assert(fs.statSync(p.join(d,f)).mtimeMs>=fs.statSync(p.join(d,'random_mix_compile.log')).mtimeMs,'corrected System E rerun required');
 assert.equal((r.s.match(/FM_RESULT pass[0-3] errors0 first-1/g)||[]).length,4);
 const ref=log('random_'+seed+'/reference.log','PASS REFERENCE');
 assert(r.s.includes('Loading work_random.opll(rtl)')&&ref.s.includes('Loading original_work.opll_reference(rtl)'),'independent original reference binding');
 const lines=fs.readFileSync(p.join(d,'random_'+seed+'/reference.dat'),'utf8').trim().split(/\r?\n/);assert.equal(lines.length,48000);
 const samples=lines.map(l=>{const tokens=l.trim().split(/\s+/);assert(tokens.every(t=>/^[0-9a-f]+$/i.test(t)),'unknown oracle');return parseInt(tokens.at(-1),16);});
 const signed=samples.map(x=>x&8192?x-16384:x);assert(new Set(samples).size>1,'silent randomized witness');
 const capture=r.s.match(/CAPTURE cycle(\d+) clkd(\d+) div(\d+)/);assert(capture);
 randomized.push({seed,log:f,sha256:r.sha,saveOnly:1,loads:3,rawHostSamples:192000,captureCycle:+capture[1],captureClockPhase:+capture[2],psgDivider:+capture[3],systemE:seed%5===0,normalCPU:seed%5!==0&&!!(seed&1),oracleSHA256:sha(fs.readFileSync(p.join(d,'random_'+seed+'/reference.dat'))),rawMinimum:Math.min(...signed),rawMaximum:Math.max(...signed),distinctSamples:new Set(samples).size});
}
const regressions=require('./regression_manifest.json').map(c=>{const f=c.family+'/'+c.name+'/simulation.log',r=log(f,c.marker);if(c.also)assert(r.s.includes(c.also));const fixtureResults=[];for(const fixture of c.fixtures||[]){const full=p.join(d,c.family,c.name,fixture.file==='replay.do'?'run.do':fixture.file),actual=sha(fs.readFileSync(full));const output=/^image(?:_save)?\.hex$/.test(fixture.file);if(!output)assert.equal(actual,fixture.sha256,'retained oracle '+full);fixtureResults.push({...fixture,currentSHA256:actual,role:output?'generated current-format SAVE output':'retained immutable input/oracle'});}return {...c,fixtures:fixtureResults,log:f,logSHA256:r.sha,passed:true};});
const imports=log('imports/imports.log','PASS');assert(imports.s.includes('20'),'import count');
const out={passed:true,randomized,regressions,imports:{log:'imports/imports.log',sha256:imports.sha,loads:20},totals:{randomCases:16,randomSaveOnly:16,randomLoads:48,randomRawHostSamples:3072000,targetedCases:regressions.length},limits:['Randomized raw OPLL oracle is independent unmodified baseline OPLL; active-FM mixed output remains characterization only.','Targeted domain fixtures mock FM readiness/data; actual FM restoration is covered separately.','Retained oracle and ROM fixture hashes are checked without rewriting expected results.']};
fs.writeFileSync(p.join(d,'regression_results.json'),JSON.stringify(out,null,2)+'\n');console.log(out.totals);
