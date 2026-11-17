const fs=require('fs'),p=require('path'),d=__dirname;
const old=JSON.parse(fs.readFileSync(p.resolve(d,'../savestate_g12_sdram/cases.json'),'utf8'));
const cases=old.filter(c=>['history_0','history_1','systeme_transfer_2','ordinary_transfer_1'].includes(c.id));
fs.writeFileSync(p.join(d,'matrix/additional_cases.json'),JSON.stringify(cases,null,2));
console.log('Prepared natural equal-image history pair and two shared-transfer sanity cases.');
