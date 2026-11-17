$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 $cases=@(
  @{n='old_held';a='-gEDGE=-60 -gWIDTH=0 -gRUN=2'},
  @{n='old_fresh';a='-gEDGE=-60 -gWIDTH=5 -gSECOND=0 -gRUN=2'},
  @{n='both_reference';a='-gEDGE=-60 -gWIDTH=5 -gSECOND=-15 -gWIDTH2=5 -gRUN=0'},
  @{n='semantic_p0_ref';a='-gSCHEDULE=1 -gWIDTH=5 -gRUN=0'},
  @{n='semantic_p0_save';a='-gSCHEDULE=1 -gWIDTH=5 -gRUN=1'},
  @{n='semantic_p2_ref';a='-gPROGRAM=2 -gSCHEDULE=1 -gWIDTH=5 -gRUN=0'},
  @{n='semantic_p2_save';a='-gPROGRAM=2 -gSCHEDULE=1 -gWIDTH=5 -gRUN=1'},
  @{n='ei_replay';a='-gPROGRAM=1 -gEDGE=-15 -gWIDTH=5 -gRUN=2'},
  @{n='prefix_replay';a='-gPROGRAM=3 -gEDGE=-15 -gWIDTH=5 -gRUN=2'},
  @{n='halt_replay';a='-gPROGRAM=2 -gEDGE=-60 -gWIDTH=5 -gRUN=2'}
 )
 foreach($c in $cases){
  $n=$c.n
  @"
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc nmi_causal_work.nmi_tb -gTARGET=359 $($c.a)
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
