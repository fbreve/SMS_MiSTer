param([int]$Worker=0,[int]$Workers=4)
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 $cases=Get-Content -Raw cases.json|ConvertFrom-Json
 for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){
  $c=$cases[$i];$label=$c.name;$releaseSecond=0;if($label -eq 'both_released'){$releaseSecond=1}
  @"
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps fixed_work.fixed_tb -gSOURCE=$($c.source) -gPROGRAM=$($c.program) -gEDGE=$($c.edge) -gWIDTH=$($c.width) -gSECOND=$($c.second) -gHELD=$($c.held) -gSCHEDULE=$($c.schedule) -gFORMAT=$($c.format) -gREPLAYS=$($c.replays) -gRELEASE_SECOND=$releaseSecond
set NumericStdNoWarnings 1
run -all
quit -code 0
"@|Set-Content "$label.sim.do"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do "$label.sim.do" -l "$label.transcript" -wlf "$label.wlf" *> "$label.log"
  $s=Get-Content -Raw "$label.log"
  if($LASTEXITCODE -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS F16 fixed'){throw "Failed $label"}
  Write-Output "PASS $label"
 }
}finally{Pop-Location}
