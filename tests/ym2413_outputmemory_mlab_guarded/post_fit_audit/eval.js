const {load,sig}=require('./netlist.js');
const seed=process.argv[2];
const nl=load(`${__dirname}/work_seed${seed}/candidate/fitted_netlist/SMS.vo`,'savestates');
function mk(assign){
 const memo=new Map(),xleaves=new Set();
 function val(w){const {w:n,inv}=sig(w);let v;
  if(n==='gnd')v=0;else if(n==='vcc')v=1;else v=wire(n);
  return v===2?2:(inv?1-v:v);}
 function wire(n){
  if(assign.has(n))return assign.get(n);
  if(memo.has(n))return memo.get(n);
  const c=nl.byQ[n];let r;
  if(!c||c.type==='dffeas'){xleaves.add(n);r=2;}
  else{
   if(c.mask&&c.mask.extended_lut==='on'){xleaves.add('EXT:'+n);r=2;}
   else{
    const ins=['dataa','datab','datac','datad','datae','dataf'].map(p=>c.ports[p]?val(c.ports[p]):0);
    const mask=BigInt('0x'+c.mask.lut_mask);const unk=[];ins.forEach((v,i)=>{if(v===2)unk.push(i)});
    let seen=new Set();
    for(let k=0;k<(1<<unk.length);k++){let idx=0;ins.forEach((v,i)=>{let b=v;if(v===2){b=(k>>unk.indexOf(i))&1;}idx|=b<<i;});seen.add(Number((mask>>BigInt(idx))&1n));if(seen.size>1)break;}
    r=seen.size>1?2:[...seen][0];
   }
  }
  memo.set(n,r);return r;}
 return {val,wire,xleaves};
}
const find=re=>Object.keys(nl.byQ).filter(k=>re.test(k));
module.exports={nl,mk,find,sig};
if(require.main===module){
 console.log(find(/^\\state\.ST_(FM_LOAD|FM_LOAD_DESC|ERROR|FM_LOAD_STORE)~q$/));
 console.log(find(/^\\fm_word\[\d\]/),find(/^\\dout_latch\[[01]\]/),find(/^\\dout_expected/),find(/DDRAM_BUSY/),find(/saved_stage/));
 console.log(find(/^\\state\./).length,'state ffs');
}
