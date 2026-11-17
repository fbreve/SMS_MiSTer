const fs=require('fs'),p=require('path'),d=__dirname;
const read=n=>{if(!fs.existsSync(p.join(d,n)))return '';const b=fs.readFileSync(p.join(d,n));return b[0]===255?b.toString('utf16le'):b.toString();};
const names=[...Array.from({length:8},(_,i)=>'final_batch'+i),'regress','broad_a','broad_b','broad_format','extras','stalls','old_reader','rerun','rerun_other'];
const result=names.map(name=>({name,passes:(read(name+'.out').match(/PASS /g)||[]).length,error:read(name+'.err').trim()}));
const completed=result.slice(0,8).flatMap(x=>[...read(x.name+'.out').matchAll(/PASS (\S+)/g)].map(x=>x[1]));
console.log(JSON.stringify({mainCases:completed.length,groups:Object.fromEntries(['replay_','timing_','legacy','untagged','bad_'].map(n=>[n,completed.filter(x=>x.startsWith(n)).length])),suites:result.slice(8),workerErrors:result.slice(0,8).filter(x=>x.error)},null,2));
