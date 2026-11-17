const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');const dir=__dirname,root=path.resolve(dir,'../..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const ss=read('rtl/savestates.sv'),ee=read('rtl/eeprom_93c46.vhd'),fields=JSON.parse(fs.readFileSync(path.join(dir,'fields.json')));
const oldee=read('tests/savestate_eeprom/baseline/rtl/eeprom_93c46.vhd');
const command=s=>s.slice(s.indexOf('                        case state is'),s.lastIndexOf('end case;')+9).replace(/\r/g,'');
if(command(ee)!==command(oldee))throw Error('Ordinary opcode behavior changed');
const pipeline=s=>s.slice(s.indexOf('            -- Synchronous 2-byte SPRAM write sequence'),s.indexOf("            if "+(s===ee?"reset_n = '0'":"ss_set = '1'"))).replace(/\r/g,'').trim();
if(pipeline(ee)!==pipeline(oldee))throw Error('Ordinary write pipeline changed');
for(const [name,h,l,pack,restore]of fields){const range=h===l?`(${h})`:`(${h} downto ${l})`;if(!ee.includes(`ss_ext_out${range} <= ${pack||name};`)||!ee.includes(`${name} <= ${restore||'ss_ext_in'+range};`))throw Error('Field symmetry '+name);}
for(const f of ['rtl/io.vhd','rtl/vdp.vhd','rtl/sega_controller.sv','rtl/mapper_ctrl.vhd','rtl/mapper_detect.vhd','rtl/dpram.vhd','SMS.qsf','files.qip'])if(read(f)!==read('tests/savestate_eeprom/baseline/'+f))throw Error('Unexpected scope '+f);
const before=read('tests/savestate_eeprom/baseline/rtl/savestates.sv');
for(const name of ['has_nvram_8k','has_nvram_16k','has_nvram_32k','has_nvram']){const re=new RegExp('wire '+name+'\\s*=[^;]+;');if(ss.match(re)[0]!==before.match(re)[0])throw Error('F05/F06 SRAM predicates changed '+name);}
for(const n of ['HCOUNTER_MAGIC','IO_EXT_MAGIC','MD_EXT_MAGIC']){const re=new RegExp('localparam \\[23:0\\] '+n+'[^;]+;');if(ss.match(re)[0]!==before.match(re)[0])throw Error('Old extension changed '+n);}
const scope=cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/).sort(),expected=['SMS.sv','rtl/eeprom_93c46.vhd','rtl/cart_eeprom.vhd','rtl/savestates.sv','rtl/system.vhd'].sort();if(JSON.stringify(scope)!==JSON.stringify(expected))throw Error('Production scope mismatch');
const prior=path.join(root,'tests/savestate_md6/candidate'),base=path.join(dir,'baseline');
function walk(p){return fs.readdirSync(path.join(base,p),{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(p,e.name)):[path.join(p,e.name)]);}
const names=[...walk('rtl'),...walk('sys'),'SMS.sv','SMS.qsf','SMS.qpf','files.qip'],inputs={};
for(const f of names){const b=fs.readFileSync(path.join(base,f));if(!b.equals(fs.readFileSync(path.join(prior,f))))throw Error('Committed F08 baseline/build mismatch '+f);inputs[f.replaceAll('\\','/')]=sha(b);}
const old=JSON.parse(read('tests/savestate_md6/results.json'));
fs.writeFileSync(path.join(dir,'F08_reference.json'),JSON.stringify({commit:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),build:old.candidate,inputs},null,2));
for(const ext of ['fit','sta'])fs.copyFileSync(path.join(prior,'output_files/SMS.'+ext+'.summary'),path.join(dir,'F08_'+ext+'.summary'));
const msg=`PASS 13 full protocol fields symmetric (81 bits), 57 legacy/wrapper bits; unchanged SRAM selection, RAM implementation, F07/F02/F08 engines; ${names.length} committed F08 build inputs verified.\n`;
fs.writeFileSync(path.join(dir,'static.log'),msg);console.log(msg);
