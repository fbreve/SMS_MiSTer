param([int]$Worker=0,[int]$Workers=1)
$ErrorActionPreference='Stop'
$families=@('reg_g05','reg_sprites','reg_g10','reg_dual','reg_g04')
$rows=Get-Content "$PSScriptRoot/regression_manifest.json" -Raw|ConvertFrom-Json
for($i=$Worker;$i -lt $families.Count;$i+=$Workers){
 $family=$families[$i]
 while($true){
  $ready=$true
  foreach($r in @($rows|Where-Object family -eq $family)){
   $log="$PSScriptRoot/$family/$($r.name)/reference_new.log"
   if(-not(Test-Path $log)){$ready=$false;continue}
   $s=Get-Content $log -Raw
   if($s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "Reference failed $family/$($r.name)"}
   if($s -notmatch 'PASS UNINTERRUPTED REFERENCE' -or $s -notmatch 'Errors: 0'){$ready=$false}
  }
  if($ready){break}
  Start-Sleep -Seconds 10
 }
 Write-Output "Reference gate passed $family"
 & "$PSScriptRoot/regress.ps1" -Family $family
}
