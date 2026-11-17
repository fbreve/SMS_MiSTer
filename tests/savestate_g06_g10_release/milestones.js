const fs=require('fs'),p=require('path'),zlib=require('zlib'),readline=require('readline');
// Source-count derivation is explicitly distinguished from observed CSV rows.
(async()=>{const out={};for(const name of ['common_t1','forced_common_t1']){
 const file=p.join(__dirname,name,'timeline.csv.full.gz'),input=fs.createReadStream(file),unzip=input.pipe(zlib.createGunzip());
 const lines=readline.createInterface({input:unzip,crlfDelay:Infinity});let first;
 for await(const s of lines){const a=s.split(',');if(a[9]==='34'&&a[10]==='0'){first={cycle:+a[0],clkd:+a[1]};break;}}
 lines.close();input.destroy();unzip.destroy();if(!first)throw Error('missing load wait');
 const delta=n=>(first.clkd-n%30+30)%30;
 out[name]={observedFirstLoggedLoadUnfreeze:first,sourceDerived:{firstUnfreezeState:{cycle:first.cycle-250,clkd:delta(250)},postFlushPreUnfreeze:{cycle:first.cycle-251,clkd:delta(251)}},derivation:'Logger starts at ST_UNFREEZE old unfreeze_cnt250; unchanged controller enters that state at count0, one cycle after ST_PRE_UNFREEZE. This post-flush milestone is inferred from exact fixed FSM counts, not directly logged.'};
}fs.writeFileSync(p.join(__dirname,'milestones.json'),JSON.stringify(out,null,2)+'\n');console.log(JSON.stringify(out,null,2));})().catch(e=>{console.error(e);process.exitCode=1;});
