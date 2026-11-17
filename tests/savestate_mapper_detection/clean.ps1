$ErrorActionPreference='Stop'
$base=(Resolve-Path $PSScriptRoot).Path
# Remove only this investigation's disposable simulator libraries. Preserve
# historical fixtures, evidence, and build products in every other directory.
foreach($name in 'work','boundary_work','banking_work','cpu_work','edge_work'){
 $candidate=Join-Path $base $name
 if(Test-Path -LiteralPath $candidate){
  $resolved=(Resolve-Path -LiteralPath $candidate).Path
  if(-not $resolved.StartsWith($base+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw "Out-of-scope target $resolved"}
  Remove-Item -LiteralPath $resolved -Recurse -Force
 }
}
foreach($name in 'transcript','vsim.wlf'){
 $candidate=Join-Path $base $name
 if(Test-Path -LiteralPath $candidate){Remove-Item -LiteralPath $candidate -Force}
}
