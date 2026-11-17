const fs=require('fs'),path=require('path');
const d=__dirname,r=path.resolve(d,'../..'),old=path.join(r,'tests/savestate_evolution_selector_fix');
const read=(p,n)=>fs.readFileSync(path.join(p,n),'utf8'),write=(n,s)=>fs.writeFileSync(path.join(d,n),s);
// Observation-only ports: no assignments or conditions in the functional
// production process are changed. These ports never feed back into the DUT.
let evo=read(r,'rtl/evolution_mapper.vhd');
evo=evo.replace('ss_set      : in', 'debug_phase : out std_logic_vector(5 downto 0);\n        ss_set      : in');
evo=evo.replace('    process(clk)', "    debug_phase <= switch_pending & switch_armed & record_read_pending_r & menu_launch_armed_r & old_m1_n & game_launch_r;\n    process(clk)");
write('evolution_observed.vhd',evo);
let machine=read(old,'evolution_machine.sv').replace('output launch);','output launch,output[5:0]phase);').replace('.ss_in(ein)', '.debug_phase(phase),.ss_in(ein)');write('evolution_machine.sv',machine);
let ss=read(r,'rtl/savestates.sv');for(const n of ['mapper_snap','evolution_snap']){let re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=ss.match(re)[0];ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}write('savestates_sim.sv',ss);
for(const n of ['T80_sim.vhd','T80s_sim.vhd'])write(n,read(old,n));
let cpu=read(old,'cpu_tb.sv');
cpu=cpu.replace('parameter CASE=0;', 'parameter CASE=0; parameter OFFSET=0;');
cpu=cpu.replace('wire launch;', 'wire launch;wire[5:0]phase;').replace('.launch(launch));','.launch(launch),.phase(phase));');
// A single launch, then the physical-page byte read. JP and data-read loop
// are mirrored in every Flash page; only data at 8123 distinguishes mapping.
cpu=cpu.replace("14:rom=8'h10", "14:rom=8'h20");
cpu=cpu.replace('integer accepts=0,guest_reads=0;', 'integer accepts=0,guest_reads=0;integer accepted_cycle=0;reg[5:0]accepted_phase;reg[159:0]savedextra;reg[63:0]savedmap;');
cpu=cpu.replace('accepts=accepts+1;', 'begin accepts=accepts+1;accepted_cycle=cycle;accepted_phase=phase;$display("ACCEPT op%0d cycle%0d phase=%b A=%h M1=%b MREQ=%b RD=%b WR=%b CPU=%h",accepts,cycle,phase,addr,z80_m1_n,mreq,rd,wr,z80_reg);end');
cpu=cpu.replace("(stage<2&&data!==8'h28)||(stage>=2&&data!==8'h28)", "(stage==0&&data!==8'h28)||(stage==2&&data!==(accepted_saved_armed?8'h00:8'h28))");
cpu=cpu.replace('integer accepts=0', 'reg accepted_saved_armed;\ninteger accepts=0');
cpu=cpu.replace('tick;if(saving)ss_save=1;else ss_load=1;tick;', 'tick;if(saving)ss_save=1;else ss_load=1;$display("OP_REQUEST saving%0d cycle%0d phase=%b A=%h M1=%b MREQ=%b RD=%b WR=%b",saving,cycle,phase,addr,z80_m1_n,mreq,rd,wr);tick;');
cpu=cpu.replace('initial begin\n repeat(4)tick;reset_n=1;', 'initial begin\n repeat(4)tick;reset_n=1;');
let start=cpu.indexOf(' while(!(vblank&&x<64))'),end=cpu.indexOf('\nend\ninitial begin repeat(6000000)',start);
cpu=cpu.slice(0,start)+`
 while(!(vblank&&x<64))tick;mrst=1;
 if(OFFSET<0)begin wait(!z80_m1_n&&!mreq&&addr==16'h000a);repeat(-OFFSET-1)tick;end
 else begin wait(!wr&&!mreq&&addr==16'h3ffe);repeat(OFFSET)tick;end
 $display("REQUEST cycle%0d offset%0d phase=%b A=%h M1=%b MREQ=%b WR=%b",cycle,OFFSET,phase,addr,z80_m1_n,mreq,wr);
 if(CASE==1)begin wait(guest_data==8'h28);$display("PASS F15 uninterrupted real T80 Flash288123 DI28");$finish;end
 operation(1);accepted_saved_armed=accepted_phase[4];savedextra={mem['h2c],mem['h1b],mem['h19][63:32]};savedmap=mem['hf];
 $display("V10 map=%h extra=%h cpu=%h_%h_%h_%h",savedmap,savedextra,mem[5],mem[4],mem[3],mem[2]);
 wait(guest_data==8'h28);$display("SAVE_ONLY PASS reference CPU8123 Flash288123 DI28 acceptedPhase=%b",accepted_phase);
 for(integer iteration=0;iteration<(OFFSET==0?3:1);iteration=iteration+1)begin
  stage=1;repeat(300+iteration*71)tick;operation(0);stage=2;first_after=0;
  wait(first_after);repeat(200)tick;
  $display("REPLAY iteration%0d phase=%b game=%h mode=%h physical=%h guest=%h",iteration,phase,game,mode,physical,guest_data);
 end
 if(accepted_saved_armed)begin if(mode!==0||game!==0)$fatal(1,"expected lost pending commit");end
 else if(mode!==8'h87||game!==16'h2800)$fatal(1,"completed control failed");
 $display("PASS F15 real T80 OFFSET%0d vulnerable=%0d accepted=%0d",OFFSET,accepted_saved_armed,accepts);$finish;`+cpu.slice(end);
