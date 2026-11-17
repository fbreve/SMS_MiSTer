param([int]$Worker=0,[int]$Workers=4)
$ErrorActionPreference='Stop'
$cases=Get-Content -Raw "$PSScriptRoot/matrix.json"|ConvertFrom-Json
for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){
 $c=$cases[$i]
 $label="integrated_p$($c.program)_o$($c.offset)_t$($c.period)_s$($c.sys)_c0_sig$($c.signature)_i$($c.intCase)"
 $log="$PSScriptRoot/$label.log"
 if(Test-Path $log){$prior=Get-Content -Raw $log;if($prior -match 'PASS G0[19] program.*loads3 comparisons36403' -and $prior -notmatch '\*\* (Error|Fatal|Failure)|Errors: [1-9]'){Write-Output "PASS retained $label";continue}}
 & "$PSScriptRoot/integrated.ps1" -Program $c.program -Offset $c.offset -Period $c.period -Sys $c.sys -Signature $c.signature -IntCase $c.intCase
 if($LASTEXITCODE -ne 0){throw "Failed case $i"}
}
