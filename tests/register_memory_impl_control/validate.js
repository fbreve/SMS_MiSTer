const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex'),read=f=>{let b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const results=JSON.parse(read(p.join(d,'results.json'))),normal=JSON.parse(read(p.join(root,'tests/register_memory_auto_seed2/results.json'))),m=JSON.parse(read(p.join(d,'input_manifest.json'))),before=JSON.parse(read(p.join(d,'preservation_before.json')));
for(const [f,h]of Object.entries(before.files))assert.equal(hash(p.join(root,f)),h,f);
assert.equal(cp.execFileSync('git',['show-ref','--heads'],{cwd:root,encoding:'utf8'}),before.refs);
const metadata={};
for(const v of ['baseline','candidate']){
 const dir=p.join(d,v),fit=read(p.join(dir,'output_files/SMS.fit.rpt')),oldDir=p.join(root,'tests/register_memory_auto_seed2',v),oldFit=read(p.join(oldDir,'output_files/SMS.fit.rpt'));
 for(const [f,h]of Object.entries(m.inputs)){
  assert.equal(hash(p.join(dir,f)),h[v]);
  const now=fs.readFileSync(p.join(dir,f)),old=fs.readFileSync(p.join(oldDir,f));
  if(f==='SMS.qsf')assert.equal(now.toString(),old.toString()+'\n# Isolated implementation-control experiment, both matched seed-2 variants.\nset_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT EXTRA\n');else assert(now.equals(old),v+'/'+f);
 }
 for(const f of ['build_id.v','jtag.cdf'])assert.equal(hash(p.join(dir,f)),hash(p.join(oldDir,f)));
 assert(/;\s*Physical Synthesis Effort Level\s*;\s*Extra\s*;/i.test(fit),'Extra not effective');
 assert(/;\s*Perform Register Retiming for Performance\s*;\s*On\s*;/i.test(fit));
 assert.equal(+fit.match(/;\s*(?:Fitter Initial Placement )?Seed\s*;\s*(\d+)/i)[1],2);
 assert.equal(+fit.match(/;\s*Placement Effort Multiplier\s*;\s*([\d.]+)/i)[1],4);
 const transform=text=>{const rows=text.split(/\r?\n/).filter(l=>/^;/.test(l)&&/Retimed Register/.test(l));return {whole:rows.length,scaler:rows.filter(l=>l.includes('ascal:ascal|')).length,luminance:rows.filter(l=>/o_poly_lum|o_[hv]_lum_pix/.test(l)).length};};
 const opt=text=>text.split(/\r?\n/).filter(l=>/^Info \(12800[0-3]\)|^    Extra Info \(176220\)/.test(l));
 const old=normal.builds[v],now=results.builds[v],keys=['needed','placed','registers','synthesisRegisters','M10K','MLABcells','MLABbits','DSP','logicALUT','routingALUT','memoryBits','setup','hold'];
 metadata[v]={effectivePhysicalEffort:'Extra',seed:2,placementMultiplier:4,interconnectMatchesNormal:JSON.stringify(now.finalInterconnect)===JSON.stringify(old.finalInterconnect),routingResourcesMatchNormal:JSON.stringify(now.routingResourceRows)===JSON.stringify(old.routingResourceRows),criticalWarnings:now.criticalWarnings,normalCriticalWarnings:old.criticalWarnings,retiming:transform(fit),normalRetiming:transform(oldFit),optimizerMessages:opt(fit),normalOptimizerMessages:opt(oldFit),vsNormal:Object.fromEntries(keys.map(k=>[k,now[k]-old[k]])),newWarningsVsNormal:now.normalizedWarnings.filter(l=>!old.normalizedWarnings.includes(l)),removedWarningsVsNormal:old.normalizedWarnings.filter(l=>!now.normalizedWarnings.includes(l))};
 const q=read(p.join(d,v+'_query.log'));assert(q.includes('0 errors, 0 warnings'));assert(read(p.join(d,v+'_ignored_sdc.rpt')).includes('No constraints were ignored.'));
 const setup=read(p.join(d,v+'_setup.rpt'));assert.equal(+setup.match(/Worst case slack is\s+(-?[\d.]+)/)[1],now.setup);
}
const toolReference=JSON.parse(read(p.join(root,'tests/register_memory_auto/tools.json')));for(const [tool,h]of Object.entries(toolReference.binaries))assert.equal(hash('C:/intelFPGA_lite/17.0/quartus/bin64/'+tool+'.exe'),h,tool);
const recovery={normalAutoSetup:normal.builds.candidate.setup,extraAutoSetup:results.builds.candidate.setup,autoSetupDelta:results.builds.candidate.setup-normal.builds.candidate.setup,originalNormalBaselineSetup:normal.builds.baseline.setup,matchedExtraBaselineSetup:results.builds.baseline.setup,marginImproved:results.builds.candidate.setup>normal.builds.candidate.setup,originalBaselineMarginRecovered:results.builds.candidate.setup>=normal.builds.baseline.setup,matchedExtraMarginPreserved:results.builds.candidate.setup>=results.builds.baseline.setup,autoHasNoReportedViolations:results.builds.candidate.violations===0,retimingRecovered:metadata.candidate.retiming.scaler>0};
fs.writeFileSync(p.join(d,'validation.json'),JSON.stringify({metadata,recovery,protectedFiles:Object.keys(before.files).length,protectedBranches:before.refs.trim().split('\n').length,preservationMismatches:0,onlyQsfControlAdded:true,originalsUnchanged:true,newSimulationsRun:false,logicalEvidence:'../register_memory_auto/functional_results.json',toolHashesMatch:true,experimentalStatus:cp.execFileSync('git',['status','--short'],{cwd:p.join(root,'tests/register_memory_auto/worktree'),encoding:'utf8'}),originalStatus:cp.execFileSync('git',['status','--short'],{cwd:root,encoding:'utf8'})},null,2)+'\n');
console.log(JSON.stringify({metadata,recovery},null,2));
