$ErrorActionPreference='Stop'
$evidenceRoot=(Resolve-Path -LiteralPath $PSScriptRoot).Path
$workspaceRoot=(Resolve-Path -LiteralPath "$PSScriptRoot/../..").Path
if($evidenceRoot -ne [IO.Path]::GetFullPath((Join-Path $workspaceRoot 'tests/savestate_systeme_pause_fix'))){throw 'Unexpected cleanup root'}
$archive=Join-Path $evidenceRoot 'exploratory'
New-Item -ItemType Directory -Force -Path $archive | Out-Null
foreach($name in @('exploratory_load_sampling.log','fixed_case7_stall0_full0_offset99_delay6.log')){
 $source=Join-Path $evidenceRoot $name
 if(Test-Path -LiteralPath $source){
  $resolved=(Resolve-Path -LiteralPath $source).Path
  if([IO.Path]::GetDirectoryName($resolved) -ne $evidenceRoot){throw 'Unexpected archive source'}
  Move-Item -LiteralPath $resolved -Destination (Join-Path $archive $name)
 }
}
$libraries=@(Get-ChildItem -LiteralPath $evidenceRoot -Directory | Where-Object {$_.Name -match '_work$'})
foreach($library in $libraries){
 $resolved=(Resolve-Path -LiteralPath $library.FullName).Path
 if([IO.Path]::GetDirectoryName($resolved) -ne $evidenceRoot -or ($library.Attributes -band [IO.FileAttributes]::ReparsePoint)){throw "Unsafe cleanup target: $resolved"}
 Remove-Item -LiteralPath $resolved -Recurse -Force
}
foreach($name in @('transcript','vsim.wlf')){
 $source=Join-Path $evidenceRoot $name
 if(Test-Path -LiteralPath $source){Remove-Item -LiteralPath $source -Force}
}
Write-Output "Removed $($libraries.Count) local ModelSim libraries; retained canonical logs, fixtures, baseline and complete isolated Quartus build."
