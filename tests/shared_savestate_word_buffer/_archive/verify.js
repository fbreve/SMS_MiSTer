const fs=require('fs'),cp=require('child_process'),p=require('path'),d=__dirname;
const results={baseline:cp.execFileSync('git',['rev-parse','master'],{encoding:'utf8'}).trim(),candidate:cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),tests:[]};
for(const name of ['existing','focused','targeted']){
 const log=fs.readFileSync(p.join(d,name+'.recheck.log'),'utf8');
 if(!log.includes('# PASS ')||/\*\* (Error|Fatal):|Errors: [1-9]/.test(log))throw Error('Unqualified '+name);
 results.tests.push({name,pass:true,summary:log.split(/\r?\n/).filter(l=>/PASS |FINAL_WORD/.test(l))});
}
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log('PASS all three independent simulator processes');
