$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Copy-Item "$PSScriptRoot/reg_g10/header.svh" "$PSScriptRoot/reg_g10_full/header.svh"
Push-Location "$PSScriptRoot/reg_g10_full"
try {
 & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if((Get-Content compile.log -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'Full flush compile failed'}
 Push-Location dut_full_flush
 try {
  & "$bin/vmap.exe" -c *> vmap.log
  & "$bin/vmap.exe" vdp_work ../vdp_work *>> vmap.log
  & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> simulation_stdout.log
  $s=Get-Content simulation.log -Raw
  if($s -notmatch 'PASS V15 VDP' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):'){throw 'Full flush failed'}
  @{passed=$true;clocks=900000;logSHA=(Get-FileHash simulation.log -Algorithm SHA256).Hash}|ConvertTo-Json|Set-Content "$PSScriptRoot/full_flush_proof.json"
  Write-Output 'PASS production full flush900000'
 } finally {Pop-Location}
} finally {Pop-Location}
