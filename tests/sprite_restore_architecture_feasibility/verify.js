const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=args=>cp.execFileSync('git',['--no-optional-locks',...args],{cwd:root}).toString().trim();
const ledger=JSON.parse(fs.readFileSync(p.join(d,'provenance.json')));
assert.equal(git(['rev-parse','HEAD']),ledger.head);assert.equal(git(['branch','--show-current']),ledger.branch);
assert.equal(git(['diff','--stat']),'');assert.equal(git(['diff','--cached','--stat']),'');
for(const r of ledger.tracked)assert.equal(sha(fs.readFileSync(p.join(root,r.file))),r.sha256,r.file);
for(const r of ledger.inputs)assert.equal(sha(fs.readFileSync(p.join(root,'tests/savestate_g08_fm/quartus_early',r.file))),r.sha256,r.file);
for(const [f,h] of Object.entries(ledger.retained))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,f);
let normalized=0;for(const r of ledger.inputs){if(ledger.unused.includes(r.file))continue;const b=fs.readFileSync(p.join(root,'tests/savestate_g08_fm/quartus_early',r.file),'utf8');const c=cp.execFileSync('git',['show','HEAD:'+r.file],{cwd:root}).toString();assert.equal(b.replaceAll('\r\n','\n'),c.replaceAll('\r\n','\n'),r.file);normalized++;}
const report=fs.readFileSync(p.join(d,'review.md'),'utf8');assert(report.startsWith('# G06/G10'));assert.equal((report.match(/^## \d+\./gm)||[]).length,12);assert(report.includes('9470'));assert(report.includes('9974'));
const status=git(['status','--short']);assert.equal(status,ledger.status);
const artifacts={};for(const f of fs.readdirSync(d)){if(f!=='verification.json'&&fs.statSync(p.join(d,f)).isFile())artifacts[f]=sha(fs.readFileSync(p.join(d,f)));}
const out={passed:true,head:ledger.head,branch:ledger.branch,trackedHashesChecked:ledger.tracked.length,seed1InputHashesChecked:ledger.inputs.length,normalizedHeadMatches:normalized,retainedEvidenceHashesChecked:Object.keys(ledger.retained).length,artifacts,trackedDiffStat:git(['diff','--stat']),indexDiffStat:git(['diff','--cached','--stat']),status,candidateCreated:false,productionRTLChanged:false,quartusInvoked:false,simulationInvoked:false,decision:'STOP - no PoC selected'};
fs.writeFileSync(p.join(d,'verification.json'),JSON.stringify(out,null,2)+'\n');console.log(JSON.stringify(out,null,2));
