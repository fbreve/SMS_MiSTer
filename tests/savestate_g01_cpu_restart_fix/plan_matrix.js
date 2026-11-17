const fs=require('fs'),path=require('path');const d=__dirname;const read=n=>{let b=fs.readFileSync(path.join(d,n));return b.toString(b[0]===255?'utf16le':'utf8');};
const plans=[];const add=(program,offset,extra={})=>plans.push({program,offset,period:15,sys:0,signature:0,intCase:0,...extra});
const parsed={};for(let p=10;p<=26;p++){const s=read(`integrated_p${p}_o0_t15_s0_c120_sig0_i0.log`);if(!s.includes('accepted120'))throw Error('Incomplete sweep '+p);let entries=[];const re=/REQUEST_SWEEP case(\d+) cycle(\d+)[^\r\n]*[\s\S]*?CONTEXT pre([\da-f]+) class(\d+)[\s\S]*?ACCEPT_REG BC([\da-f]+) DE([\da-f]+) HL([\da-f]+)[^\r\n]*[\s\S]*?ACCEPT program\d+[^\r\n]*cycle(\d+) PC([\da-f]+)/g;for(const m of s.matchAll(re))entries.push({requestCycle:+m[2],context:+m[4],bc:parseInt(m[5],16),acceptedCycle:+m[8],pc:parseInt(m[9],16),rawContext:m[3]});if(entries.length!==120)throw Error('Parse '+p);parsed[p]=entries;}
const target={10:[1,0x123],11:[2,0x123],12:[3,0x121],13:[4,0x121],14:[3,0x125],15:[4,0x125],16:[5,0x121],26:[3,0x121]};
for(const[p,[context,pc]]of Object.entries(target)){const e=parsed[p].find(e=>e.context===context&&e.pc===pc);if(!e)throw Error('Missing context '+p);add(+p,e.requestCycle-169502,{expectedContext:context,family:'prefix'});}
for(let p=18;p<=25;p++){for(const count of[3,2,1]){const bc=p>=22?(count<<8)|0x7c:count,e=parsed[p].find(e=>e.pc===0x139&&e.bc===bc);if(!e)throw Error('Missing block count '+p+'/'+bc.toString(16));add(p,e.requestCycle-169502,{expectedBC:bc,expectedContext:2,family:count===3?'block-first':count===2?'block-middle':'block-terminal'});}}
for(const offset of[0,600,1200,2400])add(17,offset,{family:'ordinary'});
for(const intCase of[0,1,2,3,4])add(28,840,{intCase,family:'EI'});
for(const offset of[0,700,1000])add(29,offset,{family:'HALT-inactive'});
add(30,1000,{intCase:2,family:'HALT-INT'});add(30,1000,{intCase:1,family:'HALT-pending-INT'});add(31,1000,{family:'HALT-NMI'});
add(18,1968,{period:10,family:'turbo-block'});add(18,1968,{period:10,sys:1,family:'SystemE-block'});add(28,840,{period:10,sys:1,intCase:1,family:'SystemE-EI'});
// Original mapper-integrated witnesses and explicit persistent guest observers.
add(4,1056,{family:'original-normal'});add(4,800,{period:10,family:'original-turbo'});
add(4,1056,{signature:1,family:'original-observer-normal'});add(4,800,{period:10,signature:1,family:'original-observer-turbo'});
add(0,1200,{family:'G09-last-read'});add(9,3100,{family:'G09-HALT-NMI'});
fs.writeFileSync(path.join(d,'matrix.json'),JSON.stringify(plans,null,2));fs.writeFileSync(path.join(d,'accepted_sweeps.json'),JSON.stringify(parsed,null,2));console.log('Planned '+plans.length+' full integration cases from 2040 accepted sweep observations.');
