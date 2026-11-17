const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,adapter=require('../savestate_g06_g10_fix/controller_adapter');
const sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const canonical=s=>s.replace(/\/\/[^\n]*/g,'').replace(/\/\*[\s\S]*?\*\//g,'').replace(/\s+/g,'');
const current=adapter(p.resolve(d,'../../rtl/savestates.sv'));
const folded=canonical(current).replace('if(do_save||systeme)begincram_entry','if(do_save)begincram_entry');
const rows=[];
for(const family of ['g03','g02','g04','g10','g05','dual']){
 const dir=p.join(d,'native_'+family),src=fs.readFileSync(p.join(dir,'savestates_sim.sv'),'utf8');
 const same=canonical(src)===canonical(current);
 if(!same){
  assert.notEqual(family,'dual');assert.equal(canonical(src),folded,family+' controller');
  const tb=fs.readFileSync(p.join(dir,'vdp_tb.sv'),'utf8')+'\n'+fs.readFileSync(p.join(dir,'header.svh'),'utf8');
  const assignments=[...tb.replace(/\/\/[^\n]*/g,'').matchAll(/(?<![\w.])systeme\s*(?:=|<=)\s*([^;,\n]+)/g)].map(x=>x[1].trim());
  assert(assignments.length>0,family+' System E initialization');
  assert(assignments.every(x=>["'0",'0',"1'b0"].includes(x)),family+' nonzero owner assignment '+assignments);
  assert(!/force\s+systeme\b/.test(tb));
  rows.push({family,compiledControllerSHA:sha(src),selectedControllerSHA:sha(current),bridge:'Only additional System E LOAD branch; identical for this fixed systeme=0 fixture',systemeAssignments:assignments});
 }else rows.push({family,compiledControllerSHA:sha(src),selectedControllerSHA:sha(current),bridge:'exact selected controller'});
 // Local simulation palette adds only an unclocked, read-only full-memory tap.
 let cm=fs.readFileSync(p.join(dir,'rtl/vdp_cram.vhd'),'utf8');
 cm=cm.replace('ss_debug_out:out std_logic_vector(383 downto 0);','');
 cm=cm.replace(" debug_tap:for i in 0 to 31 generate ss_debug_out(12*i+11 downto 12*i)<=ram(i);end generate;\n",'');
 assert.equal(cm,fs.readFileSync(p.resolve(d,'../../rtl/vdp_cram.vhd'),'utf8'),family+' palette bridge');
 const vhdl=s=>s.replace(/--[^\n]*/g,'').replace(/\s+/g,'').toLowerCase();
 const stripAudit=s=>s.split('\n').filter(l=>!/^\s*(?:audit(?:_memory|_main_probe)?\s*(?::|<=|=>|\()|signal audit_main_probe:)/i.test(l)).join('\n')
  .replace(/\s*ss_cram_debug_out:out std_logic_vector\(383 downto 0\);/i,'')
  .replace(/,ss_debug_out=>ss_cram_debug_out/i,'');
 for(const file of ['vdp.vhd','vdp_main.vhd','vdp_background.vhd','vdp_sprites.vhd','vdp_sprite_shifter.vhd']){
  const local=fs.readFileSync(p.join(dir,'rtl',file),'utf8'),production=fs.readFileSync(p.resolve(d,'../../rtl',file),'utf8');
  assert.equal(vhdl(stripAudit(local)),vhdl(production),family+' '+file+' read-only instrumentation bridge');
 }
}
fs.writeFileSync(p.join(d,'source_bridge.json'),JSON.stringify({passed:true,selectedControllerSHA:sha(current),rows,note:'Native non-System-E simulations remain applicable after preserving old64 System E fallback; all System E and protocol/format runs use the selected source.'},null,2)+'\n');
console.log('PASS source bridges: five fixed-SMS/GG families, selected-source dual, and six read-only RAM taps.');
