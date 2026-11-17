const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const dir=__dirname,root=p.resolve(dir,'../..'),old=p.join(root,'tests/savestate_g06_vdp_sprites_fix/prototype');
const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n'),write=(f,s)=>fs.writeFileSync(p.join(dir,f),s);
function sub(s,a,b){if(!s.includes(a))throw Error('missing '+a.slice(0,60));return s.replace(a,b);}
fs.mkdirSync(dir,{recursive:true});
for(const f of ['rom.hex','rom.json','T80_sim.vhd','savestates_sim.sv','shifter_proto.vhd','sprites_proto.vhd','main_proto.vhd','vdp_proto.vhd'])fs.copyFileSync(p.join(old,f),p.join(dir,f));
let s=read(p.join(old,'T80s_sim.vhd'));
s=sub(s,'NMIReplay  : out std_logic;','NMIReplay  : out std_logic;\n        MCProbe, TSProbe: out std_logic_vector(2 downto 0);\n        RestartProbe: out std_logic_vector(1 downto 0);');
s=sub(s,'    nmi_apply <=','    MCProbe<=MCycle; TSProbe<=TState; RestartProbe<=nmi_restart;\n    nmi_apply <=');write('T80s_sim.vhd',s);
s=read(p.join(old,'header.svh')).replace('PROTO=1;','PROTO=1,TURBO=1,SAVE_ONLY=0,DIAGNOSTIC=0,SAVE_PHASE=-1,COMMON_PHASE=0;');write('header.svh',s);
s=read(p.join(old,'vdp_tb.sv'));s=s.slice(0,s.indexOf('// TRACE_CSV_BEGIN'))+'endmodule\n';
const divider=read(p.join(root,'SMS.sv')).match(/always @\(negedge clk_sys\) begin\n\tce_sp <= clkd\[0\];[\s\S]*?\nend\n/)[0];
write('divider_source.sv',divider);
s=s.replace('assign cpu_ce=ce_pix;','wire cpu_tick=TURBO?ce_pix:ce_cpu;\nwire[2:0] mc_probe,ts_probe;wire[1:0]restart_probe;\nassign cpu_ce=cpu_tick;');
s=s.replace(/always@\(negedge clk\)begin cycle=cycle\+1;ce_cpu=0;[\s\S]*?endcase end/,'always@(negedge clk)cycle=cycle+1;\n'+divider.replaceAll('clk_sys','clk'));
s=s.replace('.CEN(ce_pix&&!frozen)', '.CEN(cpu_tick&&!frozen)');
s=s.replace('.NMIReplay(replay),','.NMIReplay(replay),.MCProbe(mc_probe),.TSProbe(ts_probe),.RestartProbe(restart_probe),');
s=s.replace('if(vdp_regs!==trace[j]||color!==pixels[j])$fatal(1,"prototype SAVE-only VDP mismatch x%0d y%0d",x,y);','if(vdp_regs!==trace[j]||color!==pixels[j])begin if(!DIAGNOSTIC)$fatal(1,"prototype SAVE-only VDP mismatch x%0d y%0d",x,y); if(saveflags<4)$display("DIAGNOSTIC_SAVE_MISMATCH j%0d x%0d y%0d dut%h ref%h",j,x,y,vdp_regs,trace[j]);saveflags++;end');
s=s.replace(' for(integer pass=0;pass<REPLAYS;pass=pass+1)begin',' if(SAVE_ONLY)begin $display("DONE SAVE_ONLY samples%0d mismatches%0d",savechecks,saveflags);$finish;end\n for(integer pass=0;pass<REPLAYS;pass=pass+1)begin');
const logger=`
integer timeline,cap_cycle=-1,release_cycle=-1,last_freeze=0,loads=0;
integer accepted_cycle=-1,accepted_phase=-1,release_target=-1;
// Legal external DDR backpressure after the final image write. No machine,
// divider, controller state or release predicate is forced. Leave 32 idle
// settle clocks and 255 unfreeze-count clocks before the chosen quiet edge.
always@(posedge clk)if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&dut.do_save)begin
 accepted_cycle=cycle;accepted_phase=clkd;
 if(SAVE_PHASE>=0)release_target=cycle+896040+SAVE_PHASE-clkd;
end
always@(negedge clk)begin #2;
 if(SAVE_PHASE>=0&&dut.state==55&&cycle<release_target-287)DDRAM_BUSY=1;
 else DDRAM_BUSY=0;
end
initial begin timeline=$fopen("timeline.csv","w");$fdisplay(timeline,"cycle,clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,cpu_tick,freeze,logical_freeze,state,do_save,MC,TS,restart,M1,MREQ,RD,WR,IORQ,bus_A,DI,DO,acc,ram,x,y,sprites,vdp,status_request,status_sample");end
always@(posedge ss_freeze)begin cap_cycle=cycle;$display("DIVIDER_ARM cycle%0d clkd%0d ce%b%b%b%b save%b",cycle,clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,dut.do_save);end
always@(negedge ss_freeze)if(hadfreeze)begin release_cycle=cycle;loads=loads+!dut.do_save;$display("DIVIDER_RELEASE cycle%0d clkd%0d ce%b%b%b%b save%b",cycle,clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,dut.do_save);end
// Explicit Phase6 control only. Production and phase-only backpressure cases
// never execute this branch. The target phase1 is naturally reached at ARM.
always@(negedge ss_freeze)if(hadfreeze&&!dut.do_save&&COMMON_PHASE)begin
 if(!TURBO||accepted_phase!=0||ce_cpu||ce_vdp||ce_pix||ce_sp)$fatal(1,"invalid common-phase control");
 $display("TESTBENCH_COMMON_PHASE before%0d after1 cycle%0d",clkd,cycle);clkd=1;
end
always@(posedge clk)begin
 if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)$display("DIVIDER_ACCEPT cycle%0d clkd%0d MC%0d TS%0d",cycle,clkd,mc_probe,ts_probe);
 if(z80_set||vdp_regs_set)$display("RESTORE_STROBE cycle%0d clkd%0d CPU%b VDP%b",cycle,clkd,z80_set,vdp_regs_set);
 if(vdp_regs_set&&PROTO)begin #1;if(g06_live!==g06_snap)$fatal(1,"raw sprite restore mismatch");end
end
// Pre-edge observations: divider outputs are stable from the preceding falling edge.
always@(posedge clk)begin
 if(dut.state==37||dut.state==41||z80_set||vdp_regs_set||(dut.state==34&&dut.unfreeze_cnt>=250)||
    (REFERENCE&&cap_cycle>=0&&cycle-cap_cycle<10500)||(!frozen&&release_cycle>=0&&cycle-release_cycle<10500))
 $fdisplay(timeline,"%0d,%0d,%b,%b,%b,%b,%b,%b,%b,%0d,%b,%0d,%0d,%0d,%b,%b,%b,%b,%b,%h,%h,%h,%h,%h,%0d,%0d,%h,%h,%b,%b",cycle,clkd,ce_cpu,ce_vdp,ce_pix,ce_sp,cpu_tick,ss_freeze,frozen,dut.state,dut.do_save,mc_probe,ts_probe,restart_probe,cm1,cmreq,crd,cwr,ciq,ca,vd,co,z80_reg[7:0],ram[256],x,y,g06_live,vdp_regs,!ciq&&!crd&&ca[7:0]==8'hbf,cpu_tick&&!frozen&&ts_probe==2&&mc_probe!=1&&!ciq&&!crd&&ca[7:0]==8'hbf);
end
final begin $fclose(timeline);end
`;
s=s.replace('endmodule',logger+'\nendmodule');write('vdp_tb.sv',s);
write('compile.do',read(p.join(old,'compile.do')).replaceAll('../../../rtl','../../rtl'));
write('run.do',read(p.join(old,'run.do')).replace(' -gREFERENCE=', ' -gTURBO=$env(RELEASE_TURBO) -gCOMMON_PHASE=$env(RELEASE_COMMON_PHASE) -gSAVE_PHASE=$env(RELEASE_SAVE_PHASE) -gSAVE_ONLY=$env(RELEASE_SAVE_ONLY) -gDIAGNOSTIC=$env(RELEASE_DIAGNOSTIC) -gREFERENCE='));
write('run.ps1',`param([int]$Turbo=1,[int]$Reference=0,[int]$Sprites=2,[int]$Proto=1,[int]$SaveOnly=0,[int]$Diagnostic=0,[int]$SavePhase=-1,[int]$CommonPhase=0,[switch]$Compile,[string]$Label='case')
$ErrorActionPreference='Stop';Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Compile){& "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log;if($LASTEXITCODE){throw 'compile failed'}}
$case=Join-Path $PSScriptRoot $Label;New-Item -ItemType Directory -Force -Path $case|Out-Null
Copy-Item -LiteralPath rom.hex,run.do -Destination $case
if(!$Reference){$ref=Join-Path $PSScriptRoot "reference_t$Turbo";Copy-Item -LiteralPath (Join-Path $ref 'reference.dat') -Destination $case}
Set-Location $case;& "$bin/vmap.exe" -c|Out-Null;& "$bin/vmap.exe" vdp_work ../vdp_work|Out-Null
$env:VDP_GG=1;$env:VDP_PAL=0;$env:VDP_REQUEST_X=40;$env:VDP_SPRITE_X=120;$env:VDP_SPRITES=$Sprites;$env:VDP_REPLAYS=1;$env:VDP_PROTO=$Proto;$env:VDP_REFERENCE=$Reference
$env:RELEASE_TURBO=$Turbo;$env:RELEASE_SAVE_ONLY=$SaveOnly;$env:RELEASE_DIAGNOSTIC=$Diagnostic
$env:RELEASE_SAVE_PHASE=$SavePhase
$env:RELEASE_COMMON_PHASE=$CommonPhase
& "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log
if($LASTEXITCODE){throw 'runtime failed'}
`);
write('.gitignore','*_work/\n*.wlf\ntranscript\nmodelsim.ini\n');
const baseline=JSON.parse(read(p.join(root,'tests/savestate_g06_vdp_sprites_fix/baseline.json')));
write('baseline.json',JSON.stringify({...baseline,branch:cp.execFileSync('git',['branch','--show-current'],{cwd:root,encoding:'utf8'}).trim(),dividerSha256:crypto.createHash('sha256').update(divider).digest('hex')},null,2));
const retained={};for(const f of ['reproduction/overflow9/dut.log','reproduction/dut.log','prototype/dut.log','prototype/trace_collision/cycles.csv','prototype/trace_reference/cycles.csv','prototype/image.hex']){const q=p.join(root,'tests/savestate_g06_vdp_sprites_fix',f);retained[f]={path:p.relative(dir,q).replaceAll('\\','/'),sha256:crypto.createHash('sha256').update(fs.readFileSync(q)).digest('hex')};}write('retained.json',JSON.stringify(retained,null,2));
