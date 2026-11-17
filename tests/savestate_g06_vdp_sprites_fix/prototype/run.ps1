param([int]$Sprites=2,[int]$Reference=0,[int]$Proto=1,[switch]$Compile)
$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Compile){& "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log;if($LASTEXITCODE){throw 'compile failed'}}
if($Sprites -eq 9){Set-Location overflow9;& "$bin/vmap.exe" -c | Out-Null;& "$bin/vmap.exe" vdp_work ../vdp_work | Out-Null}
$env:VDP_GG=1;$env:VDP_PAL=0;$env:VDP_REQUEST_X=40;$env:VDP_SPRITE_X=120;$env:VDP_SPRITES=$Sprites;$env:VDP_REPLAYS=1;$env:VDP_PROTO=$Proto;$env:VDP_REFERENCE=$Reference
& "$bin/vsim.exe" -c -do 'do run.do' -l $(if($Reference){'reference.log'}else{'dut.log'})
if($LASTEXITCODE){throw 'runtime failed'}
