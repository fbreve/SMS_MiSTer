$ErrorActionPreference='Stop'
Copy-Item -LiteralPath "$PSScriptRoot/output_bank_tb.vhd" -Destination "$PSScriptRoot/worktree/tests/ym2413_fullstate/output_bank_tb.vhd"
& "$PSScriptRoot/run_ghdl.ps1" -Name compile_output_bank -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','output_bank_tb.vhd')
& "$PSScriptRoot/run_ghdl.ps1" -Name output_bank -GhdlArgs @('-r','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','output_bank_tb','--assert-level=error','--ieee-asserts=disable')
Get-Content "$PSScriptRoot/worktree/tests/ym2413_fullstate/logs/output_bank.stdout.log"
