const fs=require('fs'),path=require('path');const d=__dirname,r=path.resolve(d,'../..'),out=path.join(d,'regression'),old=path.resolve(d,'../savestate_g09_last_read/regression');fs.mkdirSync(out,{recursive:true});
const read=p=>fs.readFileSync(p,'utf8').replace(/\r\n/g,'\n');
for(const name of fs.readdirSync(old)){if(!/\.(sv|vhd|do|ps1|mif)$/.test(name)||name.endsWith('.sim.do'))continue;let p=path.join(old,name);if(!fs.statSync(p).isFile())continue;let s=read(p);if(name.endsWith('.sv'))s=s.replace(/savestates (\w+)\(/g,"savestates $1(.z80_restart(3'd0),");fs.writeFileSync(path.join(out,name),s);}
const cpu=read(path.join(r,'rtl/T80/T80.vhd')).replace(/: work\.(T80_MCode|T80_ALU|T80_Reg)/g,': entity work.$1');const wrap=read(path.join(r,'rtl/T80/T80s.vhd')).replace(': work.T80',': entity work.T80');
fs.writeFileSync(path.join(out,'T80_sim.vhd'),cpu);fs.writeFileSync(path.join(out,'T80s_sim.vhd'),wrap);fs.copyFileSync(path.join(d,'savestates_integrated.sv'),path.join(out,'savestates_sim.sv'));
let tb=read(path.join(out,'cpu_tb.sv')).replace("savestates dut(.z80_restart(3'd0),",'wire[2:0]restart_out;\nsavestates dut(.z80_restart(restart_out),').replace('.DIRSet(z80_set)', '.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set)');fs.writeFileSync(path.join(out,'cpu_tb.sv'),tb);
let f13=read(path.join(out,'f13_history_tb.sv')).replace("24'h48430c","24'h48430d");fs.writeFileSync(path.join(out,'f13_history_tb.sv'),f13);
fs.copyFileSync(path.join(r,'tests/savestate_cpu_nmi_fix/sim.ps1'),path.join(out,'sim.ps1'));
const pause=path.join(out,'pause'),prior=path.join(r,'tests/savestate_cpu_nmi_fix/regression/pause');fs.mkdirSync(pause,{recursive:true});
for(const name of fs.readdirSync(prior)){if(!/\.(sv|vhd|do|mif)$/.test(name)||name.endsWith('.sim.do'))continue;const p=path.join(prior,name);if(fs.statSync(p).isFile())fs.copyFileSync(p,path.join(pause,name));}
fs.writeFileSync(path.join(pause,'T80_sim.vhd'),cpu);fs.writeFileSync(path.join(pause,'T80s_sim.vhd'),wrap);fs.copyFileSync(path.join(d,'savestates_integrated.sv'),path.join(pause,'savestates_sim.sv'));
let pt=read(path.join(pause,'fixed_tb.sv')).replace('savestates dut(', 'wire[2:0]restart_out;\nsavestates dut(.z80_restart(restart_out),').replace('.DIRSet(z80_set)', '.RestartContext(restart_out),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set)');fs.writeFileSync(path.join(pause,'fixed_tb.sv'),pt);
console.log('Prepared current G01/F16 source regressions: Evolution, detection, paused CPU/PSG.');
