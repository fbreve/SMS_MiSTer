const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..'),prior=path.join(r,'tests/savestate_evolution_pending_fix');
const read=(dir,n)=>fs.readFileSync(path.join(dir,n),'utf8'),write=(n,s)=>fs.writeFileSync(path.join(d,n),s);
let ss=read(r,'rtl/savestates.sv');for(const n of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=ss.match(re)[0];ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}write('savestates_sim.sv',ss);
let cpu=read(r,'rtl/T80/T80.vhd').replace(/: work\.(T80_MCode|T80_ALU|T80_Reg)/g,': entity work.$1');
cpu=cpu.replace('DIRSet     : in', 'debug_nmi : out std_logic_vector(12 downto 0);\n        debug_old : out std_logic;\n        DIRSet     : in');
cpu=cpu.replace('\tREG <=', '\tdebug_nmi <= NMI_s & NMICycle & IntCycle & std_logic_vector(MCycle) & std_logic_vector(TState) & Prefix & IntE_FF1 & IntE_FF2;\n\tREG <=');
cpu=cpu.replace("\t\tvariable OldNMI_n : std_logic;\n\tbegin", "\t\tvariable OldNMI_n : std_logic;\n\tbegin\n        debug_old <= OldNMI_n;");
// After the ordinary edge sampler's variable assignment, expose its current
// value without changing any original statement or feeding observations back.
cpu=cpu.replace('OldNMI_n := NMI_n;', 'OldNMI_n := NMI_n;\n                debug_old <= OldNMI_n;');write('T80_observed.vhd',cpu);
let wrapper=read(r,'rtl/T80/T80s.vhd').replace(': work.T80',': entity work.T80').replace('DIRSet     : in', 'debug_nmi : out std_logic_vector(12 downto 0);\n        debug_old : out std_logic;\n        DIRSet     : in').replace('DIRSet => DIRSet,','debug_nmi => debug_nmi, debug_old => debug_old,\n            DIRSet => DIRSet,');write('T80s_observed.vhd',wrapper);
let header=read(prior,'cpu_tb.sv').split('task operation(')[0];
header=header.replace('module cpu_tb;','module nmi_tb;\nparameter EDGE=100000, WIDTH=0, SOURCE=0, PROGRAM=0, RUN=2, TARGET=360, BASE=300, SECOND=9999999, WIDTH2=0, SCHEDULE=0, INJECT=0;');
header=header.replace('reg host_turbo=0;','').replace(/task tick;[\s\S]*?endtask/, '');
header=header.replace('cycle%(host_turbo?10:15)==0','cycle%15==0');
header=header.replace("reg [31:0] io_out = '0;",'wire [31:0] io_out;').replace("reg [127:0] gg_out = '0;",'wire [127:0] gg_out;');
write('nmi_tb.sv',header+read(d,'scenario.sv.in'));
// Wire a production IO endpoint with inactive unrelated peripherals.
const raw=read(r,'rtl/io.vhd'),ports=raw.slice(raw.indexOf('Port(')+5,raw.indexOf('end io;')).replace(/--[^\n]*/g,'').split(';').map(x=>x.trim()).filter(x=>x.includes(':'));
const map={clk:'clk',ce_cpu:'(cpu_ce&&!ss_freeze)',WR_n:'io_wr',RD_n:'io_rd',A:'addr[7:0]',D_in:'data',D_out:'io_data',Pause:'pause_n',RESET_n:'mrst',gg:'effective_gg',gg_link_en:'effective_gg',gg_link_in:'link_pins',gg_link_nmi_n:'link_nmi',gg_state_out:'gg_out',gg_state_in:'gg_in',gg_state_set:'gg_set',io_state_out:'io_out',io_state_in:'io_in',io_state_set:'io_set',ss_freeze:'ss_freeze',E1Use:"1'b0",E2Use:"1'b0"};
const con=[];for(const entry of ports){const m=entry.match(/^(\w+)\s*:\s*(in|out)\s+(?:std_logic_vector\s*\(\s*(\d+)\s+downto\s+(\d+)\s*\)|std_logic)/i);if(!m)throw Error('IO port parse '+entry);const n=m[1],output=m[2].toLowerCase()==='out',w=m[3]?+m[3]-+m[4]+1:1;let v=map[n];if(v===undefined)v=output?'':(n.match(/^(J[12]_|j[12]_)/)?`${w}'d${(1<<w)-1}`:`${w}'d0`);con.push('.'+n+'('+v+')');}
write('io_instance.sv','io endpoint('+con.join(',')+');\n');
write('nmi.do',`onerror {quit -code 1}
onbreak {quit -code 1}
vlib nmi_sync_work
vcom -work nmi_sync_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd
vlog -work nmi_sync_work -sv -quiet savestates_sim.sv nmi_tb.sv
vsim -c -t 1ps -voptargs=+acc nmi_sync_work.nmi_tb -gEDGE=$env(NMI_EDGE) -gWIDTH=$env(NMI_WIDTH) -gSOURCE=$env(NMI_SOURCE) -gPROGRAM=$env(NMI_PROGRAM) -gRUN=$env(NMI_RUN) -gTARGET=$env(NMI_TARGET)
set NumericStdNoWarnings 1
run -all
quit -code 0
`);
fs.copyFileSync(path.join(prior,'sim.ps1'),path.join(d,'sim.ps1'));
console.log('Prepared production-controller/T80/video/IO NMI fixture; observation outputs only.');



