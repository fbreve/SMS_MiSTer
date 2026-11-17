const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,exe='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe';
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function hexMemory(file,count){
 const words=new Array(count);let at=0;
 for(let line of fs.readFileSync(file,'utf8').split(/\r?\n/)){
  line=line.replace(/\/\/.*$/,'').trim();if(!line)continue;
  const named=line.match(/^([0-9a-f]+):\s*(.*)$/i);if(named){at=parseInt(named[1],16);line=named[2];}
  for(const token of line.split(/\s+/).filter(Boolean)){
   if(token.startsWith('@'))at=parseInt(token.slice(1),16);
   else {assert(/^[0-9a-f]+$/i.test(token),'unknown memory token');words[at++]=BigInt('0x'+token);}
  }
 }
 assert.equal(words.length,count);assert(!words.includes(undefined),'incomplete memory');return words;
}
const seedLog=fs.readFileSync(p.join(d,'seed_cold_reference.log'),'utf8');
assert(seedLog.includes('SEED_READY'),'qualified seed has not been exported yet');
assert(fs.readFileSync(p.join(d,'seed_boot150.mem')).equals(fs.readFileSync(p.join(d,'../discovery_boot150.mem'))),'cold playable-scene memory reproduction failed');
assert(fs.readFileSync(p.join(d,'seed_boot150.ppm')).equals(fs.readFileSync(p.join(d,'../discovery_boot150.ppm'))),'cold playable-scene pixels were not reproduced');
const slotFile=p.join(d,'seed_slot.hex'),sramFile=p.join(d,'seed_sram.hex');
const slot=hexMemory(slotFile,12288),physical=hexMemory(sramFile,32768),raw=Buffer.from(physical.map(Number));
const saved=fs.readFileSync(p.join(d,'seed_saved.mem'));
assert.equal(slot[1]>>32n,0xa458e3d4n);assert.equal(slot[1]&0xffffffffn,0x534d5331n);
assert.equal(slot[0]>>32n,24574n);assert.equal(slot[5]>>38n,0n);
assert(raw.equals(saved.subarray(40960)),'separate physical SRAM fixture differs from captured SRAM');
for(let n=0;n<16384;n++)assert.equal(Number(slot[0x101+(n>>3)]>>BigInt((n&7)*8)&255n),saved[n]);
for(let n=0;n<8192;n++)assert.equal(Number(slot[0x901+(n>>3)]>>BigInt((n&7)*8)&255n),saved[32768+n]);
const snapshotLine=seedLog.match(/SAVE_METADATA[^\r\n]+/)[0];assert(snapshotLine.endsWith('context=0'),'ordinary predecessor required for common legacy fixture');
fs.writeFileSync(p.join(d,'seed_manifest.json'),JSON.stringify({ROM:'standard USA/Europe/Brazil',ROM_SHA256:'02e9404e81bddd4ca21fef2b2711dfe562c3bd7b230bf042df3142362e29a6a9',slotSHA256:sha(fs.readFileSync(slotFile)),separatePhysicalSRAMSHA256:sha(raw),SRAMHexFileSHA256:sha(fs.readFileSync(sramFile)),snapshotLine,slotHasCompleteSRAM:false,fixture:'Actual master controller slot plus explicitly separate physical SRAM initialized once during fixture bootstrap freeze. No old tail is treated as complete; each run generates its own test SAVE.',checks:'Owner, size, ordinary context, VRAM16K, WRAM8K and all physical SRAM verified'},null,2)+'\n');
const plans=[{name:'baseline',candidate:0,reference:0,sham:0},{name:'sram',candidate:2,reference:0,sham:0},{name:'reference',candidate:0,reference:1,sham:0},{name:'context',candidate:1,reference:0,sham:0},{name:'sham',candidate:2,reference:0,sham:1}];
for(const q of plans)q.name='r_'+q.name;
const rom=JSON.parse(fs.readFileSync(p.join(d,'../rom_owner_results.json'))).results[0].path;
let active=0,next=0,finished=0,failed=false;const results=[];
function persist(){fs.writeFileSync(p.join(d,'reset_run_status.json'),JSON.stringify({scope:'Native controller map-level candidates; visual/trace analysis required before any PASS',results},null,2)+'\n');}
function launch(){while(!failed&&active<5&&next<plans.length){
 const q=plans[next++],log=q.name+'_map.log';assert(!fs.existsSync(p.join(d,log)),'refusing to overwrite '+log);
 active++;const record={...q,log,status:'running',startedUTC:new Date().toISOString()};results.push(record);persist();
 const child=cp.spawn(exe,['-c','-do','reset.do','-l',log],{cwd:d,env:{...process.env,YS_ROM:rom,YS_OUT:q.name,YS_CANDIDATE:String(q.candidate),YS_REFERENCE:String(q.reference),YS_SHAM:String(q.sham),YS_SLOT:slotFile,YS_SRAM:sramFile},stdio:'ignore',windowsHide:true});
 record.pid=child.pid;persist();console.log('START',q.name,'pid',child.pid);
 child.on('exit',code=>{active--;finished++;const text=fs.existsSync(p.join(d,log))?fs.readFileSync(p.join(d,log),'utf8'):'';record.exitCode=code;record.finishedUTC=new Date().toISOString();record.status=code===0&&text.includes('COMPLETE movement sequence')&&!/\*\* (Fatal|Error)/.test(text)?'completed_pending_analysis':'failed_or_incomplete';
  if(record.status==='failed_or_incomplete')failed=true;persist();console.log('END',q.name,record.status);launch();if(finished===plans.length||(failed&&active===0)){process.exitCode=failed?1:0;}
 });
}}
launch();
