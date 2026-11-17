$ErrorActionPreference='Stop'
$taskD=Join-Path $PSScriptRoot 'worktree/tests/ym2413_fullstate'
[IO.File]::WriteAllText((Join-Path $taskD 'auto_tb.vhd'),([IO.File]::ReadAllText((Join-Path $taskD 'auto_header.vhd'))+[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'auto_body.vhd'))))
& "$PSScriptRoot/run_ghdl.ps1" -Name compile_campaign_tb -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','auto_tb.vhd')
& "$PSScriptRoot/campaign.ps1"
