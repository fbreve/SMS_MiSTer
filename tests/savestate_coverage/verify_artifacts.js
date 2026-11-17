const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process');
const dir=__dirname,root=path.resolve(dir,'../..');
const hashes=JSON.parse(fs.readFileSync(path.join(dir,'source_hashes.json')));
for(const [file,want] of Object.entries(hashes.files)){
 const got=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,file))).digest('hex');
 if(got!==want)throw Error('Production source changed: '+file);
}
if(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim()!==hashes.head)throw Error('HEAD changed');
cp.execFileSync('git',['diff','--exit-code','--','SMS.sv','rtl','files.qip'],{cwd:root});
const sim=fs.readFileSync(path.join(dir,'simulation.log'),'utf8');
for(const name of ['io_gap_tb','eeprom_gap_tb','md_gap_tb'])if(!sim.includes('PASS '+name))throw Error('Missing test '+name);
const psg=fs.readFileSync(path.join(dir,'psg.log'),'utf8');
if(!psg.includes('PASS PSG replay: 128 cases, 8 noise controls, all 16 divider phases'))throw Error('Missing PSG result');
if(/\*\* (Failure|Fatal|Error)/.test(sim+psg))throw Error('Simulation error in logs');
const counts=JSON.parse(fs.readFileSync(path.join(dir,'counts.json')));
if(Object.values(counts.classification).reduce((a,b)=>a+b,0)!==counts.groups)throw Error('Count mismatch');
const msg=`PASS: ${Object.keys(hashes.files).length} production file hashes unchanged; clean tracked production diff; 3 defect reproductions; 128 PSG replay cases; ${counts.groups} classified groups.\n`;
fs.writeFileSync(path.join(dir,'verification.txt'),msg+'git status --short:\n'+cp.execFileSync('git',['status','--short'],{cwd:root,encoding:'utf8'}));
console.log(msg);
