const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process');
const dir=__dirname,root=path.resolve(dir,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const read=p=>fs.readFileSync(path.join(root,p),'utf8'),old=read('tests/savestate_md6/baseline/rtl/sega_controller.sv'),now=read('rtl/sega_controller.sv');
const compact=s=>s.replace(/\s+/g,'');
if(compact(old.split('always @*')[1])!==compact(now.split('always @*')[1]))throw Error('Pin decode changed');
const normal=old.split('always @(posedge clk) begin')[1].split('always @*')[0].trim().replace(/end\s*$/,'');
if(!compact(now).includes(compact(normal)))throw Error('Normal protocol update changed');
for(const f of ['rtl/io.vhd','rtl/vdp.vhd','rtl/system.vhd','rtl/eeprom_93c46.vhd','SMS.qsf','files.qip'])if(read(f)!==read('tests/savestate_md6/baseline/'+f))throw Error('Scope changed '+f);
const files=cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/).sort();
if(JSON.stringify(files)!==JSON.stringify(['SMS.sv','rtl/savestates.sv','rtl/sega_controller.sv'].sort()))throw Error('Unexpected production diff');
const s=read('rtl/savestates.sv');
for(const token of ["MD_EXT_MAGIC = 24'h484303", "video_word = {MD_EXT_MAGIC, 2'd3", "{18'd0,md_snap}","dout_latch[63:46] == 0","dout_latch[39:23] < 80540","dout_latch[42:40] <= 4"])if(!s.includes(token))throw Error('Missing transport validation '+token);
// Verify the existing successful F02 build really used the complete committed
// source/settings tree. Preserve its evidence rather than rebuilding another base.
const previous=path.join(root,'tests/savestate_gg_io/candidate'),base=path.join(dir,'baseline');
function walk(d,p=''){return fs.readdirSync(path.join(d,p),{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(d,path.join(p,e.name)):[path.join(p,e.name)]);}
const names=[...walk(base,'rtl'),...walk(base,'sys'),'SMS.sv','SMS.qsf','SMS.qpf','files.qip'];
const inputs={};for(const f of names){const b=fs.readFileSync(path.join(base,f));if(!b.equals(fs.readFileSync(path.join(previous,f))))throw Error('F02 build input mismatch '+f);inputs[f.replaceAll('\\','/')]=sha(b);}
const prior=JSON.parse(read('tests/savestate_gg_io/results.json'));
const reference={commit:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),build:prior.candidate,inputs};
fs.writeFileSync(path.join(dir,'F02_reference.json'),JSON.stringify(reference,null,2));
for(const ext of ['fit','sta'])fs.copyFileSync(path.join(previous,'output_files/SMS.'+ext+'.summary'),path.join(dir,'F02_'+ext+'.summary'));
fs.writeFileSync(path.join(dir,'static.log'),`PASS: unchanged normal protocol and pin decode; only F08 production files; unchanged IO/VDP/EEPROM/settings; ${names.length} committed F02 build inputs verified.\n`);
console.log(fs.readFileSync(path.join(dir,'static.log'),'utf8'));
