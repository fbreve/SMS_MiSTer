param([int]$Shift)
$ErrorActionPreference='Continue'
# Windows calls this priority "Low" in Task Manager; native children inherit it.
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$g=(Resolve-Path ../../../tools/ghdl6/bin/ghdl.exe).Path
$log="native_runs/shift$Shift"
& $g -r --std=08 -fsynopsys -fexplicit --work=candidate_work --workdir=ghdl_candidate -Pghdl_reference acc_native_tb "-gSHIFT=$Shift" -gFRAME_EVENTS=6 --assert-level=error --ieee-asserts=disable *> "$log.log"
$code=$LASTEXITCODE;Set-Content -LiteralPath "$log.exitcode" -Value $code;exit $code
