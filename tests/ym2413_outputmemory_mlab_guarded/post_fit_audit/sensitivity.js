const {nl,mk,find}=require('./eval.js');
const S=require('./scenarios.js');
// Build baseline assignment through scenario() internals by replicating
const states=S.states,dl=S.dl;
const wd=find(/ddram_watchdog/).filter(k=>nl.byQ[k]&&nl.byQ[k].type==='dffeas');
function assign(o){const a=new Map();for(const s of states)a.set(s,0);a.set(`\\state.${o.state}~q`,1);
 for(let i=0;i<7;i++)a.set(`fm_word[${i}]`,(o.word>>i)&1);for(const k of dl)a.set(k,0);a.set('dout_latch[1]',o.dl1);a.set('dout_latch[0]',0);
 a.set(S.sq,o.saved);a.set('\\dout_expected~q',0);a.set('DDRAM_BUSY',0);for(const k of wd)a.set(k,0);return a;}
const root=process.argv[4]==='ena'?S.savedFF.ports.ena:S.errFF.ports.d;
const a=assign({state:'ST_FM_LOAD',word:50,dl1:1,saved:0});
let m=mk(a);console.log('root',root,m.val(root));
// find sensitive leaves iteratively: fix X leaves greedily to see which matter
const xs=[...m.xleaves];const sens=[];for(const x of xs){if(a.has(x))continue;const r=[0,1].map(b=>{const c=new Map(a);c.set(x,b);return mk(c).val(root);});if(r[0]!==2||r[1]!==2)sens.push(x+' (0:'+r[0]+',1:'+r[1]+')');}console.log('X leaves',xs.length,'sensitive:',sens);

