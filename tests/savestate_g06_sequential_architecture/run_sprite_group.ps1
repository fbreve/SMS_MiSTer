param([int]$Worker=0,[int]$Workers=3)
$ErrorActionPreference='Stop'
$rows=Get-Content "$PSScriptRoot/sprite_cases.json" -Raw|ConvertFrom-Json
$ordered=@($rows|Where-Object name -eq 'dut_accelerated64')+@($rows|Where-Object {$_.name -notin @('dut_accelerated64','dut_collision')})
for($i=$Worker;$i -lt $ordered.Count;$i+=$Workers){
 & "$PSScriptRoot/run_case.ps1" -Family sprites -Case $ordered[$i].name
 if($LASTEXITCODE){throw 'Sprite group failed'}
}
