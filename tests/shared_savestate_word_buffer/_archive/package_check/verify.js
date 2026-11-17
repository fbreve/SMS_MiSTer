const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');
const dir=p.resolve(process.argv[2]),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const results={revisions:{baseline:'ab09fdf41221c9e3e77eee87264a125ba43021fe',candidate:'28ead01f7f8709ddda5dc4a63206b9921cb757e0'},inputs:{},tests:[]};
for(const file of fs.readdirSync(dir).filter(f=>/\.sv$|\.do$/.test(f)))results.inputs[file]=sha(fs.readFileSync(p.join(dir,file)));
for(const [name,operations,writes,reads] of [['existing',16,57580,57564],['focused',24,181956,0],['targeted',8,60652,0]]){
 const raw=fs.readFileSync(p.join(dir,name+'.log')),log=raw.toString();
 assert(log.includes('# PASS ')&&!/\*\* (Error|Fatal):|Errors: [1-9]|is not bound/.test(log),name);
 const summary=log.match(/PASS savestate controller differential cycles=(\d+) output_checks=(\d+) outputs=58 operations=(\d+) restored=(\d+) DDRwrites=(\d+) DDRreads=(\d+) busy=(\d+)/);assert(summary,name+' summary');
 assert.equal(+summary[3],operations);assert.equal(+summary[5],writes);assert.equal(+summary[6],reads);
 if(name==='targeted')for(const state of [17,18,35,45,52,53])assert(new RegExp('FINAL_WORD state='+state+' pre=[1-9]\\d* registered=[1-9]\\d*').test(log),'final-word coverage '+state);
 results.tests.push({name,pass:true,cycles:+summary[1],operations,writes,reads,logSha256:sha(raw),summary:log.split(/\r?\n/).filter(l=>/PASS |FINAL_WORD/.test(l))});
}
fs.writeFileSync(p.join(dir,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log('PASS all three independent simulator processes');
