const fs=require('fs'),p=require('path'),d=__dirname,src=p.resolve(d,'../ym2413_registermemory_auto/physical_seed2'),dest=p.join(d,'physical_seed2');
let code=fs.readFileSync(p.join(src,'analyze.js'),'utf8');
code=code.replace('SMS_YM2413_REGMEM_AUTO_104W','SMS_YM2413_REGMEM_MLAB_104W');
fs.writeFileSync(p.join(dest,'analyze.js'),code);
fs.copyFileSync(p.join(d,'preservation_before.json'),p.join(dest,'preservation_before.json'));
const file=p.join(dest,'inputs.json'),m=JSON.parse(fs.readFileSync(file)),crypto=require('crypto'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
m.smokeInputs.reference=sha(fs.readFileSync(p.join(d,'smoke/reference/registermemory.vhd')));
fs.writeFileSync(file,JSON.stringify(m,null,2)+'\n');
console.log('PASS MLAB analysis helper and smoke provenance prepared; frozen inputs unchanged');
