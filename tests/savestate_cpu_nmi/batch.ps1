param([int]$Worker=0,[int]$Workers=1,[string]$Manifest='cases.json',[string]$Library='nmi_sync_work')
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 $cases=Get-Content -Raw $Manifest|ConvertFrom-Json
 for($i=0;$i -lt $cases.Count;$i++){
  if($i%$Workers -ne $Worker){continue}
  $c=$cases[$i];$label=$c.label
  $script=@"
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc ${Library}.nmi_tb -gSOURCE=$($c.source) -gPROGRAM=$($c.program) -gEDGE=$($c.edge) -gWIDTH=$($c.width) -gRUN=$($c.run) -gTARGET=359
set NumericStdNoWarnings 1
run -all
quit -code 0
"@
  $script|Set-Content "$label.sim.do"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -l "$label.transcript" -do "$label.sim.do" *> "$label.log"
  $s=Get-Content -Raw "$label.log"
  if($LASTEXITCODE -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){throw "Failed $label"}
  Write-Output "PASS $label"
 }
}finally{Pop-Location}


