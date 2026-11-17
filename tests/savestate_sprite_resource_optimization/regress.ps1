param([int]$Worker=0,[int]$Workers=1,[switch]$SkipSprites)
$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$rows=Get-Content -Raw "$PSScriptRoot/regression_manifest.json"|ConvertFrom-Json
$families=@($rows.family|Select-Object -Unique)
function Test-Complete($row,$base){
 $file=Join-Path $base "$($row.name)/simulation.log"
 if(-not(Test-Path $file)){return $false}
 $text=Get-Content $file -Raw
 return ($text -match $row.marker -and $text -match 'Errors: 0' -and $text -notmatch '\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open readmem')
}
for($i=$Worker;$i -lt $families.Count;$i+=$Workers){
 $family=$families[$i];if($SkipSprites -and $family -eq 'sprites'){continue};$base=Join-Path $PSScriptRoot $family
 $familyRows=@($rows|Where-Object family -eq $family)
 if(@($familyRows|Where-Object {-not(Test-Complete $_ $base)}).Count -eq 0){Write-Output "PASS completed family $family";continue}
 Push-Location $base
 try {& "$bin/vsim.exe" -c -do 'do compile.do' *> compile.log;if($LASTEXITCODE){throw "Compile failed $family"};$c=Get-Content compile.log -Raw;if($c -match '\*\* (Error|Fatal)|Errors: [1-9]'){throw "Compile errors $family"}}finally{Pop-Location}
 foreach($r in @($rows|Where-Object family -eq $family)){
  if(Test-Complete $r $base){Write-Output "PASS completed $family/$($r.name)";continue}
  Push-Location (Join-Path $base $r.name)
  try {
   if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}
   & "$bin/vmap.exe" vdp_work ../vdp_work *>> vmap.log
   if($r.referenceFrom){Copy-Item -LiteralPath $r.referenceFrom -Destination reference.dat}
   & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
   $log=Get-Content simulation.log -Raw
   if($LASTEXITCODE -or $log -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $log -notmatch $r.marker){Get-Content simulation.log -Tail 18;throw "Regression failed $family/$($r.name)"}
   Write-Output "PASS $family/$($r.name)"
  }finally{Pop-Location}
 }
}
