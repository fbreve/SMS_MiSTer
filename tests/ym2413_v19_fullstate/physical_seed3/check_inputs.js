const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,m=JSON.parse(fs.readFileSync(p.join(d,'inputs.json'))),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
for(const v of process.argv.slice(2).length?process.argv.slice(2):['baseline','candidate'])for(const [f,info]of Object.entries(m.builds[v].inputs))assert.equal(hash(fs.readFileSync(p.join(d,v,f))),info.SHA256,'Frozen input changed '+v+'/'+f);
console.log('PASS frozen input hashes');
