const fs=require('fs'),cp=require('child_process'),p=require('path'),root=p.resolve(__dirname,'../..'),d=p.resolve(process.argv[2]);
fs.mkdirSync(d,{recursive:true});
const base=cp.execFileSync('git',['show','ab09fdf41221c9e3e77eee87264a125ba43021fe:rtl/savestates.sv'],{cwd:root,encoding:'utf8'}),cand=cp.execFileSync('git',['show','28ead01f7f8709ddda5dc4a63206b9921cb757e0:rtl/savestates.sv'],{cwd:root,encoding:'utf8'});
for(const [n,src] of [['baseline',base],['candidate',cand]]){
 let s=src;for(const name of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+name+';\\r?\\n','m'),m=s.match(re);if(m)s=s.replace(re,'').replace('// NVRAM size calculation helpers',m[0]+'// NVRAM size calculation helpers');}
 fs.writeFileSync(p.join(d,'controller_'+n+'.sv'),s.replace('module savestates (','module savestates_'+n+' ('));
}
let tb=fs.readFileSync(p.join(__dirname,'fixtures/regression_tb.sv'),'utf8').replace(/^\uFEFF/,'');
fs.writeFileSync(p.join(d,'existing_tb.sv'),tb);
let directed=tb.replace('module savestate_tb;','module directed_tb;').replaceAll('testcase<8','testcase<24').replaceAll('loads!=8||operations!=16','loads!=24||operations!=48');
directed=directed.replace('DDRAM_BUSY=stalls&&(cycles%97<5);',`DDRAM_BUSY=(cycles%41<13)||(cycles%137<23);
 vram_D=(cycles*37)^8'h91;vram2_D=(cycles*53)^8'h42;wram_D=(cycles*71)^8'hc3;nvram_D=(cycles*97)^8'h24;`);
directed=directed.replace("mapper_out=systeme?64'h60:64'h1000000000000;", "mapper_out=systeme?((testcase/2)%4)*64'h40:64'h1000000000000;");
directed=directed.replace(' $finish;', ' $display("PASS directed accepted_data_address_equivalence"); $finish;');
// Compare all outputs already in the fixture, including held DDR payloads; verify at receiving edge too.
directed=directed.replace(' DDRAM_DOUT_READY<=0;',` if({DDRAM_WE_a,DDRAM_RD_a,DDRAM_ADDR_a,DDRAM_DIN_a,DDRAM_BE_a}!=={DDRAM_WE_b,DDRAM_RD_b,DDRAM_ADDR_b,DDRAM_DIN_b,DDRAM_BE_b})$fatal(1,"receiving edge mismatch");
 DDRAM_DOUT_READY<=0;`);
fs.writeFileSync(p.join(d,'directed_tb.sv'),directed);
