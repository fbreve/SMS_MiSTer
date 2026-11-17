param([int]$Shift,[string]$Prefix='phase')
$ErrorActionPreference='Stop'
& "$PSScriptRoot/run_ghdl.ps1" -Name "${Prefix}_$Shift" -GhdlArgs @('-r','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','feedback_tb',"-gSHIFT=$Shift",'--assert-level=error','--ieee-asserts=disable')
$taskLog=Join-Path $PSScriptRoot "worktree/tests/ym2413_fullstate/logs/${Prefix}_$Shift.stdout.log"
if(!(Select-String -LiteralPath $taskLog -SimpleMatch 'PASS FEEDBACK ALL loads=2' -Quiet)){throw 'Simulation did not reach final PASS'}
Write-Output "PASS exact phase $Shift"
