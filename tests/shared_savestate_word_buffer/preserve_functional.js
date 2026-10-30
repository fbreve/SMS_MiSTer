const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');
const attempt=p.resolve(process.argv[2]),out=p.join(__dirname,'evidence/functional');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
assert(!fs.existsSync(out),'Preserved evidence already exists');
const results=JSON.parse(fs.readFileSync(p.join(attempt,'results.json'),'utf8'));
assert.equal(results.tests.length,3);assert(results.tests.every(t=>t.pass));
fs.mkdirSync(out,{recursive:true});
for(const test of results.tests){
 const data=fs.readFileSync(p.join(attempt,test.name+'.log'));assert.equal(hash(data),test.logSha256);
 fs.writeFileSync(p.join(out,test.name+'.log'),data);
}
results.scripts=Object.fromEntries(['prepare.js','prepare_focused.js','prepare_targeted.js','run.ps1','verify.js','fixtures/regression_tb.sv'].map(f=>[f,hash(fs.readFileSync(p.join(__dirname,f)))]));
fs.writeFileSync(p.join(out,'results.json'),JSON.stringify(results,null,2)+'\n');
