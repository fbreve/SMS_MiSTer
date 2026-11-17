const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),src=p.join(d,'../savestate_f06_sega_sram_fix');
if(!fs.existsSync(p.join(d,'baseline.json'))){
 const hashes={};for(const f of cp.execFileSync('git',['ls-files'],{encoding:'utf8'}).trim().split(/\r?\n/))if(fs.existsSync(f)&&fs.statSync(f).isFile())hashes[f]=sha(fs.readFileSync(f));
 const reports=['savestate_g_closure','savestate_g08_release','savestate_g08_release_fix','savestate_f01_opll_architecture','savestate_f01_opll_fix','savestate_f06_sega_sram_fix'];
 fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),F01:'7fcd5e12847eedf9e97a44dc937c3dbac3205f7c',G08release:cp.execFileSync('git',['rev-parse','08cf142'],{encoding:'utf8'}).trim(),F06:cp.execFileSync('git',['rev-parse','854761c'],{encoding:'utf8'}).trim(),hashes,reports:Object.fromEntries(reports.map(x=>[x,sha(fs.readFileSync(p.join(d,'..',x,'review.md')))])),format:18,resources:require('../savestate_f06_sega_sram_fix/early_results.json').candidate},null,2));
}
for(const f of ['pause_fixture.sv','T80_sim.vhd','T80s_sim.vhd','opll_reference.vhd','rom.hex'])fs.copyFileSync(p.join(src,f),p.join(d,f));
// LD A,1 / JP loop is 17 CPU clocks: coprime to the 72-step FM schedule.
const rom=fs.readFileSync(p.join(d,'rom.hex'),'utf8').trim().split(/\s+/);rom.splice(0x2e,5,'3e','01','c3','2e','00');fs.writeFileSync(p.join(d,'rom.hex'),rom.join('\n')+'\n');
fs.cpSync(p.join(src,'sim_opll'),p.join(d,'sim_opll'),{recursive:true});
const probe=s=>s.replace(/mixout\s+: (?:buffer|out) std_logic_vector\(\s*13 downto 0\s*\)/i,m=>m+'; audit_counter : out std_logic_vector(6 downto 0)').replace(/end rtl;\s*$/i,'audit_counter <= slot & stage;\nend rtl;');
for(const f of ['sim_opll/opll.vhd','opll_reference.vhd']){const file=p.join(d,f),s=fs.readFileSync(file,'latin1'),next=probe(s);assert.notEqual(next,s);assert(next.includes('audit_counter <= slot & stage'));fs.writeFileSync(file,next,'latin1');}
fs.writeFileSync(p.join(d,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')));
let s=fs.readFileSync(p.join(src,'random_tb.sv'),'utf8').replace('module random_tb;','module fm_tb;').replace('parameter RANDOMSEED=1,','parameter PHASE=70,RESET_SKEW=0,FM_ONLY=1,CHARACTERIZE=1,PROGRAM=0,RANDOMSEED=1,');
s=s.replace('repeat(6)tick;reset_n=1;', 'repeat(6+RESET_SKEW)tick;reset_n=1;');
s=s.replace('fmsetup; randomsetup; repeat(SEED)tick;', 'fmsetup; if(PROGRAM)randomsetup;repeat(SEED)tick;');
s=s.replace('if(TARGET)storage_busy=1;request(1);', 'storage_busy=1;request(1);');
s=s.replace(/if\(TARGET\)begin while\(!\(dut.state==37[^\n]+storage_busy=0;end/,`begin integer seek;seek=0;while(!(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&fm_counter==PHASE))begin tick;seek++;if(seek>2000000)$fatal(1,"unreachable phase%0d",PHASE);end storage_busy=0;end`);
s=s.replace('wire[13:0]fmout,rfmout;', 'wire[6:0]fm_counter,rfm_counter;wire[13:0]fmout,rfmout;');
s=s.replace('opll fm(.ss_hold','opll fm(.audit_counter(fm_counter),.ss_hold').replace('opll_reference rfm(.xin','opll_reference rfm(.audit_counter(rfm_counter),.xin');
// Literal routing, clamp and scaling; FM_ONLY mutes PSG at the mixer input.
s=s.replaceAll('{audio1[10],audio1,4\'b0}',"(FM_ONLY?16'd0:{audio1[10],audio1,4'b0})").replaceAll('{a1r[10],a1r,4\'b0}',"(FM_ONLY?16'd0:{a1r[10],a1r,4'b0})").replaceAll('{raudio[10],raudio,4\'b0}',"(FM_ONLY?16'd0:{raudio[10],raudio,4'b0})").replaceAll('{rar[10],rar,4\'b0}',"(FM_ONLY?16'd0:{rar[10],rar,4'b0})");
s=s.replace('if((FM_SUPPRESS||systeme)&&errors)$fatal', 'if(!CHARACTERIZE&&errors)$fatal');
s=s.replace('$display("PASS F01 FMCASE', '$display("PASS G08FM FMCASE');
s=s.replace('reg[13:0]ofm[0:47999];','reg[13:0]ofm[0:47999];reg[6:0]ocounter[0:47999];reg oupdate[0:47999],omixphase[0:47999];reg fm_event,rfm_event;');
s=s.replace('"%h %h %h %h %h %h %h",{rl,rr_audio},rpsgcfg,rpsgext,rpsgdiv,{raudio,rar},rclkd,rfmout','"%h %h %h %h %h %h %h %h %b %b",{rl,rr_audio},rpsgcfg,rpsgext,rpsgdiv,{raudio,rar},rclkd,rfmout,rfm_counter,rfm_event,refphase');
s=s.replace('"%h %h %h %h %h %h %h",oracle[k],ocfg[k],oext[k],odiv[k],osnd[k],ophase[k],ofm[k]);if(scan!=7)', '"%h %h %h %h %h %h %h %h %b %b",oracle[k],ocfg[k],oext[k],odiv[k],osnd[k],ophase[k],ofm[k],ocounter[k],oupdate[k],omixphase[k]);if(scan!=10)');
s=s.replace('if(fmout!==ofm[k])', 'if({fm_counter,fm_event,audio_phase_out}!=={ocounter[k],oupdate[k],omixphase[k]})$fatal(1,"FM event/phase mismatch pass%0d k%0d",pass,k);if(fmout!==ofm[k])');
s=s.replace('wait(!ss_freeze);\n$writememh', 'wait(!ss_freeze);\n$writememh');
s=s.replace(/\nendmodule\s*$/,`
always@(posedge clk)begin
 fm_event<=ce_cpu&&!ss_freeze&&!paused&&fm_counter==70;
 rfm_event<=rce_cpu&&!holdref&&!rpaused&&rfm_counter==70;
 if(dut.state==37&&!storage_busy&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
  $display("ACCEPT save%b counter%0d native%0d fmCE%b phase%b raw%h mixed%h/%h",dut.do_save,fm_counter,clkd,ce_cpu,audio_phase_out,fmout,al,ar);
  #1;$display("POST_T counter%0d raw%h mixed%h/%h nextPhase%b",fm_counter,fmout,al,ar,audio_phase_out);
 end
end
always@(negedge ss_freeze)if(reset_n)begin #1;
 $display("HANDOFF_RESTORED counter%0d raw%h savedCounter%0d savedRaw%h nextPhase%b",fm_counter,fmout,mem['h2998+39][6:0],mem['h2998+51][13:0],audio_phase_in);
end
endmodule
`);
assert(s.includes('unreachable phase'));assert(s.includes('scan!=10'));fs.writeFileSync(p.join(d,'fm_tb.sv'),s);
let compile=fs.readFileSync(p.join(src,'random_compile.do'),'utf8').replaceAll('work_random','fm_work').replace('random_tb.sv','fm_tb.sv');fs.writeFileSync(p.join(d,'compile.do'),compile);
fs.writeFileSync(p.join(d,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -L fm_work -L original_work -t 1ps -voptargs=+acc fm_work.fm_tb -gPHASE=$env(PHASE) -gRESET_SKEW=$env(RESET_SKEW) -gREF=$env(REF) -gFM_ONLY=$env(FM_ONLY) -gSTALL=$env(STALL) -g/fm_tb/dut/TB_FAST=1\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);
fs.writeFileSync(p.join(d,'.gitignore'),'fm_work/\noriginal_work/\n**/modelsim.ini\n**/*.wlf\n**/vsim_stacktrace.vstf\n');
console.log('Prepared current-v18 strict FM handoff composition with observer-only OPLL counter ports.');
