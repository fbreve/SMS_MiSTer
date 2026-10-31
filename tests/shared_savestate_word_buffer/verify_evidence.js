const fs=require('fs'),p=require('path'),crypto=require('crypto'),zlib=require('zlib'),assert=require('assert');
const read=f=>JSON.parse(fs.readFileSync(p.join(__dirname,f),'utf8').replace(/^\uFEFF/,''));
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const functional=read('evidence/functional/results.json');
for(const [file,sha] of Object.entries(functional.scripts))assert.equal(hash(fs.readFileSync(p.join(__dirname,file))),sha,file);
for(const test of functional.tests){assert(test.pass);assert.equal(hash(fs.readFileSync(p.join(__dirname,'evidence/functional',test.name+'.log'))),test.logSha256);}
const physical=read('physical/results.json');assert(physical.complete,'Both matched pairs must be complete');
for(const [file,sha] of Object.entries(physical.scripts))assert.equal(hash(fs.readFileSync(p.join(__dirname,file))),sha,file);
assert.deepEqual(Object.keys(physical.builds),['1','2']);
for(const [file,entry] of Object.entries(physical.archive)){
 const bytes=fs.readFileSync(p.join(__dirname,'physical',file));
 assert.equal(hash(bytes),entry.gzipSha256,file);const raw=zlib.gunzipSync(bytes);
 assert.equal(hash(raw),entry.sha256,file);assert.equal(raw.length,entry.bytes,file);
}
for(const seed of ['1','2'])for(const variant of ['baseline','candidate']){
 const build=physical.builds[seed][variant];assert.equal(build.effectiveSeed,+seed);
 for(const stage of ['map','fit','asm','sta'])assert(physical.archive[`evidence/seed${seed}/${variant}/${stage}.log.gz`]);
 for(const stage of ['map','fit','sta'])assert(physical.archive[`evidence/seed${seed}/${variant}/reports/SMS.${stage}.summary.gz`]);
}
console.log(`PASS preserved evidence: ${functional.tests.length} simulations, four physical builds, ${Object.keys(physical.archive).length} hashed archives; no build databases required`);
