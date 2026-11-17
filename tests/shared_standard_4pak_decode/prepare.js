const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),git=(a,cwd=root)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,maxBuffer:256*1024*1024}),txt=(a,c)=>git(a,c).toString(),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
assert(!fs.existsSync(p.join(d,'input_manifest.json')));
const baseline=txt(['rev-parse','8443a0d']).trim(),candidate=txt(['rev-parse','613ecb4']).trim();
assert.equal(txt(['diff','--name-only',baseline,candidate]).trim(),'rtl/memory_decode.vhd');
fs.writeFileSync(p.join(d,'complete.diff'),git(['diff',baseline,candidate]));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify({head:txt(['rev-parse','HEAD']).trim(),refs:txt(['show-ref']),diff:txt(['diff','--binary']),index:sha(fs.readFileSync(p.join(root,'.git/index')))},null,2));
function blobs(cwd,rev,prefix='') {const rows=txt(['ls-tree','-r',rev],cwd).trim().split('\n').map(s=>s.match(/^\d+ blob (\w+)\t(.+)$/)).filter(m=>m&&!m[2].startsWith('releases/')),buf=cp.execFileSync('git',['cat-file','--batch'],{cwd,input:rows.map(m=>m[1]).join('\n')+'\n',maxBuffer:256*1024*1024});let pos=0,out={};for(const m of rows){const end=buf.indexOf(10,pos),size=+buf.subarray(pos,end).toString().split(' ')[2];pos=end+1;out[prefix+m[2]]=buf.subarray(pos,pos+size);pos+=size+1;}return out;}
const sub=txt(['ls-tree',baseline,'mist/mist-modules']).match(/160000 commit (\w+)/)[1],sources={...blobs(root,baseline),...blobs(p.join(root,'mist/mist-modules'),sub,'mist/mist-modules/')};
const m={baseline,candidate,submodule:sub,toolVersion:cp.execFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe',['--version']).toString(),toolHashes:{},builds:{}};
assert(m.toolVersion.includes('17.0.2 Build 602'));
for(const e of ['quartus_sh','quartus_map','quartus_fit','quartus_asm','quartus_sta'])m.toolHashes[e]=sha(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+e+'.exe'));
for(const seed of [1,2])for(const v of ['A','C']){const key=`seed${seed}/${v}`,target=p.join(d,key),inputs={};assert(!fs.existsSync(target));for(const[f,raw]of Object.entries(sources)){if(f.startsWith('releases/'))continue;let b=raw;if(v==='C'&&f==='rtl/memory_decode.vhd')b=git(['show',candidate+':'+f]);if(f==='SMS.qsf')b=Buffer.from(b.toString().replace('set_global_assignment -name SEED 1','set_global_assignment -name SEED '+seed));const dest=p.join(target,f);fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,b);inputs[f]={SHA256:sha(b)};}for(const f of ['build_id.v','jtag.cdf']){const b=f==='build_id.v'?Buffer.from('`define BUILD_DATE "261030"\n'):fs.readFileSync(p.join(root,'tests/psg_c_physical/seed1/A',f));fs.writeFileSync(p.join(target,f),b);inputs[f]={SHA256:sha(b)};}m.builds[key]={seed,variant:v,inputs};}
for(const seed of [1,2]){const a=m.builds[`seed${seed}/A`].inputs,c=m.builds[`seed${seed}/C`].inputs;assert.deepEqual(Object.keys(a).filter(f=>a[f].SHA256!==c[f].SHA256),['rtl/memory_decode.vhd']);}
fs.writeFileSync(p.join(d,'input_manifest.json'),JSON.stringify(m,null,2));
console.log('Prepared four fresh matched builds',baseline,candidate);
