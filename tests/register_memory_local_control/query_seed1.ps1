$ErrorActionPreference='Stop'
$drive='W:'
if(Test-Path "$drive/"){throw "$drive already mapped"}
if(Get-Process quartus_map,quartus_fit,quartus_asm -ErrorAction SilentlyContinue | Where-Object {-not $_.HasExited}){throw 'Wait for builds to finish'}
& subst.exe $drive $PSScriptRoot
try {
 foreach($taskVariant in @('candidate_seed1')){
  if(Test-Path "$PSScriptRoot/${taskVariant}_query.log"){throw 'Never overwrite a query attempt'}
  Push-Location "$PSScriptRoot/$taskVariant"
  try {
   $ErrorActionPreference='Continue'
   & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t "$drive/query.tcl" "$drive/$taskVariant/SMS" "$drive/${taskVariant}" *> "$PSScriptRoot/${taskVariant}_query.log"
   $taskCode=$LASTEXITCODE;$ErrorActionPreference='Stop'
   if($taskCode){throw 'Timing query failed'}
   Write-Output "PASS $taskVariant detailed timing"
  } finally {Pop-Location}
 }
} finally {& subst.exe $drive /D}

