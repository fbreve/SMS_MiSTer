const fs=require('fs'),path=require('path');const d=__dirname;const data=JSON.parse(fs.readFileSync(path.join(d,'accepted_sweeps.json'),'utf8'));
for(let p=18;p<=25;p++){const e=data[p].filter(e=>e.pc===0x139);const groups={};for(const v of e){const k=v.bc.toString(16);(groups[k]??=[]).push(v.requestCycle-169502);}console.log(p,JSON.stringify(groups));}
