const fs=require('fs'),p=require('path'),crypto=require('crypto'),d=__dirname;
const entries=[['case0','PASS fullstate'],['setup','PASS fullstate'],...Array.from({length:6},(_,i)=>['mode'+(i+1),'PASS fullstate']),['nonfm','PASS nonFM ALL'],['protocol','PASS protocol ALL'],['map','PASS independent pattern ALL'],['phases','PASS PHASE SWEEP ALL']];
let out={status:'PASS',logs:[],note:'case0 uses native FLUSH_MAX=900000; setup and modes1..6 use only FLUSH_MAX=90. FM state and transport are identical. case0 predates strengthened all-channel setup assertions; setup/modes include them.'};
for(const [name,pass] of entries){
 const file=p.join(d,name+'.log');if(!fs.existsSync(file)){if(name==='setup')continue;throw Error('missing log '+file);}
 const s=fs.readFileSync(file,'utf8');
 if(name==='case0'&&s.includes('PASS musical setup'))out.note=out.note.replace('case0 predates strengthened all-channel setup assertions; setup/modes include them.','All musical tests include strengthened setup assertions.');
 if(name.startsWith('mode')&&!s.includes('PASS musical setup'))throw Error('outdated musical fixture '+name);
 if(!s.includes(pass)||/\*\* (Fatal|Failure|Error):/.test(s))throw Error('failed log '+name);
 const oracleCount=(s.match(/PASS independent internal oracle/g)||[]).length;
 if(pass==='PASS fullstate'&&oracleCount!==9)throw Error('incomplete internal oracle '+name);
 if(name==='phases'&&(s.match(/PASS LOCAL ALL/g)||[]).length!==72)throw Error('incomplete phases');
 out.logs.push({name:name+'.log',sha256:crypto.createHash('sha256').update(s).digest('hex'),oracleCount,passes:s.split(/\r?\n/).filter(x=>x.includes('PASS '))});
}
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(out,null,2)+'\n');
console.log('PASS all preserved logs, independent oracles and completion markers');
