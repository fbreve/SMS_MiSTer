param([int]$GG=1,[int]$Pal=0,[int]$RequestX=40,[int]$SpriteX=120,[int]$Sprites=2,[int]$Replays=3,[int]$Reference=0,[switch]$Compile)
$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
if($Compile){& 'C:/Program Files/nodejs/node.exe' prepare.js; & $sim -c -do 'do compile.do' -l compile.log; if($LASTEXITCODE){throw 'compile failed'}}
$env:VDP_GG=$GG;$env:VDP_PAL=$Pal;$env:VDP_REQUEST_X=$RequestX;$env:VDP_SPRITE_X=$SpriteX;$env:VDP_SPRITES=$Sprites;$env:VDP_REPLAYS=$Replays
$env:VDP_REFERENCE=$Reference
$label="gg${GG}_pal${Pal}_x${RequestX}_spr${Sprites}_sx${SpriteX}_ref${Reference}"
& $sim -c -do 'do run.do' -l "$label.log"
if($LASTEXITCODE){throw "simulation failed: $label"}
