const fs=require('fs'),p=require('path'),d=__dirname,auto=p.resolve(d,'../ym2413_registermemory_auto');
let code=fs.readFileSync(p.join(auto,'prepare_multiseed.js'),'utf8').replaceAll('AUTO','MLAB');
code=code.replace("fs.copyFileSync(p.join(src,f),p.join(d,f))","fs.copyFileSync(p.join(f==='build.ps1'?p.resolve(task,'../ym2413_registermemory_auto/physical_seed2'):src,f),p.join(d,f))");
fs.writeFileSync(p.join(d,'prepare_multiseed.js'),code);
