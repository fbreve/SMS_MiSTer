const fs=require('fs'),p=require('path'),d=__dirname;
for(const file of fs.readdirSync(d).filter(f=>/\.(js|ps1|md)$/.test(f)&&!f.startsWith('_')).concat(['fixtures/regression_tb.sv'])){
 const f=p.join(d,file);fs.writeFileSync(f,fs.readFileSync(f,'utf8').replace(/^\uFEFF/,'').replaceAll('\r\n','\n'));
}
