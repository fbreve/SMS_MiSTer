param([int]$Sprites=9,[int]$Proto=0)
$ErrorActionPreference='Stop'
Set-Location (Join-Path $PSScriptRoot $(if($Sprites -eq 9){'trace_overflow'}else{'trace_collision'}))
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
& "$bin/vmap.exe" -c | Out-Null;& "$bin/vmap.exe" vdp_work ../vdp_work | Out-Null
$env:VDP_GG=1;$env:VDP_PAL=0;$env:VDP_REQUEST_X=40;$env:VDP_SPRITE_X=120;$env:VDP_SPRITES=$Sprites;$env:VDP_REPLAYS=1;$env:VDP_REFERENCE=0;$env:VDP_PROTO=$Proto
& "$bin/vsim.exe" -c -do 'do run.do' -l dut.log
if($LASTEXITCODE){throw 'trace runtime failed'}
