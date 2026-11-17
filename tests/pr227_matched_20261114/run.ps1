$ErrorActionPreference = 'Stop'
$buildRoot = $PSScriptRoot
$quartus = 'C:\intelFPGA_lite\17.0\quartus\bin64\quartus_sh.exe'
foreach ($label in @('baseline','candidate')) {
    $buildDir = Join-Path $buildRoot "seed1\$label"
    Push-Location $buildDir
    try {
        $started = (Get-Date).ToUniversalTime().ToString('o')
        & $quartus --flow compile SMS *> (Join-Path $buildRoot "seed1_$label.console.log")
        $code = $LASTEXITCODE
        @{label=$label;seed=1;started=$started;finished=(Get-Date).ToUniversalTime().ToString('o');exitCode=$code} | ConvertTo-Json | Set-Content (Join-Path $buildRoot "seed1_$label.status.json")
    } finally { Pop-Location }
}
