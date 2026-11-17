const fs=require('fs'),cp=require('child_process'),crypto=require('crypto'),d=__dirname;
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{encoding:'utf8'}).trim();
const base=JSON.parse(fs.readFileSync(d+'/baseline.json'));
const changes=Object.entries(base.files).filter(([p,h])=>!fs.existsSync(p)||hash(p)!==h).map(([p])=>p);
if(changes.length)throw Error('tracked source changes '+changes);
if(git('rev-parse','HEAD')!==base.head||git('branch','--show-current')!=='investigate/savestate-f06-sega-sram')throw Error('branch/head changed');
if(git('diff','--stat')||git('diff','--cached','--stat'))throw Error('tracked diff');
const build=JSON.parse(fs.readFileSync('tests/savestate_f01_opll_fix/build_final_inputs.json'));
const buildChanges=Object.entries(build.inputs).filter(([p,h])=>!fs.existsSync(p)||hash(p)!==h).map(([p])=>p);
if(buildChanges.length)throw Error('baseline build mismatch '+buildChanges);
for(const [name,marker] of [['simulation','PASS SRAM COMPLETE'],['lifecycle','PASS LIFECYCLE COMPLETE'],['identity','PASS ACTUAL RTL IDENTITIES COLLIDE']]){
 let s=fs.readFileSync(d+'/'+name+'.log','utf8');
 if(!s.includes(marker)||!s.includes('Errors: 0')||/\*\* (Fatal|Error):/.test(s))throw Error(name+' failed');
}
const log=fs.readFileSync(d+'/simulation.log','utf8'),rows=[...log.matchAll(/PASS witness (\d+) captured_bytes=(\d+) bank0_exact=(\d) bank1_exact=(\d)/g)].map(m=>({case:+m[1],capturedBytes:+m[2],bank0Exact:!!+m[3],bank1Exact:!!+m[4]}));
if(rows.length!==11||!log.includes('PASS NONINJECTIVE full98304bytes'))throw Error('missing witness');
let a=fs.readFileSync(d+'/pair_a.bin'),b=fs.readFileSync(d+'/pair_b.bin');
if(a.length!==98304||!a.equals(b))throw Error('image collision failed');
const report=fs.readFileSync(d+'/review.md','utf8');
for(let i=1;i<=54;i++)if(!report.includes('## '+i+'. '))throw Error('missing report section '+i);
const artifacts={};for(const p of fs.readdirSync(d))if(/\.(sv|vhd|js|do|md|bin|hex|log)$/.test(p)&&!p.endsWith('_console.log')&&p!=='console.log')artifacts[p]=hash(d+'/'+p);
const result={head:base.head,branch:git('branch','--show-current'),trackedFiles:Object.keys(base.files).length,trackedChanges:changes,buildInputs:Object.keys(build.inputs).length,buildInputChanges:buildChanges,witnesses:rows,collision:{bytes:a.length,sha256:hash(d+'/pair_a.bin'),differentRetainedBytes:1,futureA:'41',futureB:'42'},decision:'E. HOST ASSISTANCE REQUIRED',nextStep:'2. focused host/cartridge-identity investigation',productionFormat:17,diffStat:git('diff','--stat'),stagedDiff:git('diff','--cached','--stat'),status:git('status','--short'),artifacts};
fs.writeFileSync(d+'/evidence.json',JSON.stringify(result,null,2));
console.log('PASS 11 witnesses, full-image collision, lifecycle and actual RTL identity collision; '+result.trackedFiles+' tracked files and '+result.buildInputs+' build inputs unchanged');
