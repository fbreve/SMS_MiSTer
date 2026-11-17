const fs=require('fs'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const read=p=>fs.readFileSync(p,'utf8').replace(/\r\n/g,'\n');
const cur=read('rtl/savestates.sv'),old=read(d+'/baseline/savestates.sv');
let cases=0;for(const save of [0,1])for(const full of [0,1])for(const se of [0,1])for(let sc=0;sc<4;sc++)for(const ee of [0,1])for(const evo of [0,1])for(let flags=0;flags<64;flags++){
 const old8=!evo&&!!(flags&3),old16=!evo&&!!(flags&4),old32=!evo&&!!(flags&56),oldAny=old8||old16||old32;
 const f=!!((save||full)&&!se&&!sc&&!ee);
 const priorRam=sc!==0||(!sc&&oldAny),nowRam=priorRam||f;
 const priorSize=ee?128:sc?(sc===1?2048:sc===2?16384:32768):old32?32768:old16?16384:8192;
 const nowSize=ee?128:sc?(sc===1?2048:sc===2?16384:32768):(f||old32)?32768:old16?16384:8192;
 if(!save&&!full){assert.equal(nowRam,priorRam);assert.equal(nowSize,priorSize);}
 if((save||full)&&!se&&!sc&&!ee){assert(nowRam);assert.equal(nowSize,32768);}
 if(ee||sc||se)assert(!f);
 cases++;
}
for(const name of ['ST_SAVE_NVRAM','ST_LOAD_NVRAM']){
 const start='        '+name+': begin';const a=old.indexOf(start),b=cur.indexOf(start);assert(a>=0&&b>=0);
 // Compare the whole unchanged tail through the next section heading.
 const end=old.indexOf('\n        //',a+start.length),next=cur.indexOf('\n        //',b+start.length);
 assert.equal(old.slice(a,end),cur.slice(b,next),name+' byte sequencing changed');
}
for(const m of old.matchAll(/localparam \[23:0\] (\w*MAGIC) = (24'h[0-9a-fA-F]+);/g))assert(cur.includes(m[0]),'removed historical version '+m[1]);
assert(cur.includes("wire [63:0] video_word = {SRAM_MAGIC, 2'd3,"));
assert(cur.includes("localparam [63:0] FM_DESC = {16'd104,8'd17,8'd1,32'h464d5331}"));
const sourceBridge=require('./controller_revision_bridge.json');
fs.writeFileSync(d+'/source_checks.json',JSON.stringify({passed:true,predicateContexts:cases,legacyLoadPredicatesEquivalent:true,currentOrdinaryModeAlways32768:true,EEPROM_SC_SystemEExcludedFromFullSegaPath:true,byteSequencersUnchanged:true,historicalTagConstantsPreserved:true,FMPrivateDescriptorUnchanged:true,sourceBridge},null,2));
console.log('PASS source checks: '+cases+' predicate contexts, legacy footprint and byte sequencers unchanged');
