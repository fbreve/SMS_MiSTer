const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const roots={baseline:p.resolve(d,'../savestate_g01_cpu_restart_fix/candidate'),candidate:p.join(d,'quartus')};
const read=f=>{const b=fs.readFileSync(f);return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString();};
function own(root){const rows={};for(const line of read(p.join(root,'output_files/SMS.map.rpt')).split(/\r?\n/)){const c=line.split(';').map(x=>x.trim());if(c.length<11||!c[8].startsWith('|sys_top'))continue;const a=c[2].match(/\((\d+)\)/),r=c[3].match(/\((\d+)\)/);if(a&&r)rows[c[8]]={aluts:+a[1],registers:+r[1]};}return rows;}
const b=own(roots.baseline),c=own(roots.candidate),zero={aluts:0,registers:0};
const deltas=[...new Set([...Object.keys(b),...Object.keys(c)])].map(entity=>({entity,baseline:b[entity]||zero,candidate:c[entity]||zero})).map(z=>({...z,delta:{aluts:z.candidate.aluts-z.baseline.aluts,registers:z.candidate.registers-z.baseline.registers}})).filter(z=>z.delta.aluts||z.delta.registers).sort((a,b)=>Math.abs(b.delta.registers)-Math.abs(a.delta.registers));
const registers=Object.fromEntries(Object.entries(roots).map(([name,root])=>[name,+read(p.join(root,'output_files/SMS.map.summary')).match(/Total registers\s*:\s*([\d,]+)/)[1].replaceAll(',','')]));
const ledger=deltas.reduce((n,z)=>n+z.delta.registers,0);assert.equal(ledger,registers.candidate-registers.baseline);
const result={registers,delta:ledger,entityDeltas:deltas};fs.writeFileSync(p.join(d,'synthesis_ledger.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({...result,entityDeltas:deltas.filter(z=>z.delta.registers)},null,2));
