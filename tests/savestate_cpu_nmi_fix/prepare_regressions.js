const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..'),ss=fs.readFileSync(path.join(d,'savestates_sim.sv'),'utf8');
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);
const cpu=fs.readFileSync(path.join(r,'rtl/T80/T80.vhd'),'utf8').replace(/: work\.(T80_MCode|T80_ALU|T80_Reg)/g,': entity work.$1'),wrapper=fs.readFileSync(path.join(r,'rtl/T80/T80s.vhd'),'utf8').replace(': work.T80',': entity work.T80');
for(const root of ['regression','regressions'])for(const p of walk(path.join(d,root))){const n=path.basename(p);if(n==='savestates_sim.sv'){fs.writeFileSync(p,ss);continue}if(n==='T80_sim.vhd'){fs.writeFileSync(p,cpu);continue}if(n==='T80s_sim.vhd'){fs.writeFileSync(p,wrapper);continue}if(!p.endsWith('.sv'))continue;
 let s=fs.readFileSync(p,'utf8');
 // Existing non-NMI benches supply the known inactive normalized triplet.
 s=s.replace(/savestates (\w+)\s*\(/g,"savestates $1(.z80_nmi(3'b001),");
 // Connect real DUT CPUs to the new production restart protocol; references
 // without DIRSet remain unchanged. Their input NMI is already tied inactive.
 s=s.replaceAll('.DIRSet(z80_set),',".NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.DIRSet(z80_set),");
 s=s.split(/\r?\n/).map(l=>{
  if(l.includes("24'h48430b")&&(l.includes('!==')||l.includes('stored extension')))return l.replaceAll("24'h48430b","24'h48430c");
  // Preserve the old test's unsupported-future-tag intent after v12 exists.
  if(l.includes("24'h48430c")&&(l.includes("mem['h1a]")||l.includes('mem[\'h1a]'))&&!l.includes('!=='))return l.replaceAll("24'h48430c","24'h48430d");
  return l;
 }).join('\n');
 fs.writeFileSync(p,s);
}
console.log('Refreshed copied regressions on current RTL; only interface/version expectations adapted.');
