const fs=require('fs'), cp=require('child_process'), crypto=require('crypto');
const dir=__dirname, root=process.cwd();
const read=p=>fs.readFileSync(p,'utf8').replace(/\r\n/g,'\n');
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const tracked=cp.execFileSync('git',['ls-files'],{encoding:'utf8'}).trim().split('\n').filter(p=>fs.existsSync(p)&&fs.statSync(p).isFile());
fs.writeFileSync(dir+'/baseline.json',JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),files:Object.fromEntries(tracked.map(p=>[p,hash(p)])),reports:Object.fromEntries(['savestate_coverage','savestate_resource_growth','savestate_f01_opll_fix','savestate_g06_sequential_architecture','savestate_format_consolidation'].map(p=>['tests/'+p+'/review.md',hash('tests/'+p+'/review.md')]))},null,2));
let controller=require('../savestate_g06_g10_fix/controller_adapter.js')('rtl/savestates.sv');
fs.writeFileSync(dir+'/savestates_sim.sv',controller);
let base=read('tests/savestate_f01_opll_fix/format/format_tb.sv');
base=base.slice(0,base.indexOf('initial begin\n for(integer i=0;i<12288'));
base=base.replace('module vdp_tb;','module sram_tb;').replace("reg [63:0] mapper_out = '0;","wire [63:0] mapper_out;")
 .replace("reg [7:0] nvram_D = '0;","wire [7:0] nvram_D;")
 .replace('savestates dut(','savestates #(.TB_FAST(1)) dut(')
 .replace('assign replay=0;','assign replay=0; assign restart_out=0;');
// Keep real controller acceptance and transport. Only the existing UI cooldown and
// the fixed post-restore presentation flush are bypassed in this component fixture.
fs.writeFileSync(dir+'/prefix.sv',base);
fs.writeFileSync(dir+'/run.do',`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib work\nvcom -2008 -quiet ../../rtl/dpram.vhd ../../rtl/mapper_ctrl.vhd ../../rtl/memory_bus.vhd\nvlog -sv -quiet savestates_sim.sv sram_tb.sv lifecycle_tb.sv\nvsim -c -t 1ps -L altera_mf work.sram_tb\nrun -all\nquit -sim\nvsim -c -t 1ps -L altera_mf work.lifecycle_tb\nrun -all\nquit -code 0\n`);
console.log('Baseline and controller fixture prepared');

