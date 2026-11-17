const fs=require('fs'),p=require('path'),here=__dirname,root=p.resolve(here,'../..'),src=p.join(root,'tests/savestate_g01_cpu_restart_fix/regression/pause'),d=p.join(here,'pause_known');
fs.mkdirSync(d,{recursive:true});const put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
let s=fs.readFileSync(p.join(src,'fixed_tb.sv'),'utf8').replace(/\r\n/g,'\n');
s=s.replace('wire ss_freeze;', 'wire ss_freeze;wire cpu_prepare,replay,replay_t2,phase_set,actual_tick;wire[1:0]phase_in;reg phase_ready=0;reg[4:0]clkd=0;');
s=s.replace('reg[4:0]clkd=0;reg ce_cpu', 'reg ce_cpu');
s=s.replace('savestates dut(', `savestates dut(.ss_cpu_prepare(cpu_prepare),.z80_replay(replay),.z80_tick_active(actual_tick),.z80_replay_t2(replay_t2),
 .clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),.clock_phase_in(phase_in),.clock_phase_set(phase_set),.clock_phase_ready(phase_ready),
 .sprite_out(4778'd0),.sprite2_out(4778'd0),.sprite_in(),.sprite2_in(),.sprite_valid(),`);
s=s.replace('cycle=cycle+1;ce_cpu<=0;', `cycle=cycle+1;phase_ready<=phase_set;
if(phase_set)begin case(phase_in)0:clkd<=0;1:clkd<=10;2:clkd<=20;3:clkd<=25;endcase
ce_cpu<=0;ce_pix<=0;ce_vdp<=0;ce_sp<=0;end else begin ce_cpu<=0;`)
 .replace('endcase end\n', 'endcase end end\n');
s=s.replace('assign z80_m1_n=cm1;', 'assign actual_tick=!paused||ss_capture_progress;\nassign z80_m1_n=cm1;');
// Initialize both architectural banks legally.144 startup CPU ticks plus six
// NOPs (24) preserve the original14-tick loop phase used by the pause cases.
const startup=JSON.parse(fs.readFileSync(p.join(here,'candidate/rom.json'),'utf8')).bytes.slice(0,40);
const program=[...startup,0,0,0,0,0,0];const loop=program.length;program.push(0x3c,0xc3,loop&255,loop>>8);
put('rom.hex',Array.from({length:65536},(_,i)=>(program[i]||0).toString(16).padStart(2,'0')).join('\n')+'\n');
s=s.replace(/function\[7:0\]rom\(input\[15:0\]a\);case\(a\)[^\n]+endfunction/, 'reg[7:0]pause_rom[0:65535];initial $readmemh("rom.hex",pause_rom);function[7:0]rom(input[15:0]a);rom=pause_rom[a];endfunction');
s=s.replace('.CEN((ce_pix&&!ss_freeze&&(!paused||ss_capture_progress)))', '.CEN((ce_pix&&!ss_freeze&&(!paused||ss_capture_progress))||(ce_cpu&&cpu_prepare&&replay))')
 .replace('.NMIHold(dut.z80_nmi_hold),', '.NMIHold(dut.z80_nmi_hold),.RestoreHold(ss_freeze),.ReplayT2(replay_t2),.NMIReplay(replay),');
