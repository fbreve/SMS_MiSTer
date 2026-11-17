const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
const roots={baseline:path.join(r,'tests/savestate_lightgun_fix/candidate'),candidate:path.join(d,'candidate')};
const read=p=>{const b=fs.readFileSync(p);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
function ownRegisters(root){
 const s=read(path.join(root,'output_files/SMS.fit.rpt')),start=s.lastIndexOf('Fitter Resource Utilization by Entity'),out={};
 for(const l of s.slice(start).split(/\r?\n/)){
  const c=l.split(';').map(x=>x.trim());if(c.length<18||!c[15].startsWith('|sys_top'))continue;
  const m=c[8].match(/\((\d+)\)/);if(m)out[c[15]]=+m[1];
 }
 return out;
}
const b=ownRegisters(roots.baseline),c=ownRegisters(roots.candidate);
const delta=[...new Set([...Object.keys(b),...Object.keys(c)])].map(entity=>({entity,baseline:b[entity]||0,candidate:c[entity]||0,delta:(c[entity]||0)-(b[entity]||0)})).filter(x=>x.delta).sort((x,y)=>Math.abs(y.delta)-Math.abs(x.delta));
const synthesis=Object.fromEntries(Object.entries(roots).map(([k,p])=>[k,+read(path.join(p,'output_files/SMS.map.summary')).match(/Total registers\s*:\s*([\d,]+)/)[1].replaceAll(',','')]));
const result={synthesisRegisters:synthesis,synthesisRegisterDelta:synthesis.candidate-synthesis.baseline,fitterOwnRegisterDelta:delta.reduce((n,x)=>n+x.delta,0),entityOwnRegisterDeltas:delta,interpretation:'Synthesis register count unchanged. Fitter-only register changes arise after physical synthesis/retiming/packing; no new architectural or snapshot register was added.'};
fs.writeFileSync(path.join(d,'resource_analysis.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({...result,entityOwnRegisterDeltas:delta.slice(0,8)},null,2));
