const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert');
const prefix='tests/shared_savestate_word_buffer/',root=process.cwd(),out=p.join(root,prefix,'_archive/package_check');
assert(!fs.existsSync(out));
const files=cp.execFileSync('git',['ls-files','--cached','--',prefix],{encoding:'utf8'}).trim().split('\n');
for(const file of files){assert(file.startsWith(prefix));assert(!/\/(runs|_archive|simulations|db)\/|\.(rbf|sof)$/.test(file));const dest=p.join(out,file.slice(prefix.length));fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,cp.execFileSync('git',['show',':'+file],{maxBuffer:8*1024*1024}));}
console.log(cp.execFileSync(process.execPath,[p.join(out,'verify_evidence.js')],{cwd:out,encoding:'utf8'}));console.log('PASS staged package only: '+files.length+' files, no simulator or Quartus databases');
