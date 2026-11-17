$ErrorActionPreference='Stop'
$d="$PSScriptRoot/baseline";$s="$PSScriptRoot/sim.ps1"
$env:NMI_SOURCE='0';$env:NMI_PROGRAM='0';$env:NMI_RUN='2';$env:NMI_TARGET='359';$env:NMI_EDGE='-15';$env:NMI_WIDTH='5'
& $s -Folder $d -Do nmi.do -Label pending
& $s -Folder $d -Do causal.do -Label causal
$env:NMI_EDGE='0';$env:NMI_WIDTH='1';& $s -Folder $d -Do nmi.do -Label capture_pulse
$env:NMI_WIDTH='0';& $s -Folder $d -Do nmi.do -Label held
$env:NMI_RUN='1';$env:NMI_EDGE='9999999';$env:NMI_WIDTH='5';& $s -Folder $d -Do nmi.do -Label pair_inactive
$env:NMI_EDGE='-15';& $s -Folder $d -Do nmi.do -Label pair_pending
