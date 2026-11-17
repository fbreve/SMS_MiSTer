const fs=require('fs'),p=require('path');const dir=__dirname,root=p.resolve(dir,'../..'),old=p.join(root,'tests/savestate_g06_g10_release'),d=p.join(dir,'protocol');
fs.mkdirSync(d,{recursive:true});const write=(f,s)=>fs.writeFileSync(p.join(d,f),s),read=f=>fs.readFileSync(p.join(old,f),'utf8').replace(/\r\n/g,'\n');
for(const f of ['rom.hex','rom.json','T80_sim.vhd','savestates_sim.sv','shifter_proto.vhd','sprites_proto.vhd','main_proto.vhd','vdp_proto.vhd'])fs.copyFileSync(p.join(old,f),p.join(d,f));
write('T80s_sim.vhd',read('T80s_sim.vhd').replace("NMIHold    : in std_logic := '0';","NMIHold    : in std_logic := '0';\n        RestoreHold: in std_logic := '0';").replace("NMIHold='1' or nmi_restart/=\"00\"", "NMIHold='1' or RestoreHold='1' or nmi_restart/=\"00\""));
write('header.svh',read('header.svh').replace('COMMON_PHASE=0;','COMMON_PHASE=0,FIX=1,SCAN_MASK=0,SLOTS=8,EXT_REFERENCE=0,PHASE_SWEEP=0;'));
let s=read('vdp_tb.sv');s=s.slice(0,s.indexOf('integer timeline'))+'endmodule\n';
const control=`
always@(posedge clk)begin
 if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
  if(dut.do_save)phase_snap<=clkd;
  if(FIX&&!REFERENCE)fix_hold<=1;
 end
 if(dut.state==41&&dut.do_save)beam_snap<=video_state_out;
end
always@(posedge ss_freeze)if(FIX&&!REFERENCE)fix_hold<=1;
always@(negedge ss_freeze)if(FIX&&!REFERENCE&&hadfreeze)restart_stage<=dut.do_save?2:1;
integer input_phase_index=0;integer legal_phases[0:11]='{1,3,7,9,11,13,17,19,21,23,27,29};
always@(negedge ss_freeze)if(PHASE_SWEEP&&FIX&&!REFERENCE&&hadfreeze&&!dut.do_save)begin
 if(ce_cpu||ce_vdp||ce_pix||ce_sp)$fatal(1,"upstream release was not quiet");
 clkd=legal_phases[input_phase_index%12];$display("PROTOCOL_INPUT_PHASE %0d",clkd);input_phase_index++;
end
always@(posedge clk)begin
 if(!reset_n)begin fix_hold<=0;prep<=0;commit<=0;restart_stage<=0;end
 else case(restart_stage)
  1:begin prep<=1;if(!replay)begin prep<=0;restart_stage<=2;end end
  2:begin prep<=0;commit<=1;restart_stage<=3;end
  3:begin commit<=0;fix_hold<=0;restart_stage<=0;$display("PROTOCOL_RELEASE cycle%0d phase%0d beam%h",cycle,clkd,beam_snap);end
 endcase
end
`;
s=s.replace('wire frozen=ss_freeze&&!REFERENCE;',`reg fix_hold=0,prep=0,commit=0;integer restart_stage=0;reg[4:0]phase_snap;reg[21:0]beam_snap;
wire frozen=(ss_freeze||fix_hold)&&!REFERENCE;\n`);
s=s.replace('.CEN(cpu_tick&&!frozen)', '.CEN(cpu_tick&&(!frozen||(prep&&replay)))');
s=s.replace('.NMIHold(dut.z80_nmi_hold),','.NMIHold(dut.z80_nmi_hold),.RestoreHold(FIX&&frozen),');
s=s.replace('assign wram_D=ram[wram_A[12:0]];', 'reg[7:0]wram_read_q;assign wram_D=wram_read_q;always@(posedge clk)wram_read_q<=ram[wram_A[12:0]];');
s=s.replace('if(!REFERENCE&&video_state_out[21:4]!==dut.video_snap[21:4])', 'if(!FIX&&!REFERENCE&&video_state_out[21:4]!==dut.video_snap[21:4])');
s=s.replace('wire[649:0]g06_live;reg[649:0]g06_snap;',`localparam N=74*SLOTS;
wire[N+57:0]g06_live;reg[N+57:0]g06_snap;
wire[N+57:0]g06_restore=SCAN_MASK?{g06_snap[N+57:N+16],16'd0,g06_snap[N-1:0]}:g06_snap;`);
s=s.replace('vdp vdp1(', 'vdp #(.MAX_SPPL(SLOTS-1)) vdp1(').replace('.g06_in(g06_snap)', '.g06_in(g06_restore)');
s=s.replace('.video_state_in(video_state_in),.video_state_set(video_state_set)', '.video_state_in(commit?beam_snap:video_state_in),.video_state_set(video_state_set|commit)');
s=s.replace('always @(negedge clk) begin\n\tce_sp <=',`always @(negedge clk) begin
 if(commit)begin clkd<=phase_snap;ce_cpu<=0;ce_vdp<=0;ce_pix<=0;ce_sp<=0;end else begin
\tce_sp <=`);
s=s.replace('\nreg[63:0]mem','\nend\nreg[63:0]mem');
s=s.replace('  $display("RESULT pass%0d collisionSamples%0d statusBusSamples%0d",pass,divs,guestdiv);','  $display("RESULT pass%0d collisionSamples%0d statusBusSamples%0d",pass,divs,guestdiv);if(FIX&&(divs||guestdiv))$fatal(1,"protocol LOAD mismatch");');
s=s.replace('integer n,j,f,checks=', 'reg[229:0]rcpu[0:3000];\ninteger n,j,f,checks=');
s=s.replace('   if(SPRITES>2)begin n=$fscanf', '   if(EXT_REFERENCE)begin n=$fscanf(f,"%h %h %h %h %h %h %h %h\\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j],racc[j],rmem[j],rcpu[j]);if(n!=8)$fatal(1,"short extended reference");end\n   else if(SPRITES>2)begin n=$fscanf');
s=s.replace('   if(SPRITES>2)$fdisplay', '   if(EXT_REFERENCE)$fdisplay(f,"%h %h %h %h %h %h %h %h",x,y,vdp_regs,color,vd,z80_reg[7:0],ram[256],z80_reg);\n   else if(SPRITES>2)$fdisplay');
s=s.replace('   if(PROTO)begin', '   if(EXT_REFERENCE&&(z80_reg!==rcpu[j]||ram[256]!==rmem[j]))$fatal(1,"extended SAVE-only CPU/RAM mismatch x%0d y%0d",x,y);\n   if(PROTO)begin');
s=s.replace('   checks++;', '   if(EXT_REFERENCE&&(z80_reg!==rcpu[j]||ram[256]!==rmem[j]))$fatal(1,"extended LOAD CPU/RAM mismatch x%0d y%0d cpu%h ref%h ram%h ref%h",x,y,z80_reg,rcpu[j],ram[256],rmem[j]);\n   if(FIX&&vdp_regs!==trace[j])$fatal(1,"full VDP LOAD mismatch x%0d y%0d",x,y);\n   checks++;');
s=s.replace('   checks++;', '   if(FIX&&color!==pixels[j])$fatal(1,"LOAD pixel mismatch x%0d y%0d dut%h ref%h",x,y,color,pixels[j]);\n   checks++;');
const check=`
reg[N+57:0]held_sprite;reg[135:0]held_vdp;reg was_prep=0;integer prep_ticks=0;
always@(negedge fix_hold)if(FIX&&!REFERENCE&&hadfreeze)begin #1;
 if(video_state_out!==beam_snap)$fatal(1,"canonical release did not restore captured beam");
end
always@(posedge clk)begin
 if(dut.state==41&&dut.do_save&&g06_live[N+2:N]!==0)$fatal(1,"accepted scanner not WAITING");
 if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)
  if(!(clkd==0||clkd==10||clkd==20||clkd==25))$fatal(1,"capture phase is not two-bit encodable");
 if(prep&&!was_prep)begin held_sprite=g06_live;held_vdp=vdp_regs;prep_ticks=0;end
 if(prep)begin
  if(cpu_tick&&replay)prep_ticks++;
  if(g06_live!==held_sprite||vdp_regs!==held_vdp)$fatal(1,"post-T VDP state advanced during CPU preparation");
  if(!ciq||!cwr)$fatal(1,"CPU preparation issued IO/write");
 end
 if(was_prep&&!prep)$display("CPU_PREPARATION_DONE ticks%0d MC%0d TS%0d",prep_ticks,mc_probe,ts_probe);
 was_prep<=prep;
end
`;
s=s.replace('endmodule',control+check+'\nendmodule');write('vdp_tb.sv',s);
let controller=read('savestates_sim.sv').replace('module savestates (','module savestates #(parameter TB_FAST=0) (').replace("20'd900000;", "(TB_FAST?20'd0:20'd900000);");
controller=controller.replace('is_old_format || (video_state_out[21:4]', 'TB_FAST || is_old_format || (video_state_out[21:4]');write('savestates_sim.sv',controller);
write('compile.do',read('compile.do').replaceAll('../../rtl','../../../rtl'));
write('run.do',read('run.do').replace(' -gREFERENCE=', ' -gFIX=$env(PROTOCOL_FIX) -gSCAN_MASK=$env(PROTOCOL_SCAN_MASK) -gSLOTS=$env(PROTOCOL_SLOTS) -gEXT_REFERENCE=$env(PROTOCOL_EXT) -gPHASE_SWEEP=$env(PROTOCOL_SWEEP) -g/vdp_tb/dut/TB_FAST=$env(PROTOCOL_FAST) -gREFERENCE='));
write('run.ps1',read('run.ps1').replace("[string]$Label='case'","[int]$Fix=1,[int]$ScanMask=0,[int]$Slots=8,[int]$Replays=1,[int]$Fast=0,[int]$Extended=0,[int]$Sweep=0,[string]$Label='case'").replace('$env:VDP_GG=1;','$env:PROTOCOL_FIX=$Fix;$env:PROTOCOL_SCAN_MASK=$ScanMask;$env:PROTOCOL_SLOTS=$Slots;$env:PROTOCOL_EXT=$Extended;$env:PROTOCOL_FAST=$Fast;$env:PROTOCOL_SWEEP=$Sweep;$env:VDP_GG=1;').replace('$env:VDP_REPLAYS=1;','$env:VDP_REPLAYS=$Replays;').replace('$ref=Join-Path $PSScriptRoot "reference_t$Turbo";', '$ref=Join-Path $PSScriptRoot $(if($Sprites -gt 2){if($Extended){"reference_ext9_t$Turbo"}else{"reference9_t$Turbo"}}else{if($Extended){"reference_ext_t$Turbo"}else{"reference_t$Turbo"}});'));
for(const turbo of [0,1]){const f=p.join(d,'reference_t'+turbo);fs.mkdirSync(f,{recursive:true});fs.copyFileSync(p.join(old,'reference_t'+turbo,'reference.dat'),p.join(f,'reference.dat'));}
write('reference.dat',read('reference_t1/reference.dat'));
fs.mkdirSync(p.join(d,'reference9_t1'),{recursive:true});fs.copyFileSync(p.join(root,'tests/savestate_g06_vdp_sprites_fix/prototype/overflow9/reference.dat'),p.join(d,'reference9_t1/reference.dat'));
console.log('Protocol adapters prepared; production untouched.');
