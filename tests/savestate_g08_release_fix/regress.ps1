param([ValidateSet('format','raw_psg','vdp_original','vdp_g06')][string]$Fixture)
$ErrorActionPreference='Stop';$main=Join-Path $PSScriptRoot $Fixture;$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $main
try {
 & "$bin/vmap.exe" -c | Out-Null
 $script=if($Fixture -like 'vdp_*'){'compile.do'}else{'run.do'}
 & "$bin/vsim.exe" -c -do "do $script" -l simulation.log *> simulation_stdout.log
 $s=Get-Content -Raw simulation.log
 if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)'){throw "Failed $Fixture compile/run"}
 if($Fixture -like 'vdp_*'){
 foreach($id in (Get-Content -Raw cases.json | ConvertFrom-Json)){foreach($ref in 1,0){
 $leaf=$(if($ref){'reference_'}else{'dut_'})+$id
 Push-Location (Join-Path $main $leaf)
 try {
 & "$bin/vmap.exe" -c | Out-Null
 & "$bin/vmap.exe" vdp_work ../vdp_work | Out-Null
 if(!$ref){foreach($f in 'reference.dat','native_reference.dat','reference_events.dat','reference_memory.hex','reference_cram.hex'){if(Test-Path (Join-Path $main "reference_$id/$f")){Copy-Item (Join-Path $main "reference_$id/$f") $f}}}
 & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> simulation_stdout.log
 $s=Get-Content -Raw simulation.log
 if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)' -or $s -notmatch 'PASS (UNINTERRUPTED REFERENCE|(RICH )?V15 VDP)'){throw "Failed $Fixture/$leaf"}
 Write-Output "PASS $Fixture/$leaf"
 }finally{Pop-Location}
 }}
 }elseif($s -notmatch 'PASS (V16 FORMAT|PSG replay)'){throw "No pass marker $Fixture"}
 Write-Output "PASS $Fixture"
}finally{Pop-Location}
