const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),cp=require('child_process'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),git=(...args)=>cp.execFileSync('git',args,{encoding:'utf8',stdio:['ignore','pipe','ignore']}).trim();
const g=require('./functional_gate.json'),m=require('./build_early_inputs.json'),b=require('./early_results.json'),base=require('./baseline.json');assert(g.passed&&b.sourceHashesVerified);
assert.equal(git('rev-parse','HEAD'),base.head);assert.equal(git('branch','--show-current'),'investigate/savestate-g08-fm');assert.equal(git('diff','--cached','--name-only'),'');
assert.deepEqual(git('diff','--name-only').split(/\r?\n/).sort(),Object.keys(g.sourceHashes).sort());
for(const[f,h]of Object.entries(g.sourceHashes)){assert.equal(sha(fs.readFileSync(f)),h,f);assert.equal(m.inputs[f],h);}
for(const[f,h]of Object.entries(m.inputs))assert.equal(sha(fs.readFileSync(p.join(d,'quartus_early',f))),h,'built input unchanged '+f);
assert.equal(sha(fs.readFileSync(p.join(d,'quartus_early/build_id.v'))),m.buildIdSHA);
assert.equal(sha(fs.readFileSync(p.join(d,'functional_gate.json'))),m.gateSHA,'build-bound simulation gate');
for(const[name,h]of Object.entries(base.reports))assert.equal(sha(fs.readFileSync(p.join(d,'..',name,'review.md'))),h,'prerequisite report unchanged '+name);
const report=fs.readFileSync(p.join(d,'review.md'),'utf8');assert.equal([...report.matchAll(/^## \d+\. /gm)].length,44);
for(const match of report.matchAll(/\[[^\]]+\]\(([^)]+)\)/g)){const target=match[1];if(!/^(https?:|#)/.test(target))assert(fs.existsSync(p.resolve(d,target.split('#')[0])),'report link '+target);}
git('diff','--check');
const out={passed:true,head:base.head,branch:git('branch','--show-current'),productionChanges:Object.keys(g.sourceHashes),staged:[],sourceHashes:g.sourceHashes,gateSHA:m.gateSHA,reportSHA:sha(Buffer.from(report)),prerequisiteReportsUnchanged:true,reportSections:44,quartusSourceHashesVerified:true};
fs.writeFileSync(p.join(d,'final_verification.json'),JSON.stringify(out,null,2));console.log(JSON.stringify(out,null,2));
