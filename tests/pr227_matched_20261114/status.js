const fs=require('fs'),path=require('path'),os=require('os');
console.log('Memory GiB total/free:',(os.totalmem()/2**30).toFixed(1),(os.freemem()/2**30).toFixed(1));
for(const f of fs.readdirSync(__dirname).filter(f=>f.endsWith('.stdout.log'))){const p=path.join(__dirname,f),s=fs.statSync(p);const h=fs.openSync(p,'r'),b=Buffer.alloc(Math.min(131072,s.size));fs.readSync(h,b,0,b.length,s.size-b.length);fs.closeSync(h);const lines=b.toString().split(/[\r\n]+/).filter(Boolean);console.log(f,s.size,lines.at(-1)?.slice(0,260));}
