param([int]$Turbo=1,[int]$Reference=0,[int]$Sprites=2,[int]$Proto=1,[int]$SaveOnly=0,[int]$Diagnostic=0,[int]$SavePhase=-1,[int]$CommonPhase=0,[switch]$Compile,[int]$Fix=1,[int]$ScanMask=0,[int]$Slots=8,[int]$Replays=1,[int]$Fast=0,[int]$Extended=0,[int]$Sweep=0,[int]$Natural=0,[int]$Warmup=0,[int]$PauseCapture=0,[string]$Label='case')
$ErrorActionPreference='Stop';Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Compile){& "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log;if($LASTEXITCODE){throw 'compile failed'}}
$case=Join-Path $PSScriptRoot $Label;New-Item -ItemType Directory -Force -Path $case|Out-Null
Copy-Item -LiteralPath rom.hex,run.do -Destination $case
if(!$Reference){$ref=Join-Path $PSScriptRoot $(if($Sprites -gt 2){if($Extended){"reference_ext9_t$Turbo"}else{"reference9_t$Turbo"}}else{if($Extended){"reference_ext_t$Turbo"}else{"reference_t$Turbo"}});if($Warmup){$ref=Join-Path $PSScriptRoot "reference_warm_t$Turbo"};if($PauseCapture){$ref=Join-Path $PSScriptRoot "reference_pause_t$Turbo"};Copy-Item -LiteralPath (Join-Path $ref 'reference.dat') -Destination $case}
Set-Location $case;& "$bin/vmap.exe" -c|Out-Null;& "$bin/vmap.exe" vdp_work ../vdp_work|Out-Null
$env:PROTOCOL_NATURAL=$Natural;$env:PROTOCOL_PAUSE=$PauseCapture;$env:PROTOCOL_WARMUP=$Warmup;$env:PROTOCOL_FIX=$Fix;$env:PROTOCOL_SCAN_MASK=$ScanMask;$env:PROTOCOL_SLOTS=$Slots;$env:PROTOCOL_EXT=$Extended;$env:PROTOCOL_FAST=$Fast;$env:PROTOCOL_SWEEP=$Sweep;$env:VDP_GG=1;$env:VDP_PAL=0;$env:VDP_REQUEST_X=40;$env:VDP_SPRITE_X=120;$env:VDP_SPRITES=$Sprites;$env:VDP_REPLAYS=$Replays;$env:VDP_PROTO=$Proto;$env:VDP_REFERENCE=$Reference
$env:RELEASE_TURBO=$Turbo;$env:RELEASE_SAVE_ONLY=$SaveOnly;$env:RELEASE_DIAGNOSTIC=$Diagnostic
$env:RELEASE_SAVE_PHASE=$SavePhase
$env:RELEASE_COMMON_PHASE=$CommonPhase
& "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log
if($LASTEXITCODE){throw 'runtime failed'}
