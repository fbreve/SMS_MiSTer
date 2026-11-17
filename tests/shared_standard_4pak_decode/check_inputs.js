const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');const d=__dirname,m=JSON.parse(fs.readFileSync(p.join(d,'input_manifest.json'))),key=process.argv[2];
assert(m.builds[key],key);const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
for(const[f,h]of Object.entries(m.builds[key].inputs))assert.equal(sha(fs.readFileSync(p.join(d,key,f))),h.SHA256,key+' '+f);
for(const[e,h]of Object.entries(m.toolHashes))assert.equal(sha(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+e+'.exe')),h,e);
console.log('Frozen source/configuration/tool inputs verified: '+key);
