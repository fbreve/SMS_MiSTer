const fs=require('fs'),path=require('path'),d=__dirname,c=[];
function add(source,program,edge,width,run){const label=`s${source}_p${program}_e${edge}_w${width}_r${run}`;if(!c.some(x=>x.label===label))c.push({label,source,program,edge,width,run});}
const coarse=[-450,-360,-300,-120,-61,-60,-59,-30,-16,-15,-14,-2,-1,0,1,2,15,60,9999999];
for(let p=0;p<4;p++)for(const e of coarse)for(const run of [0,1])add(0,p,e,5,run);
for(let e=-61;e<=2;e++)for(const run of [0,1])add(0,0,e,5,run);
for(const e of coarse)for(const run of [0,1])add(1,0,e,5,run);
for(const s of [0,1])for(const e of [-60,-15,0,1,9999999])for(const run of [0,1])add(s,0,e,0,run);
fs.writeFileSync(path.join(d,'cases.json'),JSON.stringify(c,null,2));console.log(c.length+' timing runs');
