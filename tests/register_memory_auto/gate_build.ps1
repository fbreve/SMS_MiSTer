$ErrorActionPreference='Continue'
if(Test-Path Y:/){throw 'Y: already exists'}
& subst.exe Y: $PSScriptRoot
Push-Location "$PSScriptRoot/gate_candidate"
try {
 & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_map.exe --read_settings_files=on --write_settings_files=off Y:/gate_candidate/RegisterMemory *> map.log
 if($LASTEXITCODE){throw 'Standalone candidate map failed'}
 & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_eda.exe --simulation --tool=modelsim --format=verilog --functional=on --output_directory=netlist Y:/gate_candidate/RegisterMemory *> eda.log
 if($LASTEXITCODE){throw 'Standalone candidate export failed'}
} finally {Pop-Location; & subst.exe Y: /D}
