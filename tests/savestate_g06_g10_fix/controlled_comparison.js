// Compare the candidate with both retained and same-date committed baselines.
const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.join(d,'quartus_baseline_date'),candidateRoot=p.join(d,'quartus');
const read=f=>{const b=fs.readFileSync(f);return b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString();},sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const candidate=JSON.parse(read(p.join(d,'quartus_results.json'))),compile=read(p.join(root,'compile.log'));
assert(compile.includes('Full Compilation was successful'),'Control full compilation incomplete');
const manifest=JSON.parse(read(p.join(d,'baseline_control_sources.json')));
for(const [f,h]of Object.entries(manifest))assert.equal(sha(p.join(root,f)),h,'Control source drift '+f);
assert.equal(sha(p.join(root,'build_id.v')),sha(p.join(candidateRoot,'build_id.v')),'Generated build dates differ');
const fit=read(p.join(root,'output_files/SMS.fit.summary')),rpt=read(p.join(root,'output_files/SMS.fit.rpt')),sta=read(p.join(root,'output_files/SMS.sta.summary'));
const val=n=>+fit.match(new RegExp(n+'[^:\\r\\n]*:\\s*([\\d,]+)'))[1].replaceAll(',','');
const baseline={ALMsNeeded:val('Logic utilization'),ALMsPlaced:+rpt.match(/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/)[1].replaceAll(',',''),registers:val('Total registers'),M10K:val('Total RAM Blocks'),memoryBits:val('Total block memory bits'),DSP:val('Total DSP Blocks')};
const resources=Object.fromEntries(Object.entries(baseline).map(([k,v])=>[k,{retained:candidate.resources[k].baseline,sameDateBaseline:v,candidate:candidate.resources[k].used,deltaVersusRetained:candidate.resources[k].delta,deltaVersusSameDate:candidate.resources[k].used-v}]));
const timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));assert(timing.length);
const setup=Math.min(...timing.filter(t=>t.type.startsWith('Setup')).map(t=>t.slack)),hold=Math.min(...timing.filter(t=>t.type.startsWith('Hold')).map(t=>t.slack));
function own(folder){const rows={};let s=read(p.join(folder,'output_files/SMS.fit.rpt'));s=s.slice(s.lastIndexOf('Fitter Resource Utilization by Entity'));for(const l of s.split(/\r?\n/)){const c=l.split(';').map(x=>x.trim());if(c.length<18||!c[15].startsWith('|sys_top'))continue;const n=i=>{const m=c[i].match(/\(([\d.]+)\)/);return m?+m[1]:0;};rows[c[15]]={ALMsNeeded:n(2),registers:n(8)};}return rows;}
const b=own(root),c=own(candidateRoot),entities=[...new Set([...Object.keys(b),...Object.keys(c)])].map(entity=>({entity,delta:{ALMsNeeded:+((c[entity]?.ALMsNeeded||0)-(b[entity]?.ALMsNeeded||0)).toFixed(3),registers:(c[entity]?.registers||0)-(b[entity]?.registers||0)}})).filter(z=>z.delta.ALMsNeeded||z.delta.registers).sort((a,b)=>Math.abs(b.delta.ALMsNeeded)-Math.abs(a.delta.ALMsNeeded));
assert.equal(entities.reduce((n,z)=>n+z.delta.registers,0),resources.registers.deltaVersusSameDate,'Same-date fitted register ledger');
const result={status:'PASS',sourceHead:'8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a',sourceHashesVerified:true,sameGeneratedBuildID:read(p.join(root,'build_id.v')),retainedBuildID:read(p.resolve(d,'../savestate_g01_cpu_restart_fix/candidate/build_id.v')),resources,baselineTiming:{setup,hold,violations:timing.filter(t=>t.slack<0||t.tns<0)},candidateTiming:{setup:candidate.setup,hold:candidate.hold,violations:candidate.violations},deltaTimingSameDate:{setup:+(candidate.setup-setup).toFixed(3),hold:+(candidate.hold-hold).toFixed(3)},entityDeltas:entities};
fs.writeFileSync(p.join(d,'controlled_comparison.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({...result,entityDeltas:entities.slice(0,10)},null,2));
