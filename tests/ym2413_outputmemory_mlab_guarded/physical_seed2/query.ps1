$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path W:/){throw 'W: occupied'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Compilation active'}
$taskNativeReports=@{}
Get-ChildItem "$taskRoot/candidate/output_files" -File | Where-Object {$_.Extension -in '.rpt','.summary'} | ForEach-Object {$taskNativeReports[$_.FullName]=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}
$taskNativeReports | ConvertTo-Json | Set-Content "$taskRoot/native_reports_before_queries.json"
& subst.exe W: $taskRoot
if($LASTEXITCODE){throw 'Mapping failed'}
try {
 Push-Location "$taskRoot/candidate"
 try {
  if(Test-Path physical_setup.rpt){throw 'Do not overwrite path evidence'}
  $ErrorActionPreference='Continue'
  & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe -t W:/settings.tcl W:/candidate *> settings.log
  $taskSettingsExit=$LASTEXITCODE
  & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t W:/paths.tcl W:/candidate/SMS *> paths.log
  $taskPathsExit=$LASTEXITCODE
  $ErrorActionPreference='Stop'
  if($taskSettingsExit -or $taskPathsExit){throw "Queries failed: settings=$taskSettingsExit paths=$taskPathsExit"}
 } finally {Pop-Location}
 node "$taskRoot/check_inputs.js"
 if($LASTEXITCODE){throw 'Frozen inputs changed'}
 foreach($taskReport in $taskNativeReports.Keys){if((Get-FileHash -LiteralPath $taskReport -Algorithm SHA256).Hash -ne $taskNativeReports[$taskReport]){throw "Native report changed: $taskReport"}}
 Write-Output 'PASS read-only queries; native reports unchanged'
} finally {& subst.exe W: /D}