// Restore-edge checks isolate omitted protocol flags from exact saved F14 data.
cpu=cpu.replace('always @(posedge clk)begin\n if(dut.state', `always @(posedge clk)begin
 if(evolution_set)begin #1;if(evolution_out!==evolution_in||mapper_out!==mapper_in)$fatal(1,"F14/mapper restore mismatch");$display("RESTORE exact F14=%h phase=%b",evolution_out[152:96],phase);end
 if(dut.state`);
write('cpu_tb.sv',cpu.replace('repeat(6000000)tick','repeat(10000000)tick'));
cpu=cpu.replace('always @(posedge clk)begin\n if(evolution_set)', 'always @(posedge clk)begin\n if(cpu_ce&&!ss_freeze&&mrst&&!first_before)$display("CE A=%h BUS=%b%b%b%b%b phase=%b extra=%h map=%h Flash=%h DI=%h CPU=%h",addr,z80_m1_n,mreq,iq,rd,wr,phase,evolution_out,mapper_out,physical,di,z80_reg);\n if(evolution_set)');
write('cpu_tb.sv',cpu.replace('repeat(6000000)tick','repeat(10000000)tick'));
let script=read(old,'cpu.do').replace('../../rtl/evolution_mapper.vhd','evolution_observed.vhd').replaceAll('cpu_work','pending_cpu_work').replace('pending_cpu_work.cpu_tb','pending_cpu_work.cpu_tb -gOFFSET=$env(F15_OFFSET)');write('cpu.do',script);
write('reference.do',script.replace(' -gOFFSET=', ' -gCASE=1 -gOFFSET='));
// Copy established regression sources into this investigation only. No old
// evidence or logs are overwritten, and no FPGA build is copied or generated.
for(const n of ['evolution_fixed_tb.sv','history_tb.sv','history.do','run.do','f13_machine.sv','f13_history_tb.sv','f13_mapper_ctrl_sim.vhd','f13_banking_tb.vhd','f13_run.do','banking.do'])write(n,read(old,n));
write('regression_machine.sv',read(old,'evolution_machine.sv'));
for(const n of ['run.do','history.do'])write(n,read(old,n).replace('evolution_machine.sv','regression_machine.sv'));
write('regression_cpu_tb.sv',read(old,'cpu_tb.sv'));write('regression_cpu.do',read(old,'cpu.do').replace('cpu_tb.sv','regression_cpu_tb.sv').replace('evolution_machine.sv','regression_machine.sv'));
let header=read(old,'evolution_fixed_tb.sv').split('reg mrst=')[0];
header=header.replace('tick;if(saving)ss_save=1;else ss_load=1;tick;', 'tick;if(saving)ss_save=1;else ss_load=1;$display("REQUEST CASE%0d saving%0d cycle%0d phase=%b A=%h M1=%b MREQ=%b WR=%b",CASE,saving,cycle,phase0,addr,m1,mreq,wr);tick;');
write('directed_tb.sv',header+read(d,'directed.sv.in'));
let banked=machine.replace('module evolution_machine','module evolution_banked_machine');
banked=banked.replace('wire[7:0]b61', 'wire[7:0]b0,b1,b2,b3;wire[7:0]b61');
banked=banked.replace("8'd0,8'd1,8'd2,8'd3,mode",'b0,b1,b2,b3,mode');
banked=banked.replace(".rom_a_i({6'd0,a})", ".rom_a_i(a[15:14]==2?{b2,a[13:0]}:{6'd0,a})");
banked=banked.replace('endmodule',`mapper_ctrl banks(.RESET_n(reset_n),.clk_sys(clk),.evolution_game_launch(launch),.mapper_set(set),.mapper_evolution(1'b1),.mapper_in(min),.mapper_janggun(1'b0),.systeme(1'b0),.bootloader_n(1'b1),.mapper_wonderkid(1'b0),.mapper_lock(1'b0),.detect_codies_static(1'b0),.mapper_codies_force(1'b0),.mapper_eeprom(1'b0),.mapper_zemina_force(1'b0),.mapper_nemesis_auto(1'b0),.rom_size_pages(8'hff),.ce_z80(1'b1),.WR_n(wr),.MREQ_n(mreq),.A(a),.ss_freeze(1'b0),.D_in(d),.sc3000_en(1'b0),.mapper_castle(1'b0),.mapper_linear(1'b0),.mapper_dahjee_a(1'b0),.mapper_sega_locked(1'b0),.use_zem(1'b0),.mapper_manual_force(1'b1),.sega_mapper_write_seen(1'b1),.bank0_out(b0),.bank1_out(b1),.bank2_out(b2),.bank3_out(b3));\nendmodule`);
write('evolution_banked_machine.sv',banked);
write('directed_tb.sv',header+read(d,'directed.sv.in').replaceAll('evolution_machine ','evolution_banked_machine '));
write('directed.do',read(old,'run.do').replace('../../rtl/evolution_mapper.vhd','evolution_observed.vhd f13_mapper_ctrl_sim.vhd').replace('evolution_fixed_tb.sv','directed_tb.sv').replace('evolution_machine.sv','evolution_banked_machine.sv').replaceAll('fixed_work','pending_direct_work'));
const pause=path.join(d,'regressions/savestate_systeme_pause_fix');fs.mkdirSync(pause,{recursive:true});for(const e of fs.readdirSync(path.join(old,'regressions/savestate_systeme_pause_fix'),{withFileTypes:true}))if(e.isFile()&&/\.(sv|vhd|v|do|mif)$/.test(e.name))fs.copyFileSync(path.join(old,'regressions/savestate_systeme_pause_fix',e.name),path.join(pause,e.name));
console.log('Prepared F15 observation-only sources and isolated regressions.');