s=s.replace('endmodule', `
reg[311:0]held_psgs;reg preparing=0;integer prepare_clocks=0;
always@(posedge clk)begin
 if(cpu_prepare&&!preparing)begin held_psgs={psg_ext_out,psg_out,psg_div_out,psg2_ext_out,psg2_out,div2};prepare_clocks=0;end
 if(cpu_prepare)begin
  prepare_clocks++;
  if(prepare_clocks>48)$fatal(1,"paused private preparation exceeded bound");
  if({psg_ext_out,psg_out,psg_div_out,psg2_ext_out,psg2_out,div2}!==held_psgs)$fatal(1,"paused CPU preparation advanced PSGs");
 end
 if(compare_machine&&frame>=1&&!ss_freeze&&$isunknown({z80_reg,rr}))$fatal(1,"uninitialized Pause CPU oracle");
 if(preparing&&!cpu_prepare)$display("PAUSE_PRIVATE_PREPARATION clocks%0d savedT2%b UIpaused%b",prepare_clocks,replay_t2,paused);
 preparing<=cpu_prepare;
end
endmodule`);
put('fixed_tb.sv',s);
const sms=fs.readFileSync(p.join(root,'SMS.sv'),'utf8').replace(/\r\n/g,'\n');
let start=sms.lastIndexOf('always @(posedge clk_sys) begin',sms.indexOf('joy8_r   <='));
let block=sms.slice(start,sms.indexOf('assign HDMI_BOB_DEINT')).replaceAll('clk_sys','clk').replaceAll('raw_reset','!reset_n');
put('pause_fixture.sv',`module pause_fixture(input clk,reset_n,systeme,joy8_sig,VBlank,ss_freeze,input preserve,output reg se_paused,output reg se_pause_pending,output reg se_unpause_pending);
reg joy8_r,VBlank_r,ss_freeze_r;wire ss_unfreeze=ss_freeze_r&~ss_freeze;always@(posedge clk)ss_freeze_r<=ss_freeze;
${block}endmodule\n`);
for(const f of ['T80','T80s'])put(f+'_sim.vhd',fs.readFileSync(p.join(root,'rtl/T80/'+f+'.vhd'),'utf8').replace(/:\s*work\.(T80\w*)/g,': entity work.$1'));
let c=fs.readFileSync(p.join(here,'candidate/savestates_sim.sv'),'utf8');if(!c.includes('TB_FAST'))c=c.replace('module savestates (','module savestates #(parameter TB_FAST=0) (').replace("20'd900000;", "(TB_FAST?20'd0:20'd900000);");put('savestates_sim.sv',c);
let run=fs.readFileSync(p.join(root,'tests/savestate_systeme_pause_fix/fixed.do'),'utf8').replaceAll('../../rtl','../../../rtl');
put('compile.do',run.slice(0,run.indexOf('vsim -c'))+'quit -code 0\n');
put('case.do',run.slice(run.indexOf('vsim -c')).replace(' -gCASE=', ' -g/pause_tb/dut/TB_FAST=$env(PAUSE_FAST) -gCASE='));
const cases=[{id:'paused_m1',CASE:3,DELAY:36,FAST:0},{id:'paused_nonm1',CASE:4,DELAY:6,FAST:0},{id:'load_current_pause',CASE:7,DELAY:6,FAST:1},{id:'load_current_running',CASE:8,DELAY:6,FAST:1},...Array.from({length:14},(_,i)=>({id:'stopped_'+i,CASE:16,DELAY:6+10*i,FAST:1}))];
fs.writeFileSync(p.join(d,'cases.json'),JSON.stringify(cases,null,2));
put('matrix.ps1',`$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
& $bin -c -do 'do compile.do' -l compile.log
if($LASTEXITCODE){throw 'compile failed'}
$cases=Get-Content -Raw cases.json|ConvertFrom-Json
foreach($c in $cases){
 $env:PAUSE_CASE=$c.CASE;$env:PAUSE_DELAY=$c.DELAY;$env:PAUSE_KEEP=0;$env:PAUSE_FULL=0;$env:PAUSE_STALL=0;$env:PAUSE_OFFSET=0;$env:PAUSE_FAST=$c.FAST
 & $bin -c -do 'do case.do' -l "$($c.id).transcript" *> "$($c.id).log"
 $s=Get-Content -Raw "$($c.id).log"
 if($LASTEXITCODE -or $s -match '\\*\\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS FIXED'){Get-Content "$($c.id).log" -Tail 16;throw "Failed $($c.id)"}
 Write-Output "PASS $($c.id)"
}
Write-Output "PAUSE MATRIX COMPLETE $($cases.Count) cases"
`);
console.log('Production Pause process, actual T80 and dual PSG fixtures prepared.');
