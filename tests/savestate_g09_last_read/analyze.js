const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process');
const d=__dirname,r=path.resolve(d,'../..');
const read=p=>{const b=fs.readFileSync(p);return b.toString(b[0]===255?'utf16le':'utf8').replace(/^\uFEFF/,'');};
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const git=(...args)=>cp.execFileSync('git',args,{cwd:r,encoding:'utf8'}).trim();
const logs=fs.readdirSync(d).filter(p=>/^p\d+_o\d+_t\d+_s\d+_c\d+\.log$/.test(p));
let captures=0,canonicalCaptures=0,fullPass=0,canonicalFull=0,loads=0,comparisons=0;const cases=[];
for(const name of logs){
 const s=read(path.join(d,name));const a=[...s.matchAll(/ACCEPT program(\d+) offset(\d+) period(\d+) sys(\d+) cycle(\d+) PC([a-f0-9]+) bus([a-f0-9]+) last_pre([a-f0-9]+) MC(\d+) TS(\d+)/g)].map(m=>({program:+m[1],offset:+m[2],period:+m[3],sys:+m[4],cycle:+m[5],pc:m[6],address:m[7],last_pre:m[8],mc:+m[9],ts:+m[10]}));
 const requests=[...s.matchAll(/REQUEST_SWEEP case(\d+) cycle(\d+) A([a-f0-9]+) last([a-f0-9]+) M1([01]) MREQ([01]) RD([01]) WR([01]) MC(\d+) TS(\d+)/g)].map(m=>({index:+m[1],cycle:+m[2],address:m[3],last:m[4],m1:+m[5],mreq:+m[6],rd:+m[7],wr:+m[8],mc:+m[9],ts:+m[10]}));
 const cap=s.match(/PASS G09 CAPTURE_SWEEP program(\d+) period(\d+) sys(\d+) accepted(\d+)/);
 const pass=s.match(/PASS G09 program(\d+) offset(\d+) period(\d+) sys(\d+) loads(\d+) comparisons(\d+) dependent(\d+)/);
 const failure=s.match(/DIFF iter(\d+) clock(\d+) expected([0-9a-f]+) actual([0-9a-f]+)/);
 const canonical=cap?name.endsWith('_c180.log'):!!pass&&name!=='p9_o3000_t15_s0_c0.log';
 if(cap){if(a.length!==+cap[4]||requests.length!==+cap[4])throw Error('capture count '+name);captures+=a.length;if(canonical)canonicalCaptures+=a.length;}
 else if(pass){if(a.length!==1||+pass[5]!==3)throw Error('full count '+name);fullPass++;loads+=3;if(canonical){canonicalFull++;comparisons+=+pass[6];}}
 else if(!failure)throw Error('Incomplete log '+name);
 if((cap||pass)&&/\*\* (Error|Fatal|Failure)|Errors: [1-9]/.test(s))throw Error('Passing log has failure '+name);
 if(a.some(x=>x.mc!==1||x.ts!==2||x.pc!==x.address))throw Error('Wrong fetch boundary '+name);
 let delta;
 if(failure){const x=BigInt('0x'+failure[3]),y=BigInt('0x'+failure[4]);const mask=(1n<<323n)-1n;if((x&mask)!==(y&mask))throw Error('Mismatch extends outside CPU vector');delta={clock:+failure[2],cpu_xor:((x^y)>>323n).toString(16),reference_BC:((x>>403n)&65535n).toString(16),restored_BC:((y>>403n)&65535n).toString(16),non_cpu_projection_equal:true,scope:'CPU register mismatch; no broader investigation or successful replay claim'};}
 cases.push({name,sha256:hash(path.join(d,name)),canonical,kind:cap?'capture_observations':pass?'full_replay':'interrupted_replay',accepts:a,requests,request_phases:[...new Set(requests.map(x=>`${x.mc}:${x.ts}`))],request_a000:requests.filter(x=>x.address==='a000'),pass:!!(cap||pass),loads:pass?+pass[5]:0,comparisons:pass?+pass[6]:0,reference:s.match(/REFERENCE signature([0-9a-f]+) bank([0-9a-f]+)/)?.slice(1),restart_reads:[...s.matchAll(/RESTART_READ iter(\d+) A([a-f0-9]+) last_pre([a-f0-9]+) RD([01]) MC(\d+) TS(\d+)/g)].map(m=>({iteration:+m[1],address:m[2],q_last:m[3],rd:+m[4],mc:+m[5],ts:+m[6]})),perturbations:[...s.matchAll(/PERTURB iter(\d+) last([a-f0-9]+) bank([a-f0-9]+) boot([01]) wonder([01]) history([a-f0-9]+)/g)].map(m=>({iteration:+m[1],last:m[2],bank:m[3],boot:+m[4],wonder:+m[5],history:m[6]})),cpu_difference:delta});
}
const sources=git('ls-files','SMS.sv','rtl','files.qip').split('\n').filter(Boolean).map(p=>{const local=read(path.join(r,p)).replace(/\r\n/g,'\n'),head=cp.execFileSync('git',['show',`HEAD:${p}`],{cwd:r,encoding:'utf8'}).replace(/\r\n/g,'\n');if(local!==head)throw Error('Production changed '+p);return{path:p,sha256:hash(path.join(r,p)),matches_HEAD:true};});
if(git('diff','--stat')||git('diff','--cached','--stat'))throw Error('Unexpected tracked or staged diff');
const sanity=['g09_f13_case0','g09_f15_cpu'].map(n=>{const p=path.join(d,'regression',n+'.log'),s=read(p);if(!s.includes('PASS')||/\*\* (Error|Fatal|Failure)|Errors: [1-9]/.test(s))throw Error('sanity '+n);return{name:n,sha256:hash(p),pass:true};});
const pilot=read(path.join(d,'pilot.log'));if(!pilot.includes('PASS G09'))throw Error('pilot');
const images=fs.readdirSync(d).filter(n=>/^image_.*\.hex$/.test(n)).map(n=>{const words=read(path.join(d,n)).replace(/\/\/[^\n]*/g,'').trim().split(/\s+/);if(words.length!==12288||words.some(w=>!/^[0-9a-f]{16}$/i.test(w)))throw Error('Unknown/incomplete image '+n);if((BigInt('0x'+words[26])>>40n)!==0x48430cn||(BigInt('0x'+words[5])>>41n)!==0n)throw Error('Not current v12 '+n);return{path:n,words:words.length,all_known:true,sha256:hash(path.join(d,n))};});
const fixtures=fs.readdirSync(d).filter(n=>/\.(js|sv|vhd|ps1|do|in|md)$/.test(n)).map(n=>({path:n,sha256:hash(path.join(d,n))}));
const result={head:git('rev-parse','HEAD'),branch:git('branch','--show-current'),classification:'CLOSED - PROVEN RECONSTRUCTABLE',new_targeted_simulation_runs:logs.length+1,existing_sanity_runs:2,total_elaborated_simulation_runs:logs.length+3,successful_full_replay_runs_including_pilot:fullPass+1,successful_loads_including_pilot:loads+3,canonical_full_replay_runs:canonicalFull,canonical_loads:canonicalFull*3,canonical_host_comparisons:comparisons,accepted_capture_observations:captures,canonical_accepted_capture_observations:canonicalCaptures,canonical_completed_saves:canonicalFull,interrupted_replays:cases.filter(x=>!x.pass).length,complete_v12_divergent_pairs:0,new_guest_mapping_divergences_established:0,cases,sanity,images,fixtures,production:sources,diff_stat:git('diff','--stat'),staged_stat:git('diff','--cached','--stat'),status:git('status','--short')};
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify(result,null,2)+'\n');
const summary={...result};for(const k of ['cases','sanity','production','fixtures','images'])delete summary[k];console.log(JSON.stringify(summary,null,2));
