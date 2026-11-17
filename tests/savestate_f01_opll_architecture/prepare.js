const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),src=p.join(root,'tests/savestate_g08_release_fix/original_combined');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'utf8'}).trim();
if(!fs.existsSync(p.join(d,'baseline.json')))fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:git('rev-parse','HEAD'),branch:git('branch','--show-current'),tracked:Object.fromEntries(git('ls-files').split('\n').filter(f=>fs.existsSync(p.join(root,f))&&fs.statSync(p.join(root,f)).isFile()).map(f=>[f,hash(p.join(root,f))])),prerequisites:Object.fromEntries(['savestate_coverage','savestate_resource_growth','savestate_sprite_resource_optimization','savestate_g08_release','savestate_g08_release_fix'].map(n=>[n,hash(p.join(root,'tests',n,'review.md'))]))},null,2));
fs.writeFileSync(p.join(d,'.gitignore'),'work/\nwork_fast/\nwork_native/\nsearch_work/\nmodelsim.ini\ntranscript\n*.wlf\n*_stdout.log\nmicro_*/db/\nmicro_*/incremental_db/\nmicro_*/output_files/\n');
for(const f of ['pause_fixture.sv','rom.hex'])fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.writeFileSync(p.join(d,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')));
for(const f of ['T80','T80s'])fs.writeFileSync(p.join(d,f+'_sim.vhd'),fs.readFileSync(p.join(root,'rtl/T80',f+'.vhd'),'utf8').replace(/: work\./g,': entity work.'));
let s=fs.readFileSync(p.join(src,'audio_tb.sv'),'utf8');
s=s.replace('parameter TARGET=0,','parameter FMCASE=0,HISTORY=0,FASTVIDEO=1,TARGET=0,');
s=s.replace('systeme=1;','systeme=0;');
s=s.replace(".audio_in_l2(16'd0),.audio_in_r2(16'd0)",'.audio_in_l2({fmout[12:0],3\'b0}),.audio_in_r2({fmout[12:0],3\'b0})');
s=s.replace(".audio_in_l2(16'd0),.audio_in_r2(16'd0)",'.audio_in_l2({rfmout[12:0],3\'b0}),.audio_in_r2({rfmout[12:0],3\'b0})');
s=s.replace('repeat(SEED)tick;',`fmsetup; repeat(SEED)tick;`);
s=s.replace('qmode=1;put(8\'h9f);',`qmode=1; fmwrite(8'h30,8'hf0); fmwrite(8'h10,8'h37+pass); repeat(5000+pass*103)tick; put(8'h9f);`);
s=s.replace('reg[63:0]immutable_image', 'integer fmerrors=0,fmfirst=-1;reg[13:0]ofm[0:20000];\nreg[63:0]immutable_image');
s=s.replace('"%h %h %h %h %h %h",{rl,rr_audio},rpsgcfg,rpsgext,rpsgdiv,{raudio,rar},rclkd','"%h %h %h %h %h %h %h",{rl,rr_audio},rpsgcfg,rpsgext,rpsgdiv,{raudio,rar},rclkd,rfmout');
s=s.replace('"%h %h %h %h %h %h",oracle[k],ocfg[k],oext[k],odiv[k],osnd[k],ophase[k]);if(scan!=6)', '"%h %h %h %h %h %h %h",oracle[k],ocfg[k],oext[k],odiv[k],osnd[k],ophase[k],ofm[k]);if(scan!=7)');
s=s.replace('errors=0;first=-1;raw_errors=0;', 'errors=0;first=-1;raw_errors=0;fmerrors=0;fmfirst=-1;');
s=s.replace('if({al,ar}!==oracle[k])', 'if(fmout!==ofm[k])begin fmerrors++;if(fmfirst<0)fmfirst=k;end\nif({al,ar}!==oracle[k])');
s=s.replace('$display("RESULT pass', '$display("FM_RESULT pass%0d errors%0d first%0d",pass,fmerrors,fmfirst);\n$display("RESULT pass');
s=s.replace('if(raw_errors)$fatal', 'if(raw_errors)$fatal');
s=s.replace('$display("PASS CHARACTERIZED");', '$display("PASS CHARACTERIZED FMCASE%0d HISTORY%0d",FMCASE,HISTORY);');
s=s.replace(/\nendmodule\s*$/, `
reg fm_a=0,rfm_a=0,fwr=0;reg[7:0]fm_d=0,rfm_d=0,fbus=0;reg fa=0;
wire[13:0]fmout,rfmout;
// Literal system.vhd latch behavior; legal fixture IO writes, not CPU OUT instructions.
always@(posedge clk)begin
 if(!reset_n)begin fm_a<=0;fm_d<=0;rfm_a<=0;rfm_d<=0;end
 else begin if(!ss_freeze&&fwr)begin fm_a<=fa;fm_d<=fbus;end
 if(!qmode&&fwr)begin rfm_a<=fa;rfm_d<=fbus;end end
end
opll fm(.xin(clk),.xena(ce_cpu&&!ss_freeze&&!paused),.d(fm_d),.a(fm_a),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n),.mixout(fmout));
opll rfm(.xin(clk),.xena(rce_cpu&&!holdref&&!rpaused),.d(rfm_d),.a(rfm_a),.cs_n(1'b0),.we_n(1'b0),.ic_n(reset_n),.mixout(rfmout));
task fmwrite(input[7:0]addr,input[7:0]data);begin
 fa=0;fbus=addr;fwr=1;repeat(60)tick;fwr=0;repeat(60)tick;
 fa=1;fbus=data;fwr=1;repeat(60)tick;fwr=0;repeat(2400)tick;
end endtask
task fmsetup;begin
 // User instrument: sustained audible carrier, adjustable attack/decay/release.
 fmwrite(0,8'h21);fmwrite(1,8'h21);fmwrite(2,8'h10);fmwrite(3,8'h07);
 fmwrite(4,FMCASE==1?8'h41:8'hf4);fmwrite(5,FMCASE==1?8'h41:8'hf4);
 fmwrite(6,FMCASE==2?8'h84:8'h04);fmwrite(7,FMCASE==2?8'h84:8'h04);
 fmwrite(8'h30,FMCASE==5?8'h10:8'h00);
 fmwrite(8'h10,HISTORY?8'hb1:8'h91);fmwrite(8'h20,8'h19);
 repeat(50000)tick; fmwrite(8'h10,8'h91);
 if(FMCASE==8)begin fmwrite(8'h31,8'h20);fmwrite(8'h11,8'hf1);fmwrite(8'h21,8'h17);end
 if(FMCASE==7)begin fmwrite(8'h36,8'h10);fmwrite(8'h37,8'h10);fmwrite(8'h38,8'h10);fmwrite(8'h16,8'h81);fmwrite(8'h17,8'h71);fmwrite(8'h18,8'h51);fmwrite(8'h26,8'h19);fmwrite(8'h27,8'h19);fmwrite(8'h28,8'h19);fmwrite(8'h0e,8'h3f);end
 if(FMCASE==4)begin if(!FASTVIDEO)while(cycle<630000)tick;fmwrite(8'h20,8'h09);end
 if(FMCASE==1||FMCASE==2)begin fmwrite(8'h20,8'h09);if(!FASTVIDEO)while(cycle<640000)tick;fmwrite(8'h20,8'h19);end
end endtask
endmodule
`);
s=s.replace('wire[13:0]fmout,rfmout;','').replace('wire[15:0]al,ar,rl,rr_audio;','wire[13:0]fmout,rfmout; wire[15:0]al,ar,rl,rr_audio;');
s=s.replace('video video1(',"generate if(FASTVIDEO)begin assign x=0;assign y=224;assign vb=1;assign hb=0;assign video_state_out=22'd0;assign rx=0;assign ry=224;assign rvb=1;assign rhb=0;assign rvideo=0;end else begin\nvideo video1(");
s=s.replace('reg[4:0]rclkd=0;', 'end endgenerate\nreg[4:0]rclkd=0;');
fs.writeFileSync(p.join(d,'audio_tb.sv'),s);
const vhdl=['vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll'];
fs.mkdirSync(p.join(d,'sim_opll'),{recursive:true});
for(const n of vhdl){const raw=fs.readFileSync(p.join(root,'rtl/VM2413',n+'.vhd'),'latin1'),preamble=raw.slice(0,raw.search(/\blibrary\s+ieee/i));let v=raw.replace(/\bRelease\b/g,'EGRelease').replace(/VOICE_ID_TYPE'range/gi,'0 to 37').replace(/ch_type'range/gi,'0 to 8').replace(/--[^\r\n]*/g,'');
 let stack=[],insert=[];for(const m of v.matchAll(/\bcase\s+[^;\n]+?\bis\b|\bwhen\s+others\b|\bend\s+case\b/gi)){if(/^case/i.test(m[0]))stack.push(false);else if(/^when/i.test(m[0]))stack[stack.length-1]=true;else if(!stack.pop())insert.push(m.index);}for(const i of insert.reverse())v=v.slice(0,i)+'when others => null; '+v.slice(i);
 fs.writeFileSync(p.join(d,'sim_opll',n+'.vhd'),preamble+v,'latin1');}
fs.writeFileSync(p.join(d,'compile.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib work\nvcom -2008 -quiet ${vhdl.map(n=>'../../rtl/VM2413/'+n+'.vhd').join(' ')}\nvcom -2008 -quiet ../../rtl/AudioMix.vhd ../../rtl/video.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd\nvlog -quiet ../../rtl/jt89/jt89_vol.v ../../rtl/jt89/jt89_tone.v ../../rtl/jt89/jt89_noise.v ../../rtl/jt89/jt89_mixer.v ../../rtl/jt89/jt89.v\nvlog -sv -quiet savestates_sim.sv pause_fixture.sv audio_tb.sv\nquit -code 0\n`);
fs.writeFileSync(p.join(d,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -t 1ps -voptargs=+acc work.pause_tb -gFMCASE=$env(FMCASE) -gHISTORY=$env(HISTORY) -gREF=$env(REF) -gSTALL=$env(STALL) -g/pause_tb/dut/TB_FAST=1\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);
console.log('Prepared current-source controller/T80/JT89/VM2413 fixture');
fs.writeFileSync(p.join(d,'compile.do'),fs.readFileSync(p.join(d,'compile.do'),'utf8').replaceAll('../../rtl/VM2413/','sim_opll/'));
fs.writeFileSync(p.join(d,'compile.do'),fs.readFileSync(p.join(d,'compile.do'),'utf8').replaceAll('vlog -quiet','vlog -suppress 2388 -quiet').replaceAll('vlib work','vlib work_fast').replaceAll('vcom -2008','vcom -work work_fast -2008').replaceAll('vlog -','vlog -work work_fast -'));
fs.writeFileSync(p.join(d,'run.do'),fs.readFileSync(p.join(d,'run.do'),'utf8').replace('work.pause_tb','work_fast.pause_tb'));
fs.writeFileSync(p.join(d,'run.do'),fs.readFileSync(p.join(d,'run.do'),'utf8').replace('run -all',`when {/pause_tb/ss_freeze == 1} {echo "FM_BOUNDARY phase=[examine -radix hexadecimal /pause_tb/fm/pg/MEM/phase_array] envelope=[examine -radix hexadecimal /pause_tb/fm/eg/u_envelope_memory/egdata_set] slot=[examine -radix unsigned /pause_tb/fm/s0/ff_count]"; nowhen 1}\nrun -all`));
