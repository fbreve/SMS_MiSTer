const fs=require('fs'),p=require('path');const here=__dirname,src=p.join(here,'protocol'),d=p.join(here,'candidate');
const read=f=>fs.readFileSync(p.join(src,f),'utf8').replace(/\r\n/g,'\n'),put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
for(const f of ['rom.hex','rom.json','T80_sim.vhd','T80s_sim.vhd','run.ps1','run.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));
for(const f of ['reference_t0','reference_t1','reference_ext_t0','reference_ext_t1','reference9_t1']){
 fs.mkdirSync(p.join(d,f),{recursive:true});fs.copyFileSync(p.join(src,f,'reference.dat'),p.join(d,f,'reference.dat'));
}
let h=read('header.svh').replace('PHASE_SWEEP=0;', 'PHASE_SWEEP=0,WARMUP=0,PAUSE_CAPTURE=0,NATURAL_PHASE=0;');
h=h.replace('savestates dut(',`localparam N=74*SLOTS;
wire[N+41:0]g06_live;wire[4777:0]sprite_restored;wire sprite_valid;
wire cpu_prepare,phase_set,replay,replay_t2;wire[1:0]phase_in;reg phase_ready=0;reg[4:0]clkd=0;reg logical_pause=0;
savestates dut(.ss_cpu_prepare(cpu_prepare),.z80_replay(replay),
 .z80_tick_active(!logical_pause),.z80_replay_t2(replay_t2),
 .clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0),
 .clock_phase_in(phase_in),.clock_phase_set(phase_set),.clock_phase_ready(phase_ready),
 .sprite_out({{(4778-(N+42)){1'b0}},g06_live}),.sprite2_out(4778'd0),
 .sprite_in(sprite_restored),.sprite2_in(),.sprite_valid(sprite_valid),`);
put('header.svh',h);
let s=read('vdp_tb.sv');s=s.slice(0,s.indexOf('\nalways@(posedge clk)begin\n if(dut.state==37'));
s=s.replace('localparam N=74*SLOTS;','').replace('wire[N+57:0]g06_live;reg[N+57:0]g06_snap;', '').replace('reg[4:0]clkd=0;','').replace('wire replay;','');
s=s.replace(/^wire\[N\+57:0\]g06_restore=.*\n/m,'').replace(/^always@\(posedge clk\)if\(dut.state==41.*\n/m,'');
s=s.replace('reg fix_hold=0,prep=0,commit=0;integer restart_stage=0;reg[4:0]phase_snap;reg[21:0]beam_snap;', '');
s=s.replace('wire frozen=(ss_freeze||fix_hold)&&!REFERENCE;', 'reg warming=WARMUP!=0;wire frozen=ss_freeze&&(!REFERENCE||warming);');
s=s.replace('if(REFERENCE)begin wait(dut.state==41);tick;end', 'if(REFERENCE&&!warming)begin wait(dut.state==41);tick;end');
s=s.replace(' $display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);', `
 if(WARMUP)begin
  // A genuine v13 LOAD invokes the documented legacy normalization. No force
  // initializes retained sprite history. Then run another complete frame.
  request(1);mem[26][63:40]=24'h48430d;
  repeat(20)tick;request(0);
  if($isunknown(g06_live))$fatal(1,"legacy normalization left unknown sprite state");
  $display("LEGAL_LEGACY_WARMUP complete spritebits%0d",N+42);
  warming=0;
  begin integer next_frame;next_frame=frame+1;
   while(!(frame>=next_frame&&vb&&x>=REQUEST_X&&y==(GG?168:192)))tick;
  end
 end
 $display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);`);
s=s.replace('if(commit)begin clkd<=phase_snap;ce_cpu<=0;ce_vdp<=0;ce_pix<=0;ce_sp<=0;end else begin', `phase_ready<=phase_set;
 if(phase_set&&(!REFERENCE||warming))begin
 case(phase_in)0:clkd<=0;1:clkd<=10;2:clkd<=20;3:clkd<=25;endcase
 ce_cpu<=0;ce_vdp<=0;ce_pix<=0;ce_sp<=0;end else begin`);
s=s.replace('.CEN(cpu_tick&&(!frozen||(prep&&replay)))', '.CEN((cpu_tick&&!frozen&&!logical_pause)||(ce_cpu&&cpu_prepare&&replay))');
s=s.replace('.RestoreHold(FIX&&frozen),', '.RestoreHold(FIX&&frozen),.ReplayT2(replay_t2),');
s=s.replace('task request(input bit saveop);begin', 'task request(input bit saveop);begin if(PAUSE_CAPTURE)begin while(cm1||cmreq)tick;logical_pause=1;end');
s=s.replace('release dut.op_cooldown;', 'release dut.op_cooldown;if(PAUSE_CAPTURE)logical_pause=0;');
s=s.replace('.video_state_in(commit?beam_snap:video_state_in),.video_state_set(video_state_set|commit)', '.video_state_in(video_state_in),.video_state_set(video_state_set&&(!REFERENCE||warming))');
s=s.replace('.probe(probe),.g06_out(g06_live),.g06_in(g06_restore),.g06_valid(PROTO!=0),.g06_freeze(frozen&&PROTO!=0)', '.ss_sprite_out(g06_live),.ss_sprite_in(sprite_restored[N+41:0]),.ss_sprite_valid(sprite_valid),.ss_freeze(frozen)');
s=s.replace('assign psg_out=0;', 'assign probe=0;assign psg_out=0;');
s=s.replace('reg[63:0]mem[0:12287];', `integer last_issue_cycle=0,phase_distance=-1,phase_profile_index=0,expected_prepare_phase=-1;
integer natural_phases[0:11]='{1,3,7,9,11,13,17,19,21,23,27,29};
reg[63:0]image_saved[0:12287];reg[63:0]mem[0:12287];`);
s=s.replace('pending<=3;readaddr<=DDRAM_ADDR;', `pending<=3;readaddr<=DDRAM_ADDR;
 if(NATURAL_PHASE&&DDRAM_ADDR==29'h07c00000+(systeme?29'h2900:29'hd00))begin
  last_issue_cycle=cycle;
  if(phase_distance>=0)begin
   expected_prepare_phase=natural_phases[phase_profile_index%12];
   pending<=3+(expected_prepare_phase-((clkd+phase_distance)%30)+30)%30;
   phase_profile_index++;
  end
 end
`);
s=s.replace('f=$fopen("image.hex","w");', 'for(n=0;n<12288;n++)image_saved[n]=mem[n];f=$fopen("image.hex","w");');
s=s.replace('  $display("RESULT pass', '  for(n=0;n<12288;n++)if(mem[n]!==image_saved[n])$fatal(1,"LOAD changed saved image word%h",n);\n  $display("RESULT pass');
s=s.replace('   checks++;', '   if(color!==pixels[j])$fatal(1,"integrated LOAD pixel mismatch x%0d y%0d dut%h ref%h",x,y,color,pixels[j]);\n   checks++;');
s=s.replace('if($isunknown(mem[n]))$fatal(1,"unknown image word%0d",n);', 'if($isunknown(mem[n]))begin if(n<10497 || n>10646)$fatal(1,"unknown established image word%0d",n);else $display("INACTIVE_PAYLOAD_UNKNOWN word%h",n);end ');
s=s.replace('if(n<10497 || n>10646)', 'if(WARMUP || n<10497 || n>10646)');
s+=`
reg[N+41:0]held_sprite;reg[135:0]held_vdp;reg was_prepare=0;integer prep_ticks=0;
always@(posedge clk)begin
 if(cpu_prepare&&!was_prepare)begin held_sprite=g06_live;held_vdp=vdp_regs;prep_ticks=0;end
 if(cpu_prepare)begin
  if(ce_cpu&&replay)prep_ticks++;
  if(g06_live!==held_sprite||vdp_regs!==held_vdp)$fatal(1,"integrated preparation advanced VDP");
  if(!ciq||!cwr)$fatal(1,"integrated preparation issued IO/write");
 end
 if(was_prepare&&!cpu_prepare)$display("INTEGRATED_PREP_DONE ticks%0d MC%0d TS%0d",prep_ticks,mc_probe,ts_probe);
 was_prepare<=cpu_prepare;
end
always@(negedge ss_freeze)if(hadfreeze&&(!REFERENCE||warming))begin #1;
 if(video_state_out!==dut.video_snap)$fatal(1,"integrated canonical beam mismatch");
 $display("INTEGRATED_RELEASE phase%0d",clkd);
end
// Semantic enable contract, expressed as first-event distances and periods,
// independently of the divider's case implementation.
integer native_age=-1;integer first_cpu,first_vdp,first_pix,first_sp;
always@(negedge ss_freeze)if(hadfreeze&&!REFERENCE)begin
 native_age=0;first_vdp=5;
 case(phase_in)
 0:begin first_cpu=10;first_pix=10;first_sp=2;end
 1:begin first_cpu=15;first_pix=10;first_sp=2;end
 2:begin first_cpu=5;first_pix=10;first_sp=2;end
 3:begin first_cpu=15;first_pix=5;first_sp=1;end
 endcase
end
always@(posedge clk)if(native_age>=0&&!ss_freeze)begin
 native_age++;
 if(ce_cpu!==(native_age>=first_cpu&&(native_age-first_cpu)%15==0)||
    ce_vdp!==(native_age>=first_vdp&&(native_age-first_vdp)%5==0)||
    ce_pix!==(native_age>=first_pix&&(native_age-first_pix)%10==0)||
    ce_sp!==(native_age>=first_sp&&(native_age-first_sp)%2==0))$fatal(1,"native enable ordering clock%0d phasecode%0d",native_age,phase_in);
 if(native_age==60)begin $display("NATIVE_ENABLE_ORDER PASS phasecode%0d hostclocks60",phase_in);native_age=-1;end
end
always@(posedge cpu_prepare)if(NATURAL_PHASE)begin
 if(phase_distance<0)begin phase_distance=cycle-last_issue_cycle;$display("NATURAL_PHASE_CALIBRATION distance%0d",phase_distance);end
 else begin
  if(clkd!==expected_prepare_phase)$fatal(1,"transport phase target failed actual%0d expected%0d",clkd,expected_prepare_phase);
  $display("NATURAL_TRANSPORT_PHASE %0d",clkd);
 end
end
endmodule
`;
put('vdp_tb.sv',s);
let c=fs.readFileSync(p.join(d,'savestates_sim.sv'),'utf8');
c=c.replace('module savestates (','module savestates #(parameter TB_FAST=0) (').replace("20'd900000;", "(TB_FAST?20'd0:20'd900000);");put('savestates_sim.sv',c);
put('compile.do',read('compile.do').replace('shifter_proto.vhd sprites_proto.vhd main_proto.vhd vdp_proto.vhd','rtl/vdp_sprite_shifter.vhd rtl/vdp_sprites.vhd rtl/vdp_main.vhd rtl/vdp.vhd'));
put('run.do',read('run.do').replace(' -gREFERENCE=', ' -gWARMUP=$env(PROTOCOL_WARMUP) -gREFERENCE='));
put('T80s_sim.vhd',read('T80s_sim.vhd').replace("RestoreHold: in std_logic := '0';", "RestoreHold: in std_logic := '0';\n        ReplayT2: in std_logic := '1';")
 .replace('elsif CEN=\'1\' and nmi_restart="10" then nmi_restart <= "11";', 'elsif CEN=\'1\' and nmi_restart="10" then\n                if ReplayT2=\'1\' then nmi_restart <= "11";else nmi_restart <= "00";end if;'));
put('run.do',fs.readFileSync(p.join(d,'run.do'),'utf8').replace(' -gREFERENCE=', ' -gPAUSE_CAPTURE=$env(PROTOCOL_PAUSE) -gREFERENCE='));
put('run.ps1',read('run.ps1').replace("[string]$Label='case'", "[int]$Natural=0,[int]$Warmup=0,[int]$PauseCapture=0,[string]$Label='case'")
 .replace('$env:PROTOCOL_FIX=$Fix;', '$env:PROTOCOL_NATURAL=$Natural;$env:PROTOCOL_PAUSE=$PauseCapture;$env:PROTOCOL_WARMUP=$Warmup;$env:PROTOCOL_FIX=$Fix;')
 .replace(';Copy-Item -LiteralPath (Join-Path $ref', ';if($Warmup){$ref=Join-Path $PSScriptRoot "reference_warm_t$Turbo"};if($PauseCapture){$ref=Join-Path $PSScriptRoot "reference_pause_t$Turbo"};Copy-Item -LiteralPath (Join-Path $ref'));
put('run.do',fs.readFileSync(p.join(d,'run.do'),'utf8').replace(' -gREFERENCE=', ' -gNATURAL_PHASE=$env(PROTOCOL_NATURAL) -gREFERENCE='));
console.log('Draft integration fixture prepared.');
