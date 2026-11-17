const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const corrected=process.argv.includes('--r2');
const root=p.resolve(__dirname,'../..'),prior=p.join(root,'tests/pr227_matched_20261114'),out=p.join(__dirname,corrected?'physical_r2':'physical');fs.mkdirSync(out);
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:100*1024*1024});
const revision=git('rev-parse','HEAD').toString().trim(),base='8cd53ccc954c24970372ea6d8a3fb2336a14c46f',dependency=git('rev-parse',base+':mist/mist-modules').toString().trim();assert.equal(revision,'69edeb48455820d3119ab54d052bf3de906c91fa');assert.equal(git('status','--porcelain','--untracked-files=no').toString().trim(),corrected?'M rtl/savestates.sv':'');
const patch=git('diff','--','rtl/savestates.sv'),patchSHA256=sha(patch);if(corrected){const identity=JSON.parse(fs.readFileSync(p.join(__dirname,'r2/source_identity.json')));assert.equal(identity.productionSHA256,sha(fs.readFileSync(p.join(root,'rtl/savestates.sv'))));assert.equal(identity.uncommittedPatchSHA256,patchSHA256);fs.writeFileSync(p.join(out,'production_correction.patch'),patch);}
assert.equal(git('rev-parse',revision+':mist/mist-modules').toString().trim(),dependency);
const archive=p.join(out,'candidate.tar'),depArchive=p.join(out,'dependency.tar');git('archive','--format=tar','--output='+archive,revision,'--','.',':(exclude)releases');cp.execFileSync('git',['archive','--format=tar','--output='+depArchive,dependency],{cwd:p.join(root,'mist/mist-modules')});
const reused=[];
for(const seed of [1,2,3]){
 const before=JSON.parse(fs.readFileSync(p.join(prior,seed===1?'candidate_inputs.json':`seed${seed}_candidate_inputs.json`))),baseline=p.join(prior,`seed${seed}/candidate`);assert.equal(before.revision,base);
 for(const [f,h]of Object.entries(before.files).filter(([f])=>!f.startsWith('releases/')))assert.equal(sha(fs.readFileSync(p.join(baseline,f))),h,'Prior input changed '+f);
 const dir=p.join(out,`seed${seed}/candidate`);fs.mkdirSync(dir,{recursive:true});cp.execFileSync('tar',['-xf',archive,'-C',dir]);cp.execFileSync('tar',['-xf',depArchive,'-C',p.join(dir,'mist/mist-modules')]);if(corrected)fs.copyFileSync(p.join(root,'rtl/savestates.sv'),p.join(dir,'rtl/savestates.sv'));
 for(const f of ['SMS.qsf','fixed_build_id.tcl'])fs.copyFileSync(p.join(baseline,f),p.join(dir,f));
 const files={};function walk(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){const f=p.join(d,e.name);if(e.isDirectory())walk(f);else files[p.relative(dir,f).replaceAll('\\','/')]=sha(fs.readFileSync(f));}}walk(dir);
 const changed=Object.keys(before.files).filter(f=>!f.startsWith('releases/')&&before.files[f]!==files[f]);assert.deepEqual(changed.sort(),['SMS.sv','rtl/savestates.sv'].sort());
 fs.writeFileSync(p.join(out,`seed${seed}_candidate_inputs.json`),JSON.stringify({revision,uncommittedPatchSHA256:corrected?patchSHA256:null,dependency,seed,buildDate:'261114',baselineInputManifest:p.relative(root,p.join(prior,seed===1?'candidate_inputs.json':`seed${seed}_candidate_inputs.json`)),changed,files},null,2));
 const oldMetrics=JSON.parse(fs.readFileSync(p.join(prior,'measurements.json'))).find(q=>q.seed===seed&&q.label==='candidate');assert(oldMetrics.fitSuccessful&&oldMetrics.timingSuccessful);
 for(const [f,h]of Object.entries(oldMetrics.reportHashes))assert.equal(sha(fs.readFileSync(p.join(baseline,'output_files',f))),h,'Prior report changed '+f);
 reused.push({seed,revision:base,directory:baseline,metrics:oldMetrics,reportHashesVerified:true,allInputHashesVerified:true});
}
const oldIntegrity=JSON.parse(fs.readFileSync(p.join(prior,'integrity.json'))),tools={};for(const n of ['quartus_sh','quartus_map','quartus_fit','quartus_asm','quartus_sta']){tools[n]=sha(fs.readFileSync(`C:/intelFPGA_lite/17.0/quartus/bin64/${n}.exe`));assert.equal(tools[n],oldIntegrity.toolHashes[n]);}
fs.writeFileSync(p.join(out,'baseline_reuse.json'),JSON.stringify({scope:'Reuse only verified prior PR227 candidate 8cd53ccc as the FM baseline, never its master baseline or historical v19',reused},null,2));
fs.writeFileSync(p.join(out,'provenance.json'),JSON.stringify({revision,uncommittedPatchSHA256:corrected?patchSHA256:null,baseline:base,dependency,buildDate:'261114',device:'5CSEBA6U23I7',seeds:[1,2,3],tools,version:cp.execFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe',['--version']).toString(),preparationOnly:true,compilationGatedOnFunctionalResults:true},null,2));console.log('Prepared three candidate exports; all three paired FM baseline input/report hashes and Quartus executable hashes verified. No compilation started.');
