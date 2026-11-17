const fs=require('fs'),p=require('path');const dir=__dirname,d=p.join(dir,'prototype');
let s=fs.readFileSync(p.join(d,'vdp_tb.sv'),'utf8');
if(s.includes('TRACE_CSV_BEGIN'))throw Error('already instrumented');
const block=`
// TRACE_CSV_BEGIN: observation only; native clock observations, no forcing.
integer trace_file,freeze_age=-1,release_age=-1;reg[135:0]held_regs;reg trace_started=0,first_internal=0,first_status=0;
initial begin trace_file=$fopen("cycles.csv","w");$fdisplay(trace_file,"cycle,freeze,ce_vdp,ce_pix,x,y,probe,vdp,sprites,cpu,A,RD,WR,IORQ,DO,DI,ram_C100,replay");end
always@(posedge ss_freeze)begin freeze_age=0;held_regs=vdp_regs;trace_started=1;end
always@(negedge ss_freeze)if(trace_started)begin release_age=0;end
always@(negedge clk)begin #3;
 if(freeze_age>=0)freeze_age++;
 if(release_age>=0)release_age++;
 if(dut.state==37||dut.state==41||(ss_freeze&&freeze_age<5200)||(!ss_freeze&&release_age>=0&&release_age<2000)||vdp_regs_set)
  $fdisplay(trace_file,"%0d,%b,%b,%b,%0d,%0d,%h,%h,%h,%h,%h,%b,%b,%b,%h,%h,%h,%b",cycle,ss_freeze,ce_vdp,ce_pix,x,y,probe,vdp_regs,g06_live,z80_reg,ca,crd,cwr,ciq,co,vd,ram[256],replay);
 if(ss_freeze&&dut.do_save&&!first_internal&&vdp_regs[119]!==held_regs[119])begin
  first_internal=1;$display("FIRST_FREEZE_INTERNAL cycle%0d x%0d y%0d line_overflow %b/%b",cycle,x,y,vdp_regs[119],held_regs[119]);end
 if(ss_freeze&&dut.do_save&&!first_status&&vdp_regs[118]!==held_regs[118])begin
  first_status=1;$display("FIRST_FREEZE_STATUS cycle%0d x%0d y%0d overflow %b/%b",cycle,x,y,vdp_regs[118],held_regs[118]);end
end
always@(posedge ss_freeze)$display("SPRITE_CAPTURE cycle%0d save%b packet%h",cycle,dut.do_save,g06_live);
always@(posedge clk)if(vdp_regs_set)$display("SPRITE_PRE_RESTORE cycle%0d packet%h saved%h",cycle,g06_live,g06_snap);
always@(posedge clk)if(vdp_regs_set && PROTO)begin #1;
 if(g06_live !== g06_snap)$fatal(1,"SPRITE_POST_RESTORE mismatch live%h saved%h",g06_live,g06_snap);
 $display("SPRITE_POST_RESTORE cycle%0d packet%h",cycle,g06_live);
end
final begin $fclose(trace_file);end
`;
s=s.replace('endmodule',block+'\nendmodule');fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
for(const name of ['trace_overflow','trace_collision']){
 const q=p.join(d,name);fs.mkdirSync(q,{recursive:true});fs.copyFileSync(p.join(d,'rom.hex'),p.join(q,'rom.hex'));fs.copyFileSync(p.join(d,name==='trace_overflow'?'overflow9/reference.dat':'reference.dat'),p.join(q,'reference.dat'));fs.copyFileSync(p.join(d,'run.do'),p.join(q,'run.do'));
}
fs.writeFileSync(p.join(d,'trace.ps1'),`param([int]$Sprites=9,[int]$Proto=0)
$ErrorActionPreference='Stop'
Set-Location (Join-Path $PSScriptRoot $(if($Sprites -eq 9){'trace_overflow'}else{'trace_collision'}))
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
& "$bin/vmap.exe" -c | Out-Null;& "$bin/vmap.exe" vdp_work ../vdp_work | Out-Null
$env:VDP_GG=1;$env:VDP_PAL=0;$env:VDP_REQUEST_X=40;$env:VDP_SPRITE_X=120;$env:VDP_SPRITES=$Sprites;$env:VDP_REPLAYS=1;$env:VDP_REFERENCE=0;$env:VDP_PROTO=$Proto
& "$bin/vsim.exe" -c -do 'do run.do' -l dut.log
if($LASTEXITCODE){throw 'trace runtime failed'}
`);
