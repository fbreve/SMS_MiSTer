const fs=require('fs'),p=require('path'),d=__dirname,variant=process.argv[2]||'baseline',candidate=variant==='candidate';
const lib=candidate?'known_candidate_work':'known_baseline_work';
let s=fs.readFileSync(p.join(d,candidate?'candidate_tb.sv':'baseline/fm_tb.sv'),'utf8');
s=s.replace('parameter PHASE=70,','parameter REPLAYS=1,STEREO=0,PHASE=70,');
s=s.replace('pass<4','pass<=REPLAYS').replace('pass<3','pass<REPLAYS');
s=s.replaceAll('[0:47999]','[0:N-1]');
s=s.replace('fmsetup; if(PROGRAM)randomsetup;',`fmsetup;
 // Exercise a real key-off/on/off history on every inactive channel. This
 // establishes known phase/envelope state using legal held F0/F1 commands.
 for(integer ch=1;ch<9;ch++)fmwrite(8'h20+ch,8'h19);
 for(integer ch=1;ch<9;ch++)fmwrite(8'h20+ch,8'h09);
 if(PROGRAM)randomsetup;`);
s=s.replace("audio_control_out=11'h7ff;","audio_control_out=STEREO?11'h7f0:11'h7ff;");
s=s.replaceAll(".mux(8'hff)",".mux(STEREO?8'hf0:8'hff)");
// Read back every actual OPLL row after LOAD using its public private-state
// interface in the existing256-clock post-apply UNFREEZE interval. F01 applies
// after the global flush. No state, counter, phase or enable is forced.
s=s.replace('reg[31:0]fm_wrapper_rdata=0;',"reg[31:0]fm_wrapper_rdata=0;reg audit_busy=0,audit_read=0;reg[7:0]audit_addr=0;wire[7:0]observed_addr=audit_busy?audit_addr:fm_state_addr;wire observed_read=audit_busy?audit_read:fm_state_read;");
s=s.replace('.ss_addr(fm_state_addr),.ss_read(fm_state_read)', '.ss_addr(observed_addr),.ss_read(observed_read)');
s=s.replace("ss_freeze&&fm_state_read&&fm_state_addr==8'h4c", "ss_freeze&&observed_read&&observed_addr==8'h4c");
s=s.replace(/\nendmodule\s*$/,`
integer audit_loads=0;integer audit_fd;reg[31:0]audit_expected;
initial begin
 audit_fd=$fopen("restored_state.dat","w");
 forever begin
  @(posedge clk);#1;
  if(dut.state==34&&dut.unfreeze_cnt==0&&!dut.do_save)begin
   audit_loads++;
   tick;audit_busy=1;
   for(integer row=0;row<104;row++)begin
    audit_addr=row;audit_read=1;tick;
    audit_expected=row[0]?mem['h2998+row/2][63:32]:mem['h2998+row/2][31:0];
    $fdisplay(audit_fd,"load%0d row%0d actual%08h expected%08h",audit_loads,row,fm_state_rdata,audit_expected);
    if(fm_state_rdata!==audit_expected)$fatal(1,"OPLL readback load%0d row%0d actual%h expected%h",audit_loads,row,fm_state_rdata,audit_expected);
    audit_read=0;tick;
   end
   audit_busy=0;
   $display("PASS OPLL_READBACK load%0d rows104",audit_loads);
   wait(dut.state!=34);
  end
 end
end
endmodule
`);
fs.writeFileSync(p.join(d,variant+'_known_tb.sv'),s);
let c=fs.readFileSync(p.join(d,candidate?'candidate_compile.do':'baseline/compile.do'),'utf8');
c=c.replaceAll(candidate?'fm_candidate_work':'fm_work',lib).replace(candidate?'candidate_tb.sv':'fm_tb.sv',variant+'_known_tb.sv');
c=c.replace(candidate?'candidate_controller.sv':'savestates_sim.sv',variant+'_known_controller.sv');
if(!candidate)c=c.replace('../../rtl/AudioMix.vhd','baseline/rtl/AudioMix.vhd');
const controller=require('../savestate_g06_g10_fix/controller_adapter')(p.join(d,candidate?'candidate/rtl/savestates.sv':'baseline/rtl/savestates.sv'));
fs.writeFileSync(p.join(d,variant+'_known_controller.sv'),controller);
// The original library is already compiled, immutable and shared read-only.
c=c.split(/\r?\n/).filter(l=>!l.startsWith('vlib original_work')&&!l.startsWith('vcom -work original_work')).join('\n');
fs.writeFileSync(p.join(d,variant+'_known_compile.do'),c);
if(!candidate)fs.writeFileSync(p.join(d,'baseline_controller.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(d,'baseline/rtl/savestates.sv')));
fs.writeFileSync(p.join(d,variant+'_known_run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
if {![info exists env(TB_FAST)]} {set env(TB_FAST) 1}
vsim -L ${lib} -L original_work -t 1ps ${lib}.fm_tb -gPHASE=$env(PHASE) -gRESET_SKEW=$env(RESET_SKEW) -gREF=$env(REF) -gFM_ONLY=$env(FM_ONLY) -gSTALL=$env(STALL) -gN=$env(N) -gREPLAYS=$env(REPLAYS) -gSTEREO=$env(STEREO) -gPROGRAM=$env(PROGRAM) -gRANDOMSEED=$env(RANDOMSEED) -gCONVERGE=$env(CONVERGE) -gHISTORY=$env(HISTORY) -g/fm_tb/dut/TB_FAST=$env(TB_FAST)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
console.log('Prepared '+variant+' known-state fixture with public guest initialization.');
