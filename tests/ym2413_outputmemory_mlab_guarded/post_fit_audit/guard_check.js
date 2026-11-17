const {scenario}=require('./scenarios.js');
const out=[];
const W='intermediate_12';
for(const wr of [0,1]){
 const run=(label,o)=>{const r=scenario({...o,extra:{[W]:wr,...(o.extra||{})}});out.push(`wr=${wr} ${label.padEnd(34)} errD=${r.errD} savedD=${r.savedD} savedEna=${r.savedEna} savedSclr=${r.savedSclr}`+(r.errD===2||r.savedEna===2?'  X:'+r.x.join(','):''));};
 run('word50 bit1 saved=0 -> must ERROR',{state:'ST_FM_LOAD',word:50,dl1:1,saved:0});
 run('word50 bit1 saved=1 -> no error',{state:'ST_FM_LOAD',word:50,dl1:1,saved:1});
 run('word50 bit0 saved=0 -> no error',{state:'ST_FM_LOAD',word:50,dl1:0,saved:0});
 run('word50 bit0 saved=1 -> no error',{state:'ST_FM_LOAD',word:50,dl1:0,saved:1});
 run('word39 lo=00 : savedD=1 ena=1',{state:'ST_FM_LOAD',word:39,dl1:0,dl0:0,saved:0});
 run('word39 lo=10 : savedD=0 ena=1',{state:'ST_FM_LOAD',word:39,dl1:1,dl0:0,saved:1});
 run('word39 lo=01 : savedD=0 ena=1',{state:'ST_FM_LOAD',word:39,dl1:0,dl0:1,saved:1});
 run('word39 lo=11 : savedD=0 ena=1',{state:'ST_FM_LOAD',word:39,dl1:1,dl0:1,saved:1});
 run('word10 bit1 saved=0 -> no error',{state:'ST_FM_LOAD',word:10,dl1:1,saved:0});
 run('word49 bit1 saved=0 -> no error',{state:'ST_FM_LOAD',word:49,dl1:1,saved:0});
 run('word51 bit1 saved=0 -> no error',{state:'ST_FM_LOAD',word:51,dl1:1,saved:0});
 run('DESC state: sclr=1',{state:'ST_FM_LOAD_DESC',word:0,dl1:0,saved:1});
 run('other state (IDLE-ish) word50 bit1 s0',{state:null,word:50,dl1:1,saved:0});
}
console.log(out.join('\n'));

