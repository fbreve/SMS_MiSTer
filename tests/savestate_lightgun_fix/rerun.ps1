param([int]$Group=0)
$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
$cases=@();foreach($kind in 'cpu_stalls','stalls','variant'){foreach($i in 0..3){$cases+="$kind$i"}}
foreach($i in 0..32){$cases+="sweep$i"};foreach($i in 0..15){$cases+="phase$i"}
$cases+=@('hcounter_guard0','hcounter_guard3');foreach($i in 0..3){$cases+="format$i"}
for($caseIndex=$Group;$caseIndex -lt $cases.Count;$caseIndex+=18){
 $caseName=$cases[$caseIndex]
 & $sim -c -do "$caseName.do" *> "$caseName.log"
 $code=$LASTEXITCODE;$log=Get-Content -Raw "$caseName.log"
 if($code -ne 0 -or $log -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $log -notmatch 'PASS F11'){Get-Content "$caseName.log" -Tail 20;throw "Failed $caseName"}
 Write-Output "PASS $caseName"
}
