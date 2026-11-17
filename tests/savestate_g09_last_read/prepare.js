const fs=require('fs'),path=require('path');
const d=__dirname,r=path.resolve(d,'../..'),old=path.join(r,'tests/savestate_cpu_nmi_fix');
const read=(base,p)=>fs.readFileSync(path.join(base,p),'utf8');
const put=(p,s)=>fs.writeFileSync(path.join(d,p),s);
// Exact current production plus observation-only ports / ModelSim syntax adapters.
let cpu=read(r,'rtl/T80/T80.vhd').replace(/: work\.(T80_MCode|T80_ALU|T80_Reg)/g,': entity work.$1');
const dbg='debug_nmi : out std_logic_vector(12 downto 0); debug_old : out std_logic;\n';
cpu=cpu.replace('DIRSet     : in',dbg+'DIRSet     : in').replace('\tREG <=','    debug_nmi <= NMI_s & NMICycle & IntCycle & std_logic_vector(MCycle) & std_logic_vector(TState) & Prefix & IntE_FF1 & IntE_FF2;\n debug_old <= OldNMI_n;\n\tREG <=');put('T80_observed.vhd',cpu);
put('T80s_observed.vhd',read(r,'rtl/T80/T80s.vhd').replace(': work.T80',': entity work.T80').replace('DIRSet     : in',dbg+'DIRSet     : in').replace('DIRSet => DIRSet,','debug_nmi => debug_nmi, debug_old => debug_old,\n DIRSet => DIRSet,'));
let mc=read(r,'rtl/mapper_ctrl.vhd');
// These three cases cover all binary addresses but not std_logic metavalues.
mc=mc.replace(/(when "11" =>[^\n]*\n)(\s*end case;)/g,'$1 when others => null;\n$2');
mc=mc.replace('eeprom_soft_reset_out : out std_logic','last_read_observe : out std_logic_vector(15 downto 0);\n eeprom_soft_reset_out : out std_logic').replace('\tbank0_out <= bank0;','last_read_observe <= last_read_addr;\n\tbank0_out <= bank0;');
put('mapper_ctrl_observed.vhd',mc);
let ss=read(r,'rtl/savestates.sv');
for(const n of ['mapper_snap','evolution_snap','dout_latch']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';[^\\n]*\\r?\\n','m'),m=ss.match(re);if(!m)throw Error(n);ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',m[0]+'// NVRAM size calculation helpers');}put('savestates_sim.sv',ss);
let mapping=read(old,'regression/f13_machine.sv');
mapping=mapping.replace('module machine(','module mapping(').replace('input WR_n,MREQ_n,mapper_set,','input WR_n,MREQ_n,mapper_set,ce_z80,sys,').replace('output[7:0]read_data);','output[7:0]read_data,output[15:0]last_read);').replace("wire  ce_z80 = '1;",'').replace("wire  systeme = '0;",'wire systeme=sys;').replace('mapper_ctrl mapper_ctrl_inst(','mapper_ctrl mapper_ctrl_inst(.last_read_observe(last_read),');
put('mapping.sv',mapping);
put('io_instance.sv',read(old,'io_instance.sv'));
// Guest code is immutable; Q is selected by a live input port, not code patching.
let machine=read(old,'machine.sv').replace('module nmi_machine #(parameter SOURCE=0,PROGRAM=0)','module nmi_machine #(parameter SOURCE=0,PROGRAM=0,SYS=0)');
machine=machine.replace('input clk,mrst,cpu_ce,ss_freeze,pause_n,','input clk,mrst,cpu_ce,ss_freeze,pause_n,input[1:0]qmode,input map_set,input[63:0]map_in,input[17:0]hist_in,output[63:0]map_out,output[17:0]hist_out,output[15:0]last_read,output[21:0]physical,');
machine=machine.replace("if(!ss_freeze)rom_q<=rom(addr);","if(!ss_freeze)rom_q<=addr==16'h8123 ? {2'd0,physical[21:14]} : addr==16'ha000 ? 8'd5 : addr==16'h9000 ? 8'd6 : rom(addr);");
const rom=[];const emit=(a,bytes)=>bytes.forEach((v,i)=>rom.push(`${a+i}:rom=8'h${v.toString(16)};`));
// AB header and jump into known-register initialization copied from F16.
emit(0,[0x41,0x42,0xc3,0x20,0]);
const init=[];
// Relocate the original initialization without changing immediate operands.
const source=read(old,'machine.sv');
const setup=source.slice(source.indexOf('  0:rom='),source.indexOf(' // Handler:'));
const vals=new Map();for(const m of setup.matchAll(/(\d+):rom=([^;]+);/g)){let v=m[2];if(v.includes('effective_gg'))v=v.startsWith("effective_gg?'hd3")?'0':'0';vals.set(+m[1],v);}
for(let i=0;i<=53;i++)rom.push(`${0x20+i}:rom=${vals.get(i)};`);
// Two 256-iteration DJNZ loops mature the detection window before the marker.
emit(0x56,[0x16,2,0x06,0,0x10,0xfe,0x15,0x20,0xf9,0xd3,0x7e,0xc3,0,1]);
// Dispatcher: identical live port value zero on every replay suffix.
emit(0x100,[0xdb,0x7d,0xb7,0xca,0x20,1,0xfe,1,0xca,0,3,0xfe,2,0xca,0,4,0xc3,0,5]);
const bodies=[
 [0x3a,0x23,0x81,0x3e,3,0x32,0,0xa0],
 [0x3a,0,0xa0,0x32,0,0xa0],
 [0x3a,0,0x90,0x32,0,0xa0],
 [0x3a,0,0xa0,0x3a,0,0x90,0x3a,0,0xa0,0x32,0,0xa0],
 [0x21,0,0xa0,0x11,0,0xa0,0x01,2,0,0xed,0xb0],
 [0x21,0,0x90,0x11,0,0xa0,0x01,2,0,0xed,0xb0],
 [0x21,0,0x90,0x11,0,0xa0,0x01,1,0,0xed,0xb0,0x32,0,0xa0],
 [0x3e,7,0x32,0xff,0xff,0x3a,0,0xa0,0x32,0,0xa0],
 [0xdd,0x21,0,0xa0,0xdd,0x34,0],
 [0x76,0x3e,9,0x32,0,0xa0]
];
// PROGRAM chooses a constant ROM variant at elaboration, never during a run.
let bodyCases='';bodies.forEach((b,p)=>{b=b.concat([0x3a,0x23,0x81,0x32,0x10,0xc1,0xc3,0,1]);bodyCases+=`if(PROGRAM==${p})case(a)\n`+b.map((v,i)=>`${0x120+i}:rom=8'h${v.toString(16)};`).join('\n')+'\ndefault:begin end endcase\n';});
for(let q=1;q<=3;q++){
 const a=q===1?0x300:q===2?0x400:0x500;
 const b=[0x3e,0,0xd3,0x3e,0x3e,8,0xd3,0x3e];
 if(q===3)b.push(0x3e,4,0x32,0,0x80); // Real Wonder Kid recognition while window is open.
 else b.push(0x3e,q+7,0x32,0xfd,0xff); // Real Sega history and different banks.
 b.push(0x3e,q+8,0x32,0xff,0xff,0x3a,q===1?0:0x23,q===1?0xa0:0x81,0xc3,(a+18)&255,(a+18)>>8);
 // Stable Q loop at a fixed, distinct PC, with a real memory read.
 b.splice(b.length-3,3,0xc3,a&255,a>>8);
 emit(a,b);
}
const handler=source.slice(source.indexOf("  'h66:rom="),source.indexOf("  'h100:rom="));
const func='function[7:0]rom(input[15:0]a);begin\nrom=0;case(a)\n'+rom.join('\n')+'\n'+handler+'\ndefault:rom=0;endcase\n'+bodyCases+'end endfunction';
machine=machine.replace(/function\[7:0\]rom[\s\S]*?endfunction/,func);
machine=machine.replace("assign di=ss_freeze?8'hff:!iq?io_data:","assign di=ss_freeze?8'hff:!iq?(addr[7:0]==8'h7d ? {6'd0,qmode}:io_data):");
const maplogic=`
 reg boot=1;always @(posedge clk)begin
 if(!mrst)boot<=1;else if(map_set)boot<=map_in[54];else if(!ss_freeze&&!iq&&!wr&&addr[7:0]==8'h3e)boot<=data[3];
 end
 reg downloaded=0;reg[24:0]load_a=0;reg[7:0]load_d=0;reg load_en=0;
 initial begin @(negedge clk);load_en=1;load_a=0;load_d=8'h41;@(negedge clk);load_a=1;load_d=8'h42;@(negedge clk);load_en=0;downloaded=1;end
 wire[7:0]dummy;
 mapping maps(.clk_sys(clk),.ROMCL(clk),.ROMAD(load_a),.ROMDT(load_d),.ROMEN(load_en),.RESET_n(mrst),.ss_freeze(ss_freeze),.bootloader_n(boot),.A(addr),.D_in(data),.WR_n(wr),.MREQ_n(mreq),.mapper_set(map_set),.ce_z80(cpu_ce&&!ss_freeze),.sys(SYS!=0),.mapper_in(map_in),.mapper_history_in(hist_in),.mapper_history_out(hist_out),.state_out(map_out),.rom_address(physical),.dahjee(),.sega_seen(),.read_data(dummy),.last_read(last_read));
`;
machine=machine.replace(' T80s #',maplogic+' T80s #');put('machine.sv',machine);
let tb=read(old,'fixed_tb.sv');
tb=tb.slice(0,tb.indexOf('localparam LENGTH='))+read(d,'tail.sv.in');
tb=tb.replace('parameter SOURCE=0,PROGRAM=0,EDGE=-15,WIDTH=5,SECOND=9999999,HELD=0,SCHEDULE=0,FORMAT=0,REPLAYS=3;','parameter PROGRAM=0,OFFSET=0,PERIOD=15,SYS=0,CAPTURES=0;');
tb=tb.replace("reg systeme = '0;",'wire systeme=SYS!=0;');
tb=tb.replace('wire[2:0]nmi_snap,nmi_dir;','wire[17:0]history_out,history_in;\nwire[2:0]nmi_snap,nmi_dir;');
tb=tb.replace(".mapper_history_out(18'h0ffff),.mapper_history_in()",'.mapper_history_out(history_out),.mapper_history_in(history_in)');
tb=tb.replace('cycle%15==0','cycle%PERIOD==0');put('fixed_tb.sv',tb);
put('run.do',`onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -work work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd mapper_ctrl_observed.vhd ../../rtl/mapper_detect.vhd ../../rtl/memory_decode.vhd
vlog -work work -sv -quiet savestates_sim.sv mapping.sv machine.sv fixed_tb.sv
vsim -c -t 1ps work.fixed_tb -gPROGRAM=$env(G09_PROGRAM) -gOFFSET=$env(G09_OFFSET) -gPERIOD=$env(G09_PERIOD) -gSYS=$env(G09_SYS) -gCAPTURES=$env(G09_CAPTURES)
set NumericStdNoWarnings 1
run -all
quit -code 0
`);
console.log('Prepared current production CPU/controller/mapper; observation-only last-read port.');
