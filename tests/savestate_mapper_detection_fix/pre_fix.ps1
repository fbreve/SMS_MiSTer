$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 # Compile the frozen F12 fixtures, not the current fixed generator outputs.
 foreach($name in 'run','edge','cpu'){
  $body=Get-Content -Raw "baseline/$name.do"
  $body=$body.Replace('../../rtl/mapper_detect.vhd','baseline/mapper_detect.vhd')
  foreach($file in 'savestates_sim.sv','mapper_ctrl_sim.vhd','machine.sv','history_tb.sv','edge_tb.sv','cpu_reach_tb.sv','T80_sim.vhd','T80s_sim.vhd'){$body=$body.Replace($file,"baseline/$file")}
  [IO.File]::WriteAllText("$PSScriptRoot/pre_$name.do",$body)
 }
 foreach($case in 0,1){
  $env:F13_CASE="$case"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do pre_run.do *> "pre_case$case.log"
  if($LASTEXITCODE -ne 0 -or (Get-Content -Raw "pre_case$case.log") -notmatch "PASS F13 case$case expected_divergence1"){throw "Pre-fix case$case not reproduced"}
 }
 foreach($mode in 0,1){
  $env:F13_EDGE_MODE="$mode"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do pre_edge.do *> "pre_edge$mode.log"
  if($LASTEXITCODE -ne 0 -or (Get-Content -Raw "pre_edge$mode.log") -notmatch "PASS F13 edge-history MODE$mode"){throw "Pre-fix edge$mode not reproduced"}
 }
 foreach($early in 0,1){
  $env:F13_EARLY="$early"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do pre_cpu.do *> "pre_cpu$early.log"
  if($LASTEXITCODE -ne 0 -or (Get-Content -Raw "pre_cpu$early.log") -notmatch 'PASS F13 real T80/video accepted'){throw "Pre-fix real CPU capture$early failed"}
 }
 Write-Output 'PASS six pre-fix reproductions/reachability checks'
}finally{Pop-Location}
