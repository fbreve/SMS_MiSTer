param([int]$Profile=1)
$ErrorActionPreference='Stop'
& "$PSScriptRoot/fixed.ps1" -Cases 1,3,4,7,8,9 -Stall $Profile
