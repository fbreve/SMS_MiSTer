const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process');
const dir=__dirname,root=p.resolve(dir,'../..');const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const raw=f=>fs.readFileSync(p.join(dir,f));const log=f=>{const b=raw(f);return b[0]===255?b.toString('utf16le'):b.toString('utf8');};
const ref=log('reference.dat').trim().split(/\r?\n/).map((s,j)=>{const [x,y,regs,rgb,data]=s.trim().split(/\s+/);return{j,x:parseInt(x,16),y:parseInt(y,16),regs,rgb,data,collision:Number((BigInt('0x'+regs)>>117n)&1n)};});
const transitions=ref.filter((v,j)=>j==0||v.collision!=ref[j-1].collision).map(v=>({j:v.j,x:v.x,y:v.y,collision:v.collision,data:v.data}));
const baseline=JSON.parse(log('baseline.json'));const mismatches=[];
for(const[f,h]of Object.entries(baseline.hashes))if(sha(fs.readFileSync(p.join(root,f)))!==h)mismatches.push(f);
const res={head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),branch:cp.execFileSync('git',['branch','--show-current'],{cwd:root,encoding:'utf8'}).trim(),productionHashMismatches:mismatches,reference:{samples:ref.length,sha256:sha(raw('reference.dat')),collisionTransitions:transitions},gitDiffStat:cp.execFileSync('git',['diff','--stat'],{cwd:root,encoding:'utf8'}),gitStagedStat:cp.execFileSync('git',['diff','--cached','--stat'],{cwd:root,encoding:'utf8'}),status:cp.execFileSync('git',['status','--short'],{cwd:root,encoding:'utf8'})};
if(fs.existsSync(p.join(dir,'image.hex'))){const b=raw('image.hex'),words=b.toString('utf8').trim().split(/\r?\n/);res.image={words:words.length,known:words.every(s=>/^[0-9a-f]{16}$/i.test(s)),sha256:sha(b),videoWord:words[26]};
 const byte=a=>Number((BigInt('0x'+words[0x101+(a>>3)])>>BigInt((a&7)*8))&255n);
 let mismatches=0;for(let a=0;words.length===12288&&a<16384;a++){
  let want=((a*37)^(a>>3)^0xa7)&255;
  if(a>=0x3800&&a<0x3f00)want=a&1?8:1;
  if(a>=0x2000&&a<0x2040)want=(a&3)==0?255:0;
  if(a>=0x3f00&&a<0x3f40)want=a-0x3f00<2?167:208;
  if(a>=0x3f80)want=a&1?0:120;
  if(byte(a)!==want)mismatches++;
 }
 res.image.initializedVRAMBytesChecked=words.length===12288?16384:0;res.image.initializedVRAMMismatches=mismatches;
}
const logs=fs.readdirSync(dir).filter(f=>/^gg.*\.log$/.test(f));res.runs=logs.map(f=>({file:f,sha256:sha(raw(f)),events:log(f).split(/\r?\n/).filter(s=>/REQUEST |ACCEPT |ARM |RELEASE |DIVERGENCE|RESULT |DONE VDP|PASS UNINTERRUPTED|Fatal|Error/.test(s))}));
res.controlRuns=['one_sprite/reference.log','one_sprite/dut.log'].filter(f=>fs.existsSync(p.join(dir,f))).map(f=>({file:f,sha256:sha(raw(f)),events:log(f).split(/\r?\n/).filter(s=>/REQUEST |ACCEPT |ARM |RELEASE |DIAGNOSTIC|DIVERGENCE|RESULT |DONE VDP|PASS UNINTERRUPTED|Fatal|Error/.test(s))}));
res.overflowRuns=['overflow9/reference.log','overflow9/dut.log'].filter(f=>fs.existsSync(p.join(dir,f))).map(f=>({file:f,sha256:sha(raw(f)),events:log(f).split(/\r?\n/).filter(s=>/REQUEST |ACCEPT |ARM |RELEASE |DIVERGENCE|GUEST_STORE|CHARACTERIZED|PASS UNINTERRUPTED|Fatal|Error/.test(s))}));
if(fs.existsSync(p.join(dir,'overflow9/reference.dat'))){const a=log('overflow9/reference.dat').trim().split(/\r?\n/).map((l,j)=>{const[x,y,regs,rgb,data,acc,mem]=l.trim().split(/\s+/);return{j,x:parseInt(x,16),y:parseInt(y,16),acc,mem};});res.overflowReference={samples:a.length,sha256:sha(raw('overflow9/reference.dat')),guestTransitions:a.filter((v,j)=>j===0||v.acc!==a[j-1].acc||v.mem!==a[j-1].mem)};}
if(fs.existsSync(p.join(dir,'one_sprite/image.hex'))&&res.image?.words===12288){const a=log('image.hex').trim().split(/\r?\n/),b=log('one_sprite/image.hex').trim().split(/\r?\n/);res.imagePair={other:'one_sprite/image.hex',otherSha256:sha(raw('one_sprite/image.hex')),otherKnown:b.every(s=>/^[0-9a-f]{16}$/i.test(s)),wordsCompared:Math.min(a.length,b.length),equal:a.length===b.length&&a.every((v,i)=>v===b[i]),differentWords:a.map((v,i)=>v===b[i]?null:{address:i,a:v,b:b[i]}).filter(v=>v!==null)};}
res.artifactHashes={};for(const f of ['prepare.js','vdp_tb.sv','header.svh','T80_sim.vhd','T80s_sim.vhd','vdp_sim.vhd','savestates_sim.sv','state_behavior.md','inventory.json','connections.json','rom.hex'])res.artifactHashes[f]=sha(raw(f));
res.transport=log('gg1_pal0_x40_spr2_sx120_ref0.log').split(/\r?\n/).filter(s=>/ACCEPT |ARM |RELEASE |RESULT |DONE/.test(s));
res.sanity=['sanity/hcounter.log','sanity/g01.log'].map(f=>({file:f,sha256:sha(raw(f)),markers:log(f).split(/\r?\n/).filter(s=>/PASS|Errors:/.test(s))}));
fs.writeFileSync(p.join(dir,'results.json'),JSON.stringify(res,null,2));
console.log(JSON.stringify({reference:res.reference,productionHashMismatches:mismatches,image:res.image,runs:res.runs.map(v=>({file:v.file,events:v.events}))},null,2));
if(mismatches.length||res.gitDiffStat||res.gitStagedStat)throw Error('production/index changed');
if(process.argv.includes('--final')){
 const main=log('gg1_pal0_x40_spr2_sx120_ref0.log'),control=log('one_sprite/dut.log');
 if(!/DONE VDP gg1 pal0 sprite2 saveonly1000 checks3000/.test(main)||/Fatal|Errors: [1-9]/.test(main))throw Error('main incomplete/failed');
 const rows=[...main.matchAll(/RESULT pass(\d+) collisionSamples(\d+) statusBusSamples(\d+)/g)];
 if(rows.length!==3||rows.some(r=>+r[2]===0||+r[3]===0))throw Error('missing repeated observed divergence');
 if(!/RESULT pass0 collisionSamples0 statusBusSamples0/.test(control)||!/DONE VDP/.test(control)||/Fatal|Errors: [1-9]/.test(control))throw Error('one-sprite control failed');
 if(!res.image.known||res.image.words!==12288||res.image.initializedVRAMMismatches||!res.image.videoWord.startsWith('48430d'))throw Error('image invalid');
 const ov=log('overflow9/dut.log');if(!/PASS G06 SAVE_ONLY CHARACTERIZED/.test(ov)||/Fatal|Errors: [1-9]/.test(ov))throw Error('overflow SAVE-only characterization incomplete');
 if(!/SAVE_GUEST_STORE/.test(ov)||!/guestACC[1-9][0-9]* guestStores[1-9][0-9]*/.test(ov))throw Error('missing actual CPU A / RAM signature');
 if(!res.imagePair?.otherKnown||res.imagePair.wordsCompared!==12288||res.imagePair.differentWords.length!==1||res.imagePair.differentWords[0].address!==0x8e1)throw Error('complete-image candidate comparison invalid');
 if(!/PASS: F07 fixed/.test(log('sanity/hcounter.log'))||!/PASS G01 TRACE.*loads3 comparisons36403/.test(log('sanity/g01.log'))||res.sanity.some(v=>/Fatal|Errors: [1-9]/.test(log(v.file))))throw Error('scoped sanity incomplete');
 console.log('PASS final source, initialized image, reference, repeated divergence and negative-control gates');
}
