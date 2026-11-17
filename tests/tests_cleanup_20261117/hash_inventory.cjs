const fs=require('fs'),path=require('path'),crypto=require('crypto');
const root=path.resolve(__dirname,'../..'),files=require('./inventory_before.json');
function hash(file){const h=crypto.createHash('sha256'),fd=fs.openSync(file,'r'),buf=Buffer.allocUnsafe(8*1024*1024);try{let n;while((n=fs.readSync(fd,buf,0,buf.length,null)))h.update(buf.subarray(0,n));}finally{fs.closeSync(fd);}return h.digest('hex');}
const selected=files.filter(f=>f.extension==='.rbf'||f.extension==='.zip'||f.extension==='.sof'||f.extension==='.tgz'||f.extension==='.tar');let n=0;
for(const f of selected){f.sha256=hash(path.join(root,f.path));if(++n%1000===0)console.log('Hashed',n);}
fs.writeFileSync(path.join(__dirname,'binary_hashes.json'),JSON.stringify(selected,null,2));
const rbfs=selected.filter(f=>f.extension==='.rbf'),groups=new Map();for(const f of rbfs){if(!groups.has(f.sha256))groups.set(f.sha256,[]);groups.get(f.sha256).push(f);}
const summary=[...groups].map(([sha256,files])=>({sha256,bytes:files[0].bytes,copies:files.length,paths:files.map(f=>f.path)}));fs.writeFileSync(path.join(__dirname,'rbf_groups.json'),JSON.stringify(summary,null,2));
console.log('RBF files',rbfs.length,'unique hashes',groups.size,'bytes',rbfs.reduce((a,f)=>a+f.bytes,0));console.log('release names',[...new Set(rbfs.filter(f=>f.path.includes('/releases/')).map(f=>path.basename(f.path)))]);
console.log('Archives',selected.filter(f=>['.tar','.tgz'].includes(f.extension)).map(f=>[f.path,f.sha256]));
