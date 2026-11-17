const fs=require('fs'),p=require('path'),assert=require('assert'),measure=require('./measure'),d=__dirname;
require('./verify');const m=measure(p.join(d,'../savestate_g08_fm/quartus_early'));
for(const[k,v]of Object.entries({needed:37117,placed:38599,registers:48880,synthesisRegisters:46327,M10K:488,memoryBits:3818050,DSP:39,recoverable:2055,unavailable:573,logicALUT:46835,routingALUT:18266,setup:0.104,hold:0.239,violations:0}))assert.equal(m[k],v,k);
fs.writeFileSync(p.join(d,'measured_baseline.json'),JSON.stringify(m,null,2)+'\n');console.log('PASS fresh retained v19 report parse: all required resources, packing identity and timing match.');
