$ErrorActionPreference='Stop'
if(Test-Path Z:/){throw 'Z: already mapped'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sta -ErrorAction SilentlyContinue | Where-Object {-not $_.HasExited}){throw 'Wait for paired builds to finish'}
& subst.exe Z: $PSScriptRoot
try {
 foreach($taskVariant in @('baseline','candidate')){
  if(Test-Path "$PSScriptRoot/${taskVariant}_query.log"){throw 'Never overwrite a query attempt'}
  Push-Location "$PSScriptRoot/$taskVariant"
  try {
   $ErrorActionPreference='Continue'
   & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/query.tcl "Z:/$taskVariant/SMS" "Z:/${taskVariant}" *> "$PSScriptRoot/${taskVariant}_query.log"
   $taskCode=$LASTEXITCODE;$ErrorActionPreference='Stop'
   if($taskCode){throw 'Timing query failed'}
   Write-Output "PASS $taskVariant detailed timing"
  } finally {Pop-Location}
 }
} finally {& subst.exe Z: /D}
