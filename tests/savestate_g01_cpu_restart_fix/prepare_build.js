const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,r=path.resolve(d,'../..'),old=path.resolve(d,'../savestate_cpu_nmi_fix'),dest=path.join(d,'candidate');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),git=(...a)=>cp.execFileSync('git',a,{cwd:r,maxBuffer:10*1024*1024});
assert(git('rev-parse','HEAD').toString().trim()==='faf7036e4450027f79cc639a731053dca29840ca');
if(fs.existsSync(dest))throw Error('Use a fresh candidate directory; no reused Quartus database permitted');
const manifest=JSON.parse(fs.readFileSync(path.join(old,'build_sources.json'),'utf8')),tracked=new Set(git('ls-tree','-r','--name-only','HEAD').toString().trim().split(/\r?\n/));let verified=0;const external=[];
for(const[n,h]of Object.entries(manifest)){const p=path.join(old,'candidate',n),b=fs.readFileSync(p);assert.equal(hash(b),h,'Retained F16 baseline source '+n);if(tracked.has(n)){assert.equal(b.toString().replace(/\r\n/g,'\n'),git('show','HEAD:'+n).toString().replace(/\r\n/g,'\n'),'F16 committed source '+n);verified++;}else external.push(n);}
const sources={};for(const n of Object.keys(manifest)){const p=path.join(dest,n);fs.mkdirSync(path.dirname(p),{recursive:true});const b=fs.readFileSync(path.join(r,n));fs.writeFileSync(p,b);sources[n]=hash(b);}
fs.copyFileSync(path.join(old,'candidate/build_id.v'),path.join(dest,'build_id.v'));
const previous=JSON.parse(fs.readFileSync(path.join(old,'results.json'),'utf8'));
fs.writeFileSync(path.join(d,'build_sources.json'),JSON.stringify(sources,null,2));
fs.writeFileSync(path.join(d,'baseline.json'),JSON.stringify({commit:'faf7036e4450027f79cc639a731053dca29840ca',verified,manifestOnly:external,...previous.candidate,setup:previous.worstSlack.setup,hold:previous.worstSlack.hold,violations:previous.violations.length},null,2));
console.log('Prepared source-only full build; verified '+verified+' baseline files against committed F16. Quartus not started.');
