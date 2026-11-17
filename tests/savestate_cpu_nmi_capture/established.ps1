$ErrorActionPreference='Stop'
$folder="$PSScriptRoot/established";$sim="$PSScriptRoot/sim.ps1"
$env:NMI_SOURCE='0';$env:NMI_PROGRAM='0';$env:NMI_RUN='2';$env:NMI_TARGET='359';$env:NMI_WIDTH='5';$env:NMI_EDGE='-15'
& $sim -Folder $folder -Do nmi.do -Label pending
& $sim -Folder $folder -Do causal.do -Label causal
$env:NMI_EDGE='0';$env:NMI_WIDTH='1'
& $sim -Folder $folder -Do nmi.do -Label capture_pulse
$env:NMI_SOURCE='1';$env:NMI_EDGE='-120';$env:NMI_WIDTH='0'
& $sim -Folder $folder -Do nmi.do -Label gg_entry
$env:GG_FIXED='true'
& $sim -Folder "$PSScriptRoot/regression/gg" -Do gg.do -Label gg_direct
& $sim -Folder "$PSScriptRoot/regression/gg" -Do f11_final0.do -Label gg_ddr
