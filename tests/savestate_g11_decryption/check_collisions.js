const fs=require('fs'),p=require('path'),crypto=require('crypto'),d=__dirname;
function image(file){
 const tokens=fs.readFileSync(file,'utf8').replace(/\/\/[^\n]*/g,'').trim().split(/\s+/),words=[];let address=0;
 for(const token of tokens){if(token.startsWith('@'))address=parseInt(token.slice(1),16);else {if(!/^[0-9a-f]{16}$/i.test(token))throw Error('unknown/malformed complete image '+token);words[address++]=token.toLowerCase();}}
 if(words.length!==12288||words.some(x=>!x))throw Error('incomplete v16 image');
 return {words,sha256:crypto.createHash('sha256').update(words.join('')).digest('hex')};
}
const pairs=[['joystick/mc_history_a','joystick/mc_history_b','image_save.hex'],['phase/sega_resave_even','phase/sega_resave_shift15','image_resave.hex']];
const results=[];
for(const [left,right,file]of pairs){
 const a=p.join(d,left,file),b=p.join(d,right,file);
 if(!fs.existsSync(a)||!fs.existsSync(b)){results.push({left,right,file,pending:true});continue;}
 const ia=image(a),ib=image(b),different=[];for(let n=0;n<12288;n++)if(ia.words[n]!==ib.words[n])different.push(n);
 const logA=fs.readFileSync(p.join(d,left,'replay.log'),'utf8'),logB=fs.readFileSync(p.join(d,right,'replay.log'),'utf8');
 const futureA=p.join(d,left,'reference.dat'),futureB=p.join(d,right,'reference.dat');
 const postA=p.join(d,left,'future_resave.dat'),postB=p.join(d,right,'future_resave.dat');
 results.push({left,right,file,completeKnownWords:12288,shaA:ia.sha256,shaB:ib.sha256,equalCompleteImage:!different.length,differentWords:different,acceptedHistoryA:logA.match(/G11_CAPTURE[^\n]*/g),acceptedHistoryB:logB.match(/G11_CAPTURE[^\n]*/g),equalFutureOracle:fs.existsSync(futureA)&&fs.existsSync(futureB)&&fs.readFileSync(futureA).equals(fs.readFileSync(futureB)),equalPostResaveFuture:fs.existsSync(postA)&&fs.existsSync(postB)?fs.readFileSync(postA).equals(fs.readFileSync(postB)):null,allReplaysPassed:/PASS MATRIX/.test(logA)&&/PASS MATRIX/.test(logB)});
}
fs.writeFileSync(p.join(d,'collisions_result.json'),JSON.stringify(results,null,2)+'\n');console.log(JSON.stringify(results,null,2));
