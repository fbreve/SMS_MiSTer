$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path Z:/){throw 'Z: occupied'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Compilation active'}
node "$taskRoot/report_hashes.js" check
if($LASTEXITCODE){throw 'Native reports changed'}
Copy-Item -LiteralPath "$taskRoot/../hdmi_path.tcl" -Destination "$taskRoot/hdmi_path.tcl"
& subst.exe Z: $taskRoot
if($LASTEXITCODE){throw 'Mapping failed'}
try {
 foreach($taskVariant in @('baseline','candidate')) {
  if(Test-Path "$taskRoot/$taskVariant/physical_shadowmask_osd.rpt"){throw 'Refuse overwrite'}
  Push-Location "$taskRoot/$taskVariant"
  try {
   $ErrorActionPreference='Continue'
   & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/hdmi_path.tcl "Z:/$taskVariant/SMS" *> shadowmask_paths.log
   $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
   if($taskExit){throw 'Shadowmask query failed'}
  } finally {Pop-Location}
 }
 node "$taskRoot/report_hashes.js" check
 if($LASTEXITCODE){throw 'Native reports changed'}
} finally {& subst.exe Z: /D}
