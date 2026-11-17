const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,m=JSON.parse(fs.readFileSync(p.join(d,'input_manifest.json')));
for(const v of ['A','C']){const a=m.builds['seed1/'+v].inputs,b=m.builds['seed2/'+v].inputs;assert.deepEqual(Object.keys(a),Object.keys(b));assert.deepEqual(Object.keys(a).filter(f=>a[f].SHA256!==b[f].SHA256),['SMS.qsf']);}
for(const seed of [1,2]){const a=m.builds[`seed${seed}/A`].inputs,b=m.builds[`seed${seed}/C`].inputs;assert.deepEqual(Object.keys(a).filter(f=>a[f].SHA256!==b[f].SHA256),['rtl/memory_decode.vhd']);}
const a=fs.readFileSync(p.join(d,'seed1/A/rtl/memory_decode.vhd'),'utf8'),c=fs.readFileSync(p.join(d,'seed1/C/rtl/memory_decode.vhd'),'utf8');
assert.equal(a.slice(0,a.indexOf("\t\telsif mapper_4pak = '1' then")),c.slice(0,c.indexOf('\t\telse\n\t\t\t-- Standard Sega')));
fs.writeFileSync(p.join(d,'configuration_equality.json'),JSON.stringify({pairsDifferOnly:['rtl/memory_decode.vhd'],seedsDifferOnly:['SMS.qsf: SEED 1/2'],unchangedPriorityBranchesAndOtherOutputs:true,allGeneratedInputsEqual:true},null,2));console.log('Configuration and unchanged priority logic PASS');
