const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'fixed_tb.sv'),'utf8').replace('module fixed_tb;','module released_tb;');
const old="begin while(cycle<ready_cycle+359+SECOND)tick;if(!accepted)begin dlevel(1);rlevel(1);end end";
if(!s.includes(old))throw Error('Second pulse anchor');
s=s.replace(old,"begin while(cycle<ready_cycle+359+SECOND)tick;if(!accepted)begin dlevel(1);rlevel(1);repeat(5)tick;dlevel(0);rlevel(0);end end");
s=s.replace('image_s%0d','released_image_s%0d');s=s.replace("if(FORMAT==123)mem['h1a][39:38]=2;","if(FORMAT>=123&&FORMAT<=125)mem['h1a][39:38]=FORMAT==123?2:FORMAT==124?0:1;");
fs.writeFileSync(path.join(d,'released_tb.sv'),s);
let script=fs.readFileSync(path.join(d,'fixed.do'),'utf8').replaceAll('fixed_work','released_work').replace('machine.sv fixed_tb.sv','machine.sv released_tb.sv').replace('released_work.fixed_tb','released_work.released_tb');fs.writeFileSync(path.join(d,'released.do'),script);
console.log('Prepared additional released-second-edge and subtype coverage on a separate library.');
