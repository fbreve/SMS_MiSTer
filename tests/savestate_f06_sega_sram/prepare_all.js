// Run from repository root. Generated files stay inside this investigation.
const fs=require('fs'),cp=require('child_process'),d=__dirname;
for(const p of ['prepare.js','assemble.js','lifecycle.js'])cp.execFileSync(process.execPath,[d+'/'+p],{stdio:'inherit'});
let mapper=fs.readFileSync('rtl/mapper_ctrl.vhd','utf8').replace(/case A\(1 downto 0\) is([\s\S]*?)end case;/g,(m,b)=>'case A(1 downto 0) is'+b+'when others => null; end case;');
fs.writeFileSync(d+'/mapper_sim.vhd',mapper);
let s=fs.readFileSync(d+'/sram_tb.sv','utf8');
s=s.replace('saveimage;for(integer j=0;j<12288;j++)saved_image[j]=mem[j];','reset_n=0;repeat(3)tick;reset_n=1;repeat(3)tick;saveimage;for(integer j=0;j<12288;j++)saved_image[j]=mem[j];');
s=s.replace('saveimage;for(integer j=0;j<12288;j++)if(mem[j]!==saved_image[j])','reset_n=0;repeat(3)tick;reset_n=1;repeat(3)tick;saveimage;for(integer j=0;j<12288;j++)if(mem[j]!==saved_image[j])');
fs.writeFileSync(d+'/sram_tb.sv',s);
s=fs.readFileSync(d+'/lifecycle_tb.sv','utf8');
let decls=['wire downloading = cart_download;','reg old_downloading = 0;','reg bk_ena = 0;','reg  bk_loading = 0;','reg  bk_state   = 0;'];
for(const n of decls)s=s.replace(n,'');
s=s.replace('module lifecycle_tb;','module lifecycle_tb;\n'+decls.join('\n'))
 .replace('wire downloading = cart_download;','wire downloading;')
 .replace('task tick;','assign downloading=cart_download;\ntask tick;')
 .replace('wire reset_active=RESET|status[0]|cart_download|bk_loading|eject_rom;','wire reset_active;assign reset_active=RESET|status[0]|cart_download|bk_loading|eject_rom;');
fs.writeFileSync(d+'/lifecycle_tb.sv',s);
const pre='onerror {quit -code 1}\nonbreak {quit -code 1}\n';
const run=top=>`vsim -c -t 1ps -L altera_mf work.${top}\nset StdArithNoWarnings 1\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`;
fs.writeFileSync(d+'/run.do',pre+'vlib work\nvcom -2008 -quiet ../../rtl/dpram.vhd mapper_sim.vhd ../../rtl/memory_bus.vhd\nvlog -sv -suppress 2244 -quiet ../../rtl/opll_snapshot.sv savestates_sim.sv sram_tb.sv lifecycle_tb.sv\n'+run('sram_tb'));
fs.writeFileSync(d+'/lifecycle.do',pre+run('lifecycle_tb'));
