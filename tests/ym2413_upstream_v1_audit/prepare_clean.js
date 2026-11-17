const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),source=p.join(root,'tests/ym2413_public_v1_integration/worktree'),wt=p.join(d,'worktree'),base='66f16d5c656fd8906d62570da4d258875bcee684';
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,maxBuffer:3e7,stdio:['ignore','pipe','pipe']}),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(git(root,'rev-parse','master').toString().trim(),base);assert.equal(git(root,'rev-parse','origin/master').toString().trim(),base);assert.equal(git(wt,'diff').length,0);
const changed=git(source,'diff','--name-only',base).toString().trim().split(/\r?\n/),production=changed.filter(f=>f==='SMS.sv'||f==='files.qip'||f.startsWith('rtl/')),excluded=changed.filter(f=>!production.includes(f));
assert.equal(production.length,24);assert.equal(excluded.length,18);assert(!production.some(f=>f.startsWith('sys/')));
const manifest={baseline:base,branch:'integration/ym2413-public-v1-upstream',production:{},excludedExperimentalFiles:excluded,intentionalComments:[]};
for(const f of production){let bytes=fs.readFileSync(p.join(source,f)),next=bytes;
 if(f==='rtl/VM2413/registermemory.vhd'){
  const lines=bytes.toString('hex'); // No transcoding; locate the exact comment byte span.
  const comment=Buffer.from('-- Channel information storage: single-read, single-write SRAM.');
  assert(fs.readFileSync(p.join(root,f)).includes(comment),'User translation missing in main workspace');
  const token=bytes.indexOf(Buffer.from('1read/1write'));assert(token>0);
  const start=bytes.lastIndexOf(Buffer.from('--'),token),end=bytes.indexOf(13,token);assert(start>0&&end>token);
  const decoded=new TextDecoder('shift_jis',{fatal:true}).decode(bytes.subarray(start,end));
  assert(decoded.includes('1read/1write')&&decoded.includes('SRAM'));
  next=Buffer.concat([bytes.subarray(0,start),comment,bytes.subarray(end)]);
  manifest.intentionalComments.push({file:f,line:bytes.subarray(0,start).filter(x=>x===10).length+1,before:decoded,after:comment.toString('ascii'),beforeSHA256:sha(bytes),afterSHA256:sha(next)});
 }
 fs.mkdirSync(p.dirname(p.join(wt,f)),{recursive:true});fs.writeFileSync(p.join(wt,f),next);
 manifest.production[f]={validatedWorktreeSHA256:sha(bytes),cleanSHA256:sha(next),rawIdentical:bytes.equals(next)};
}
fs.writeFileSync(p.join(d,'clean_manifest.json'),JSON.stringify(manifest,null,2)+'\n',{flag:'wx'});
console.log('Copied all 24 production files; excluded 18 experimental test files; transplanted SRAM comment only.');
