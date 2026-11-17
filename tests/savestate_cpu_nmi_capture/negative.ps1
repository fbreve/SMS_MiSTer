$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 foreach($c in @(@{n='missing_capture_sample';a='-gCAND=1 -gEDGE=0 -gWIDTH=1 -gBAD=2'},@{n='gg_sample_too_early';a='-gCAND=2 -gSOURCE=1 -gEDGE=-45 -gWIDTH=0 -gBAD=1'},@{n='gg_advanced_twice';a='-gCAND=2 -gSOURCE=1 -gEDGE=-15 -gWIDTH=0 -gBAD=3'})){
  $n=$c.n
  @"
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc capture_work.capture_tb -gTARGET=359 $($c.a)
set NumericStdNoWarnings 1
run -all
quit -code 0
"@|Set-Content "$n.sim.do"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -l "$n.transcript" -do "$n.sim.do" *> "$n.log"
  $s=Get-Content -Raw "$n.log"
  if($s -notmatch 'DIFF cand' -or $s -notmatch '\*\* Fatal: Replay differs' -or $s -match 'PASS candidates'){throw "Negative control did not detect $n"}
  Write-Output "PASS expected divergence: $n"
 }
}finally{Pop-Location}
