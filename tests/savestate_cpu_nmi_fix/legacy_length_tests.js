// Keep older peripheral fallback tests explicitly on their original v11 tag.
// Malformed v12 now fails closed and has separate F16 rejection tests.
const fs=require('fs'),path=require('path'),d=__dirname;
const walk=p=>fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(p,e.name)):[path.join(p,e.name)]);
for(const p of ['regression','regressions'].flatMap(n=>walk(path.join(d,n))).filter(p=>p.endsWith('.sv')&&!path.basename(p).includes('savestates'))){let s=fs.readFileSync(p,'utf8'),n=s.replace(/(\d+:)\s*mem\['h1a\]\[39:38\]=([^;]+);/g,"$1begin mem['h1a][63:40]=24'h48430b;mem['h1a][39:38]=$2;end");if(n!==s){fs.writeFileSync(p,n);console.log(path.relative(d,p));}}
