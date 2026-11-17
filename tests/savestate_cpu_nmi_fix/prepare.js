const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..'),old=path.join(r,'tests/savestate_cpu_nmi');
const read=(dir,n)=>fs.readFileSync(path.join(dir,n),'utf8'),write=(n,s)=>fs.writeFileSync(path.join(d,n),s);
let ss=read(r,'rtl/savestates.sv');for(const n of ['mapper_snap','evolution_snap','dout_latch']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';[^\\n]*\\r?\\n','m'),m=ss.match(re);if(!m)throw Error('declaration '+n);ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',m[0]+'// NVRAM size calculation helpers');}write('savestates_sim.sv',ss);
let cpu=read(r,'rtl/T80/T80.vhd').replace(/: work\.(T80_MCode|T80_ALU|T80_Reg)/g,': entity work.$1');
const dbg='debug_nmi : out std_logic_vector(12 downto 0); debug_old : out std_logic;\n';
cpu=cpu.replace('DIRSet     : in',dbg+'DIRSet     : in').replace('\tREG <=','    debug_nmi <= NMI_s & NMICycle & IntCycle & std_logic_vector(MCycle) & std_logic_vector(TState) & Prefix & IntE_FF1 & IntE_FF2;\n    debug_old <= OldNMI_n;\n\tREG <=');write('T80_observed.vhd',cpu);
write('T80s_observed.vhd',read(r,'rtl/T80/T80s.vhd').replace(': work.T80',': entity work.T80').replace('DIRSet     : in',dbg+'DIRSet     : in').replace('DIRSet => DIRSet,','debug_nmi => debug_nmi, debug_old => debug_old,\n DIRSet => DIRSet,'));
let header=read(old,'nmi_tb.sv').split('reg mrst=0')[0];
header=header.replace(/module nmi_tb;[\s\S]*?reg clk/,`module fixed_tb;
parameter SOURCE=0,PROGRAM=0,EDGE=-15,WIDTH=5,SECOND=9999999,HELD=0,SCHEDULE=0,FORMAT=0,REPLAYS=3;
reg clk`);
header=header.replace("reg [7:0] wram_D = '0;",'wire [7:0] wram_D;');
header=header.replace('savestates dut(',"wire[2:0]nmi_snap,nmi_dir;wire nmi_valid,nmi_hold;\nsavestates dut(.z80_nmi(nmi_snap),.z80_nmi_dir(nmi_dir),.z80_nmi_valid(nmi_valid),.z80_nmi_hold(nmi_hold),");
write('fixed_tb.sv',header+read(d,'fixed.sv.in'));
const prior=read(old,'scenario.sv.in'),rom=prior.slice(prior.indexOf('function[7:0]rom'),prior.indexOf('wire pix=')).replace(/assign di=[^\n]+\n/,'');
const machine=`\`timescale 1ns/1ps
module nmi_machine #(parameter SOURCE=0,PROGRAM=0)(
 input clk,mrst,cpu_ce,ss_freeze,pause_n,input[6:0]link_pins,
 input[229:0]cpu_dir,input cpu_set,input[2:0]nmi_dir,input nmi_valid,nmi_hold,
 input[127:0]gg_in,input gg_set,input[31:0]io_in,input io_set,
 input[13:0]wram_A,wram_WA,input[7:0]wram_WD,input wram_WE,output reg[7:0]wram_D,
 output[229:0]cpu_reg,output[2:0]nmi_snap,output[12:0]nstate,output old_nmi,nmi_replay,ready,
 output[127:0]gg_out,output[31:0]io_out,output[15:0]addr,output[7:0]data,di,output[1:0]iset,output m1,mreq,wr,rd,iq,nmi_n);
 wire effective_gg=SOURCE==1;wire link_nmi;wire[7:0]io_data;
 assign nmi_n=(pause_n|effective_gg)&link_nmi;
 wire io_port=(addr[7:6]==0)&&(addr[0]||(effective_gg&&addr[5:3]==0));
 wire io_wr=wr|iq|!io_port,io_rd=rd|iq|!io_port;
 \`include "io_instance.sv"
 reg[7:0]ram[0:8191];initial for(integer i=0;i<8192;i=i+1)ram[i]=0;
 reg[7:0]rom_q;
 always @(posedge clk)begin
  wram_D<=ram[wram_A[12:0]];
  if(wram_WE)ram[wram_WA[12:0]]<=wram_WD;
  if(!ss_freeze)rom_q<=rom(addr);
  if(!mreq&&!wr&&!ss_freeze&&addr[15:14]==3)ram[addr[12:0]]<=data;
 end
 assign ready=!iq&&!wr&&addr[7:0]=='h7e;
 ${rom}
 // CPU reads are unavailable while the savestate owns memory. T1 must occur
 // after handoff and provide ordinary setup time for this registered ROM port.
 assign di=ss_freeze?8'hff:!iq?io_data:addr[15:14]==3?ram[addr[12:0]]:rom_q;
 T80s #(.T2Write(0)) cpu(.RESET_n(mrst),.CLK(clk),.CEN(cpu_ce&&!ss_freeze),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(nmi_n),.BUSRQ_n(1'b1),.M1_n(m1),.MREQ_n(mreq),.IORQ_n(iq),.RD_n(rd),.WR_n(wr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(addr),.DI(di),.DO(data),.REG(cpu_reg),.DIRSet(cpu_set),.DIR(cpu_dir),.ISet_out(iset),.NMIState(nmi_snap),.NMIDIR(nmi_dir),.NMIValid(nmi_valid),.NMIEnable(1'b1),.NMIHold(nmi_hold),.NMIReplay(nmi_replay),.debug_nmi(nstate),.debug_old(old_nmi));
endmodule\n`;
// ISet is Prefix observation from the real core, not a driven surrogate.
write('machine.sv',machine);
write('io_instance.sv',read(old,'io_instance.sv').replace('.ss_freeze(ss_freeze)','.ss_freeze(ss_freeze|nmi_replay)'));
write('fixed.do',`onerror {quit -code 1}
onbreak {quit -code 1}
vlib fixed_work
vcom -work fixed_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd
vlog -work fixed_work -sv -quiet savestates_sim.sv machine.sv fixed_tb.sv
vsim -c -t 1ps -voptargs=+acc fixed_work.fixed_tb -gSOURCE=$env(FIX_SOURCE) -gPROGRAM=$env(FIX_PROGRAM) -gEDGE=$env(FIX_EDGE) -gWIDTH=$env(FIX_WIDTH) -gSECOND=$env(FIX_SECOND) -gHELD=$env(FIX_HELD) -gSCHEDULE=$env(FIX_SCHEDULE) -gFORMAT=$env(FIX_FORMAT)
set NumericStdNoWarnings 1
run -all
quit -code 0
`);
console.log('Prepared current production controller/CPU/IO integration with independent reference and memory handoff model.');
