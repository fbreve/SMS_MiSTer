$ErrorActionPreference='Stop'
& "$PSScriptRoot/run_ghdl.ps1" -Name compile_bank -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','bank_tb.vhd')
& "$PSScriptRoot/run_ghdl.ps1" -Name bank -GhdlArgs @('-r','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','bank_tb','--assert-level=error','--ieee-asserts=disable')
Write-Output 'PASS independent bank regression'
