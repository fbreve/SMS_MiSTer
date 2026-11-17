$ErrorActionPreference='Stop'
Copy-Item "$PSScriptRoot/feedback_bank_tb.vhd" "$PSScriptRoot/worktree/tests/ym2413_fullstate/feedback_bank_tb.vhd"
& "$PSScriptRoot/run_ghdl.ps1" -Name compile_feedback_bank -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','feedback_bank_tb.vhd')
& "$PSScriptRoot/run_ghdl.ps1" -Name feedback_bank -GhdlArgs @('-r','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','feedback_bank_tb','--assert-level=error','--ieee-asserts=disable')
Get-Content "$PSScriptRoot/worktree/tests/ym2413_fullstate/logs/feedback_bank.stdout.log"
