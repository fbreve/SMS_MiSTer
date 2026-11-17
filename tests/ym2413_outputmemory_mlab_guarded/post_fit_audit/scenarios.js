const {nl,mk,find,sig}=require('./eval.js');
const states=find(/^\\state\.[A-Za-z_0-9]+~q$/);
const savedFF=Object.values(nl.cells).find(c=>c.type==='dffeas'&&/fm_saved_stage_zero\s*$/.test(c.name.trim()));
const sq=savedFF.ports.q;console.log('saved FF',savedFF.name,JSON.stringify(savedFF.ports));
const errFF=nl.cells['\\state.ST_ERROR'];
const dl=find(/^dout_latch\[\d+\]$/);const wd=find(/ddram_watchdog/).filter(k=>nl.byQ[k]&&nl.byQ[k].type==='dffeas');function scenario({state,word,dl1,dl0=0,saved,expected=0,busy=0,extra={}}){
 const a=new Map();
 for(const s of states)a.set(s,0);if(state)a.set(`\\state.${state}~q`,1);
 for(let i=0;i<7;i++)a.set(`fm_word[${i}]`,(word>>i)&1);
 for(const k of dl)a.set(k,0);a.set('dout_latch[1]',dl1);a.set('dout_latch[0]',dl0);
 a.set(sq,saved);a.set('\\dout_expected~q',expected);a.set('DDRAM_BUSY',busy);
 for(const k of wd)a.set(k,0);for(const [k,v] of Object.entries(extra))a.set(k,v);
 const m=mk(a);
 const r={errD:m.val(errFF.ports.d),savedD:m.val(savedFF.ports.d),savedEna:m.val(savedFF.ports.ena),savedSclr:m.val(savedFF.ports.sclr)};
 r.x=[...m.xleaves].slice(0,8);return r;
}
module.exports={scenario,states,sq,savedFF,errFF,dl};
if(require.main===module){
 console.log(states.length,'state ffs; dl bits',dl.length,'; saved Q',sq);
 const run=(label,o)=>console.log(label,JSON.stringify(scenario(o)));
 run('w50 bit1 saved0 ',{state:'ST_FM_LOAD',word:50,dl1:1,saved:0});
 run('w50 bit1 saved1 ',{state:'ST_FM_LOAD',word:50,dl1:1,saved:1});
 run('w50 bit0 saved0 ',{state:'ST_FM_LOAD',word:50,dl1:0,saved:0});
 run('w50 bit0 saved1 ',{state:'ST_FM_LOAD',word:50,dl1:0,saved:1});
 run('w39 lo=0 ',{state:'ST_FM_LOAD',word:39,dl1:0,saved:0});
 run('w39 lo=2 ',{state:'ST_FM_LOAD',word:39,dl1:1,saved:1});
 run('w39 lo=1 ',{state:'ST_FM_LOAD',word:39,dl1:0,dl0:1,saved:1});
 run('desc ',{state:'ST_FM_LOAD_DESC',word:0,dl1:0,saved:1});
 run('w10 bit1 saved0 (other word)',{state:'ST_FM_LOAD',word:10,dl1:1,saved:0});
}



