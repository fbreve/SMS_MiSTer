param([int]$Shift)
$ErrorActionPreference='Continue'
Set-Location $PSScriptRoot
$env:HEAL_SHIFT="$Shift";$env:HEAL_FOLLOW='142728'
$log="heal_runs/shift$Shift"
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -wlf "$log.wlf" -do heal_run.do -l "$log.log" *> "$log.console.log"
$code=$LASTEXITCODE
Set-Content -LiteralPath "$log.exitcode" -Value $code
exit $code
