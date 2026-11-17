const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert');
const task=__dirname,d=p.join(task,'physical_seed2'),repo=p.resolve(task,'../..'),ref=p.join(repo,'tests/ym2413_v19_fullstate/physical_seed2'),wt=p.join(task,'worktree'),base='9873761503510e4b2c7e06600bf5515344235c2f';
assert(!fs.existsSync(d),'Refuse overwriting physical build');
cp.execFileSync('node',[p.join(task,'verify.js')],{stdio:'inherit'});
const sha=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n'),git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,stdio:['ignore','pipe','pipe']});
const m=JSON.parse(fs.readFileSync(p.join(ref,'inputs.json'))),r=JSON.parse(fs.readFileSync(p.join(ref,'results.json'))).builds.candidate;
for(const [f,h]of Object.entries(r.reportHashes))assert.equal(sha(fs.readFileSync(p.join(ref,'candidate/output_files',f))),h,'Reference report '+f);
assert.equal(sha(fs.readFileSync(p.join(ref,r.rbf.path))),r.rbf.SHA256);
assert.equal(r.neededALMs,27421);assert.equal(r.placedALMs,32490);assert.equal(r.fittedRegisters,36112);assert.equal(r.M10K,489);assert.equal(r.setupSlack,0.367);assert.equal(r.setupTNS,0);
for(const [name,h]of Object.entries(m.toolHashes))assert.equal(sha(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+name+'.exe')),h,'Tool '+name);
fs.mkdirSync(d);
const list=git(repo,'worktree','list','--porcelain').toString().split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify({master:git(repo,'rev-parse','master').toString().trim(),worktrees:Object.fromEntries(list.map(w=>[w,{HEAD:git(w,'rev-parse','HEAD').toString().trim(),diff:sha(git(w,'diff','--binary','HEAD')),status:git(w,'status','--porcelain','--untracked-files=no').toString()}]))},null,2));
const inputs={},equivalent=[];
for(const [f,v]of Object.entries(m.builds.candidate.inputs)){if(f.startsWith('releases/'))continue;
 let bytes=fs.readFileSync(p.join(ref,'candidate',f));assert.equal(sha(bytes),v.SHA256,'Archived input '+f);
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f)){assert.equal(norm(bytes),norm(git(wt,'show',base+':'+f)),'Archived production vs commit '+f);equivalent.push(f);}
 if(f==='rtl/VM2413/registermemory.vhd')bytes=Buffer.from(bytes.toString('latin1').replace('attribute ramstyle of regs_array : signal is "logic";','attribute ramstyle of regs_array : signal is "AUTO";'),'latin1');
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f))assert.equal(norm(bytes),norm(fs.readFileSync(p.join(wt,f))),'Frozen vs candidate '+f);
 const dest=p.join(d,'candidate',f);fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,bytes);inputs[f]={...v,SHA256:sha(bytes)};
}
const manifest={...m,baseline:base,candidate:{branch:'experiment/ym2413-registermemory-auto',HEAD:base,uncommitted:true},builds:{candidate:{inputs}},sourceDifferences:['rtl/VM2413/registermemory.vhd','rtl/opll_snapshot.sv'],sourceHash:sha(Buffer.from(Object.entries(inputs).sort().map(([f,v])=>f+' '+v.SHA256).join('\n'))),reference:{directory:ref,inputsSHA256:sha(fs.readFileSync(p.join(ref,'inputs.json'))),resultsSHA256:sha(fs.readFileSync(p.join(ref,'results.json'))),committedProductionEquivalent:equivalent,onlyInputDifference:['rtl/VM2413/registermemory.vhd']},functionalResultsSHA256:sha(fs.readFileSync(p.join(task,'results.json')))};
fs.writeFileSync(p.join(d,'inputs.json'),JSON.stringify(manifest,null,2)+'\n');fs.writeFileSync(p.join(d,'production.diff'),git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/'));
const previous=p.join(repo,'tests/ym2413_selfhealing_combined/physical_seed2');
for(const f of ['build.ps1','check_inputs.js','settings.tcl','paths.tcl','query.ps1','collect.js'])fs.copyFileSync(p.join(previous,f),p.join(d,f));
let paths=fs.readFileSync(p.join(d,'paths.tcl'),'utf8').replace('foreach label {fm phase snapshot} pattern {*emu|system|fm|* *emu|system|fm|pg|MEM|* *fm_snapshot*}', 'foreach label {fm phase snapshot registers} pattern {*emu|system|fm|* *emu|system|fm|pg|MEM|* *fm_snapshot* *u_register_memory*}');fs.writeFileSync(p.join(d,'paths.tcl'),paths);
console.log(JSON.stringify({PASS:true,sourceHash:manifest.sourceHash,inputs:Object.keys(inputs).length,committedEquivalent:equivalent.length,baseline:{needed:r.neededALMs,placed:r.placedALMs,registers:r.fittedRegisters,M10K:r.M10K,WNS:r.setupSlack,TNS:r.setupTNS}},null,2));
