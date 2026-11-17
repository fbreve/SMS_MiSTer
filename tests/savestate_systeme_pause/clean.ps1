$ErrorActionPreference='Stop'
$evidenceRoot=(Resolve-Path -LiteralPath $PSScriptRoot).Path
$workspaceRoot=(Resolve-Path -LiteralPath "$PSScriptRoot/../..").Path
$expectedRoot=Join-Path $workspaceRoot 'tests/savestate_systeme_pause'
if($evidenceRoot -ne [IO.Path]::GetFullPath($expectedRoot)){throw 'Unexpected evidence directory'}
$targets=@(Get-ChildItem -LiteralPath $evidenceRoot -Directory | Where-Object {$_.Name -match '(^|_)work$'})
$generatedNames=@('T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv','pause_fixture.sv','pause_tb.sv','run.do','vsim.wlf','transcript','case1.log')
$targets+=@(Get-ChildItem -LiteralPath $evidenceRoot -File | Where-Object {$_.Name -in $generatedNames -or $_.Name -match '^case\d+_keep\d+_full\d+\.do$'})
foreach($target in $targets){
 $resolvedTarget=(Resolve-Path -LiteralPath $target.FullName).Path
 if([IO.Path]::GetDirectoryName($resolvedTarget) -ne $evidenceRoot){throw "Unexpected cleanup target: $resolvedTarget"}
 Remove-Item -LiteralPath $resolvedTarget -Force -Recurse
}
Write-Output "Removed $($targets.Count) F12 simulation intermediates; source fixtures, logs and reports retained."
