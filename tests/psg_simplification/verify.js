const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),rev='8443a0d19a88aff7a5900011bccf386daf146945';
const git=(...a)=>cp.execFileSync('git',['-c','core.safecrlf=false',...a],{cwd:root,maxBuffer:64*1024*1024}).toString();
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),norm=s=>s.replace(/\r\n/g,'\n');
const before=JSON.parse(fs.readFileSync(p.join(d,'preservation_before.json')));
const results={baseline:rev,protectedFiles:0,candidates:{},tests:{},limitations:['No Quartus, hardware, formal proof, full ROM/CPU/game qualification or perceptual audio measurement.','Controller fixture uses constant peripheral/memory patterns and real JT89, actual extracted control process and AudioMix.','System compilation is analysis, not full-machine elaboration; ModelSim syntax adapters are recorded.']};
for(const [f,h]of Object.entries(before.files)){assert.equal(hash(fs.readFileSync(p.join(root,f))),h,'Preservation: '+f);results.protectedFiles++;}
assert.equal(git('rev-parse','HEAD').trim(),before.head);assert.equal(git('branch','--show-current').trim(),before.branch);assert.equal(git('diff','--binary'),before.diff);assert.equal(git('diff','--cached','--binary'),before.indexDiff);
const refs=git('show-ref').trim().split('\n'),refmap=Object.fromEntries(refs.map(s=>{const [h,n]=s.split(' ');return[n,h];}));
for(const line of before.refs.trim().split('\n')){const[h,n]=line.split(' ');assert.equal(refmap[n],h,'Preserved ref '+n);}
results.newRefs=refs.filter(s=>!before.refs.split('\n').includes(s));
const allowed=['SMS.sv','rtl/AudioMix.vhd','rtl/jt89/jt89.v','rtl/jt89/jt89.vhd','rtl/jt89/jt89_noise.v','rtl/jt89/jt89_tone.v','rtl/jt89/jt89_vol.v','rtl/savestates.sv','rtl/system.vhd'].sort();
const manifest={};
const tree=git('ls-tree','-r',rev).trim().split('\n').map(s=>s.match(/^(\d+) (\w+) (\w+)\t(.+)$/)).filter(m=>m&&m[2]==='blob');
const bytes=cp.execFileSync('git',['cat-file','--batch'],{cwd:root,input:tree.map(m=>m[3]).join('\n')+'\n',maxBuffer:256*1024*1024});let offset=0;
const baseline={};for(const entry of tree){const end=bytes.indexOf(10,offset),head=bytes.subarray(offset,end).toString(),size=Number(head.split(' ')[2]);offset=end+1;const b=bytes.subarray(offset,offset+size);offset+=size+1;baseline[entry[4]]=b;manifest[entry[4]]={blob:entry[3],baselineSHA256:hash(b)};}
const read=(v,f)=>norm(fs.readFileSync(p.join(d,v,f),'utf8'));const a=norm(baseline['rtl/savestates.sv'].toString());
const token=s=>s.replace(/\/\*[\s\S]*?\*\//g,'').replace(/\/\/[^\n]*/g,'').replace(/\s+/g,'');
function section(s,start,end){const i=start.includes('ST_SAVE_DONE')?s.lastIndexOf(start):s.indexOf(start),j=s.indexOf(end,i+start.length);assert(i>=0&&j>i,start);return s.slice(i,j);}
function states(s){const matches=[...s.matchAll(/^        (ST_[A-Z0-9_]+(?:\s*,\s*ST_[A-Z0-9_]+)*): begin/gm)],r={};for(let i=0;i<matches.length;i++)r[matches[i][1]]=s.slice(matches[i].index,i+1<matches.length?matches[i+1].index:s.indexOf('        default: state <= ST_IDLE;',matches[i].index));return r;}
for(const v of ['B','C']){
 const wd=p.join(d,v),changed=git('-C',wd,'diff','--name-only').trim().split('\n').sort();assert.deepEqual(changed,allowed);assert.equal(git('-C',wd,'rev-parse','HEAD').trim(),rev);assert.equal(git('-C',wd,'diff','--cached'),'');
 const st=git('-C',wd,'status','--short');assert(!st.includes('??'),'no unexpected worktree files');
 fs.writeFileSync(p.join(d,`${v}.diff`),git('-C',wd,'diff','--binary'));fs.writeFileSync(p.join(d,`${v}_diff_stat.txt`),git('-C',wd,'diff','--stat'));
 let verified=0;for(const e of tree){const f=e[4],b=fs.readFileSync(p.join(wd,f));manifest[f][v+'SHA256']=hash(b);if(!allowed.includes(f)){const text=!baseline[f].includes(0);assert(text?norm(b.toString())===norm(baseline[f].toString()):b.equals(baseline[f]),'Unrelated file '+v+' '+f);verified++;}}
 const b=read(v,'rtl/savestates.sv');
 for(const f of ['jt89.v','jt89_tone.v','jt89_noise.v','jt89_vol.v','jt89_mixer.v'])assert.equal(token(read(v,'rtl/jt89/'+f)),token(fs.readFileSync(p.join(d,`sim_${v}`,f),'utf8')),'Tested native source differs '+v+' '+f);
 let simController=read(v,'rtl/savestates.sv');for(const name of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+name+';\\n','m'),decl=simController.match(re)[0];simController=simController.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}assert.equal(token(simController),token(fs.readFileSync(p.join(d,`sim_${v}/controller.sv`),'utf8')),'Tested controller differs '+v);
 for(const [start,end]of [['// One registered DDRAM transaction;','always @(*) begin'],['        // The existing FSM helpers execute only on acceptance.','endmodule'],['        ST_SAVE_DONE: begin','        ST_SAVE_SETTLE: begin']])assert.equal(token(section(b,start,end)),token(section(a,start,end)),'Handshake/publication changed '+v);
 const sa=states(a),sb=states(b),permitted=new Set(['ST_IDLE','ST_FREEZE','ST_SAVE_PSG','ST_SAVE_WRAM','ST_SAVE_NVRAM','ST_LOAD_HDR_WT','ST_LOAD_PSG','ST_LOAD_RESTORE','ST_UNFREEZE']);const stateDiff=[];
 for(const [k,s]of Object.entries(sb)){if(token(s)!==token(sa[k]||'')){stateDiff.push(k);assert(permitted.has(k)||k.startsWith('ST_SAVE_VRAM'),'Unexpected FSM state difference '+v+' '+k);}}
 for(const f of ['rtl/jt89/jt89.v','rtl/jt89/jt89_tone.v','rtl/jt89/jt89_noise.v','rtl/jt89/jt89_vol.v','rtl/jt89/jt89.vhd','rtl/AudioMix.vhd'])assert.equal(read('B',f),read('C',f),'Shared audio implementation '+f);
 assert(!/ST_(?:SAVE|LOAD)_AUDIO|has_audio_ext|ss_ext_|ss_phase_|ss_div_|audio_quiescent/.test(b));
 results.candidates[v]={branch:git('-C',wd,'branch','--show-current').trim(),head:rev,changedFiles:changed,unrelatedBlobsVerified:verified,modifiedFSMStates:stateDiff,diffSHA256:hash(fs.readFileSync(p.join(d,`${v}.diff`))),status:st,controllerAudioRegisterBits:v==='B'?0:22,extensionRegisterBitsRemoved:v==='B'?422:400};
}
function check(file,marker){const s=fs.readFileSync(p.join(d,file),'utf8');assert(s.includes(marker),'Missing '+marker+' in '+file);assert(!/\*\* (?:Error|Fatal)|Errors: [1-9]/.test(s),'Simulation errors in '+file);results.tests[file]={pass:s.split(/\r?\n/).filter(l=>l.includes('PASS')),SHA256:hash(Buffer.from(s))};}
check('sim_A/replay.log','PASS PSG replay: 128');
for(const v of ['A','B','C'])check(`strong_${v}/strengthened.log`,v==='A'?'PASS PSG replay: 128':'PASS reduced PSG contract: cases=128 different_cases=128');
for(const v of ['B','C']){check(`sim_${v}/controller_final.log`,`PASS controller ${v}:`);check(`analyze_${v}/system_analysis_pass.log`,`PASS production system VHDL analysis ${v}`);}
check('native/native.log','PASS native A/B/C:');check('native/focused_qualified.log','PASS focused history:');check('native/controls.log','PASS control consumers:');
fs.writeFileSync(p.join(d,'input_manifest.json'),JSON.stringify({baseline:rev,files:manifest},null,2));
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(results,null,2));console.log(JSON.stringify({protectedFiles:results.protectedFiles,newRefs:results.newRefs,candidates:results.candidates,tests:Object.keys(results.tests).length},null,2));
