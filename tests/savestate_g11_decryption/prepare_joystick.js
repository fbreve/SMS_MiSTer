const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'joystick');fs.mkdirSync(dst,{recursive:true});
for(const f of fs.readdirSync(p.join(d,'cache'))){if(/\.(v|sv|vhd|hex|svh|do)$/.test(f))fs.copyFileSync(p.join(d,'cache',f),p.join(dst,f));}
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
if(!s.includes("ram_bytes[1]=8'h7c"))throw Error('missing IO-history source bridge');
s=s.replace("ram_bytes[1]=8'h7c","ram_bytes[1]=8'hdc").replace('IN A,(7c)','IN A,(DC)');
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
console.log('Prepared real DC joystick-input history selection; all future inputs canonicalize at capture.');
