const fs=require('fs'),path=require('path'),d=__dirname,p=path.resolve(d,'../savestate_cpu_nmi');
const rd=n=>fs.readFileSync(path.join(p,n),'utf8'),wr=(n,s)=>fs.writeFileSync(path.join(d,n),s);
const ports=`proto_hold : in std_logic := '0'; proto_set : in std_logic := '0'; proto_bits : in std_logic_vector(2 downto 0) := "000"; proto_replay : in std_logic := '0'; proto_sample : in std_logic := '1';\n`;
let cpu=rd('T80_observed.vhd').replace('debug_nmi : out',ports+'debug_nmi : out');
const start=cpu.indexOf("\t\t\t\tif NMI_n = '0' and OldNMI_n = '1' then"),end=cpu.indexOf("\n\t\t\t\tif CEN = '1' then",start);
if(start<0||end<0)throw Error('Sampler anchor');
cpu=cpu.slice(0,start)+`                -- TEST-ONLY candidate state injection and sampling controls.
                -- Architectural/CEN logic below remains unchanged.
                if proto_set = '1' then
                    NMI_s <= proto_bits(2); NMICycle <= proto_bits(1); OldNMI_n := proto_bits(0);
                elsif proto_replay = '1' then
                    if proto_sample = '0' and OldNMI_n = '1' then NMI_s <= '1'; end if;
                    OldNMI_n := proto_sample;
                elsif proto_hold = '0' then
                    if NMI_n = '0' and OldNMI_n = '1' then NMI_s <= '1'; end if;
                    OldNMI_n := NMI_n;
                end if;
                debug_old <= OldNMI_n;
`+cpu.slice(end);wr('T80_candidate.vhd',cpu);
wr('T80s_candidate.vhd',rd('T80s_observed.vhd').replace('debug_nmi : out',ports+'debug_nmi : out').replace('debug_nmi => debug_nmi,','proto_hold => proto_hold, proto_set => proto_set, proto_bits => proto_bits, proto_replay => proto_replay, proto_sample => proto_sample,\n debug_nmi => debug_nmi,'));
wr('savestates_sim.sv',rd('savestates_sim.sv'));wr('io_instance.sv',rd('io_instance.sv'));
let header=rd('nmi_tb.sv').split('reg mrst=0')[0];header=header.replace('module nmi_tb;','module capture_tb;').replace('parameter EDGE=', 'parameter CAND=0, HELD=0, BAD=0;\nparameter EDGE=');
header=header.replace('cpu_ce=cycle%15==0;cycle=cycle+1;', 'if(logical_active)logical_cycle=logical_cycle+1; cpu_ce=logical_active ? logical_cycle%15==0 : cycle%15==0;cycle=cycle+1;');
const prior=rd('scenario.sv.in'),rom=prior.slice(prior.indexOf('function[7:0]rom'),prior.indexOf('integer ready_cycle='));
let common=prior.slice(0,prior.indexOf('function[7:0]rom'));
common=common.replace('.sv"','.sv"').replace('if(wram_WE)','if(wram_WE)').replace('!ss_freeze&&addr','!local_freeze&&addr');
common=common.replace(',stage=0,iteration=0','');
let body=rom.replace('.CEN(cpu_ce&&!ss_freeze)', '.CEN(cpu_enable)').replace('.DIRSet(z80_set),.DIR(z80_dir)', '.DIRSet(cpu_set),.DIR(cpu_dir)').replace('.debug_nmi(nstate)', '.proto_hold(proto_hold),.proto_set(proto_set),.proto_bits(proto_bits),.proto_replay(proto_replay),.proto_sample(saved_input),.debug_nmi(nstate)');
header=header.replace('always #5 clk=~clk;',fs.readFileSync(path.join(d,'controls.sv.in'),'utf8')+'\nalways #5 clk=~clk;');
wr('capture_tb.sv',header+common+body+fs.readFileSync(path.join(d,'scenario.sv.in'),'utf8'));
let io=rd('io_instance.sv').replace('.ce_cpu((cpu_ce&&!ss_freeze))','.ce_cpu(io_enable)').replace('.gg_state_in(gg_in)', '.gg_state_in(local_gg_in)').replace('.gg_state_set(gg_set)', '.gg_state_set(local_gg_set)').replace('.io_state_in(io_in)', '.io_state_in(local_io_in)').replace('.io_state_set(io_set)', '.io_state_set(local_gg_set)').replace('.ss_freeze(ss_freeze)', '.ss_freeze((BAD==3&&preparing)?1\'b0:local_freeze)');wr('io_instance.sv',io);
wr('capture.do',`onerror {quit -code 1}
onbreak {quit -code 1}
vlib capture_work
vcom -work capture_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_candidate.vhd T80s_candidate.vhd
vlog -work capture_work -sv -quiet savestates_sim.sv capture_tb.sv
vsim -c -t 1ps -voptargs=+acc capture_work.capture_tb -gCAND=$env(CAP_CAND) -gEDGE=$env(CAP_EDGE) -gWIDTH=$env(CAP_WIDTH) -gSOURCE=$env(CAP_SOURCE) -gPROGRAM=$env(CAP_PROGRAM) -gSECOND=$env(CAP_SECOND) -gHELD=$env(CAP_HELD) -gBAD=$env(CAP_BAD) -gTARGET=359
set NumericStdNoWarnings 1
run -all
quit -code 0
`);
wr('sim.ps1',rd('sim.ps1'));console.log('Generated TEST-ONLY candidate sampler/state controls; production files untouched.');
