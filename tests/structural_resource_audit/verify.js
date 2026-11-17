const fs=require('fs'),cp=require('child_process'),crypto=require('crypto'),path=require('path');
const d=__dirname,read=p=>fs.readFileSync(p,'utf8'),hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{encoding:'utf8',maxBuffer:20000000}).trim();
const base=JSON.parse(read(d+'/baseline.json'));
function assert(b,s){if(!b)throw Error(s);}
assert(git('rev-parse','HEAD')===base.HEAD,'HEAD changed');
assert(git('branch','--show-current')==='investigate/structural-resource-audit','branch');
assert(!git('diff','--stat')&&!git('diff','--cached','--stat'),'tracked changes');
git('diff','--check');
for(const x of base.trackedHDL)assert(hash(x.path)===x.sha256,'HDL changed '+x.path);
for(const x of base.prerequisites)if(x.exists)assert(hash(x.path)===x.sha256,'prior report changed '+x.path);
for(const x of base.reports)assert(hash(x.path)===x.sha256,'retained report changed '+x.path);
let v=JSON.parse(read(d+'/source_verification.json'));
assert(v.checks.length===137&&v.checks.every(x=>x.buildMatches),'build hash verification');
assert(v.checks.filter(x=>x.headNormalizedMatches===true).length===135,'HEAD source binding');
const tables=JSON.parse(read(d+'/tables.json')),ram=tables['Fitter RAM Summary'].slice(1);
assert(ram.length===41,'RAM rows');
assert(ram.reduce((s,x)=>s+Number(x.cells[18]),0)===488,'M10K reconciliation');
assert(ram.reduce((s,x)=>s+Number(x.cells[12]),0)===3818050,'RAM bits reconciliation');
assert(ram.every(x=>Number(x.cells[19])===0),'MLAB reconciliation');
const log=fs.readFileSync(d+'/control_paths.log').toString('utf16le');
assert(!/\bError\s*\(/.test(log),'TimeQuest error');
assert((log.match(/Found 3 setup paths \(0 violated\)/g)||[]).length===8,'24 source-selected paths');
const timing=[];
for(const n of ['arm','restore','vdp2_restore','header','legacy','freeze','cpu_enable','vdp_enable']){
 const s=read(d+'/'+n+'_setup.rpt'),i=s.indexOf('Path #1:'),j=s.indexOf('Path #2:');
 const first=s.slice(i,j<0?undefined:j),rows=first.split(/\r?\n/).filter(x=>x.startsWith(';')).map(x=>x.split(';').slice(1,-1).map(y=>y.trim()));
 const get=k=>rows.find(x=>x[0]===k)?.[1];
 const k=rows.findIndex(x=>x[0]==='Data'),ic=rows.slice(k).find(x=>x[0]==='IC'),cell=rows.slice(k).find(x=>x[0]==='Cell');
 timing.push({source:n,from:get('From Node'),to:get('To Node'),slack:Number(get('Slack')),dataDelay:Number(get('Data Delay')),logicLevels:Number(rows.find(x=>x[0]==='Number of Logic Levels')?.[2]),dataIC:ic?.[3],dataCell:cell?.[3]});
 assert(Number(get('Slack'))>=0,'source setup '+n);
}
fs.writeFileSync(d+'/control_timing.json',JSON.stringify(timing,null,2)+'\n');
const report=read(d+'/review.md');
assert((report.match(/^## \d+\./gm)||[]).length===22,'22 sections');
let links=[];for(const file of fs.readdirSync(d).filter(x=>x.endsWith('.md'))){for(const m of read(d+'/'+file).matchAll(/\[[^\]]*\]\(([^)]+)\)/g)){const p=m[1];if(/https?:/.test(p))continue;const resolved=path.resolve(d,p.split('#')[0]);assert(fs.existsSync(resolved)||['artifact_manifest.json','verification.json'].includes(p),'broken link '+file+' '+p);links.push({file,target:p});}}
let result={passed:true,HEAD:base.HEAD,branch:git('branch','--show-current'),trackedDiffStat:git('diff','--stat'),stagedDiffStat:git('diff','--cached','--stat'),statusShort:git('status','--short'),HDLFilesUnchanged:base.trackedHDL.length,buildInputsRawVerified:137,HEADInputsNormalizedVerified:135,unusedBackupInputs:2,RAMInstances:41,M10K:488,memoryBits:3818050,sourceSelectedTimingPaths:24,readOnlyTimeQuestPassed:true,reportSections:22,localLinksChecked:links.length,productionEdits:false,newMapOrFit:false,classification:'B. SIGNIFICANT OPTIMIZATION OPPORTUNITIES'};
fs.writeFileSync(d+'/verification.json',JSON.stringify(result,null,2)+'\n');
const artifacts=fs.readdirSync(d).filter(x=>x!=='artifact_manifest.json'&&fs.statSync(d+'/'+x).isFile()).map(x=>({file:x,bytes:fs.statSync(d+'/'+x).size,sha256:hash(d+'/'+x)}));
fs.writeFileSync(d+'/artifact_manifest.json',JSON.stringify(artifacts,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
