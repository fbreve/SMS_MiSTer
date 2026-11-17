const fs=require('fs'),path=require('path'),d=__dirname,cases=[];
function add(name,source,program,edge,width=1,second=9999999,held=0,schedule=0){for(const cand of [1,2])cases.push({name:name+'_c'+cand,source,program,edge,width,second,held,cand,bad:0,schedule});}
for(const e of [-121,-61,-60,-31,-30,-16,-15,-2,-1,0,1,2,15])add('sms_edge'+e,0,0,e);
add('inactive',0,0,9999999);add('deassert_T',0,0,-15,15);add('both_pending_entry',0,0,-60,5,-15);add('fresh_while_entry',0,0,-60,5,0);
add('old_needed_held',0,0,-300,0,9999999,1);add('old_needed_released',0,0,-300,5,9999999,1);
for(const e of [0,-15,-60])add('sms_held'+e,0,0,e,0,9999999,1);
for(const e of [-450,-120,-60,-15,0,1])for(const p of [1,2,3])add('cpu'+p+'_edge'+e,0,p,e);
for(const e of [-120,-61,-60,-46,-45,-44,-15,0,1])add('gg_edge'+e,1,0,e,0);
for(const e of [-120,-60,-45,-15])add('gg_held'+e,1,0,e,0,9999999,1);
add('future_sms',0,0,0,1,9999999,0,1);add('future_gg',1,0,-45,1,9999999,0,1);
fs.writeFileSync(path.join(d,'cases.json'),JSON.stringify(cases,null,2));console.log(cases.length+' candidate runs');
