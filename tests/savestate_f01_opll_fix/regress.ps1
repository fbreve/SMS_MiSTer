param([int]$Worker=0,[int]$Workers=1)
$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$decision=Get-Content "$PSScriptRoot/early_results.json" -Raw|ConvertFrom-Json
if($decision.classification -notin @('FITS COMFORTABLY','FITS BUT REQUIRES CAUTION')){throw 'Resource gate blocks regression'}
$rows=Get-Content "$PSScriptRoot/regression_manifest.json" -Raw|ConvertFrom-Json
$families=@($rows.family|Select-Object -Unique)
for($i=$Worker;$i -lt $families.Count;$i+=$Workers){
 $family=$families[$i];$base=Join-Path $PSScriptRoot $family
 Push-Location $base
 try{
  & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
  $compile=Get-Content compile.log -Raw
  if($LASTEXITCODE -or $compile -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "Compile failed $family"}
 }finally{Pop-Location}
 foreach($r in @($rows|Where-Object family -eq $family)){
  Push-Location "$base/$($r.name)"
  try{
   & "$bin/vmap.exe" -c *> vmap.log
   & "$bin/vmap.exe" $r.library "../$($r.library)" *>> vmap.log
   & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> simulation_stdout.log
   $s=Get-Content simulation.log -Raw
   if($LASTEXITCODE -or $s -notmatch $r.marker -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]|Failed to open readmem|Failed to open file' -or ($r.also -and $s -notmatch $r.also)){Get-Content simulation.log -Tail 16;throw "Failed $family/$($r.name)"}
   Write-Output "PASS $family/$($r.name)"
  }finally{Pop-Location}
 }
}
