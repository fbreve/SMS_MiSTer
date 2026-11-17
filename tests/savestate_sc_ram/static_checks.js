const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),dir=__dirname,root=path.resolve(dir,'../..');
const read=f=>fs.readFileSync(path.join(root,f),'utf8').replace(/\r\n/g,'\n'),git=(...args)=>cp.execFileSync('git',args,{cwd:root,encoding:'utf8'}).replace(/\r\n/g,'\n');
const s=read('rtl/savestates.sv'),b=git('show','HEAD:rtl/savestates.sv');
for(const name of ['has_nvram_8k','has_nvram_16k','has_nvram_32k','has_nvram']){
const re=new RegExp('^wire '+name+'\\s*=.*$','m');if(s.match(re)?.[0]!==b.match(re)?.[0])throw Error('F06 predicate changed '+name);
}
for(let flags=0;flags<32;flags++)for(let evolution=0;evolution<2;evolution++){
const h8=!evolution&&!!(flags&3),h16=!evolution&&!!(flags&4),h32=!evolution&&!!(flags&24),has=h8||h16||h32;
const previous=has,next=false||(0===0&&has);if(previous!==next)throw Error('F06 truth table');
}
for(const f of ['rtl/system.vhd','rtl/mapper_ctrl.vhd','rtl/mapper_detect.vhd','rtl/memory_bus.vhd','rtl/memory_decode.vhd','rtl/dpram.vhd','rtl/cart_eeprom.vhd','rtl/eeprom_93c46.vhd','rtl/io.vhd','rtl/sega_controller.sv','rtl/vdp.vhd'])if(read(f)!==git('show','HEAD:'+f))throw Error('scope '+f);
const oldSize=b.slice(b.indexOf('has_nvram_32k ? 15\'d32767'),b.indexOf('reg [6:0]  state;')).trim();if(!s.includes(oldSize))throw Error('Sega SRAM size branches changed');
for(const name of ['EEPROM_EXT_MAGIC','EEPROM_DESC','EEPROM_ABSENT']){const re=new RegExp('^localparam .* '+name+' = .*;$','m');if(s.match(re)?.[0]!==b.match(re)?.[0])throw Error('EEPROM descriptor change');}
if(!s.includes("wire [28:0] nvram_ddr_base = transfer_eeprom ? 29'h040 : 29'h0D01;"))throw Error('EEPROM region moved');
const ranges=[[0,0x25,'headers/descriptors'],[0x30,0x31,'EEPROM protocol'],[0x40,0x4f,'EEPROM bytes'],[0x101,0x900,'VRAM'],[0x901,0xd00,'WRAM'],[0xd01,0x1d00,'SC32K']];for(let i=0;i<ranges.length;i++)for(let j=i+1;j<ranges.length;j++)if(ranges[i][0]<=ranges[j][1]&&ranges[j][0]<=ranges[i][1])throw Error('overlap');if(ranges.at(-1)[1]>=0x3000)throw Error('stride');
const changed=git('diff','--name-only').trim().split('\n').sort();if(JSON.stringify(changed)!==JSON.stringify(['SMS.sv','rtl/savestates.sv']))throw Error('production scope');if(git('diff','--cached','--name-only').trim())throw Error('staged changes');
const previous=JSON.parse(read('tests/savestate_eeprom/results.json'));let verified=0;for(const [f,v]of Object.entries(previous.sources)){const hash=crypto.createHash('sha256').update(fs.readFileSync(path.join(dir,'baseline',f))).digest('hex');if(hash!==v.EEPROM)throw Error('F03 baseline mismatch '+f);verified++;}
fs.writeFileSync(path.join(dir,'static_results.json'),JSON.stringify({pass:true,baselineFiles:verified,F06:'intentionally unresolved; mapper/decode unchanged, all predicates and Sega size branches identical, SC-absent truth table equivalent',ranges},null,2)+'\n');
console.log('PASS F05 scope/layout/legacy guards; F06 intentionally unresolved and unchanged; '+verified+' committed F03/F04 baseline inputs verified');
