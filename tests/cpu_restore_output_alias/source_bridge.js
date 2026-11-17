const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname,r=p.resolve(d,'../..');
const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n'),sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const vhdl=s=>s.replace(/--[^\n]*/g,'').replace(/\s+/g,'').toLowerCase();
const rows=[];
for(const family of['g03','g10','dual','g01','nmi','pause']){
 const dir=p.join(d,'native_'+family),cpuName=['g01','nmi'].includes(family)?'T80_integrated.vhd':'T80_sim.vhd',wrapName=['g01','nmi'].includes(family)?'T80s_integrated.vhd':'T80s_sim.vhd';
 for(const[local,prod]of[[cpuName,'T80.vhd'],[wrapName,'T80s.vhd']]){
  let s=read(p.join(dir,local));s=s.replace(/: entity work\./g,': work.');
  s=s.replace(/\bdebug_(?:ctx|nmi|old)\s*:\s*out\s+(?:std_logic_vector\([^)]*\)|std_logic)\s*;/gi,'');
  s=s.replace(/^\s*debug_(?:ctx|nmi|old)\s*<=[^;]*;/gm,'');
  s=s.replace(/debug_(ctx|nmi|old)\s*=>\s*debug_\1\s*,/g,'');
  s=s.replace(/MCProbe, TSProbe:\s*out std_logic_vector\(2 downto 0\);/,'').replace(/RestartProbe:\s*out std_logic_vector\(1 downto 0\);/,'');
  s=s.replace(/MCProbe<=MCycle; TSProbe<=TState; RestartProbe<=nmi_restart;/,'');
  s=s.replace('(ioq and "000000111")','(ioq and x"7")');
  assert.equal(vhdl(s),vhdl(read(p.join(r,'rtl/T80',prod))),family+' '+prod+' production consumer identity');
  rows.push({family,file:local,sha256:sha(read(p.join(dir,local))),production:prod,bridge:'Only entity binding, read-only observation ports, and zero-extension of inherited block-IO mask for ModelSim length checking'});
 }
}
const baseline=read(p.join(r,'rtl/savestates.sv')),candidate=read(p.join(d,'candidate/rtl/savestates.sv'));
const restored=candidate.replace(/output wire(\s+\[229:0\]\s+z80_dir)/,'output reg$1').replace('assign z80_dir = z80_snap;\n','').replace('                z80_set      <= 1;','                z80_dir      <= z80_snap;\n                z80_set      <= 1;');
assert.equal(restored,baseline,'only three bounded source edits');
const inventory=require('../savestates_internal_cost_audit/inventory.json');
const evidence={passed:true,rows,baselineSHA:sha(baseline),candidateSHA:sha(candidate),sourceDelta:'output reg to wire; continuous alias; remove sole registered copy assignment',inventorySections:Object.keys(inventory),unchangedT80RegSHA:sha(fs.readFileSync(p.join(r,'rtl/T80/T80_Reg.vhd')))};
fs.writeFileSync(p.join(d,'source_bridge.json'),JSON.stringify(evidence,null,2));console.log('PASS exact current T80/T80s consumer bridges for six families; unchanged real T80_Reg; candidate only three source edits.');
