const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..');
const read=p=>fs.readFileSync(p,'utf8').replace(/\r\n/g,'\n');
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const canon=p=>crypto.createHash('sha256').update(read(p)).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']}).trim();
if(git('branch','--show-current')!=='fix/savestate-lightgun'||!git('rev-parse','HEAD').startsWith('77147af'))throw Error('Wrong branch/base');
if(git('diff','--cached','--name-only'))throw Error('Staged changes');
const changed=git('diff','--name-only').split(/\r?\n/).sort(),expected=['SMS.sv','rtl/lightgun.sv','rtl/savestates.sv'].sort();
if(JSON.stringify(changed)!==JSON.stringify(expected))throw Error('Scope '+changed);
const previous=JSON.parse(read(path.join(d,'../savestate_paddle/sources.json'))),sources={};
for(const file of Object.keys(previous)){
 const b=path.join(d,'baseline',file),old=path.join(d,'../savestate_paddle/candidate',file),cur=path.join(r,file);
 if(canon(b)!==canon(old))throw Error('Baseline differs from built committed F10 '+file);
 if(!expected.includes(file)&&canon(b)!==canon(cur))throw Error('Unrelated change '+file);
 sources[file]={baseline:sha(b),candidate:sha(cur),baselineCanonical:canon(b),candidateCanonical:canon(cur)};
}
let top=read(path.join(r,'SMS.sv')).split('\n').filter(l=>!l.includes('ss_gun')&&!l.includes('.SS_FREEZE(ss_freeze)')).join('\n');
if(top!==read(path.join(d,'baseline/SMS.sv')))throw Error('Unrelated top-level change');
const gun=read(path.join(r,'rtl/lightgun.sv')),ss=read(path.join(r,'rtl/savestates.sv'));
if(!gun.includes('if(!SS_FREEZE && CE_PIX)')||!gun.includes('if(!SS_FREEZE && HDE && VDE'))throw Error('Incomplete temporal freeze');
for(const name of ['lg_x','lg_y','old_ms','TRIGGER','cross_sz','draw','xm','xp','ym','yp','hcnt','old_vde',' x,',' y,'])if(gun.match(/assign SS_STATE_OUT =[\s\S]*?;/)[0].includes(name))throw Error('Unexpected serialized field '+name);
if(!ss.includes("GUN_EXT_MAGIC = 24'h484308")||!ss.includes("GUN_DESC = 64'h0000002e4c475538"))throw Error('Wrong format');
if(!ss.includes('gun_valid <= gun_valid && dout_latch == GUN_DESC;')||!ss.includes('gun_valid <= dout_latch[63:46] == 0;'))throw Error('Missing validation');
for(const state of ['ST_SAVE_GUN0','ST_SAVE_GUN1','ST_LOAD_GUN0','ST_LOAD_GUN1'])if((ss.match(new RegExp(state+':','g'))||[]).length!==2)throw Error('Missing command-preview/FSM pair '+state);
fs.writeFileSync(path.join(d,'sources.json'),JSON.stringify(sources,null,2)+'\n');
console.log('PASS F11 static: 136 baseline/build inputs; only SMS.sv, lightgun.sv and savestates.sv changed.');
console.log('PASS F11 46-bit state, complete temporal hold, validated v8 descriptor and payload padding.');
console.log('PASS F07 VDP/video and F02 IO unchanged; F06 mapper/storage predicates outside F11 untouched; F12-F16 untouched.');
