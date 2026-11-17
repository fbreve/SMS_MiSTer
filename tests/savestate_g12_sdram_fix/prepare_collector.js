const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.resolve(d,'../savestate_g08_release_fix/collect_build.js'),'utf8');
s=s.replaceAll('v16','G12_CANDIDATE').replaceAll('v15','v16').replaceAll('G12_CANDIDATE','candidate').replaceAll('V15','V16').replaceAll('savestate_g08_release_fix','savestate_g12_sdram_fix').replaceAll('quartus_v1[56]','quartus_(?:v16|candidate)');
s=s.replace('result.buildDate=read(',"const mapped=read(p.join(dir,'output_files/SMS.map.summary'));result.synthesisRegisters=+mapped.match(/Total registers\\s*:\\s*([\\d,]+)/)[1].replaceAll(',','');\n result.buildDate=read(");
fs.writeFileSync(p.join(d,'collect_build.js'),s);
console.log('Prepared inherited resource/packing/entity/warning collector for v16 versus G12.');
