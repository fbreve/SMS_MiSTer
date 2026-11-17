const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../../..'),work=p.resolve(d,'../worktree'),rev='66f16d5c656fd8906d62570da4d258875bcee684';
const git=(args,cwd=work)=>cp.execFileSync('git',['--no-optional-locks','-c','core.safecrlf=false',...args],{cwd,maxBuffer:256*1024*1024,stdio:['pipe','pipe','pipe']});
const txt=(a,c)=>git(a,c).toString().trim(),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),filehash=f=>sha(fs.readFileSync(f));
assert(!fs.existsSync(p.join(d,'inputs.json')),'Do not overwrite prepared build evidence');
assert.equal(txt(['rev-parse','HEAD']),rev);assert.equal(txt(['branch','--show-current']),'experiment/ym2413-v19-fullstate');
const phaseDir=p.join(work,'tests/ym2413_fullstate'),approved=JSON.parse(fs.readFileSync(p.join(phaseDir,'manifest.json'))),results=JSON.parse(fs.readFileSync(p.join(phaseDir,'results.json')));
assert.equal(approved.baseline,rev);assert.equal(results.status,'PASS');
for(const [f,h]of Object.entries(approved.sha256))assert.equal(filehash(p.join(work,f)),h,'Reviewed production changed '+f);
for(const log of results.logs)assert.equal(filehash(p.join(phaseDir,log.name)),log.sha256,'Functional log changed '+log.name);
function blobs(cwd,at,prefix=''){
 const rows=txt(['ls-tree','-r',at],cwd).split('\n').map(x=>x.match(/^(\d+) (\w+) (\w+)\t(.+)$/)).filter(x=>x&&x[2]==='blob'&&!x[4].startsWith('releases/'));
 const b=cp.execFileSync('git',['--no-optional-locks','cat-file','--batch'],{cwd,input:rows.map(x=>x[3]).join('\n')+'\n',maxBuffer:256*1024*1024});
 let pos=0,out={};for(const row of rows){const end=b.indexOf(10,pos),n=+b.subarray(pos,end).toString().split(' ')[2];pos=end+1;out[prefix+row[4]]={blob:row[3],bytes:b.subarray(pos,pos+n)};pos+=n+1;}return out;
}
const dependency=txt(['ls-tree',rev,'mist/mist-modules']).match(/160000 commit (\w+)/)[1];
const base={...blobs(work,rev),...blobs(p.join(root,'mist/mist-modules'),dependency,'mist/mist-modules/')};
const tools='C:/intelFPGA_lite/17.0/quartus/bin64',version=cp.execFileSync(p.join(tools,'quartus_sh.exe'),['--version']).toString().trim();
assert(version.includes('17.0.2 Build 602')&&version.includes('Lite Edition'));
const manifest={baseline:rev,candidate:{branch:'experiment/ym2413-v19-fullstate',HEAD:rev,uncommitted:true,FMreference:approved.reference,production:approved.sha256,phase0ResultsSHA256:filehash(p.join(phaseDir,'results.json'))},dependency:{path:'mist/mist-modules',commit:dependency},version,device:'5CSEBA6U23I7',project:'SMS',top:'sys_top',seed:1,buildDate:'261104',toolHashes:{},builds:{},generatedPolicy:'Same standard build-date/CDF metadata for both trees. Explicit map/fit/asm/sta stages; no preflow or QSF changes.',baselineReuse:'Fresh matched baseline: inspected older retained reports used different source baselines.'};
for(const n of ['quartus_sh','quartus_map','quartus_fit','quartus_asm','quartus_sta'])manifest.toolHashes[n]=filehash(p.join(tools,n+'.exe'));
for(const variant of ['baseline','candidate']){
 const dest=p.join(d,variant);assert(!fs.existsSync(dest),'Output directory exists '+dest);const inputs={};
 const sources={...base};if(variant==='candidate')for(const f of approved.changedProduction)sources[f]={...sources[f],bytes:fs.readFileSync(p.join(work,f)),reviewedCandidate:true};
 for(const [f,item]of Object.entries(sources)){if(f.startsWith('releases/'))continue;fs.mkdirSync(p.dirname(p.join(dest,f)),{recursive:true});fs.writeFileSync(p.join(dest,f),item.bytes);inputs[f]={SHA256:sha(item.bytes),blob:item.blob||null,reviewedCandidate:!!item.reviewedCandidate};}
 const generated={'build_id.v':'`define BUILD_DATE "261104"\n','jtag.cdf':'JedecChain;\n\tFileRevision(JESD32A);\n\tDefaultMfr(6E);\n\n\tP ActionCode(Ign)\n\t\tDevice PartName(SOCVHPS) MfrSpec(OpMask(0));\n\tP ActionCode(Cfg)\n\t\tDevice PartName(5CSEBA6U23I7) Path("output_files/") File("SMS.sof") MfrSpec(OpMask(1));\nChainEnd;\n\nAlteraBegin;\n\tChainType(JTAG);\nAlteraEnd;\n'};
 for(const [f,s]of Object.entries(generated)){if(f.startsWith('releases/'))continue;fs.writeFileSync(p.join(dest,f),s);inputs[f]={generated:true,SHA256:sha(s)};}
 for(const n of ['db','incremental_db','output_files','map.log','fit.log'])assert(!fs.existsSync(p.join(dest,n)),'Nonfresh '+variant+'/'+n);
 manifest.builds[variant]={inputs};
}
const a=manifest.builds.baseline.inputs,b=manifest.builds.candidate.inputs;
const differing=[...new Set([...Object.keys(a),...Object.keys(b)])].filter(f=>!a[f]||!b[f]||a[f].SHA256!==b[f].SHA256).sort();
assert.deepEqual(differing,approved.changedProduction.slice().sort());
manifest.sourceDifferences=differing;
manifest.configurationEquality=Object.keys(a).filter(f=>/\.(qsf|qpf|qip|sdc|tcl)$/.test(f)&&f!=='files.qip').every(f=>a[f].SHA256===b[f].SHA256);
assert(manifest.configurationEquality);
manifest.worktreePreservation={HEAD:txt(['rev-parse','HEAD']),branch:txt(['branch','--show-current']),diffSHA256:sha(git(['diff','--binary'])),files:approved.sha256};
fs.writeFileSync(p.join(d,'inputs.json'),JSON.stringify(manifest,null,2)+'\n');
fs.writeFileSync(p.join(d,'candidate.diff'),git(['diff','--binary']));
console.log(JSON.stringify({version,filesBaseline:Object.keys(a).length,filesCandidate:Object.keys(b).length,sourceDifferences:differing.length,configurationEqual:true,dependency}));
