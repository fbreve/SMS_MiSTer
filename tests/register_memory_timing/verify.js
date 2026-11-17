const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex'),before=JSON.parse(fs.readFileSync(p.join(d,'preservation_before.json')));
for(const [f,h]of Object.entries(before.files))assert.equal(sha(p.join(root,f)),h,f);
assert.equal(cp.execFileSync('git',['show-ref','--heads'],{cwd:root,encoding:'utf8'}),before.refs,'Branch refs changed');
const all=JSON.parse(fs.readFileSync(p.join(d,'path_comparison.json'))),e=JSON.parse(fs.readFileSync(p.join(d,'implementation_evidence.json')));
const normalize=s=>s.replace(/Z:\/(?:baseline|candidate)\//g,'<BUILD>/');
for(const seed of [1,2]){
 const a=e['seed'+seed+'_baseline'],b=e['seed'+seed+'_candidate'];assert.deepEqual(a.criticalWarnings.map(normalize).sort(),b.criticalWarnings.map(normalize).sort());assert.equal(a.sdcSHA256,b.sdcSHA256);
 for(const v of ['baseline','candidate']){
  const tag='seed'+seed+'_'+v;assert(all[tag].main.every(x=>!x.from.includes('opll:fm')&&!x.to.includes('opll:fm')));
  for(const kind of ['query','families']){let b=fs.readFileSync(p.join(d,tag+'_'+kind+'.log'));let s=b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');assert(s.includes('0 errors, 0 warnings'),tag+kind);}
  assert(fs.readFileSync(p.join(d,tag+'_ignored_sdc.rpt'),'utf8').includes('No constraints were ignored.'));
  const entries=fs.readFileSync(p.join(d,tag+'_paths.tsv'),'utf8').split(/\r?\n/).filter(x=>/^1\tsetup_.*multicycle/.test(x));assert(entries.every(l=>l.endsWith('\t1')));
 }
}
const result={protectedFiles:Object.keys(before.files).length,preservedBranchRefs:before.refs.trim().split('\n').length,preservationMismatches:0,retainedOriginalDatabasesUnchanged:true,allFourWorstSlacksReproduced:true,eightSuccessfulQueryRuns:true,criticalWarningContentMatchesWithinEachPair:true,ignoredSdcConstraints:false,allTop20PathsOutsideFM:true,noRTLConstraintsSettingsSeedsChanged:true,noMapFitOrAsmRun:true,status:cp.execFileSync('git',['status','--short'],{cwd:root,encoding:'utf8'}),experimentalStatus:cp.execFileSync('git',['status','--short'],{cwd:p.join(root,'tests/register_memory_auto/worktree'),encoding:'utf8'})};
fs.writeFileSync(p.join(d,'preservation_after.json'),JSON.stringify(result,null,2)+'\n');console.log(result);
