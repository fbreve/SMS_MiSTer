const fs=require('fs'),path=require('path');const d=__dirname,old=path.resolve(d,'../savestate_cpu_nmi_fix'),n=path.join(d,'nmi'),out=path.join(d,'nmi_final');fs.mkdirSync(out,{recursive:true});
const read=p=>{let b=fs.readFileSync(p);return b.toString(b[0]===255?'utf16le':'utf8');};
const all=JSON.parse(fs.readFileSync(path.join(n,'cases.json'),'utf8'));const groups=new Map();
for(const c of all.filter(c=>c.format===0)){const p=path.join(old,c.name+'.log');if(!fs.existsSync(p))continue;const m=read(p).match(/ACCEPT[^\r\n]*normalized([01]{3})/);if(m&&!groups.has(m[1]))groups.set(m[1],c);}
groups.set('111',all.find(c=>c.name==='both_released'));
if(groups.size!==8)throw Error('Need all eight known reachable triplets, got '+[...groups.keys()]);
const chosen=[...groups.values()];for(const edge of[-45,-15]){const c=all.find(c=>c.format===0&&c.source===1&&c.edge===edge);if(!c)throw Error('GG');if(!chosen.some(x=>x.name===c.name))chosen.push(c);}
for(const f of ['machine.sv','fixed_tb.sv','batch.ps1','sim.ps1','io_instance.sv'])fs.copyFileSync(path.join(n,f),path.join(out,f));
for(const f of ['T80_integrated.vhd','T80s_integrated.vhd','savestates_integrated.sv'])fs.copyFileSync(path.join(d,f),path.join(out,f));
let script=fs.readFileSync(path.join(n,'compile.do'),'utf8').replaceAll('fixed_work','final_work');fs.writeFileSync(path.join(out,'compile.do'),script);
let batch=fs.readFileSync(path.join(out,'batch.ps1'),'utf8').replaceAll('fixed_work','final_work');fs.writeFileSync(path.join(out,'batch.ps1'),batch);
fs.writeFileSync(path.join(out,'cases.json'),JSON.stringify(chosen,null,2));fs.writeFileSync(path.join(out,'expected_triplets.json'),JSON.stringify(Object.fromEntries([...groups].map(([k,v])=>[k,v.name])),null,2));
console.log('Prepared '+chosen.length+' exact-final-source NMI cases: eight triplets plus GG ordering.');
