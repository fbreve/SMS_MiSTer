param([int]$Group=0,[switch]$Phase)
$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
$cases=@();if($Group -lt 4){$cases=@("cpu_stalls$Group","stalls$Group","variant$Group")}
for($caseIndex=$Group;$caseIndex -lt 33;$caseIndex+=12){$cases+= "sweep$caseIndex"}
if($Phase){$cases=@();for($caseIndex=$Group;$caseIndex -lt 16;$caseIndex+=8){$cases+="phase$caseIndex"}}
foreach($caseName in $cases){
 & $sim -c -do "$caseName.do" *> "$caseName.log"
 $code=$LASTEXITCODE
 $log=Get-Content -Raw "$caseName.log"
 if($code -ne 0 -or $log -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $log -notmatch 'PASS F11'){Get-Content "$caseName.log" -Tail 20;throw "Failed $caseName"}
 Write-Output "PASS $caseName"
}
