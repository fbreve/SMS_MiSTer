param([string]$Family='release_matrix')
$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem';$base=Join-Path $PSScriptRoot $Family
Push-Location $base
try {
 & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if((Get-Content compile.log -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'Release compile failed'}
}finally{Pop-Location}
$rows=Get-Content "$PSScriptRoot/release_manifest.json" -Raw|ConvertFrom-Json
foreach($r in @($rows|Where-Object family -eq $Family)){
 Push-Location "$base/$($r.id)"
 try {
  if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}; & "$bin/vmap.exe" pause_work ../pause_work *>> vmap.log
  & "$bin/vsim.exe" -c -do 'do replay.do' -l replay.log *> replay_stdout.log
  $s=Get-Content replay.log -Raw
  if($s -notmatch 'PASS MATRIX' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "Release failed $Family/$($r.id)"}
  Write-Output "PASS $Family/$($r.id)"
 }finally{Pop-Location}
}
