param([int]$Seed)
$ErrorActionPreference='Stop'
$here=$PSScriptRoot;$src=(Resolve-Path "$here/../physical_seed$Seed/candidate").Path;$work="$here/work_seed$Seed"
if(Test-Path $work){throw 'work exists'}
if(Test-Path W:/){throw 'W: occupied'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh,quartus_eda -ErrorAction SilentlyContinue){throw 'active'}
New-Item -ItemType Directory $work | Out-Null
robocopy $src "$work/candidate" /E /NFL /NDL /NJH /NJS /NP | Out-Null
$wk=(Resolve-Path $work).Path
subst.exe W: $wk
try{Push-Location "$wk/candidate";& C:/intelFPGA_lite/17.0/quartus/bin64/quartus_eda.exe --simulation=on --functional=off --maintain_design_hierarchy=on --tool=modelsim --format=verilog --output_directory=W:/candidate/fitted_netlist --read_settings_files=on --write_settings_files=off W:/candidate/SMS *> "$wk/eda.log"; "exit $LASTEXITCODE"}finally{Pop-Location;subst.exe W: /D}
Get-ChildItem "$wk/candidate/fitted_netlist" -Recurse | select Name,Length
