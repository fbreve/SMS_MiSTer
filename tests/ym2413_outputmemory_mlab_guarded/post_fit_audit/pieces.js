const {nl,mk}=require('./eval.js');
const S=require('./scenarios.js');
const base=(w,state)=>{const a=new Map();for(const s of S.states)a.set(s,0);if(state)a.set(`\\state.${state}~q`,1);for(let i=0;i<7;i++)a.set(`fm_word[${i}]`,(w>>i)&1);for(const k of S.dl)a.set(k,0);a.set(S.sq,0);a.set('\\dout_expected~q',0);a.set('intermediate_12',1);return a;};
for(const [w,st] of [[10,'ST_FM_LOAD'],[39,'ST_FM_LOAD'],[50,'ST_FM_LOAD'],[0,'ST_FM_LOAD_DESC']]){
 const m=mk(base(w,st));const r={};
 for(const n of ['fm_saved_stage_zero~0','fm_saved_stage_zero~2','Selector161~15','Selector162~12','Equal1~15','Selector2183~2','ddram_step','fm_saved_stage_zero~1'])r[n]=m.wire(nl.byQ[`\\${n}_combout`]?`\\${n}_combout`:(n==='ddram_step'?'\\ddram_step~combout':n));
 console.log(st,w,JSON.stringify(r));
}
for(const n of ['Selector161~15','Selector162~12','Equal1~15','ddram_step']){const c=nl.cells['\\'+n]||nl.cells[n];console.log(n,c?JSON.stringify(c.ports).slice(0,400):'none');}
