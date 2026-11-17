const {nl,find}=require('./eval.js');
const S=require('./scenarios.js');
const ffs=Object.values(nl.cells).filter(c=>c.type==='dffeas');
const clr={},clk={};for(const c of ffs){clr[c.ports.clrn]=(clr[c.ports.clrn]||0)+1;clk[c.ports.clk]=(clk[c.ports.clk]||0)+1;}
console.log('savestates FFs',ffs.length,'clrn nets',JSON.stringify(clr),'clk nets',JSON.stringify(clk));
const sv=S.savedFF.ports;console.log('saved FF: clk',sv.clk,'clrn',sv.clrn,'prn',sv.prn,'aload',sv.aload,'sload',sv.sload,'power_up low (see vo)');
const err=S.errFF.ports;console.log('ST_ERROR FF: clk',err.clk,'clrn',err.clrn,'ena',err.ena,'sclr',err.sclr);
console.log('clr_noise driver in savestates module:',nl.byQ['clr_noise']?nl.byQ['clr_noise'].name:'module input port');
console.log('state ffs: ',S.states.length,' dffs with asynchronous load (aload!=gnd):',ffs.filter(c=>c.ports.aload!=='gnd').length);
console.log('saved Q fanout cells:',Object.values(nl.cells).filter(c=>Object.values(c.ports).some(v=>/fm_saved_stage_zero~q/.test(v))).map(c=>c.name));
