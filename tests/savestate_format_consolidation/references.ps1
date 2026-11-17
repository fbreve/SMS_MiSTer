param([int]$Worker=0,[int]$Workers=1,[string]$Family='')
$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$rows=Get-Content "$PSScriptRoot/regression_manifest.json" -Raw|ConvertFrom-Json
$families=@('reg_g05','reg_sprites','reg_g10','reg_dual','reg_g04')
if($Family){$families=@($Family)}
for($i=$Worker;$i -lt $families.Count;$i+=$Workers){
 $family=$families[$i];$base=Join-Path $PSScriptRoot $family
 Push-Location $base
 try{
  & "$bin/vsim.exe" -c -do 'do compile_golden.do' -l compile_golden.log *> compile_golden_stdout.log
  $compile=Get-Content compile_golden.log -Raw
  if($LASTEXITCODE -or $compile -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "Compile failed $family"}
 }finally{Pop-Location}
 foreach($r in @($rows|Where-Object family -eq $family)){
  Push-Location "$base/$($r.name)"
  try{
   if(-not(Test-Path modelsim.ini)){if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}}
   & "$bin/vmap.exe" $r.library "../golden_work" *>> vmap.log
   $do=(Get-Content run.do -Raw).Replace('-gREFERENCE=0','-gREFERENCE=1')
   Set-Content reference.do $do
   & "$bin/vsim.exe" -c -do 'do reference.do' -l reference_new.log *> reference_new_stdout.log
   $s=Get-Content reference_new.log -Raw
   if($LASTEXITCODE -or $s -notmatch 'REFERENCE' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]|Failed to open readmem|Failed to open file' -or $false){Get-Content reference_new.log -Tail 16;throw "Failed $family/$($r.name)"}
   Write-Output "PASS $family/$($r.name)"
  }finally{Pop-Location}
 }
}
