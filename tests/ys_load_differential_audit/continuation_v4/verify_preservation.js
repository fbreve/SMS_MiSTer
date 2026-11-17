const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const root=p.resolve(__dirname,'../../..'),audit=p.dirname(__dirname),initial=JSON.parse(fs.readFileSync(p.join(__dirname,'provenance.json')));
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const git=(...args)=>cp.execFileSync('git',args,{cwd:root,encoding:'utf8'}).trim();
const out={refs:{HEAD:git('rev-parse','HEAD'),master:git('rev-parse','master'),integration:git('rev-parse','integration/ym2413-public-v1-upstream'),historical:git('rev-parse','1b2a52d87d2659c908d4f9f846416d14bfd85bea')},trackedStatus:git('status','--porcelain','--untracked-files=no'),protectedReports:{},nativeHDL:{}};
assert.equal(out.trackedStatus,'');assert.equal(out.refs.HEAD,initial.refs[0]);assert.equal(out.refs.master,initial.refs[1]);assert.equal(out.refs.historical,initial.refs[2]);
for(const [f,want]of Object.entries(initial.protectedReports)){const actual=sha(p.join(audit,f));assert.equal(actual,want,f);out.protectedReports[f]=actual;}
const native=JSON.parse(fs.readFileSync(p.join(__dirname,'candidate_v2/native_source_manifest.json')));
for(const [f,want]of Object.entries(native.source))if(/\.(sv|svh|vhd|do)$/.test(f)){const actual=sha(p.join(__dirname,'candidate_v2',f));assert.equal(actual,want,f);out.nativeHDL[f]=actual;}
out.result='PASS: protected reports and executed HDL unchanged; production tracked files clean; refs unchanged';
fs.writeFileSync(p.join(__dirname,'preservation_results.json'),JSON.stringify(out,null,2));console.log(out.result);
