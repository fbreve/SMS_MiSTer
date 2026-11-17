const {load,sig}=require('./netlist.js');
const seed=process.argv[2];const nl=load(`${__dirname}/work_seed${seed}/candidate/fitted_netlist/SMS.vo`,'savestates');
console.log('cells',Object.keys(nl.cells).length);
const want=process.argv[3]||'\\state.ST_ERROR';
const ff=nl.cells[want]||nl.cells[want+' '];
console.log(want,!!ff,ff&&JSON.stringify(ff.ports));
const leaves=new Set(),seen=new Set();
function cone(w,d){const {w:n}=sig(w);if(seen.has(n))return;seen.add(n);const c=nl.byQ[n];
 if(!c||c.type==='dffeas'||n==='gnd'||n==='vcc'){leaves.add(n);return;}
 for(const p of ['dataa','datab','datac','datad','datae','dataf','datag'])if(c.ports[p]&&!/^!?(gnd|vcc)$/.test(c.ports[p]))cone(c.ports[p],d+1);}
cone(ff.ports.d,0);console.log([...leaves].sort().join('\n'));console.log('internal',seen.size-leaves.size);

