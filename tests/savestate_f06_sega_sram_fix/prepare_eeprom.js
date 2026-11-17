const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'eeprom');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(d,'../savestate_eeprom/integration_tb.sv'),'utf8');
const endpoints=`savestates #(.TB_FAST(1)) dut(.fm_initialized(1'b1),.fm_state_rdata(32'd0),
 .z80_nmi(3'b001),.z80_restart(3'd0),.z80_tick_active(1'b1),.z80_replay(1'b0),
 .clock_phase(2'd0),.clock_phase_ready(1'b1),.mapper_history_out(18'h0ffff),
 .sprite_out(4778'd0),.sprite2_out(4778'd0),.bg_out(139'd0),.bg2_out(139'd0),`;
s=s.replace('savestates dut(',endpoints).replaceAll("24'h484308","24'h484312");
s=s.replace('if(CASE_ONLY>=0 && CASE_ONLY!=k)continue;','if(CASE_ONLY>=0 && CASE_ONLY!=k)continue;\n if(!((k<4&&k!=2)||(k>=10&&k<=12)||k==17||k==18))continue;');
s=s.replace('reg [95:0] evolution_out', 'reg [159:0] evolution_out').replace('wire [95:0] evolution_in', 'wire [159:0] evolution_in');
fs.writeFileSync(p.join(dst,'integration_tb.sv'),s);
fs.writeFileSync(p.join(dst,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')('rtl/savestates.sv'));
fs.copyFileSync(p.join(d,'../savestate_eeprom/replay.sv'),p.join(dst,'replay.sv'));
fs.writeFileSync(p.join(dst,'compile.do'),'onerror {quit -code 1}\nvlib work\nvcom -2008 -quiet ../../../rtl/dpram.vhd ../../../rtl/eeprom_93c46.vhd ../../../rtl/cart_eeprom.vhd\nvlog -sv -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv integration_tb.sv replay.sv\nquit -code 0\n');
for(const stall of [0,2])fs.writeFileSync(p.join(dst,'run'+stall+'.do'),`onerror {quit -code 1}\nvsim -c -t 1ps -L altera_mf -gSTALL=${stall} work.ee_integration\nset StdArithNoWarnings 1\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);
fs.writeFileSync(p.join(dst,'replay.do'),'onerror {quit -code 1}\nvsim -c -t 1ps work.replay\nrun -all\nquit -code 0\n');
