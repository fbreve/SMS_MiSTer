const {nl,mk,find}=require('./eval.js');
const S=require('./scenarios.js');
const wd=find(/ddram_watchdog/).filter(k=>nl.byQ[k]&&nl.byQ[k].type==='dffeas');
function assign(o){const a=new Map();for(const s of S.states)a.set(s,0);if(o.state)a.set(`\\state.${o.state}~q`,1);
 for(let i=0;i<7;i++)a.set(`fm_word[${i}]`,(o.word>>i)&1);for(const k of S.dl)a.set(k,0);a.set('dout_latch[1]',o.dl1||0);a.set('dout_latch[0]',o.dl0||0);
 a.set(S.sq,o.saved||0);a.set('\\dout_expected~q',0);a.set('intermediate_12',1);for(const k of wd)a.set(k,0);return a;}
const roots={ena:S.savedFF.ports.ena,D:S.savedFF.ports.d,err:S.errFF.ports.d,sclr:S.savedFF.ports.sclr};
function sensitive(a,root){const m=mk(a);m.val(root);const out=[];for(const x of m.xleaves){if(a.has(x))continue;const r=[0,1].map(b=>{const c=new Map(a);c.set(x,b);return mk(c).val(root);});if(r[0]!==2||r[1]!==2)out.push(x);}return out;}
const table=[];let bad=0;
for(let w=0;w<=51;w++){
 for(const dl1 of [0,1])for(const saved of [0,1]){
  const a=assign({state:'ST_FM_LOAD',word:w,dl1,saved});
  const m=mk(a);const ena=m.val(roots.ena),err=m.val(roots.err);
  const sens=[...new Set([...sensitive(a,roots.ena),...sensitive(a,roots.err)])];
  // enumerate sensitive leaves (limit 10) and gather possible outcomes
  const outs=new Set();const n=Math.min(sens.length,12);
  for(let k=0;k<(1<<n);k++){const c=new Map(a);for(let i=0;i<n;i++)c.set(sens[i],(k>>i)&1);const mm=mk(c);outs.add(`ena=${mm.val(roots.ena)},err=${mm.val(roots.err)},D=${mm.val(roots.D)}`);}
  table.push({w,dl1,saved,sens:sens.length,outs:[...outs]});
 }
}
for(const t of table){
 const wantErr=t.w===50&&t.dl1===1&&t.saved===0;
 const sig=JSON.stringify(t.outs);
 console.log(`w${t.w} dl1=${t.dl1} saved=${t.saved} sens=${t.sens} -> ${t.outs.join(' | ')}`);
}
