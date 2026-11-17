// Read-only evidence checks. Invoked before preparation and every runner start.
const fs=require('fs'),p=require('path'),c=require('crypto'),assert=require('assert');
const root=p.resolve(__dirname,'../..'), ref=p.join(root,'tests/ym2413_v19_fullstate');
const sha=f=>c.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const read=f=>fs.readFileSync(f,'utf8'),norm=s=>s.replace(/\r\n/g,'\n');
const allowed=new Set(['rtl/VM2413/outputgenerator.vhd','rtl/VM2413/outputmemory.vhd','rtl/VM2413/temporalmixer.vhd','rtl/opll_snapshot.sv','rtl/savestates.sv']);
const evidence={reference:{},tools:{},sourceScope:{}};
const first=JSON.parse(read(p.join(ref,'physical_seed1/inputs.json')));
for(const [tool,hash] of Object.entries(first.toolHashes)) {
 const f=`C:/intelFPGA_lite/17.0/quartus/bin64/${tool}.exe`;
 assert.equal(sha(f),hash,'Tool identity changed: '+tool);evidence.tools[tool]=hash;
}
for(const seed of [1,2,3]) {
 const dir=p.join(ref,'physical_seed'+seed),m=JSON.parse(read(p.join(dir,'inputs.json'))),r=JSON.parse(read(p.join(dir,'results.json')));
 assert.equal(m.device,'5CSEBA6U23I7');assert(m.version.includes('17.0.2 Build 602'));assert.equal(m.seed,seed);
 for(const v of ['baseline','candidate']) {
  const b=r.builds[v];assert(b.complete&&Object.values(b.status).every(Boolean),'Incomplete reference '+seed+'/'+v);
  for(const [f,i] of Object.entries(m.builds[v].inputs))assert.equal(sha(p.join(dir,v,f)),i.SHA256,'Reference input changed '+seed+'/'+v+'/'+f);
  for(const [f,h] of Object.entries(b.reportHashes))assert.equal(sha(p.join(dir,v,'output_files',f)),h,'Reference report changed '+f);
  assert.equal(sha(p.join(dir,b.rbf.path)),b.rbf.SHA256,'Reference RBF changed');
  assert(read(p.join(dir,v,'output_files/SMS.fit.summary')).includes('Device : '+m.device));
 }
 for(const [f,i] of Object.entries(m.builds.candidate.inputs)) {
  const a=read(p.join(dir,'candidate',f)),b=read(p.join(ref,'physical_seed1/candidate',f));
  assert.equal(f==='SMS.qsf'?a.replace(/-name SEED [123]\b/,'-name SEED 1'):a,b,'Reference seed source differs '+f);
  if(/\.(qsf|sdc)$/.test(f))assert.equal(a,read(p.join(dir,'baseline',f)),'Reference baseline settings differ '+f);
 }
 evidence.reference[seed]={resultsSHA256:sha(p.join(dir,'results.json')),identity:r.identity};
}
for(const [v,exp] of [['b1','ym2413_optimized_integration'],['c1','ym2413_c1_mixer_omission']]) {
 const wt=p.join(root,'tests',exp,'worktree');const changed=[];
 for(const f of Object.keys(first.builds.candidate.inputs).filter(f=>/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f))) {
  assert(fs.existsSync(p.join(wt,f)),'Missing validated source '+v+'/'+f);
  if(norm(read(p.join(wt,f)))!==norm(read(p.join(ref,'physical_seed1/candidate',f)))) {assert(allowed.has(f),'Unexpected RTL substitution '+v+'/'+f);changed.push(f);}
 }
 assert.deepEqual(changed.sort(),[...allowed].sort());
 const verification=p.join(root,'tests',exp,v==='b1'?'verification_b1':'verification_c1');
 for(const f of allowed)assert.equal(norm(read(p.join(wt,f))),norm(read(p.join(verification,f))),'Validated simulation source differs '+v+'/'+f);
 evidence.sourceScope[v]=Object.fromEntries([...allowed].map(f=>[f,sha(p.join(wt,f))]));
}
// Freeze an audit snapshot without overwriting prior audit evidence.
if(require.main===module) {
 const target=p.join(__dirname,'preflight_'+Date.now()+'.json');fs.writeFileSync(target,JSON.stringify(evidence,null,2)+'\n',{flag:'wx'});console.log('PASS preflight: '+target);
}
module.exports=evidence;
