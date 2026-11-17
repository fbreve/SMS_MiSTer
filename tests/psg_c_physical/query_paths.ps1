$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path Z:/){throw 'Z: occupied; no mapping changed'}
if(Get-Process quartus_map,quartus_fit,quartus_asm -ErrorAction SilentlyContinue){throw 'Compilation active; wait until the four builds finish'}
& subst.exe Z: $taskRoot
if($LASTEXITCODE){throw 'Mapping failed'}
try {
 foreach($taskBuild in @('seed1/A','seed1/C','seed2/A','seed2/C')) {
  $taskDir=Join-Path $taskRoot $taskBuild
  if(!(Select-String -LiteralPath "$taskRoot/workflow.log" -SimpleMatch "$taskBuild sta ended exit=0" -Quiet)){continue}
  if(Test-Path "$taskDir/physical_setup.rpt"){throw 'Do not overwrite existing path evidence'}
  Push-Location $taskDir
  try {
   $ErrorActionPreference='Continue'
   & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/paths.tcl "Z:/$taskBuild/SMS" physical *> paths.log
   $taskExit=$LASTEXITCODE
   $ErrorActionPreference='Stop'
   if($taskExit){throw "Read-only timing query failed $taskBuild exit=$taskExit"}
   Write-Output "PASS paths $taskBuild"
  } finally {Pop-Location}
 }
} finally {& subst.exe Z: /D}
