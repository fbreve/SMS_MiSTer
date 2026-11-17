$ErrorActionPreference='Stop'
if(Test-Path Z:/){throw 'Z: is already mapped'}
if(Get-Process quartus_map,quartus_fit,quartus_sta,quartus_asm -ErrorAction SilentlyContinue){throw 'Wait until full builds complete'}
& subst.exe Z: $PSScriptRoot
try {
 foreach($taskVariant in @('baseline','candidate')) {
  Push-Location "$PSScriptRoot/$taskVariant"
  try {
   $ErrorActionPreference='Continue'
   & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/timing_paths.tcl "Z:/$taskVariant/SMS" "Z:/${taskVariant}_paths" *> "$PSScriptRoot/${taskVariant}_paths.log"
   $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
   if($taskExit){throw "TimeQuest query failed: $taskVariant"}
  } finally {Pop-Location}
 }
} finally {& subst.exe Z: /D}
