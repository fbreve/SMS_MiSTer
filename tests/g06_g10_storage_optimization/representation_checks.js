const fs=require('fs'),assert=require('assert'),d=__dirname;
// Exhaustive symbolic bit lineage, not a claim of arbitrary reachable guest Q.
let q=Array.from({length:4800},(_,i)=>i<4778?'history_'+i:'zero');const initial=q.slice(),padEverCarriesHistory=Array(22).fill(false);
for(let k=0;k<75;k++){
 for(let p=0;p<22;p++)padEverCarriesHistory[p] ||= q[4778+p]!=='zero';
 q=q.slice(64).concat(q.slice(0,64));
}
assert.deepStrictEqual(q,initial);assert(padEverCarriesHistory.every(Boolean));
// The same held live source can supply every SAVE word without capture FF.
const direct=Array.from({length:75},(_,w)=>initial.slice(w*64,w*64+64));
q=initial.slice();for(let w=0;w<75;w++){assert.deepStrictEqual(q.slice(0,64),direct[w]);q=q.slice(64).concat(q.slice(0,64));}
// A single ordinary ring cannot retain two distinct complete records at the
// existing simultaneous parallel restore pulse. No reachability/minimality
// assertion follows from this representation counterexample.
let ring=Array(4800).fill('old');
for(const owner of ['VDP1','VDP2'])for(let w=0;w<75;w++)ring=ring.slice(64).concat(Array(64).fill(owner+'_'+w));
assert(ring.every(x=>x.startsWith('VDP2')));
const result={passed:true,scope:'Exact symbolic present-representation identities; not RTL equivalence or reachable-state reconstruction proof',SAVEWords:75,SAVEBitLineages:4800,SAVERingReturnsExactly:true,frozenLiveSAVEWordEquality:true,paddingPositionsThatCarryHistory:22,bothBanksPaddingNotDead:44,oneRingAfterTwoLoadsRetains:'VDP2 only',existingSimultaneousRestoreRequires:'independent complete VDP1 and VDP2 vectors',OPLLTail:{physicalRows:256,FMRows:104,freeRows:152,freeBits:4864,oneSpriteRecordRows:150,oneRecordCouldFit:true,bothSpriteRecordsCannotFit:true,note:'Capacity is feasible for one bank, but current full-width parallel restore cannot consume this synchronous RAM without a receiver/port/schedule change.'}};
fs.writeFileSync(d+'/representation_checks.json',JSON.stringify(result,null,2)+'\n');console.log(result);
