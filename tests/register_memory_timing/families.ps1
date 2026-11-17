$ErrorActionPreference='Stop'
if(Test-Path Z:/){throw 'Z: already mapped'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sta -ErrorAction SilentlyContinue | Where-Object {-not $_.HasExited}){throw 'Another Quartus process is active'}
foreach($taskSeed in @(1,2)) {
 & subst.exe Z: "$PSScriptRoot/scratch/seed$taskSeed"
 try {
  Copy-Item -LiteralPath "$PSScriptRoot/families.tcl" -Destination "Z:/families.tcl"
  foreach($taskVariant in @('baseline','candidate')) {
   $taskOut="$PSScriptRoot/seed${taskSeed}_$taskVariant"
   if(Test-Path ($taskOut+'_families.log')){throw 'Never overwrite a query attempt'}
   Push-Location "$PSScriptRoot/scratch/seed$taskSeed/$taskVariant"
   try {
    $ErrorActionPreference='Continue'
    & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/families.tcl "Z:/$taskVariant/SMS" "Z:/family_$taskVariant" *> ($taskOut+'_families.log')
    $taskCode=$LASTEXITCODE;$ErrorActionPreference='Stop'
    if($taskCode){throw "Timing query failed: seed $taskSeed $taskVariant"}
    Get-ChildItem -Path "Z:/family_${taskVariant}_*" -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination ($taskOut+$_.Name.Substring(("family_"+$taskVariant).Length))}
    Write-Output "PASS seed$taskSeed $taskVariant"
   } finally {Pop-Location}
  }
 } finally {& subst.exe Z: /D}
}
