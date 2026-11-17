const fs=require('fs'),path=require('path'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..'),prior=path.join(r,'tests/savestate_lightgun_fix'),dest=path.join(d,'candidate');
if(!dest.startsWith(d+path.sep))throw Error('Bad build directory');
if(!fs.existsSync(dest)){
 fs.mkdirSync(dest,{recursive:true});
 for(const n of ['rtl','sys'])fs.cpSync(path.join(prior,'candidate',n),path.join(dest,n),{recursive:true});
 for(const n of ['SMS.qpf','SMS.qsf','files.qip','build_id.v'])fs.copyFileSync(path.join(prior,'candidate',n),path.join(dest,n));
}
const manifest=JSON.parse(fs.readFileSync(path.join(prior,'sources.json'),'utf8')),sources={};
for(const p of Object.keys(manifest)){
 const source=path.join(r,p),target=path.join(dest,p);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(source,target);
 sources[p]=crypto.createHash('sha256').update(fs.readFileSync(source)).digest('hex');
}
fs.writeFileSync(path.join(d,'build_sources.json'),JSON.stringify(sources,null,2)+'\n');
console.log('Prepared isolated F12 build, '+Object.keys(sources).length+' source/settings files; retained identical F11 framework/build ID.');
