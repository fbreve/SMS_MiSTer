const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const hashes={};for(const v of ['baseline','candidate']){const dir=p.join(d,v,'output_files');if(!fs.existsSync(dir))continue;for(const f of fs.readdirSync(dir).filter(x=>/\.(rpt|summary)$/.test(x)))hashes[v+'/'+f]=crypto.createHash('sha256').update(fs.readFileSync(p.join(dir,f))).digest('hex');}
const target=p.join(d,'native_reports_before_queries.json');
if(process.argv[2]==='record'){assert(!fs.existsSync(target),'Do not overwrite original report identities');fs.writeFileSync(target,JSON.stringify(hashes,null,2)+'\n');}
else assert.deepEqual(hashes,JSON.parse(fs.readFileSync(target)),'Read-only query altered native reports');
console.log('PASS native report identities '+process.argv[2]);
