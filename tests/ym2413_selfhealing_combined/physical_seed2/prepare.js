const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert');
const d=__dirname,repo=p.resolve(d,'../../..'),ref=p.join(repo,'tests/ym2413_v19_fullstate/physical_seed2'),wt=p.resolve(d,'../worktree'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const sha=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd});
const original=JSON.parse(fs.readFileSync(p.join(ref,'inputs.json')));
assert.equal(git(wt,'rev-parse','HEAD').toString().trim(),base);assert.equal(git(wt,'branch','--show-current').toString().trim(),'experiment/ym2413-selfhealing-combined');
let scope=fs.readFileSync(p.join(wt,'tests/ym2413_fullstate/verify_combined_scope.js'),'utf8');
scope=scope.replace("const root=p.resolve(__dirname,'../..')","const root="+JSON.stringify(wt)).replace(/fs\.writeFileSync\(p\.join\(__dirname,'combined_source_manifest\.json'\)[^\n]+/,'');
new Function('require','__dirname',scope)(require,d);
const preserved=()=>{const list=git(repo,'worktree','list','--porcelain').toString().split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9));return {master:git(repo,'rev-parse','master').toString().trim(),worktrees:Object.fromEntries(list.map(w=>[w,{HEAD:git(w,'rev-parse','HEAD').toString().trim(),diff:sha(git(w,'diff','--binary','HEAD')),status:git(w,'status','--porcelain','--untracked-files=no').toString()}]))};};
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify(preserved(),null,2));
const inputs={},equivalence=[],exceptions=[];
for(const [f,info] of Object.entries(original.builds.candidate.inputs)){
 let bytes=fs.readFileSync(p.join(ref,'candidate',f));assert.equal(sha(bytes),info.SHA256,'Reference frozen input '+f);
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f)){
  assert.equal(norm(bytes),norm(git(wt,'show',base+':'+f)),'Reference versus committed baseline '+f);equivalence.push(f);
 }
 if(f==='rtl/VM2413/temporalmixer.vhd'){
  bytes=Buffer.from(bytes.toString('latin1').replace('mix <= ss_v_mix;','-- Combined experiment: accumulator heals at its normal clear.').replace('mixout <= ss_v_mixout;','-- Combined experiment: output heals after a complete mixer cycle.'),'latin1');
  assert.equal(norm(bytes),norm(fs.readFileSync(p.join(wt,f))));exceptions.push(f);
 }
 const target=p.join(d,'candidate',f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,bytes);inputs[f]={...info,SHA256:sha(bytes)};
}
for(const [name,digest]of Object.entries(original.toolHashes))assert.equal(sha(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+name+'.exe')),digest,'Quartus executable '+name);
const manifest={...original,baseline:base,candidate:{branch:'experiment/ym2413-selfhealing-combined',HEAD:base,uncommitted:true},builds:{candidate:{inputs}},sourceDifferences:['rtl/VM2413/temporalmixer.vhd','rtl/opll_snapshot.sv'],reference:{directory:ref,inputsSHA256:sha(fs.readFileSync(p.join(ref,'inputs.json'))),resultsSHA256:sha(fs.readFileSync(p.join(ref,'results.json'))),committedProductionEquivalent:equivalence,onlyInputDifference:exceptions},sourceHash:sha(Buffer.from(Object.entries(inputs).sort().map(([f,v])=>f+' '+v.SHA256).join('\n')))};
fs.writeFileSync(p.join(d,'inputs.json'),JSON.stringify(manifest,null,2)+'\n');
fs.writeFileSync(p.join(d,'production.diff'),git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/'));
for(const f of ['check_inputs.js','settings.tcl','paths.tcl'])fs.copyFileSync(p.join(ref,f),p.join(d,f));
let checker=fs.readFileSync(p.join(d,'check_inputs.js'),'utf8').replace("['baseline','candidate']","['candidate']");fs.writeFileSync(p.join(d,'check_inputs.js'),checker);
let build=fs.readFileSync(p.join(ref,'build.ps1'),'utf8').replace("@('baseline','candidate')","@('candidate')");fs.writeFileSync(p.join(d,'build.ps1'),build);
console.log(JSON.stringify({PASS:true,inputs:Object.keys(inputs).length,committedEquivalent:equivalence.length,sourceHash:manifest.sourceHash,onlyDifference:exceptions},null,2));
