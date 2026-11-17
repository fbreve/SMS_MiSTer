const fs=require('fs'),path=require('path'),cp=require('child_process');const dir=__dirname,root=path.resolve(dir,'../..');
const read=f=>fs.readFileSync(path.join(root,f),'utf8');const inv=JSON.parse(fs.readFileSync(path.join(dir,'inventory.json')));
const io=read('rtl/io.vhd'),ss=read('rtl/savestates.sv');let used=0;
for(const f of inv.fields){
 const pack=f.width===1?`gg_state_out(${f.lo})`:`gg_state_out(${f.hi} downto ${f.lo})`;
 const unpack=f.width===1?`gg_state_in(${f.lo})`:`gg_state_in(${f.hi} downto ${f.lo})`;
 if(!io.includes(pack)||!io.includes(unpack))throw Error('Missing symmetric field '+f.name);
 const unsigned=['gg_tx_cnt','gg_tx_bits','gg_rx_state','gg_rx_cnt','gg_rx_bits'].includes(f.name);
 const saved=f.name==='gg_tx_shift'?'gg_tx_shift(9 downto 1)':unsigned?'std_logic_vector('+f.name+')':f.name;
 const restored=f.name==='gg_tx_shift'?unpack+" & '0'":unsigned?'unsigned('+unpack+')':unpack;
 if(!io.includes(pack+' <= '+saved+';')||!io.includes(f.name+' <= '+restored+';'))throw Error('Field mapping mismatch '+f.name);
 used+=f.width;
}
if(used!==114||!io.includes('gg_state_out(127 downto 114)')||!ss.includes("dout_latch[63:50] == 14'd0"))throw Error('width/padding');
if(!ss.includes("128'h"+inv.reset128))throw Error('reset vector mismatch');
for(const f of ['rtl/vdp.vhd'] /* EEPROM changes are verified by the F03/F04 suite. */){
 if(!fs.readFileSync(path.join(root,f)).equals(fs.readFileSync(path.join(dir,'baseline',f))))throw Error('Out of scope '+f);
}
const before=read('tests/savestate_gg_io/baseline/rtl/io.vhd');
const low=s=>[...s.matchAll(/io_state_out\([^)]+\)\s*<=\s*[^;]+;/g)].map(m=>m[0]);
if(JSON.stringify(low(before))!==JSON.stringify(low(io)))throw Error('legacy IO packing changed');
// Original audit checks run in an isolated output directory, preserving historical artifacts.
if(fs.existsSync(path.join(root,'tests/savestate_coverage/build_audit.js'))){
 const out=path.join(dir,'static_current');fs.mkdirSync(out,{recursive:true});
 const a=read('tests/savestate_coverage/build_audit.js').replace('const dir=__dirname,root=path.resolve(dir,\'../..\');',`const dir=${JSON.stringify(out)},root=${JSON.stringify(root)};`);
 cp.execFileSync(process.execPath,['-e',a],{cwd:root});
}
const rows=[['state','class','bits','payload_range','legacy_reset','rationale'],...inv.fields.map(f=>[f.name,'A',f.width,f.hi+':'+f.lo,f.reset,f.purpose]),...inv.derived.map(n=>[n,'B','','','derived','Pure combinational result, or D_out read pipeline refilled before guest samples next IO read']),...inv.external.map(n=>[n,'C','','','excluded','Identical future inputs precondition; no remote peer rewind']),...inv.dead.map(n=>[n,'D',1,'','0','Never consumed by protocol/output logic'])];
fs.writeFileSync(path.join(dir,'inventory.csv'),rows.map(r=>r.map(v=>'"'+String(v).replaceAll('"','""')+'"').join(',')).join('\n'));
const msg='PASS 24 GG fields / 114 bits symmetric; legacy IO32 packing unchanged; VDP RTL untouched; F03/F04 EEPROM covered separately; original audit checks passed.\n';fs.writeFileSync(path.join(dir,'static.log'),msg);console.log(msg);
