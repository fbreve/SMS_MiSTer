param([int]$Worker=0,[int]$Workers=1)
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 $cases=Get-Content -Raw cases.json|ConvertFrom-Json
 for($i=0;$i -lt $cases.Count;$i++){
  if($i%$Workers -ne $Worker){continue}
  $c=$cases[$i];$n=$c.name
  @"
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc capture_work.capture_tb -gCAND=$($c.cand) -gEDGE=$($c.edge) -gWIDTH=$($c.width) -gSOURCE=$($c.source) -gPROGRAM=$($c.program) -gSECOND=$($c.second) -gHELD=$($c.held) -gBAD=$($c.bad) -gSCHEDULE=$($c.schedule) -gTARGET=359
set NumericStdNoWarnings 1
run -all
quit -code 0
"@|Set-Content "$n.sim.do"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -l "$n.transcript" -do "$n.sim.do" *> "$n.log"
  $s=Get-Content -Raw "$n.log"
  if($LASTEXITCODE -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){throw "Failed $n"}
  Write-Output "PASS $n"
 }
}finally{Pop-Location}
