$ErrorActionPreference='Stop'
if(Test-Path Z:/){throw 'Z: already exists'}
& subst.exe Z: $PSScriptRoot
try {
 foreach($taskVariant in @('baseline','candidate')) {
  Push-Location "$PSScriptRoot/$taskVariant"
  try {
   $ErrorActionPreference='Continue'
   & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/register_paths.tcl "Z:/$taskVariant/SMS" "Z:/${taskVariant}_register_paths" *> "$PSScriptRoot/${taskVariant}_register_paths.log"
   $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
   if($taskExit){throw "Register query failed: $taskVariant"}
  } finally {Pop-Location}
 }
} finally {& subst.exe Z: /D}
