Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
& "$bin/vmap.exe" -c|Out-Null
& "$bin/vmap.exe" vdp_work ../vdp_work|Out-Null
& "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log
