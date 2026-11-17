const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:16e6});const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(git('branch','--show-current').toString().trim(),'investigate/savestate-g06-sequential-architecture');assert.equal(git('diff','--name-only').toString().trim(),'');assert.equal(git('diff','--cached','--name-only').toString().trim(),'');
const hashes=Object.fromEntries(git('ls-files').toString().trim().split(/\r?\n/).filter(f=>fs.statSync(p.join(root,f)).isFile()).map(f=>[f,sha(fs.readFileSync(p.join(root,f)))]));
const names=['savestate_resource_growth','savestate_sprite_resource_optimization','savestate_f01_opll_architecture','savestate_f01_opll_fix','savestate_g06_g10_fix','savestate_g02_g05_v14','savestate_g05_background_fix'];
const reports=Object.fromEntries(names.map(n=>{const f='tests/'+n+'/review.md';return [f,sha(fs.readFileSync(p.join(root,f)))];}));
const base=require('../savestate_f01_opll_fix/final_results.json');assert(base.sourceHashesVerified&&base.snapshotInferred);assert.equal(base.candidate.placed,38598);
const files=['SMS.sv','files.qip','rtl/savestates.sv','rtl/system.vhd','rtl/vdp.vhd','rtl/vdp_main.vhd','rtl/vdp_sprites.vhd','rtl/vdp_sprite_shifter.vhd'];
for(const tree of ['baseline','candidate_A'])for(const f of files){const out=p.join(d,tree,f);fs.mkdirSync(p.dirname(out),{recursive:true});fs.copyFileSync(p.join(root,f),out);}
fs.writeFileSync(p.join(d,'historical_g06_g10.diff'),git('diff','5858318^','5858318','--',...files));
fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:git('rev-parse','HEAD').toString().trim(),f01Commit:'7fcd5e12847eedf9e97a44dc937c3dbac3205f7c',preG06:git('rev-parse','5858318^').toString().trim(),g06:git('rev-parse','5858318').toString().trim(),branch:git('branch','--show-current').toString().trim(),format:17,hashes,reports,baselineMetrics:base.candidate,configuration:{tool:'Quartus 17.0.2 Build602',device:'5CSEBA6U23I7',project:'SMS',top:'sys_top',seed:1,buildDate:'261025'},files},null,2)+'\n');
console.log({head:git('rev-parse','HEAD').toString().trim(),productionClean:true,trackedFiles:Object.keys(hashes).length,reports:names.length,isolatedCopies:files.length});
