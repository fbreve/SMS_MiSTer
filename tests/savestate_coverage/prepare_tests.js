// Windows fallback when the repository Python environment points to a removed interpreter.
const fs=require('fs'),path=require('path');
const dir=__dirname, root=path.resolve(dir,'../..');
const source=fs.readFileSync(path.join(dir,'prepare_tests.py'),'utf8');
function fixture(entity, overrides){
 const src=fs.readFileSync(path.join(root,'rtl',entity+'.vhd'),'utf8').split('architecture')[0];
 const ports=[...src.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)];
 return `entity work.${entity} port map(`+ports.map(m=>`${m[1]} => ${overrides[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'open':m[3].toLowerCase().includes('vector')?"(others=>'0')":"'0'")}`).join(',\n')+');';
}
const io=fixture('io',{clk:'clk',reset_n:'rst',ce_cpu:"'1'",wr_n:'wr',rd_n:'rd',a:'addr',d_in:'din',d_out:'dout',gg:"'1'",gg_link_en:"'1'",gg_link_in:"(others=>'1')",gg_state_out:'ggsnap',gg_state_in:'ggsaved',gg_state_set:'load',io_state_out:'snap',io_state_in:'saved',io_state_set:'load',ss_freeze:'freeze'});
const common={clk_sys:'clk',reset_n:'rst',cs_in:"'1'",clk_in:'serial',di:'din',nvram_do:'x"FF"'};
const eep1=fixture('eeprom_93c46',{...common,ss_out:'snap',ss_in:'saved',ss_set:'load',ss_ext_out:'ext',ss_ext_in:'saved_ext',ss_full:"'1'"});
const eep2=fixture('eeprom_93c46',{...common,ss_out:'ref_snap'});
for(const name of ['io_gap_tb.vhd','eeprom_gap_tb.vhd','md_gap_tb.sv']){
 const start=source.indexOf(`(out/'${name}').write_text(`);
 const end=source.indexOf("\n+",start); // content is delimited below by next write/assignment
 let chunk=source.slice(start).split("\n(out/")[0].split("\neep1=")[0].split("\ndo='''")[0];
 const parts=[...chunk.matchAll(/'''([\s\S]*?)'''/g)].map(m=>m[1]);
 let text=name.startsWith('io_')?parts[0]+io+parts[1]:name.startsWith('eeprom_')?parts[0]+eep1+'\nreference: '+eep2+parts[1]:parts[0];
 fs.writeFileSync(path.join(dir,name),text);
}
fs.writeFileSync(path.join(dir,'run.do'),source.match(/\ndo='''([\s\S]*?)'''/)[1]);
console.log('Generated three test fixtures.');
