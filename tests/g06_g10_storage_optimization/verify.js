const fs=require('fs'),cp=require('child_process'),crypto=require('crypto'),path=require('path'),assert=require('assert');
const d=__dirname,hash=b=>crypto.createHash('sha256').update(b).digest('hex'),read=p=>fs.readFileSync(p,'utf8');
const git=(...a)=>cp.execFileSync('git',a,{encoding:'utf8',maxBuffer:20000000}).trim();
const b=JSON.parse(read(d+'/baseline.json'));
assert.equal(git('rev-parse','HEAD'),b.HEAD);assert.equal(git('branch','--show-current'),'optimize/g06-g10-snapshot-storage');
assert.equal(git('diff','--stat'),'');assert.equal(git('diff','--cached','--stat'),'');git('diff','--check');
for(const r of b.tracked)assert.equal(hash(fs.readFileSync(r.file)),r.sha256,r.file);
for(const r of b.reports)assert.equal(hash(fs.readFileSync(r.file)),r.sha256,r.file);
const manifest=JSON.parse(read('tests/savestate_g08_fm/build_early_inputs.json'));
for(const [p,h]of Object.entries(manifest.inputs))assert.equal(hash(fs.readFileSync('tests/savestate_g08_fm/quartus_early/'+p)),h,p);
const inv=JSON.parse(read(d+'/inventory.json'));assert.equal(inv.physicalRingBits,9600);assert.equal(inv.meaningfulBits,9556);assert.equal(inv.fields.length,18);
const log=read(d+'/freeze.log');assert(log.includes('PASS FREEZE ALL checks3278000 configurations64 nonzero64 distinct64'));assert(log.includes('Errors: 0, Warnings: 0'));assert(!/\*\* (Fatal|Error|Failure)/.test(log));assert.equal((log.match(/# PASS FREEZE mode/g)||[]).length,64);
const rep=JSON.parse(read(d+'/representation_checks.json'));assert(rep.passed&&rep.SAVERingReturnsExactly&&rep.frozenLiveSAVEWordEquality);assert.equal(rep.bothBanksPaddingNotDead,44);
const report=read(d+'/review.md');assert.equal((report.match(/^## \d+\./gm)||[]).length,22);
let localLinks=0;for(const file of fs.readdirSync(d).filter(p=>p.endsWith('.md'))){for(const m of read(d+'/'+file).matchAll(/\[[^\]]*\]\(([^)]+)\)/g)){if(m[1]==='verification.json')continue;assert(fs.existsSync(path.resolve(d,m[1].split('#')[0])),m[1]);localLinks++;}}
const result={passed:true,decision:'E. NO SAFE CANDIDATE IDENTIFIED',stoppedAtPhase:5,HEAD:b.HEAD,branch:git('branch','--show-current'),trackedFilesUnchanged:b.tracked.length,prerequisiteReportsUnchanged:b.reports.length,retainedBuildInputsRawVerified:Object.keys(manifest.inputs).length,physicalRingBits:9600,meaningfulSpriteBits:9556,paddingPositionsNotDead:44,newBaselineProbe:{scope:'two unchanged production64-slot sprite parent/shifter instances; excludes VDP collision delay and controller',configurations:64,hostComparisons:3278000,nonzeroConfigurations:64,distinctOwnerConfigurations:64,errors:0,warnings:0,logSHA256:hash(fs.readFileSync(d+'/freeze.log')),RTLHashes:['rtl/vdp_sprites.vhd','rtl/vdp_sprite_shifter.vhd'].map(p=>({file:p,sha256:hash(fs.readFileSync(p))})),fixtureHashes:['freeze_tb.sv','freeze.do','run_freeze.ps1'].map(p=>({file:p,sha256:hash(fs.readFileSync(d+'/'+p))}))},symbolicRepresentationChecksPassed:true,reportSections:22,localLinksChecked:localLinks,productionChanges:false,optimizedRTLImplemented:false,QuartusLaunched:false,commitPushPR:false,diffStat:git('diff','--stat'),statusShort:git('status','--short')};
fs.writeFileSync(d+'/verification.json',JSON.stringify(result,null,2)+'\n');
fs.writeFileSync(d+'/artifact_manifest.json',JSON.stringify(fs.readdirSync(d).filter(p=>fs.statSync(d+'/'+p).isFile()&&p!=='artifact_manifest.json'&&!/^(modelsim.ini|vsim.wlf|transcript)$/.test(p)).map(p=>({file:p,sha256:hash(fs.readFileSync(d+'/'+p))})),null,2)+'\n');
console.log(JSON.stringify({passed:result.passed,decision:result.decision,stoppedAtPhase:5,trackedFilesUnchanged:result.trackedFilesUnchanged,buildInputsVerified:result.retainedBuildInputsRawVerified,freezeComparisons:3278000,reportSections:22,statusShort:result.statusShort},null,2));
