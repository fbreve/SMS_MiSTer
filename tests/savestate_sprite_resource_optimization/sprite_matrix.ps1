param([int]$Worker=0,[int]$Workers=4)
$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$src=Join-Path $PSScriptRoot '../savestate_g06_g10_fix/sprites'
$cases=Get-Content -Raw "$src/cases.json"|ConvertFrom-Json
for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){
 $id=$cases[$i].id;$dst=Join-Path $PSScriptRoot "sprites/dut_$id"
 Push-Location $dst
 try {
  Copy-Item -LiteralPath "$src/reference_$id/reference.dat" -Destination reference.dat
  if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}
  & "$bin/vmap.exe" vdp_work ../vdp_work *>> vmap.log
  & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
  $log=Get-Content simulation.log -Raw
  if($LASTEXITCODE -or $log -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open readmem' -or $log -notmatch 'DONE VDP'){Get-Content simulation.log -Tail 18;throw "Sprite regression failed $id"}
  Write-Output "PASS sprite $id"
 }finally{Pop-Location}
}
