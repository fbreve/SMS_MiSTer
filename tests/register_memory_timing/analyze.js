const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const read=f=>{const b=fs.readFileSync(p.join(d,f));return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
function parse(file){
 const text=read(file),blocks=text.split(/Path #\d+: Setup slack is /).slice(1);
 return blocks.map(block=>{
  const row=key=>{const line=block.split(/\r?\n/).find(l=>l.startsWith('; '+key)&&l.split(';').length===4);return line?line.split(';')[2].trim():null;};
  const stats=block.slice(block.indexOf('; Statistics'),block.indexOf('; Data Arrival Path'));
  const section=stats.slice(stats.indexOf(';   Data '),stats.indexOf(';  Required Path'));
  const delay=key=>{const l=section.split(/\r?\n/).find(s=>new RegExp('^;    '+key+'\\s*;').test(s));return l?+l.split(';')[4].trim():0;};
  const st=key=>{const l=stats.split(/\r?\n/).find(s=>s.startsWith('; '+key));return l?+l.split(';')[2].trim():null;};
  const dataBlock=block.slice(block.indexOf('; Data Arrival Path'),block.indexOf('; Data Required Path'));
  const points=dataBlock.split(/\r?\n/).filter(l=>l.startsWith(';')&&l.split(';').length===9).map(l=>l.split(';').slice(1,-1).map(s=>s.trim()));
  const from=row('From Node'),to=row('To Node');
  return {slack:+block.split(/\s/)[0],from,to,launchClock:row('Launch Clock'),latchClock:row('Latch Clock'),arrival:+row('Data Arrival Time'),required:+row('Data Required Time'),relationship:st('Setup Relationship'),skew:st('Clock Skew'),data:st('Data Delay'),levels:(()=>{const l=stats.split(/\r?\n/).find(s=>s.startsWith('; Number of Logic Levels'));return l?+l.split(';')[3].trim():null;})(),cell:delay('Cell'),ic:delay('IC'),routingElements:delay('Routing Element'),sourceLocation:points.find(x=>x[6]===from)?.[5],destinationLocation:points.findLast(x=>x[6]===to)?.[5],adjustments:points.filter(x=>/uncertainty|pessimism|setup time|clock path/i.test(x[6])),file};
 });
}
const results={};
for(const seed of [1,2])for(const v of ['baseline','candidate']){
 const tag='seed'+seed+'_'+v,main=parse(tag+'_setup.rpt');
 const m=JSON.parse(fs.readFileSync(p.join(d,seed===1?'../register_memory_auto/results.json':'../register_memory_auto_seed2/results.json'))).builds[v];assert.equal(main[0].slack,m.setup);
 const families=Object.fromEntries(['linebuf','shadow_osd','counter','poly_lum'].map(f=>[f,parse(tag+'_'+f+'.rpt')]));
 const local=Object.fromEntries(['fm_from','fm_to','register_from','register_to','scaler_from','scaler_to'].map(f=>[f,parse(tag+'_'+f+'.rpt')]));
 for(const q of [...main,...Object.values(families).flat(),...Object.values(local).flat()])assert(Math.abs(q.data-q.cell-q.ic-q.routingElements)<0.004,'Bad delay sum '+q.file);
 results[tag]={main,families,local};
}
fs.writeFileSync(p.join(d,'path_comparison.json'),JSON.stringify(results,null,2)+'\n');
for(const [tag,r]of Object.entries(results))console.log(JSON.stringify({tag,worst:r.main[0],families:Object.fromEntries(Object.entries(r.families).map(([k,paths])=>[k,paths[0]])),local:Object.fromEntries(Object.entries(r.local).map(([k,paths])=>[k,paths[0]?.slack]))},null,2));
