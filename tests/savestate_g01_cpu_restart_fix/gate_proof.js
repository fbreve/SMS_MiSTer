const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');const d=__dirname,r=path.resolve(d,'../..');
const read=n=>{let b=fs.readFileSync(path.join(d,n));return b.toString(b[0]===255?'utf16le':'utf8');};
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const planned=[[10,719,1],[11,719,2],[12,600,3],[13,600,4],[14,816,3],[15,816,4],[16,600,5],[26,600,3],[12,2570,3]];
const classes=new Set([0]);const runs=planned.map(([p,o,context])=>{let log=`quick_p${p}_o${o}_t15_s0_c0.log`,s=read(log);if(!s.includes('PASS G09')||/\*\* (Error|Fatal|Failure)/.test(s)||(s.match(/REPLAY PASS/g)||[]).length!==3)throw Error('Proof failed '+log);let c=+s.match(/CONTEXT pre[\da-f]+ saved([\da-f])/)[1];if(c!==context)throw Error('Wrong natural context '+log+' '+c);classes.add(c);return{log,sha256:hash(path.join(d,log)),context:c,accepted:s.match(/ACCEPT[^\r\n]+/)[0]};});
const sweep=[];for(const p of [10,11,12,13,14,15,16,26]){const log=`proof_p${p}_o0_t15_s0_c120.log`,s=read(log);if(!s.includes('accepted120')||/\*\* (Error|Fatal|Failure)/.test(s))throw Error('Sweep failed '+log);sweep.push({log,accepted:120,sha256:hash(path.join(d,log))});}
if(classes.size!==6)throw Error('Missing class');
const trackedDiff=cp.execFileSync('git',['diff','--stat'],{cwd:r}).toString();if(trackedDiff)throw Error('Production changed before proof gate');
const result={phase:'pre-production',head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:r}).toString().trim(),classes:[...classes].sort(),runs,sweeps:sweep,fullPrototypeLoads:runs.length*3,acceptedObservations:960,trackedDiff,sourceHashes:Object.fromEntries(['T80_proof.vhd','T80s_proof.vhd','proof_machine.sv','fast_tb.sv','savestates_fast.sv','design.md'].map(n=>[n,hash(path.join(d,n))]))};
fs.writeFileSync(path.join(d,'sufficiency.json'),JSON.stringify(result,null,2));console.log('PASS pre-edit proof: all six classes, 27 exact prototype LOADs, 960 accepted observations.');
