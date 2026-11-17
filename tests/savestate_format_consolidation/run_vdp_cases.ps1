param([string]$Family='reg_g10')
$ErrorActionPreference='Stop'
$rows=Get-Content "$PSScriptRoot/regression_manifest.json" -Raw|ConvertFrom-Json
foreach($r in @($rows|Where-Object family -eq $Family)){
 while($true){
  $log="$PSScriptRoot/$Family/$($r.name)/reference_new.log"
  if(Test-Path $log){
   $s=Get-Content $log -Raw
   if($s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "Reference failed $Family/$($r.name)"}
   if($s -match 'PASS UNINTERRUPTED REFERENCE' -and $s -match 'Errors: 0'){break}
  }
  Start-Sleep -Seconds 10
 }
 Write-Output "Reference ready $Family/$($r.name)"
 & "$PSScriptRoot/regress.ps1" -Family $Family -Case $r.name
}
