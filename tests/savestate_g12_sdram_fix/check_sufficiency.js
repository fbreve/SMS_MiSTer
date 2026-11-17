const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>fs.readFileSync(p.join(d,f),'utf8');
const base=JSON.parse(read('baseline.json')),logs=[];
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),base.head);
assert.equal(cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'','production edited before gate');
assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');
for(const[f,h]of Object.entries(base.files))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'baseline hash '+f);
function log(f,marker){const s=read(f);assert(s.includes(marker)&&s.includes('# End time:')&&!/\*\* (?:Error|Fatal|Failure)|Errors: [1-9]/.test(s),'failed/incomplete '+f);logs.push({file:f,sha256:sha(s)});return s;}
function image(f){const a=read(f).split(/\r?\n/).filter(x=>x&&!x.startsWith('//'));assert(a.length===12288&&a.every(x=>/^[\da-f]{16}$/i.test(x)),'unknown image '+f);assert.equal(Number((BigInt('0x'+a[0x1a])>>40n)&0xffffffn),0x484310);const b=Buffer.alloc(98304);a.forEach((x,i)=>b.writeBigUInt64LE(BigInt('0x'+x),i*8));return sha(b);}
log('baseline/s1_c0_d8_f0/simulation.log','CONFIRMED G12 wrongFetches1 guestDifferences98');
const preMatrix=[],postMatrix=[];
for(const saved of [0,1])for(const current of [0,1]){
 const leaf=`s${saved}_c${current}_d8_f1`;
 // Canonical exact failing baseline uses the full production flush.
 const pre=saved===1&&current===0?'baseline/s1_c0_d8_f0/simulation.log':`baseline/${leaf}/simulation.log`;
 log(pre,saved===1&&current===0?'CONFIRMED G12':'PASS G12 LOAD_RUNNING');preMatrix.push({saved,current,log:pre});
 const post=`protocol/${leaf}/simulation.log`,s=log(post,'PASS G12 LOAD_RUNNING');assert(s.includes('PASS_REISSUE'),'missing fresh request proof '+post);postMatrix.push({saved,current,log:post});
}
log('prototype/s1_c0_d8_f0/simulation.log','PASS G12 LOAD_RUNNING');
const witnessImage=image('baseline/s1_c0_d8_f0/image.hex');assert.equal(witnessImage,image('prototype/s1_c0_d8_f0/image.hex'));
for(const delay of [0,1,6,7,8,9,10,14,15,20,24,29]){
 const pre=`protocol/s1_c0_d${delay}_f1`,s=log(pre+'/simulation.log','PASS G12 LOAD_RUNNING');assert(s.includes('PASS_REISSUE'));assert.equal(image(pre+'/image.hex'),witnessImage,'phase sweep image differs');
}
let integrationLoads=0,comparisons=0;const cases=[...JSON.parse(read('matrix/cases.json')),...JSON.parse(read('matrix/additional_cases.json'))];
for(const c of cases){const prefix='matrix/'+c.id;log(prefix+'/reference.log','PASS MATRIX REFERENCE');const s=log(prefix+'/replay.log',`PASS MATRIX replays${c.args.REPLAYS} N${c.args.N}`);
 const suffix=[...s.matchAll(/PASS SUFFIX pass(\d+) samples(\d+)/g)];assert.equal(suffix.length,c.args.REPLAYS+1);assert(suffix.every(m=>+m[2]===c.args.N));
 const m=s.match(/G12_LEDGER accepted(\d+) returned(\d+) physical(\d+) flight([01])/);assert(m);assert.equal(+m[1],+m[2]+ +m[4]);assert(+m[3]>=+m[2]&&+m[3]<=+m[1]);image(prefix+'/image.hex');
 integrationLoads+=c.args.REPLAYS;comparisons+=(c.args.REPLAYS+1)*c.args.N;
}
assert.equal(image('matrix/history_0/image.hex'),image('matrix/history_1/image.hex'),'natural same-image pair');
const omitted=[0,1].map(n=>read(`matrix/history_${n}/replay.log`).match(/G12_ACCEPT[^\n]+retainedAddr([\da-f]+) retainedData([\da-f]+)/i).slice(1));assert.notEqual(omitted[0][0],omitted[1][0]);assert.notEqual(omitted[0][1],omitted[1][1]);
for(const c of JSON.parse(read('g01/cases.json')))log(`g01/p${c.args.PROGRAM}.log`,'PASS G01 TRACE');
const result={pass:true,head:base.head,format:16,productionUnchanged:true,preMatrix,postMatrix,integrationCases:cases.length,integrationLoads,comparisons,witnessImage,historyPair:{sha256:image('matrix/history_0/image.hex'),omitted},logs};
fs.writeFileSync(p.join(d,'pre_edit_gate.json'),JSON.stringify(result,null,2));console.log(JSON.stringify({pass:true,integrationCases:cases.length,integrationLoads,comparisons,logs:logs.length}));
