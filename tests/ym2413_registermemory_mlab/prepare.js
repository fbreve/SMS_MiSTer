const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert'),d=__dirname,repo=p.resolve(d,'../..'),wt=p.join(d,'worktree'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const hash=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n'),git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,stdio:['ignore','pipe','pipe']});
const resume=process.argv.includes('--resume-preparation'),file='rtl/VM2413/registermemory.vhd';
assert.equal(git(wt,'rev-parse','HEAD').toString().trim(),base);assert.equal(git(wt,'branch','--show-current').toString().trim(),'experiment/ym2413-registermemory-mlab');
if(!resume){assert.equal(git(wt,'status','--porcelain').toString(),'');
const worktrees=git(repo,'worktree','list','--porcelain').toString().split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9)).filter(w=>p.resolve(w)!==p.resolve(wt));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify({master:git(repo,'rev-parse','master').toString().trim(),worktrees:Object.fromEntries(worktrees.map(w=>[w,{HEAD:git(w,'rev-parse','HEAD').toString().trim(),diff:hash(git(w,'diff','--binary','HEAD')),status:git(w,'status','--porcelain','--untracked-files=no').toString()}]))},null,2)+'\n');
const original=fs.readFileSync(p.join(wt,file));assert.equal(norm(original),norm(git(wt,'show',base+':'+file)));
const modified=Buffer.from(original.toString('latin1').replace('attribute ramstyle of regs_array : signal is "logic";','attribute ramstyle of regs_array : signal is "MLAB";'),'latin1');assert.notEqual(hash(original),hash(modified));fs.writeFileSync(p.join(wt,file),modified);
const diff=git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/');fs.writeFileSync(p.join(d,'production.diff'),diff);
const smoke=p.join(d,'smoke');fs.mkdirSync(smoke);for(const l of ['candidate','reference']){fs.mkdirSync(p.join(smoke,l));fs.mkdirSync(p.join(smoke,'ghdl_'+l));fs.writeFileSync(p.join(smoke,l,'registermemory.vhd'),l==='candidate'?modified:original);}
const bank=p.join(repo,'tests/ym2413_registermemory_auto/worktree/tests/ym2413_fullstate/bank_tb.vhd');fs.copyFileSync(bank,p.join(smoke,'bank_tb.vhd'));
}
const original=git(wt,'show',base+':'+file),modified=fs.readFileSync(p.join(wt,file)),bank=p.join(d,'smoke/bank_tb.vhd');
assert.equal(norm(modified),norm(original).replace('attribute ramstyle of regs_array : signal is "logic";','attribute ramstyle of regs_array : signal is "MLAB";'));
const ref=p.join(repo,'tests/ym2413_v19_fullstate/physical_seed2'),phys=p.join(d,'physical_seed2'),m=JSON.parse(fs.readFileSync(p.join(ref,'inputs.json'))),r=JSON.parse(fs.readFileSync(p.join(ref,'results.json'))).builds.candidate;
for(const [f,h]of Object.entries(r.reportHashes))assert.equal(hash(fs.readFileSync(p.join(ref,'candidate/output_files',f))),h);
for(const [tool,h]of Object.entries(m.toolHashes))assert.equal(hash(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+tool+'.exe')),h);
assert(!fs.existsSync(p.join(phys,'candidate')),'Do not overwrite frozen sources');fs.mkdirSync(phys,{recursive:true});const inputs={},equivalent=[];
for(const [f,v]of Object.entries(m.builds.candidate.inputs)){if(f.startsWith('releases/'))continue;
 let b=fs.readFileSync(p.join(ref,'candidate',f));assert.equal(hash(b),v.SHA256);
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f)){assert.equal(norm(b),norm(git(wt,'show',base+':'+f)),f);equivalent.push(f);}
 if(f===file)b=Buffer.from(b.toString('latin1').replace('attribute ramstyle of regs_array : signal is "logic";','attribute ramstyle of regs_array : signal is "MLAB";'),'latin1');
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f))assert.equal(norm(b),norm(fs.readFileSync(p.join(wt,f))));
 const dest=p.join(phys,'candidate',f);fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,b);inputs[f]={...v,SHA256:hash(b)};
}
const manifest={...m,baseline:base,candidate:{branch:'experiment/ym2413-registermemory-mlab',HEAD:base,uncommitted:true},builds:{candidate:{inputs}},sourceDifferences:[file,'rtl/opll_snapshot.sv'],sourceHash:hash(Buffer.from(Object.entries(inputs).sort().map(([f,v])=>f+' '+v.SHA256).join('\n'))),reference:{directory:ref,inputsSHA256:hash(fs.readFileSync(p.join(ref,'inputs.json'))),resultsSHA256:hash(fs.readFileSync(p.join(ref,'results.json'))),committedProductionEquivalent:equivalent,onlyInputDifference:[file]},baselineReuse:'Reuse matched full-state Seed 2 after verification; AUTO is a separate measured comparator.',seedStudyPolicy:'MLAB Seed 2 only; synthesis gate before fitter',smokeInputs:{reference:hash(original),candidate:hash(modified),bankTB:hash(fs.readFileSync(bank))}};
fs.writeFileSync(p.join(phys,'inputs.json'),JSON.stringify(manifest,null,2)+'\n');fs.copyFileSync(p.join(d,'production.diff'),p.join(phys,'production.diff'));
const helpers=p.join(repo,'tests/ym2413_registermemory_auto/physical_seed2');for(const f of ['check_inputs.js','settings.tcl','paths.tcl','query.ps1','collect.js'])fs.copyFileSync(p.join(helpers,f),p.join(phys,f));
console.log('PASS isolated MLAB-only change, baseline source equivalence, frozen Seed 2 settings and smoke sources');
