const fs=require('fs'),p=require('path');const d=__dirname,root=p.resolve(d,'../..'),old=p.join(root,'tests/savestate_g08_release'),dst=p.join(d,process.argv[2]||'matrix');
fs.mkdirSync(dst,{recursive:true});const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n');
for(const f of ['T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','rom.hex'])fs.copyFileSync(p.join(old,f),p.join(dst,f));
let s=read(p.join(old,'audio_tb.sv'));
s=s.replace('parameter TARGET=0,REF=0,SEED=0,N=20000,','parameter DIVSEEK=-1,PAT=0,ROUTE=0,DUAL=0,BUS=0,HISTORY=0,BOOT=6,PAUSE=0,SEEK=0,REPLAYS=3,LATENCY=3,TARGET=0,REF=0,SEED=0,N=24000,');
s=s.replace("reg [10:0] audio_control_out = '0;","wire [10:0] audio_control_out;\nreg[7:0]mux_control=8'hff,rmux=8'hff;assign audio_control_out={3'b111,mux_control};");
s=s.replace('pending<=3;readaddr', 'pending<=LATENCY;readaddr');
s=s.replace('assign cpu_ce=ce_pix;', 'assign cpu_ce=DUAL==3?ce_cpu:ce_pix;');
s=s.replace('.CEN((ce_pix&&!ss_freeze', '.CEN(((DUAL==3?ce_cpu:ce_pix)&&!ss_freeze');
s=s.replace('.CEN((rce_pix&&!holdref', '.CEN(((DUAL==3?rce_cpu:rce_pix)&&!holdref');
s=s.replace('.ce_pix(ce_pix&&!holdref)', '.ce_pix(rce_pix&&!holdref)');
s=s.replace('joy,rvb,ss_freeze,', "joy,rvb,1'b0,");
const ds=s.indexOf('reg[4:0]rclkd=0;'),de=s.indexOf('wire[15:0]ca,ra;',ds),div=s.slice(ds,de);s=s.slice(0,ds)+s.slice(de);s=s.replace('pause_fixture p(',div+'pause_fixture p(');
s=s.replace('reg qmode=0;',"reg pwr2=1;reg[7:0]pd2=0;reg qmode=0;");
s=s.replaceAll('.mux(8\'hff),.soundL(audio1)', '.mux(mux_control),.soundL(audio1)').replaceAll('.mux(8\'hff),.soundL(audio2)', '.mux(mux_control),.soundL(audio2)').replaceAll('.mux(8\'hff),.soundL(raudio)', '.mux(rmux),.soundL(raudio)');
s=s.replace('.wr_n(pwr),.din(pd),.mux(mux_control),.soundL(audio1)',".wr_n(BUS&&!ciq&&ca[7:6]==1?cwr:pwr),.din(BUS&&!ciq&&ca[7:6]==1?co:pd),.mux(mux_control),.soundL(audio1)");
s=s.replace('.wr_n(pwr),.din(pd),.mux(mux_control),.soundL(audio2)', '.wr_n(pwr2),.din(pd2),.mux(mux_control),.soundL(audio2)');
s=s.replace(".wr_n(qmode?1'b1:pwr),.din(pd),.mux(rmux)",".wr_n(BUS&&!riq&&ra[7:6]==1?rwr:(qmode?1'b1:pwr)),.din(BUS&&!riq&&ra[7:6]==1?ro:pd),.mux(rmux)");
const a=s.indexOf('wire[15:0]al,ar,rl,rr_audio;'),b=s.indexOf('reg[311:0]held_psgs;',a);
s=s.slice(0,a)+`
wire[55:0]r2cfg;wire[95:0]r2ext;wire[3:0]r2div;wire signed[10:0]r2l,r2r;
always@(posedge clk)if(audio_ext_set)mux_control<=audio_control_in[7:0];
jt89 rpsg2(.clk(clk),.clk_en(rce_cpu&&!rpaused),.rst(!reset_n),.wr_n(qmode?1'b1:pwr2),.din(pd2),.mux(rmux),.soundL(r2l),.soundR(r2r),.ready(),.ss_out(r2cfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(r2ext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(r2div),.ss_div_in(4'd0),.ss_quiescent());
// Include capture-seeking PSG progress in the independent second reference.
wire[15:0]al,ar,rl,rr_audio;wire refphase;
wire[15:0]ml1=DUAL==1?16'd0:{audio1[10],audio1,4'b0},mr1=DUAL==1?16'd0:{a1r[10],a1r,4'b0};
wire[15:0]ml2=(DUAL==1||DUAL==2)?{audio2[10],audio2,4'b0}:16'd0,mr2=(DUAL==1||DUAL==2)?{a2r[10],a2r,4'b0}:16'd0;
wire[15:0]rml1=DUAL==1?16'd0:{raudio[10],raudio,4'b0},rmr1=DUAL==1?16'd0:{rar[10],rar,4'b0};
wire[15:0]rml2=(DUAL==1||DUAL==2)?{r2l[10],r2l,4'b0}:16'd0,rmr2=(DUAL==1||DUAL==2)?{r2r[10],r2r,4'b0}:16'd0;
AudioMix mix(.clk(clk),.audio_in_l1(ml1),.audio_in_r1(mr1),.audio_in_l2(ml2),.audio_in_r2(mr2),.audio_l(al),.audio_r(ar),.ss_phase_out(audio_phase_out),.ss_phase_in(reset_n?audio_phase_in:1'b0),.ss_phase_set(audio_phase_set||!reset_n));
AudioMix rmix(.clk(clk),.audio_in_l1(rml1),.audio_in_r1(rmr1),.audio_in_l2(rml2),.audio_in_r2(rmr2),.audio_l(rl),.audio_r(rr_audio),.ss_phase_out(refphase),.ss_phase_in(1'b0),.ss_phase_set(!reset_n));
wire[177:0]raw2=DUAL==3?178'd0:{psg2_out,psg2_ext_out,div2,audio2,a2r};
wire[177:0]rraw2=DUAL==3?178'd0:{r2cfg,r2ext,r2div,r2l,r2r};
wire[360:0]raw={clkd,psg_out,psg_ext_out,psg_div_out,audio1,a1r,raw2};
wire[360:0]rraw={rclkd,rpsgcfg,rpsgext,rpsgdiv,raudio,rar,rraw2};
reg[31:0]oracle[0:N-1];reg[360:0]raw_oracle[0:N-1];reg phase_oracle[0:N-1];reg[63:0]image_copy[0:12287];
integer edge_window=0;
always@(posedge clk)begin
 if(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&!storage_busy)edge_window=5;
 if(edge_window>0)begin
 $display("RAW_EDGE_PRE cycle%0d state%0d freeze%b clkd%0d rawCE%b gatedCE%b refCE%b cen16%b/%b div%0d/%0d cnt%0d/%0d snd%0d/%0d",cycle,dut.state,ss_freeze,clkd,ce_cpu,psg1.clk_en,rpsg.clk_en,psg1.cen_16,rpsg.cen_16,psg_div_out,rpsgdiv,psg1.u_tone0.cnt,rpsg.u_tone0.cnt,audio1,raudio);
 #1;$display("RAW_EDGE_POST cycle%0d freeze%b cen16%b/%b div%0d/%0d cnt%0d/%0d snd%0d/%0d ext%h/%h",cycle,ss_freeze,psg1.cen_16,rpsg.cen_16,psg_div_out,rpsgdiv,psg1.u_tone0.cnt,rpsg.u_tone0.cnt,audio1,raudio,psg_ext_out,rpsgext);
 edge_window--;
 end
end
integer fd,k,j,pass,scan,events=0,changed_pairs=0;reg[31:0]last_pair;reg[31:0]last_ref_pair;
function[15:0]clip(input[15:0]a,input[15:0]b);reg signed[16:0]v;begin v=$signed(a)+$signed(b);clip=(v[16]!=v[15])?(v[16]?16'h8000:16'h7fff):v[15:0];end endfunction
always@(posedge clk)begin
 if(BUS&&!ss_freeze&&!ciq&&!cwr&&ca[7:0]==6)mux_control<=co;
 if(BUS&&!riq&&!rwr&&ra[7:0]==6)rmux<=ro;
 if(dut.state==41&&dut.do_save)begin
 if({al,ar}!=={clip(ml1,ml2),clip(mr1,mr2)})$fatal(1,"historical mixer cache at accepted ARM: requires additional state");
 $display("ARM_BOUNDARY cycle%0d divider%0d phase%b outputs%h/%h raw%h",cycle,clkd,audio_phase_out,al,ar,raw);
 end
end
task put2(input[7:0]v);begin pd2=v;pwr2=0;repeat(31)tick;pwr2=1;repeat(31)tick;end endtask
task program_sound;begin
put(8'h86);put(8'h00);put(8'h90);
put2(8'hc9);put2(8'h00);put2(8'hd3);
if(PAT==1)begin put(8'h9f);put(8'hc6);put(8'h00);put(8'he7);put(8'hf0);end
if(PAT==2||PAT==3)begin put(8'hc6);put(8'h00);put(8'he7);put(8'hf3);end
if(PAT==3)begin put(8'ha9);put(8'h00);put(8'hb5);put(8'hd8);end
if(PAT==6)put(8'h9f);
if(HISTORY)begin put(8'h9f);put(8'h90);end
case(ROUTE)1:begin mux_control=8'hf1;rmux=8'hf1;end 2:begin mux_control=8'h1f;rmux=8'h1f;end 3:begin mux_control=8'hf0;rmux=8'hf0;end 4:begin mux_control=8'h0f;rmux=8'h0f;end endcase
end endtask
task future(input integer n,input bit reference_run);begin
// Identical logical-time future writes, reset after every LOAD.
if((PAT==4||PAT==6||PAT==7)&&n==500)begin pd=PAT==7?8'h9f:8'h90;pwr=0;end
if((PAT==4||PAT==6||PAT==7)&&n==531)pwr=1;
if(PAT==4&&n==900)begin pd=8'h9a;pwr=0;end
if(PAT==4&&n==931)pwr=1;
if(PAT==5&&n==500)begin pd=8'h89;pwr=0;end
if(PAT==5&&n==531)pwr=1;
if(ROUTE==5&&n==501)begin mux_control=8'h0f;rmux=8'h0f;end
if(ROUTE==5&&n==900)begin mux_control=8'hf0;rmux=8'hf0;end
if(PAUSE==3&&n==100)joy=1;
if(PAUSE==3&&n==104)joy=0;
end endtask
initial begin
for(j=0;j<12288;j=j+1)mem[j]=0;
systeme=DUAL!=3;ss_game_id=32'h12345678;repeat(BOOT)tick;reset_n=1;repeat(2)tick;program_sound;
if(PAUSE)begin while(!(vb&&x==200))tick;button;wait(paused);repeat(64)tick;end
if(SEEK)storage_busy=1;request(1);
if(SEEK)begin while(!(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&clkd==(SEEK==30?0:SEEK)&&(DIVSEEK<0||psg_div_out==DIVSEEK)))tick;storage_busy=0;end
wait(ss_freeze);#0.01;
$display("CAPTURE pat%0d route%0d dual%0d boot%0d paused%b phase%b div%0d cycle%0d",PAT,ROUTE,DUAL,BOOT,paused,audio_phase_out,psg_div_out,cycle);
if(REF)begin
fd=$fopen("reference.dat","w");last_ref_pair=0;
for(k=0;k<N;k=k+1)begin @(posedge clk);#1;
if($isunknown({rl,rr_audio,rraw,refphase}))$fatal(1,"unknown reference");
$fdisplay(fd,"%h %h %b",{rl,rr_audio},rraw,refphase);
if({rl,rr_audio}!=last_ref_pair)changed_pairs++;last_ref_pair={rl,rr_audio};
future(k,1);end
$fclose(fd);$display("PASS MATRIX REFERENCE samples%0d changed%0d",N,changed_pairs);$finish;
end
fd=$fopen("reference.dat","r");if(!fd)$fatal(1,"missing oracle");
for(k=0;k<N;k=k+1)begin scan=$fscanf(fd,"%h %h %b",oracle[k],raw_oracle[k],phase_oracle[k]);if(scan!=3)$fatal(1,"short oracle");end $fclose(fd);
wait(!ss_freeze);
for(j=0;j<12288;j=j+1)begin if($isunknown(mem[j]))$fatal(1,"unknown complete image %h",j);image_copy[j]=mem[j];end
$writememh("image_save.hex",mem);
for(pass=0;pass<=REPLAYS;pass=pass+1)begin
qmode=0;
for(k=0;k<N;k=k+1)begin @(posedge clk);#1;
if(raw!==raw_oracle[k])$fatal(1,"raw PSG/div mismatch pass%0d k%0d actual%h expected%h",pass,k,raw,raw_oracle[k]);
if({al,ar}!==oracle[k]||audio_phase_out!==phase_oracle[k])$fatal(1,"audio mismatch pass%0d k%0d audio%h expected%h phase%b/%b",pass,k,{al,ar},oracle[k],audio_phase_out,phase_oracle[k]);
if(k<8)$display("FIRST pass%0d k%0d clkd%0d raw%h inputs%h/%h/%h/%h output%h/%h phase%b paused%b",pass,k,clkd,raw,ml1,mr1,ml2,mr2,al,ar,audio_phase_out,paused);
future(k,0);end
$display("PASS SUFFIX pass%0d samples%0d progressCPU%0d PSG%0d paused%b",pass,N,progress_cpu,progress_psg,paused);
for(j=0;j<12288;j=j+1)if(mem[j]!==image_copy[j])$fatal(1,"image mutated");
if(pass<REPLAYS)begin
qmode=1;put(8'h9f);put2(8'hdf);repeat(777+pass*103)tick;put(8'h80|pass);put(8'h90|pass);put2(8'hd0|pass);repeat(1000)tick;
if(PAUSE==3&&!paused)begin button;wait(paused);repeat(64)tick;end
$display("Q pass%0d raw%h outputs%h/%h",pass,raw,al,ar);
request(0);wait(ss_freeze);wait(!ss_freeze);
end end
$writememh("image.hex",mem);$display("PASS MATRIX replays%0d N%0d",REPLAYS,N);$finish;
end
initial begin #2000000000;$fatal(1,"matrix watchdog state%0d",dut.state);end
`+s.slice(b);
s=s.replace('.clk_en(rce_cpu&&!rpaused)', '.clk_en(rce_cpu&&(!rpaused||ref_progress))');
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
const controller=require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv'));
fs.writeFileSync(p.join(dst,'savestates_sim.sv'),process.argv.includes('--prototype')?require('./phase_fix')(controller):controller);
fs.writeFileSync(p.join(dst,'compile.do'),read(p.join(old,'compile.do')).replaceAll('../../rtl','../../../rtl'));
console.log('Prepared '+dst);
