param([int]$Turbo=1,[int]$Reference=0,[int]$Sprites=2,[int]$Proto=1,[int]$SaveOnly=0,[int]$Diagnostic=0,[int]$SavePhase=-1,[int]$CommonPhase=0,[switch]$Compile,[string]$Label='case')
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
