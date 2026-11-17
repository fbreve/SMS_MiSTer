const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process');const out=__dirname,hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const p=JSON.parse(fs.readFileSync(path.join(out,'provenance.json')));p.testedSeeds=[1,2,3];p.runs=[];const artifacts={};
for(const seed of p.testedSeeds)for(const label of ['baseline','candidate']){
 const stem=seed===1?`seed1_${label}_attempt3`:`seed${seed}_${label}`;
 const status=JSON.parse(fs.readFileSync(path.join(out,stem+'.status.json')));if(status.exitCode!==0)throw Error('Build failed: '+stem);p.runs.push(status);
 const dir=path.join(out,`seed${seed}`,label,'output_files');for(const f of fs.readdirSync(dir)){const file=path.join(dir,f);if(fs.statSync(file).isFile())artifacts[path.relative(out,file).replaceAll('\\','/')]=hash(fs.readFileSync(file));}
 const builtDate=fs.readFileSync(path.join(out,`seed${seed}`,label,'build_id.v'),'utf8');if(builtDate!=='`define BUILD_DATE "261114"')throw Error('Date mismatch: '+stem);
}
p.finalHead=cp.execFileSync('git',['rev-parse','HEAD'],{cwd:path.resolve(out,'../..')}).toString().trim();p.finalTrackedDiff=cp.execFileSync('git',['diff','--exit-code'],{cwd:path.resolve(out,'../..')}).toString();
fs.writeFileSync(path.join(out,'final_provenance.json'),JSON.stringify(p,null,2));fs.writeFileSync(path.join(out,'artifact_manifest.json'),JSON.stringify(artifacts,null,2));console.log('Sealed '+Object.keys(artifacts).length+' output artifacts from six completed builds.');
