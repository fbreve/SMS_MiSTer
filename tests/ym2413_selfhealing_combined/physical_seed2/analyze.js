const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),assert=require('assert'),d=__dirname;
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const r=JSON.parse(read(p.join(d,'results.json'))),manifest=JSON.parse(read(p.join(d,'inputs.json'))),ref=manifest.reference.directory;
const rows=s=>s.split(/\r?\n/).filter(x=>x.startsWith(';')).map(x=>x.split(';').slice(1,-1).map(y=>y.trim()));
function table(s,title){const start=s.indexOf('; '+title+' ');assert(start>=0,title);const lines=s.slice(start).split(/\r?\n/);let stop=lines.findIndex((x,i)=>i>3&&!x.trim());if(stop<0)stop=lines.length;return rows(lines.slice(0,stop).join('\n'));}
const hierarchy={};for(const [label,root]of [['reference',p.join(ref,'candidate')],['candidate',p.join(d,'candidate')]]){
 hierarchy[label]={};for(const [stage,title]of [['map','Analysis & Synthesis Resource Utilization by Entity'],['fit','Fitter Resource Utilization by Entity']]){
  const t=table(read(p.join(root,'output_files/SMS.'+stage+'.rpt')),title);
  hierarchy[label][stage]={header:t.find(x=>x[0]==='Compilation Hierarchy Node'),rows:t.filter(x=>/^(?:TemporalMixer|PhaseMemory|opll_snapshot|opll)$/.test(x[x.length-2]))};
 }
}
r.hierarchy=hierarchy;
assert.deepEqual(r.expandedSettingDifferences,{onlyBaseline:[],onlyCandidate:[]},'Expanded settings differ');
assert.deepEqual(r.fitterSettingDifferences,{onlyBaseline:[],onlyCandidate:[]},'Fitter settings differ');
for(const [f,h]of Object.entries(r.builds.baseline.reportHashes))assert.equal(hash(fs.readFileSync(p.join(ref,'candidate/output_files',f))),h,'Reference report changed '+f);
const before=JSON.parse(read(p.join(d,'preservation_before.json')));
const git=(cwd,...args)=>cp.execFileSync('git',['--no-optional-locks',...args],{cwd,stdio:['ignore','pipe','pipe']});
for(const [w,v]of Object.entries(before.worktrees)){assert.equal(git(w,'rev-parse','HEAD').toString().trim(),v.HEAD,w+' HEAD');assert.equal(hash(git(w,'diff','--binary','HEAD')),v.diff,w+' diff');assert.equal(git(w,'status','--porcelain','--untracked-files=no').toString(),v.status,w+' tracked status');}
assert.equal(git(p.resolve(d,'../../..'),'rev-parse','master').toString().trim(),before.master);
for(const [f,v]of Object.entries(manifest.builds.candidate.inputs))assert.equal(hash(fs.readFileSync(p.join(d,'candidate',f))),v.SHA256,'Candidate input changed '+f);
const b=r.builds.candidate,tag=b.qualifiedConstrainedTiming?'TIMING_PASS':'TIMING_FAIL';
const filename=`SMS_YM2413_MIX_MIXOUT_104W_v17_98737615_src${manifest.sourceHash.slice(0,12)}_Q17.0.2_seed2_${tag}_${b.rbf.SHA256.slice(0,12)}.rbf`;
assert(!fs.existsSync(p.join(d,filename)),'Do not overwrite preserved RBF');fs.copyFileSync(p.join(d,b.rbf.path),p.join(d,filename));
r.preservedRBF={filename,SHA256:hash(fs.readFileSync(p.join(d,filename))),bytes:b.rbf.bytes};
r.preservation='PASS: frozen inputs, archived reference native reports, master and all preexisting worktree HEADs/tracked diffs/status unchanged';
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(r,null,2)+'\n');
console.log(JSON.stringify({deltas:r.deltas,hierarchy:r.hierarchy,warnings:r.warnings,critical:b.paths.setup[0],FM:b.paths.fm_from[0],FMto:b.paths.fm_to[0],preservedRBF:r.preservedRBF,preservation:r.preservation},null,2));
