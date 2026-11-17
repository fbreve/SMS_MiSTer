// One-shot, explicitly bounded byte patch; not a general encoding converter.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),target=p.join(root,'rtl/savestates.sv');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:root,maxBuffer:16e6});
const before=fs.readFileSync(target);new TextDecoder('utf-8',{fatal:true}).decode(before);
assert(!before.subarray(0,3).equals(Buffer.from([239,187,191])),'Unexpected BOM');
const evidence=JSON.parse(fs.readFileSync(p.join(root,'tests/ym2413_c1_readiness_review/integrity_evidence.json')));
assert.equal(sha(before),evidence.outOfScopeMojibake.SHA256,'File changed since inspected review; re-audit before editing');
const protectedFiles={};
for(const [f,h]of Object.entries(evidence.checkedFiles)) {
 if(f==='rtl/savestates.sv')continue;
 const file=p.resolve(root,f);assert.equal(sha(fs.readFileSync(file)),h,'Protected evidence changed '+f);protectedFiles[file]=h;
}
const status=git('status','--porcelain=v1');
const modified=git('diff','--name-only','HEAD').toString().trim().split(/\r?\n/).filter(Boolean);
for(const f of modified.filter(f=>f!=='rtl/savestates.sv'))protectedFiles[p.join(root,f)]=sha(fs.readFileSync(p.join(root,f)));
const staged=git('diff','--cached','--binary');
for(const [name,b]of [['savestates.before.sv',before],['git_diff_before.patch',git('diff','--binary')],['git_status_before.txt',status]])fs.writeFileSync(p.join(__dirname,name),b,{flag:'wx'});
// Lexer preserves every byte outside comments, including strings and escaped identifiers.
function lex(b){const comments=[],code=[];let i=0,start=0;
 while(i<b.length){
  if(b[i]===34){i++;while(i<b.length){if(b[i]===92){i+=2;continue;}if(b[i++]===34)break;}continue;}
  if(b[i]===92){while(i<b.length&&!/[\s]/.test(String.fromCharCode(b[i])))i++;continue;}
  if(b[i]===47&&(b[i+1]===47||b[i+1]===42)){
   const a=i;code.push(b.subarray(start,a));
   if(b[i+1]===47){i+=2;while(i<b.length&&b[i]!==13&&b[i]!==10)i++;}
   else {i+=2;while(i+1<b.length&&!(b[i]===42&&b[i+1]===47))i++;assert(i+1<b.length,'Unclosed comment');i+=2;}
   comments.push([a,i]);code.push(Buffer.from([...b.subarray(a,i)].filter(x=>x===10||x===13)));start=i;continue;
  }i++;
 }code.push(b.subarray(start));return{comments,code:Buffer.concat(code)};
}
const parsed=lex(before),changes=[];
// The previous read-only review records exact corrupted line text; choose each line explicitly.
const expectedLines=[7,8,9,10,11,12,13,14,15,16,17,19,210,242,279,391,429,1044,1075,1179,1209,1478,1819,1842,1915];
assert.deepEqual(evidence.outOfScopeMojibake.lines.map(x=>x.line),expectedLines);
const replacements=new Map([['Ãƒâ€”','*'],['Ã¢â€°Ë†','approx. '],['Ã¢â€ â€™','->']]);
const lineStarts=[0];for(let i=0;i<before.length;i++)if(before[i]===10)lineStarts.push(i+1);
for(const record of evidence.outOfScopeMojibake.lines){
 const start=lineStarts[record.line-1],end=before.indexOf(13,start);assert(end>=start);
 assert.equal(before.subarray(start,end).toString('utf8'),record.text);
 const lineEdits=[];
 for(const [bad,good]of replacements){const pattern=Buffer.from(bad,'utf8');let at=before.indexOf(pattern,start);
  while(at>=0&&at<end){assert(parsed.comments.some(([a,z])=>at>=a+2&&at+pattern.length<=z),'Edit outside comment');
   // Avoid doubled spaces in "approx. 630" while preserving other whitespace.
   const text=good==='approx. '&&before[at+pattern.length]===32?'approx.':good;
   lineEdits.push({offset:at,length:pattern.length,bytes:Buffer.from(text),old:bad,new:text});at=before.indexOf(pattern,at+pattern.length);
  }
 }assert(lineEdits.length,'No confirmed corruption on selected line');changes.push({line:record.line,before:record.text,edits:lineEdits});
}
const edits=changes.flatMap(x=>x.edits).sort((a,b)=>a.offset-b.offset);const pieces=[];let cursor=0;
for(const edit of edits){assert(edit.offset>=cursor);pieces.push(before.subarray(cursor,edit.offset),edit.bytes);cursor=edit.offset+edit.length;}pieces.push(before.subarray(cursor));
const after=Buffer.concat(pieces);assert(lex(after).code.equals(parsed.code),'Executable/non-comment bytes changed');
assert.equal(after.toString('latin1').replace(/[^\r\n]/g,''),before.toString('latin1').replace(/[^\r\n]/g,''),'Line ending bytes changed');
assert(!after.some(x=>x>127),'Unexpected remaining non-ASCII text; inspect rather than re-encode');
for(const change of changes)change.after=after.toString('ascii').split(/\r?\n/)[change.line-1];
assert(fs.readFileSync(target).equals(before),'Concurrent source edit');
fs.writeFileSync(target,after);
assert(fs.readFileSync(target).equals(after),'Main workspace write did not persist');
assert(git('diff','--cached','--binary').equals(staged),'Index changed');
assert(git('status','--porcelain=v1').equals(status),'Pre-existing repository status changed');
for(const [file,h]of Object.entries(protectedFiles))assert.equal(sha(fs.readFileSync(file)),h,'Unrelated file changed '+file);
const rbf=p.join(root,'tests/ym2413_b1_c1_seed_study/seed1/c1/output_files/SMS.rbf');
assert.equal(sha(fs.readFileSync(rbf)),'7f4ba7e188c99a5ae623e49e4df4311084a23fbd47404a93de3ab974e728fafa');
const result={path:target,encodingBefore:'UTF-8 without BOM; double-encoded comment characters',encodingAfter:'ASCII subset of UTF-8; no whole-file transcoding',beforeSHA256:sha(before),afterSHA256:sha(after),nonCommentSHA256:sha(parsed.code),executableBytesIdentical:true,CRLF:(before.toString('latin1').match(/\r\n/g)||[]).length,bareLF:0,changes:changes.map(x=>({...x,edits:x.edits.map(({offset,length,old,new:n})=>({offset,length,old,new:n}))})),protectedFilesVerified:Object.keys(protectedFiles).length,RBF:{path:rbf,SHA256:sha(fs.readFileSync(rbf)),descriptorVersion:20}};
fs.writeFileSync(p.join(__dirname,'comment_correction.json'),JSON.stringify(result,null,2)+'\n',{flag:'wx'});
const delta=cp.spawnSync('git',['--no-optional-locks','diff','--no-index','--',p.join(__dirname,'savestates.before.sv'),target],{maxBuffer:1e7});assert.equal(delta.status,1,'Expected a comment-only diff');
fs.writeFileSync(p.join(__dirname,'comment_only.patch'),delta.stdout,{flag:'wx'});
fs.writeFileSync(p.join(__dirname,'git_diff_after.patch'),git('diff','--binary'),{flag:'wx'});
console.log(JSON.stringify(result,null,2));
