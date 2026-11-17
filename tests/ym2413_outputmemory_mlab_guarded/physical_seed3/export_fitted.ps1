$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path W:/){throw 'W: occupied'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_eda -ErrorAction SilentlyContinue){throw 'Another compilation/netlist export is active'}
node "$taskRoot/check_inputs.js"
if($LASTEXITCODE){throw 'Input hashes failed'}
& subst.exe W: $taskRoot
if($LASTEXITCODE){throw 'Mapping failed'}
try{
 Push-Location "$taskRoot/candidate"
 try{
  $ErrorActionPreference='Continue'
  & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_eda.exe --simulation=on --functional=off --maintain_design_hierarchy=on --tool=modelsim --format=verilog --output_directory=W:/candidate/fitted_netlist --read_settings_files=on --write_settings_files=off W:/candidate/SMS *> fitted_netlist.log
  $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
  Set-Content "$taskRoot/fitted_netlist.exitcode" $taskExit
  Write-Output "Post-fit timing netlist export exit=$taskExit"
 }finally{Pop-Location}
 node "$taskRoot/check_inputs.js"
 if($LASTEXITCODE){throw 'Frozen inputs changed'}
 if($taskExit){exit $taskExit}
}finally{& subst.exe W: /D}
