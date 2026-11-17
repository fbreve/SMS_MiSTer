const fs=require('fs'),p=require('path'),cp=require('child_process');
const d=__dirname,root=p.resolve(d,'../..'),src=p.join(root,'tests/savestate_g05_background_fix/sanity_pause');
const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n');
const sha=s=>require('crypto').createHash('sha256').update(s).digest('hex');
const tracked=cp.execFileSync('git',['ls-files'],{cwd:root,encoding:'utf8'}).trim().split('\n');
fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),files:Object.fromEntries(tracked.filter(f=>fs.existsSync(p.join(root,f))&&fs.statSync(p.join(root,f)).isFile()).map(f=>[f,sha(fs.readFileSync(p.join(root,f)))]))},null,2));
for(const f of ['T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','rom.hex'])fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.writeFileSync(p.join(d,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')));
let s=read(p.join(src,'fixed_tb.sv'));
s=s.replace('parameter CASE=0,','parameter TARGET=0,REF=0,SEED=0,N=20000,CASE=0,');
s=s.replace("reg [95:0] evolution_out = '0;","reg [159:0] evolution_out = '0;");
s=s.replace("reg audio_phase_out = '0;","wire audio_phase_out;");
s=s.replace('held=1;holdref=1;','held=1;');
s=s.replace('holdref=0;transfers=','transfers=');
// Independent reference clock recurrence: never sees a transport phase commit.
s=s.replace('wire[15:0]ca,ra;',`reg[4:0]rclkd=0;reg rce_cpu=0,rce_pix=0;
always@(negedge clk)begin rce_cpu<=0;rce_pix<=0;rclkd<=rclkd==29?0:rclkd+1;
if(rclkd==9||rclkd==24)rce_cpu<=1;if(rclkd==9||rclkd==19||rclkd==29)rce_pix<=1;end
wire[15:0]ca,ra;`);
s=s.replace('.CEN((ce_pix&&!holdref', '.CEN((rce_pix&&!holdref');
s=s.replace('.clk_en(ce_cpu&&!holdref', '.clk_en(rce_cpu&&!holdref');
// Give both PSG channels actual stereo outputs, preserving production wiring.
s=s.replace('wire pq1,pq2;', 'reg qmode=0;wire signed[10:0]a1r,a2r,rar;wire pq1,pq2;');
s=s.replace('.soundL(audio1),.soundR()', '.soundL(audio1),.soundR(a1r)');
s=s.replace('.soundL(audio2),.soundR()', '.soundL(audio2),.soundR(a2r)');
s=s.replace('.soundL(raudio),.soundR()', '.soundL(raudio),.soundR(rar)');
// Keep reference programming independent from later Q writes.
s=s.replace('.wr_n(pwr),.din(pd),.mux(8\'hff),.soundL(raudio)', '.wr_n(qmode?1\'b1:pwr),.din(pd),.mux(8\'hff),.soundL(raudio)');
// Remove old reference comparison (it deliberately ignored four release clocks).
let start=s.indexOf('always@(negedge clk)begin #2;'),end=s.indexOf('task button;',start);
s=s.slice(0,start)+s.slice(end);
start=s.indexOf('initial begin\n systeme=1;');end=s.indexOf('reg[311:0]held_psgs;',start);
s=s.slice(0,start)+`
wire[15:0]al,ar,rl,rr_audio;wire refphase;
AudioMix mix(.clk(clk),.audio_in_l1({audio1[10],audio1,4'b0}),.audio_in_r1({a1r[10],a1r,4'b0}),
.audio_in_l2(16'd0),.audio_in_r2(16'd0),.audio_l(al),.audio_r(ar),.ss_phase_out(audio_phase_out),.ss_phase_in(reset_n?audio_phase_in:1'b0),.ss_phase_set(audio_phase_set||!reset_n));
AudioMix rmix(.clk(clk),.audio_in_l1({raudio[10],raudio,4'b0}),.audio_in_r1({rar[10],rar,4'b0}),
.audio_in_l2(16'd0),.audio_in_r2(16'd0),.audio_l(rl),.audio_r(rr_audio),.ss_phase_out(refphase),.ss_phase_in(1'b0),.ss_phase_set(!reset_n));
integer fd,k,scan,errors=0,first=-1,pass,raw_errors;reg[31:0]want;reg[31:0]oracle[0:20000];
reg[55:0]ocfg[0:20000];reg[95:0]oext[0:20000];reg[3:0]odiv[0:20000];reg[21:0]osnd[0:20000];reg[4:0]ophase[0:20000];
reg[63:0]immutable_image[0:12287];
always@(posedge clk)if(dut.state==1)$display("LATE_AUDIO_CAPTURE cycle%0d phase%b div%0d",cycle,audio_phase_out,psg_div_out);
always@(posedge clk)if((dut.state==34&&dut.unfreeze_cnt>=250)||dut.state==105||dut.state==106)
$display("PRE_RELEASE cycle%0d state%0d clkd%0d cpu%b psgCE%b cen16%b out%0d mix%h/%h phase%b set%b",cycle,dut.state,clkd,ce_cpu,ce_cpu&&!ss_freeze&&!paused,psg1.cen_16,audio1,al,ar,audio_phase_out,audio_phase_set);
initial begin
for(k=0;k<12288;k=k+1)mem[k]=0;audio_control_out=11'h7ff;
systeme=1;ss_game_id=32'h12345678;repeat(6)tick;reset_n=1;repeat(2)tick;
put(8'h86);put(8'h00);put(8'h90); // audible period-six tone
if(psg1.tone0!=6||rpsg.tone0!=6)$fatal(1,"tone programming failed");
repeat(SEED)tick;
if(TARGET)storage_busy=1;request(1);
if(TARGET)begin while(!(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&psg_div_out==14))tick;storage_busy=0;end
wait(ss_freeze);
$display("CAPTURE cycle%0d clkd%0d div%0d sample%0d mixer%h/%h phase%b",cycle,clkd,psg_div_out,audio1,al,ar,audio_phase_out);
$display("PSG_CONFIG tone%0d cnt%0d out%b refTone%0d refCnt%0d cfg%h",psg1.tone0,psg1.u_tone0.cnt,psg1.u_tone0.out,rpsg.tone0,rpsg.u_tone0.cnt,psg_out);
if(REF)begin
fd=$fopen("reference.dat","w");
for(k=0;k<N;k=k+1)begin @(posedge clk);#1;$fdisplay(fd,"%h %h %h %h %h %h",{rl,rr_audio},rpsgcfg,rpsgext,rpsgdiv,{raudio,rar},rclkd);end
$fclose(fd);$display("PASS REFERENCE N%0d",N);$finish;
end else begin
fd=$fopen("reference.dat","r");if(!fd)$fatal(1,"missing reference");
for(k=0;k<N;k=k+1)begin scan=$fscanf(fd,"%h %h %h %h %h %h",oracle[k],ocfg[k],oext[k],odiv[k],osnd[k],ophase[k]);if(scan!=6)$fatal(1,"bad oracle");end $fclose(fd);
wait(!ss_freeze);
$writememh("image_save.hex",mem);
for(k=0;k<12288;k=k+1)begin if($isunknown(mem[k]))$fatal(1,"unknown image word%h",k);immutable_image[k]=mem[k];end
for(pass=0;pass<4;pass=pass+1)begin
errors=0;first=-1;raw_errors=0;
for(k=0;k<N;k=k+1)begin @(posedge clk);#1;
if({psg_out,psg_ext_out,psg_div_out,audio1,a1r,clkd}!=={ocfg[k],oext[k],odiv[k],osnd[k],ophase[k]})raw_errors++;
if({al,ar}!==oracle[k])begin errors=errors+1;if(first<0)first=k;if(errors<8)$display("AUDIO_DIFF pass%0d k%0d actual%h expected%h clkd%0d div%0d psg%0d",pass,k,{al,ar},oracle[k],clkd,psg_div_out,audio1);end
if(k>=1148&&k<=1155)$display("TRANSITION pass%0d k%0d phase%b set%b PSG%0d mixer%h/%h expected%h clkd%0d",pass,k,audio_phase_out,audio_phase_set,audio1,al,ar,oracle[k],clkd);
if(k<20)$display("FIRST pass%0d k%0d state%0d clkd%0d cpu%b sndUNDRIVEN psgCE%b psg%0d mix%h/%h phase%b set%b",pass,k,dut.state,clkd,ce_cpu,ce_cpu&&!ss_freeze&&!paused,audio1,al,ar,audio_phase_out,audio_phase_set);
end
$display("RESULT pass%0d errors%0d first%0d raw_errors%0d descriptor%h",pass,errors,first,raw_errors,mem['h20]);
if(raw_errors)$fatal(1,"raw PSG or phase mismatch: isolate mixer before verdict");
for(k=0;k<12288;k=k+1)if(mem[k]!==immutable_image[k])$fatal(1,"image changed during replay");
if(pass<3)begin qmode=1;put(8'h9f);repeat(777+pass*103)tick;put(8'h80|pass);put(8'h00);put(8'h90|pass);repeat(1000)tick;
$display("Q_HISTORY pass%0d cfg%h ext%h div%0d psg%0d audio%h/%h",pass,psg_out,psg_ext_out,psg_div_out,audio1,al,ar);
request(0);wait(ss_freeze);wait(!ss_freeze);end
end
$writememh("image.hex",mem);$display("PASS CHARACTERIZED");$finish;
end end
initial begin #1000000000;$fatal(1,"watchdog");end
`+s.slice(end);
fs.writeFileSync(p.join(d,'audio_tb.sv'),s);
let c=read(p.join(src,'compile.do')).replaceAll('../../../rtl','../../rtl').replace('vcom -work pause_work -2008 -quiet','vcom -work pause_work -2008 -quiet ../../rtl/AudioMix.vhd').replace('fixed_tb.sv','audio_tb.sv');
fs.writeFileSync(p.join(d,'compile.do'),c);
fs.writeFileSync(p.join(d,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf pause_work.pause_tb -gTARGET=$env(TARGET) -gSTALL=$env(STALL) -gREF=$env(REF) -gSEED=$env(SEED) -g/pause_tb/dut/TB_FAST=1\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);
console.log('Prepared current v15 controller, actual dual JT89/T80 and unchanged AudioMix');
