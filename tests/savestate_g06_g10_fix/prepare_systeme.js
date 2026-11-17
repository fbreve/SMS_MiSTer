const fs=require('fs'),p=require('path'),here=__dirname,root=p.resolve(here,'../..'),src=p.join(here,'psg'),d=p.join(here,'systeme');fs.mkdirSync(d,{recursive:true});
for(const f of fs.readdirSync(src))if(/\.(sv|svh|vhd|do|ps1|hex)$/.test(f)&&fs.statSync(p.join(src,f)).isFile())fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
const read=f=>fs.readFileSync(p.join(src,f),'utf8').replace(/\r\n/g,'\n'),put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
let h=read('header.svh').replace('SYSTEM_E=1;', 'SYSTEM_E=1,UI_PAUSE=0;');
h=h.replace('wire[N+41:0]g06_live;', 'wire[N+41:0]g06_live,g06_live2;wire[4777:0]sprite2_restored;wire[7:0]vd2;wire irq2;wire[11:0]color2;reg secondary_done=0;integer secondary_passes=0;')
 .replace('reg logical_pause=0;', 'wire logical_pause;wire ui_paused,ui_pp,ui_up;reg joy_pause=0;')
 .replace("reg [383:0] cram2_out = '0;", 'wire[383:0]cram2_out;').replace("reg [7:0] vram2_D = '0;", 'wire[7:0]vram2_D;')
 .replace(".sprite2_out(4778'd0)", ".sprite2_out({{(4778-(N+42)){1'b0}},g06_live2})").replace('.sprite2_in()', '.sprite2_in(sprite2_restored)');put('header.svh',h);
let s=read('vdp_tb.sv');
s=s.replace('if(phase_set)begin', 'if(phase_set&&(!REFERENCE||warming))begin')
 .replace('.video_state_set(video_state_set)', '.video_state_set(video_state_set&&(!REFERENCE||warming))')
 .replace('always@(negedge ss_freeze)if(hadfreeze)begin #1;', 'always@(negedge ss_freeze)if(hadfreeze&&(!REFERENCE||warming))begin #1;');
