const fs=require('fs'),p=require('path'),cp=require('child_process');const d=__dirname,root=p.resolve(d,'../../..');
let s=cp.execFileSync('git',['show','66f16d5c:rtl/dpram.vhd'],{cwd:root,encoding:'utf8'}).replace(/\bdpram\b/gi,'dpram_vendor').replace('string := " "','string := "UNUSED"');fs.writeFileSync(p.join(d,'dpram_vendor.vhd'),s);
