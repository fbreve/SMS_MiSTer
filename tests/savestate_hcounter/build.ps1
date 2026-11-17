param([ValidateSet('baseline','candidate')][string]$Variant = 'candidate')
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$buildRoot = Join-Path $PSScriptRoot $Variant
if (!(Test-Path -LiteralPath (Join-Path $buildRoot 'SMS.qpf'))) {
    throw "Prepare the isolated $Variant input tree first; baseline must come from the pre-fix revision."
}
# Quartus 17's old Tcl normalizer mishandles the Documents path in this sandbox.
# subst applies only to this tool's logon context; never replace an existing drive.
if (Test-Path 'Z:/') { throw 'Z: already exists; choose a free drive before running.' }
& subst.exe Z: $repoRoot
if ($LASTEXITCODE -ne 0) { throw 'Failed to map temporary build drive.' }
try {
    Push-Location $buildRoot
    try {
        & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe --flow compile "Z:/tests/savestate_hcounter/$Variant/SMS" *> compile.log
        $buildExit = $LASTEXITCODE
    } finally { Pop-Location }
} finally { & subst.exe Z: /D }
if ($buildExit -ne 0) { throw "Quartus $Variant failed: $buildExit" }
