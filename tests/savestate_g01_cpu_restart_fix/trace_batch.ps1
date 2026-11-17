param([int]$Worker=0,[int]$Workers=3)
$ErrorActionPreference='Stop'
$cases=Get-Content -Raw "$PSScriptRoot/trace_cases.json"|ConvertFrom-Json
for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){$c=$cases[$i];& "$PSScriptRoot/trace.ps1" -Program $c.program -Offset $c.offset -IntCase $c.intCase;if($LASTEXITCODE -ne 0){throw "Failed trace $i"}}
