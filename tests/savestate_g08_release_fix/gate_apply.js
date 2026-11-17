const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process');const d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>fs.readFileSync(p.join(d,f),'utf8'),check=(x,m)=>{if(!x)throw Error(m)};
const base=JSON.parse(read('baseline.json'));for(const[f,h]of Object.entries(base.files))check(sha(fs.readFileSync(p.join(root,f)))===h,'production changed before proof '+f);
function pass(f,marker){const s=read(f);check(s.includes(marker)&&s.includes('# End time:')&&!/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]/.test(s),'failed '+f);return s}
for(const id of ['unstalled','stalled']){const s=pass('original_combined/'+id+'.log','PASS CHARACTERIZED');const rows=[...s.matchAll(/RESULT pass(\d+) errors(\d+) first(-?\d+) raw_errors(\d+)/g)];check(rows.length===4&&rows.every(m=>+m[2]===0&&+m[4]===0),'original coupled suffix differs')}
for(const id of ['pending_tick','phase1_stereo'])pass('combined/'+id+'/replay.log','PASS MATRIX replays3 N24000');
for(const id of ['history0','history1'])pass('coupled_search/'+id+'/replay.log','PASS MATRIX replays1 N24000');
function image(f){const a=read(f).split(/\r?\n/).filter(x=>x&&!x.startsWith('//'));check(a.length===12288&&a.every(x=>/^[\da-f]{16}$/i.test(x)),'unknown image');let b=Buffer.alloc(98304);a.forEach((x,i)=>b.writeBigUInt64LE(BigInt('0x'+x),i*8));return sha(b)}
const h=image('coupled_search/history0/image.hex');check(h===image('coupled_search/history1/image.hex'),'equal-image search differs');
const mapping={'rtl/savestates.sv':'savestates.sv','rtl/jt89/jt89.v':'jt89.v','rtl/jt89/jt89.vhd':'jt89.vhd','rtl/system.vhd':'system.vhd','SMS.sv':'SMS.sv'};
const gate={pass:true,head:base.head,baselineHashesChecked:Object.keys(base.files).length,originalLoads:6,pendingAndStereoLoads:6,searchLoads:2,equalImageSha256:h,proposed:Object.fromEntries(Object.entries(mapping).map(([f,v])=>[f,sha(fs.readFileSync(p.join(d,'proposed',v)))])),note:'Coupled source-event replay plus phase prototype passed before production edits; full final matrix/build still required.'};
fs.writeFileSync(p.join(d,'pre_edit_gate.json'),JSON.stringify(gate,null,2)+'\n');
// Preserve original mixed CRLF/LF on unchanged lines. Only inserted/replaced
// lines use LF; this avoids unrelated whole-file line-ending churn.
function mergeLines(original,proposed){const a=original.match(/[^\n]*\n|[^\n]+$/g)||[],b=proposed.match(/[^\n]*\n|[^\n]+$/g)||[],key=s=>s.replace(/\r?\n$/,'');const m=a.length,n=b.length,rows=Array.from({length:m+1},()=>new Uint16Array(n+1));for(let i=m-1;i>=0;i--)for(let j=n-1;j>=0;j--)rows[i][j]=key(a[i])===key(b[j])?rows[i+1][j+1]+1:Math.max(rows[i+1][j],rows[i][j+1]);let i=0,j=0,out='';while(j<n){if(i<m&&key(a[i])===key(b[j])){out+=a[i++];j++;}else if(i<m&&rows[i+1][j]>=rows[i][j+1])i++;else out+=b[j++];}return out;}
if(process.argv.includes('--apply'))for(const[f,v]of Object.entries(mapping)){const file=p.join(root,f);fs.writeFileSync(file,mergeLines(fs.readFileSync(file,'utf8'),read('proposed/'+v)));}
console.log(JSON.stringify({pass:true,applied:process.argv.includes('--apply'),equalImageSha256:h}));
