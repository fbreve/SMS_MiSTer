const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const read=f=>JSON.parse(fs.readFileSync(p.join(d,f))),rows=read('measurements.json'),source=read('source_verification.json'),hashes=read('tracked_baseline.json'),report=fs.readFileSync(p.join(d,'review.md'),'utf8'),git=(...a)=>cp.execFileSync('git',a,{cwd:root}).toString().trim();
assert.equal(rows.length,18);assert.equal(source.length,19);
for(const s of source){assert.equal(s.verified.length,134);assert.equal(s.missing.length,0);assert.equal(s.mismatches.length,0);assert.equal(s.environmentDifferences.length,0);}
const selected=rows.map(r=>r.builds.find(b=>b.tree===({'g06_g10_fix':'quartus','g05_background_fix':'quartus_v15','g08_release_fix':'quartus_v16','g12_sdram_fix':'quartus_candidate'}[r.checkpoint]||'candidate')));
for(const b of [rows[0].builds[0],...selected]){assert.equal(b.tool,'17.0.2 Build 602 07/19/2017 SJ Lite Edition');assert.equal(b.device,'5CSEBA6U23I7');assert.equal(b.seed,'1');assert.equal(b.qsfSHA,selected[0].qsfSHA);assert.equal(b.violations,0);for(const k of ['needed','placed','synthregs','fitregs','M10K','memoryBits','DSP','setup','hold'])assert.equal(typeof b[k],'number',k);assert(b.setup>0&&b.hold>0);}
assert.equal(selected[14].placed-selected[13].placed,5458);assert.equal(selected[15].placed-selected[14].placed,576);assert.equal(selected[16].placed-selected[15].placed,98);assert.equal(selected[17].placed-selected[16].placed,185);
assert.equal([...report.matchAll(/^## \d+\./gm)].length,52);
for(const m of report.matchAll(/\]\(([^)]+)\)/g))assert(fs.existsSync(p.resolve(d,m[1])),'Missing link '+m[1]);
for(const[f,h]of Object.entries(hashes))assert.equal(crypto.createHash('sha256').update(fs.readFileSync(p.join(root,f))).digest('hex'),h,'Tracked input changed '+f);
assert.equal(git('diff','--stat'),'');assert.equal(git('diff','--cached','--stat'),'');assert.equal(git('branch','--show-current'),'investigate/savestate-resource-growth');
const result={pass:true,uniqueCheckpoints:19,sourceVerifiedInputsPerCheckpoint:134,reportItems:52,trackedRegularFilesUnchanged:Object.keys(hashes).length,controlledConfigIdentical:true,quartusInvocations:0,placedDeltas:{G06_G10:5458,G05:576,G08:98,G12:185},head:git('rev-parse','HEAD'),status:git('status','--short')};
fs.writeFileSync(p.join(d,'validation.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result,null,2));
