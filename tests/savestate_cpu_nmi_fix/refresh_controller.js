const fs=require('fs'),p=require('path'),d=__dirname,s=fs.readFileSync(p.join(d,'savestates_sim.sv'));
function walk(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const n=p.join(dir,e.name);if(e.isDirectory()){if(!e.name.endsWith('_work'))walk(n);}else if(e.name==='savestates_sim.sv')fs.writeFileSync(n,s);}}
walk(p.join(d,'regression'));walk(p.join(d,'regressions'));
