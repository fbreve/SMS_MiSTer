const fs=require('fs'),p=require('path'),d=__dirname,file=p.join(d,'regression_manifest.json'),rows=JSON.parse(fs.readFileSync(file));
for(const r of rows)if(r.family!=='sprites'){const s=fs.readFileSync(p.join(d,r.family,'vdp_tb.sv'),'utf8');r.marker=s.includes('$display("PASS RICH V15 VDP')?'PASS RICH V15 VDP':'PASS V15 VDP';}
fs.writeFileSync(file,JSON.stringify(rows,null,2));
