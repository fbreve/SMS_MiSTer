$ErrorActionPreference='Stop'
& "$PSScriptRoot/run_ghdl.ps1" -Name compile_campaign_output -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','output_tb.vhd')
& "$PSScriptRoot/campaign.ps1"
