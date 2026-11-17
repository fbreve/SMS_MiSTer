param([int]$Sprites=1)
$ErrorActionPreference='Stop'
$dir=Join-Path $PSScriptRoot $(if($Sprites -eq 1){'one_sprite'}else{'overflow9'})
New-Item -ItemType Directory -Force $dir | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'rom.hex') -Destination $dir
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'run.do') -Destination $dir
Set-Location $dir
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
& "$bin/vmap.exe" -c | Out-Null
& "$bin/vmap.exe" vdp_work ../vdp_work | Out-Null
$env:VDP_GG=1;$env:VDP_PAL=0;$env:VDP_REQUEST_X=40;$env:VDP_SPRITE_X=120;$env:VDP_SPRITES=$Sprites;$env:VDP_REPLAYS=1
$env:VDP_REFERENCE=1
& "$bin/vsim.exe" -c -do 'do run.do' -l reference.log
if($LASTEXITCODE){throw 'control reference failed'}
$env:VDP_REFERENCE=0
& "$bin/vsim.exe" -c -do 'do run.do' -l dut.log
if($LASTEXITCODE){throw 'control DUT failed'}
