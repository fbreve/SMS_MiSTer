const fs=require('fs'),p=require('path'),c=require('crypto'),assert=require('assert'),d=__dirname;
const result=JSON.parse(fs.readFileSync(p.join(d,'results.json')));assert(result.PASS&&result.LOADs===144);
const files=fs.readdirSync(d).filter(f=>fs.statSync(p.join(d,f)).isFile()&&f!=='artifacts_sha256.json');
const logs='worktree/tests/ym2413_fullstate/logs';
for(const f of fs.readdirSync(p.join(d,logs)).filter(f=>/\.(log|exitcode)$/.test(f)))files.push(p.posix.join(logs,f));
const hashes=Object.fromEntries(files.sort().map(f=>[f,c.createHash('sha256').update(fs.readFileSync(p.join(d,f))).digest('hex')]));
fs.writeFileSync(p.join(d,'artifacts_sha256.json'),JSON.stringify(hashes,null,2)+'\n');
console.log('PASS retained artifact hashes: '+files.length);
