const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const previous=fs.readFileSync(p.join(d,'../cram_memory_inference/collect_build.js'),'utf8');
const end=previous.indexOf('const manifest=');assert(end>0);
fs.writeFileSync(p.join(d,'measure.js'),previous.slice(0,end)+'\nmodule.exports=measure;\n');
console.log('Copied read-only metric parser into experiment; previous evidence unchanged.');