s=s.replace('.DI(!ciq?vd:', '.DI(!ciq?(ca[2]?vd2:vd):');
const v=s.match(/vdp #\(\.MAX_SPPL\(SLOTS-1\)\) vdp1\([^;]+;/)[0];
let v2=v.replace(' vdp1(', ' vdp2(').replace('.RD_n(crd|ciq)', '.RD_n(crd|ciq|!ca[2])').replace('.WR_n(cwr|ciq)', '.WR_n(cwr|ciq|!ca[2])')
 .replace('.IRQ_n(irq)', '.IRQ_n(irq2)').replace('.D_out(vd)', '.D_out(vd2)').replace('.color(color)', '.color(color2)')
 .replace('.smode_M1(m1)', '.smode_M1()').replace('.smode_M2(m2)', '.smode_M2()').replace('.smode_M3(m3)', '.smode_M3()').replace('.smode_M4(m4)', '.smode_M4()')
 .replace('.ss_regs_out(vdp_regs)', '.ss_regs_out(vdp2_regs)').replace('.ss_regs_in(vdp_regs_in)', '.ss_regs_in(vdp2_regs_in)').replace('.ss_regs_set(vdp_regs_set)', '.ss_regs_set(vdp2_regs_set)')
 .replaceAll('cram_out','cram2_out').replace('.ss_cram2_out(','.ss_cram_out(').replace('init_cwe|cram_wr','init_cwe|cram2_wr').replace('init_ca:cram_A','init_ca:cram2_A').replace('init_cd:cram_D',"(init_cd^12'ha5a):cram2_D")
 .replace('vram_en|setup','vram2_en|setup').replace('.ss_vram_A(vram_A)', '.ss_vram_A(vram2_A)').replace('.ss_vram_D(vram_D)', '.ss_vram_D(vram2_D)')
 .replace('init_we|vram_WE','init_we|vram2_WE').replace('init_a:vram_WA','init_a:vram2_WA').replace('init_d:vram_WD','pattern2(init_a%16384):vram2_WD')
 .replaceAll('g06_live','g06_live2').replace('sprite_restored[N+41:0]','sprite2_restored[N+41:0]');
s=s.replace(v, v.replace('.RD_n(crd|ciq)', '.RD_n(crd|ciq|ca[2])').replace('.WR_n(cwr|ciq)', '.WR_n(cwr|ciq|ca[2])')+'\n'+v2);
s=s.replace('assign vdp2_regs=0;', '');
s=s.replace("8'd167", "8'd190");
const f2=`function[7:0]pattern2(input integer n);integer off;begin
 pattern2=pattern(n);
 if(n>=14'h2000&&n<14'h2040)pattern2=n%4==1?8'hff:0;
 if(n>=14'h3f00&&n<14'h3f40)begin off=n-14'h3f00;pattern2=off<9?190:208;end
 if(n>=14'h3f80&&n<16384)pattern2=n[0]?0:40;
end endfunction
`;
s=s.replace('task request(input bit saveop);', f2+'task request(input bit saveop);');
// This board uses the production port-bit2 selection: BA/BB and BE/BF.
const prefix=JSON.parse(fs.readFileSync(p.join(here,'candidate/rom.json'),'utf8')).bytes.slice(0,40),rom=Array(65536).fill(0);let a=0;const emit=(...b)=>b.forEach(x=>rom[a++]=x);emit(...prefix);
for(const port of [0xbb,0xbf]){
 for(const [r,value] of [[0,4],[1,port===0xbb?0x40:0x42],[2,14],[3,255],[4,0],[5,0x7e],[6,4],[7,port===0xbb?3:6],[8,5],[9,0],[10,255]])emit(0x3e,value,0xd3,port,0x3e,0x80|r,0xd3,port);
 emit(0xaf,0xd3,port,0x3e,0xc0,0xd3,port,0x3e,0x53,0xd3,port-1);
}
const loop=a;emit(0xdb,0xbb,0x32,0,0xc1,0xdb,0xbf,0x32,1,0xc1,0xc3,loop&255,loop>>8);
put('rom.hex',rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');
// Actual production UI process. Reference transport is bypassed, including UI
// edge suppression; both simulations receive the same logical button events.
const sms=fs.readFileSync(p.join(root,'SMS.sv'),'utf8').replace(/\r\n/g,'\n');const start=sms.lastIndexOf('always @(posedge clk_sys) begin',sms.indexOf('joy8_r   <='));
const block=sms.slice(start,sms.indexOf('assign HDMI_BOB_DEINT')).replaceAll('clk_sys','clk').replaceAll('raw_reset','!reset_n');
put('pause_fixture.sv',`module pause_fixture(input clk,reset_n,systeme,joy8_sig,VBlank,ss_freeze,output reg se_paused,output reg se_pause_pending,output reg se_unpause_pending);
reg joy8_r,VBlank_r,ss_freeze_r;wire ss_unfreeze=ss_freeze_r&~ss_freeze;always@(posedge clk)ss_freeze_r<=ss_freeze;
${block}endmodule\n`);
s=s.replace('reg hl=0;', `reg hl=0;
pause_fixture ui(clk,reset_n,systeme,joy_pause,vblank,frozen,ui_paused,ui_pp,ui_up);
assign logical_pause=ui_paused&&!ss_capture_progress;
`);
s=s.replace('if(PAUSE_CAPTURE)begin while(cm1||cmreq)tick;logical_pause=1;end','').replace('if(PAUSE_CAPTURE)logical_pause=0;','');
s=s.replace('setup=0;runvideo=1;', 'setup=0;runvideo=1;if(UI_PAUSE)begin joy_pause=1;repeat(3)tick;joy_pause=0;wait(ui_paused);$display("SYSTEME_UI_PAUSED bus%h M1%b MREQ%b",ca,cm1,cmreq);end');
s=s.replace('reg pgloaded=0,pgdone=0;', 'reg pgloaded=0,pgdone=0;string pgfile="psg_reference.dat";').replaceAll('"psg_reference.dat","', 'pgfile,"');
// The secondary guest/status oracle is independent of the primary CPU oracle.
const extra=`
task secondary_score;integer f,k,n;reg[135:0]r;reg[11:0]c;reg[7:0]b,m;begin
 secondary_done=0;f=$fopen("secondary_reference.dat",REFERENCE?"w":"r");if(!f)$fatal(1,"missing secondary reference");
 for(k=0;k<1000;k++)begin do tick;while(!ce_pix);@(posedge clk);#1;
  if($isunknown({vdp2_regs,color2,vd2,ram[257]}))$fatal(1,"unknown initialized secondary oracle");
  if(REFERENCE)$fdisplay(f,"%h %h %h %h",vdp2_regs,color2,vd2,ram[257]);
  else begin n=$fscanf(f,"%h %h %h %h\\n",r,c,b,m);if(n!=4||{vdp2_regs,color2,vd2,ram[257]}!=={r,c,b,m})$fatal(1,"secondary VDP/status/RAM replay mismatch pixel%0d",k);end
 end
 $fclose(f);secondary_done=1;secondary_passes++;$display("SECONDARY_ORACLE PASS pixels1000");
end endtask
reg[N+41:0]held_second;reg[135:0]held_second_regs;reg second_preparing=0;
reg[229:0]frozen_cpu;reg was_frozen=0,was_cpu_prepare=0,was_dirset=0;integer isolated_cpu_clocks=0;
always@(posedge clk)begin
 if(cpu_prepare&&!second_preparing)begin held_second=g06_live2;held_second_regs=vdp2_regs;end
 if(cpu_prepare&&(g06_live2!==held_second||vdp2_regs!==held_second_regs))$fatal(1,"CPU preparation advanced VDP2");
 second_preparing<=cpu_prepare;
 #1;
 if(frozen&&was_frozen&&!cpu_prepare&&!was_cpu_prepare&&!z80_set&&!was_dirset)begin
  if(z80_reg!==frozen_cpu)$fatal(1,"peripheral/VDP preparation executed CPU architecture");isolated_cpu_clocks++;
 end
 frozen_cpu=z80_reg;was_frozen=frozen;was_cpu_prepare=cpu_prepare;was_dirset=z80_set;
end
task unpause_probe;integer f,k,n,started,latency,expected;reg[229:0]r;reg[135:0]v1,v2;reg[7:0]m1,m2;begin
 if(!UI_PAUSE)return;
 if(!ui_paused)$fatal(1,"logical Pause lost through savestate");
 started=cycle;joy_pause=1;repeat(3)tick;joy_pause=0;wait(!ui_paused);latency=cycle-started;
 f=$fopen("unpause_guest_reference.dat",REFERENCE?"w":"r");if(!f)$fatal(1,"missing unpause oracle");
 if(REFERENCE)$fdisplay(f,"%d",latency);else begin n=$fscanf(f,"%d\\n",expected);if(n!=1||latency!=expected)$fatal(1,"unpause latency differs");end
 pgfile="unpause_psg_reference.dat";pgloaded=0;fork pgscore;join_none
 for(k=0;k<1000;k++)begin do tick;while(!ce_pix);@(posedge clk);#1;
  if(REFERENCE)$fdisplay(f,"%h %h %h %h %h",z80_reg,vdp_regs,vdp2_regs,ram[256],ram[257]);
  else begin n=$fscanf(f,"%h %h %h %h %h\\n",r,v1,v2,m1,m2);if(n!=5||{z80_reg,vdp_regs,vdp2_regs,ram[256],ram[257]}!=={r,v1,v2,m1,m2})$fatal(1,"unpaused CPU/dual-VDP/RAM mismatch");end
 end
 wait(pgdone);$fclose(f);$display("SYSTEME_UNPAUSE PASS latency%0d CPU%h RAM%h/%h",latency,z80_reg,ram[256],ram[257]);
end endtask
`;
s=s.replace(/\nendmodule\s*$/,extra+'\nendmodule\n');
s=s.replace('fork pgscore;join_none', 'fork pgscore;join_none');
s=s.replace('request(1);fork pgscore;join_none', 'request(1);fork pgscore;secondary_score;join_none');
s=s.replace('request(0);fork pgscore;join_none', 'request(0);fork pgscore;secondary_score;join_none');
s=s.replace(' wait(pgdone);\n if(REFERENCE)', ' wait(pgdone&&secondary_done);\n if(REFERENCE)')
 .replace('if(REFERENCE)begin $fclose(f);', 'if(REFERENCE)begin $fclose(f);if(UI_PAUSE)unpause_probe;')
 .replace('  wait(pgdone);\n  $display("RESULT', '  wait(pgdone&&secondary_done);\n  $display("RESULT')
 .replace(' $display("DONE VDP', ' if(UI_PAUSE)unpause_probe;\n $display("DONE VDP');
put('vdp_tb.sv',s);
put('compile.do',read('compile.do').replace('savestates_sim.sv vdp_tb.sv','savestates_sim.sv pause_fixture.sv vdp_tb.sv'));
let run=read('run.ps1').replace("[string]$Label='case'", "[switch]$DeferUnpause,[int]$UiPause=0,[string]$Label='case'")
 .replace('$env:PROTOCOL_SYSE=$Sys;', '$env:SYSTEME_UI=$UiPause;$env:PROTOCOL_SYSE=$Sys;').replace('$env:VDP_GG=1;', '$env:VDP_GG=0;')
 .replace('"reference_s${Sys}_t${Turbo}"', '"reference_ui${UiPause}_t${Turbo}"')
 .replace(';Copy-Item -LiteralPath (Join-Path $ref "psg_reference.dat") -Destination $case}', ';Copy-Item -LiteralPath (Join-Path $ref "psg_reference.dat"),(Join-Path $ref "secondary_reference.dat") -Destination $case;if($UiPause -and !$DeferUnpause){Copy-Item -LiteralPath (Join-Path $ref "unpause_psg_reference.dat"),(Join-Path $ref "unpause_guest_reference.dat") -Destination $case}}');
put('run.ps1',run);put('run.do',read('run.do').replace(' -gREFERENCE=', ' -gUI_PAUSE=$env(SYSTEME_UI) -gREFERENCE=')
 .replace('set NumericStdNoWarnings', 'set NumericStdNoWarnings'));
// Both production VRAM instances require the same explicit simulator override.
put('run.do',fs.readFileSync(p.join(d,'run.do'),'utf8').replace(' -gREFERENCE=', ' -g/vdp_tb/vdp2/vdp_vram_inst/init_file=UNUSED -gREFERENCE='));
console.log('Independent dual-VDP/dual-PSG System E board and UI oracle prepared.');
