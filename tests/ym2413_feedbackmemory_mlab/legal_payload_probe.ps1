$ErrorActionPreference='Stop'
& "$PSScriptRoot/run_ghdl.ps1" -Name compile_legal_payload_probe -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','feedback_legal_load_probe.vhd')
& "$PSScriptRoot/run_ghdl.ps1" -Name legal_payload_probe -GhdlArgs @('-r','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','feedback_legal_load_probe','-gSHIFT=1','--assert-level=error','--ieee-asserts=disable')
Get-Content "$PSScriptRoot/worktree/tests/ym2413_fullstate/logs/legal_payload_probe.stdout.log" -Tail 5
