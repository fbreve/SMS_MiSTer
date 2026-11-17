const fs=require('fs'),p=require('path'),d=__dirname;
const txt=f=>{if(!fs.existsSync(f))return '';const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const random=[];for(let i=1;i<=16;i++){const s=txt(p.join(d,'random_'+i,'replay.log'));random.push({seed:i,pass:s.includes('PASS F01'),failed:/\*\* (?:Error|Failure|Fatal):/.test(s)});}
const cases=require('./regression_manifest.json').map(r=>{const s=txt(p.join(d,r.family,r.name,'simulation.log'));return {family:r.family,name:r.name,pass:s.includes(r.marker)&&(!r.also||s.includes(r.also)),failed:/\*\* (?:Error|Failure|Fatal):/.test(s)};});
const result={randomPass:random.filter(r=>r.pass).length,randomPending:random.filter(r=>!r.pass),regressionPass:cases.filter(r=>r.pass).length,regressionTotal:cases.length,regressionPending:cases.filter(r=>!r.pass)};
fs.writeFileSync(p.join(d,'progress.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result,null,2));
