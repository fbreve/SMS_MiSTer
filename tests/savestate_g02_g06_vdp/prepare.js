const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const dir=__dirname,root=p.resolve(dir,'../..');
const read=f=>fs.readFileSync(p.join(root,f),'utf8').replace(/\r\n/g,'\n');
const write=(f,s)=>fs.writeFileSync(p.join(dir,f),s);
let ctrl=read('rtl/savestates.sv');
for(const name of ['mapper_snap','evolution_snap','mapper_history_snap']) {
 const re=new RegExp('^[ \\t]*reg[^;\\n]*\\b'+name+'\\b[^;\\n]*;[^\\n]*\\n','m');
 const m=ctrl.match(re);if(m){ctrl=ctrl.replace(re,'');ctrl=ctrl.replace(/(\n\);)/,'$1\n'+m[0]);}
}
write('savestates_sim.sv',ctrl);
for(const f of ['T80','T80s'])write(f+'_sim.vhd',read('rtl/T80/'+f+'.vhd').replace(/: work\./g,': entity work.'));
let vdp=read('rtl/vdp.vhd');
vdp=vdp.replace('ss_regs_out    : out','probe : out std_logic_vector(31 downto 0);\n\t\tss_regs_out    : out');
vdp=vdp.replace('begin\n\t','begin\n probe <= xspr_collide_shift & spr_collide & spr_overflow & old_RD_n & old_WR_n & old_HL & old_WR_direct & cpu_write_data & data_write & xram_cpu_A_incr & "00";\n\t');
// 14+1+1+4+8+1+1+2=32, observation only.
write('vdp_sim.vhd',vdp);
let header=read('tests/savestate_g01_cpu_restart_fix/regression/pause/fixed_tb.sv').split('always #5')[0];
header=header.replace(/module pause_tb;[^\n]*/, 'module vdp_tb; parameter GG=1,PAL=0,REQUEST_X=40,SPRITE_X=120,SPRITES=2,REPLAYS=3,REFERENCE=0;');
header=header.replace(/reg \[383:0\] cram_out = '0;/,'wire [383:0] cram_out;').replace(/reg \[7:0\] vram_D = '0;/,'wire [7:0] vram_D;').replace(/reg \[7:0\] wram_D = '0;/,'wire [7:0] wram_D;');
header=header.replace(/\[95:0\] evolution_out/g,'[159:0] evolution_out').replace(/\[95:0\] evolution_in/g,'[159:0] evolution_in');
write('header.svh',header);
let rom=Array(65536).fill(0),a=0;const emit=(...b)=>b.forEach(x=>rom[a++]=x);
emit(0xf3,0x31,0xf0,0xdf,0xaf,0x01,0,0,0x11,0,0,0x21,0,0,0x08,0xaf,0x08,0xd9,0x01,0,0,0x11,0,0,0x21,0,0,0xd9,0xdd,0x21,0,0,0xfd,0x21,0,0,0xed,0x47,0xed,0x4f);
for(const [r,v] of [[0,4],[1,0x40],[2,14],[3,0xff],[4,0],[5,0x7e],[6,4],[7,3],[8,5],[9,0],[10,0xff]])emit(0x3e,v,0xd3,0xbf,0x3e,0x80|r,0xd3,0xbf);
// Legal GG low-CRAM-byte write initializes the persistent low-byte/read latch.
emit(0xaf,0xd3,0xbf,0x3e,0xc0,0xd3,0xbf,0x3e,0x53,0xd3,0xbe);
const loop=a;emit(0xdb,0xbf,0x32,0x00,0xc1,0xc3,loop&255,loop>>8);
write('rom.hex',rom.map(v=>v.toString(16).padStart(2,'0')).join('\n')+'\n');
write('rom.json',JSON.stringify({loop,bytes:rom.slice(0,a)},null,2));
write('compile.do',`onerror {quit -code 1}
onbreak {quit -code 1}
vlib vdp_work
vcom -work vdp_work -2008 -quiet ../../rtl/video.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd ../../rtl/dpram.vhd ../../rtl/vdp_cram.vhd ../../rtl/vdp_background.vhd ../../rtl/vdp_sprite_shifter.vhd ../../rtl/vdp_sprites.vhd ../../rtl/vdp_main.vhd vdp_sim.vhd
vlog -work vdp_work -sv -quiet savestates_sim.sv vdp_tb.sv
quit -code 0
`);
write('run.do',`onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gREFERENCE=$env(VDP_REFERENCE) -gGG=$env(VDP_GG) -gPAL=$env(VDP_PAL) -gREQUEST_X=$env(VDP_REQUEST_X) -gSPRITE_X=$env(VDP_SPRITE_X) -gSPRITES=$env(VDP_SPRITES) -gREPLAYS=$env(VDP_REPLAYS) -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
const files=cp.execFileSync('git',['ls-files'],{cwd:root,encoding:'utf8'}).trim().split('\n');
const hashes={};for(const f of files){const q=p.join(root,f);if(fs.existsSync(q)&&fs.statSync(q).isFile())hashes[f]=crypto.createHash('sha256').update(fs.readFileSync(q)).digest('hex');}
write('baseline.json',JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),hashes},null,2));
