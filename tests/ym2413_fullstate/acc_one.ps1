param([int]$Shift)
$ErrorActionPreference='Continue'
Set-Location $PSScriptRoot
$env:ACC_SHIFT="$Shift";$env:ACC_FRAMES='6'
$log="acc_runs/shift$Shift"
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -wlf "$log.wlf" -do acc_run.do -l "$log.log" *> "$log.console.log"
$code=$LASTEXITCODE
Set-Content -LiteralPath "$log.exitcode" -Value $code
exit $code
