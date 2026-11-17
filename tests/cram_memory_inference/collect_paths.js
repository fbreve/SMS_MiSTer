const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
function first(file){const s=fs.readFileSync(file,'utf8'),line=s.split(/\r?\n/).find(l=>/^;\s*-?\d+\.\d+\s*;/.test(l));assert(line,file+' timing row');const a=line.split(';').slice(1,-1).map(x=>x.trim());return {slack:+a[0],from:a[1],to:a[2],launch:a[3],latch:a[4],relationship:+a[5],skew:+a[6],dataDelay:+a[7]};}
const baseline={setup:first(p.join(d,'../savestate_g08_fm/early_paths_setup.rpt')),hold:first(p.join(d,'../savestate_g08_fm/early_paths_hold.rpt')),core:first(p.join(d,'../savestate_g08_fm/early_emu_setup.rpt'))};
const candidate={setup:first(p.join(d,'early_paths_setup.rpt')),hold:first(p.join(d,'early_paths_hold.rpt')),core:first(p.join(d,'early_paths_core.rpt'))};
for(const [key,f]of [['cramFrom','early_paths_cram_from.rpt'],['cramTo','early_paths_cram_to.rpt']])if(fs.existsSync(p.join(d,f)))candidate[key]=first(p.join(d,f));
const delta=Object.fromEntries(['setup','hold','core'].map(k=>[k,{slack:candidate[k].slack-baseline[k].slack,dataDelay:candidate[k].dataDelay-baseline[k].dataDelay}]));
fs.writeFileSync(p.join(d,'timing_results.json'),JSON.stringify({baseline,candidate,delta},null,2)+'\n');console.log(JSON.stringify({candidate,delta},null,2));
