const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'cache');fs.mkdirSync(dst,{recursive:true});
for(const f of fs.readdirSync(p.join(d,'campaign'))){if(/\.(v|sv|vhd|hex|svh|do)$/.test(f))fs.copyFileSync(p.join(d,'campaign',f),p.join(dst,f));}
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
s=s.replaceAll("{7'd0,HIST[0]}","{7'd0,history_input}");
s=s.replace('reg nmi_future=1;','reg history_input=HIST[0];\nalways@(posedge ss_freeze)history_input=0;\nreg nmi_future=1;');
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
console.log('Prepared history pair with identical physical future IO input levels from capture onward.');
