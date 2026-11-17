$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$plan = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'plan.json') -Raw | ConvertFrom-Json
$archiveDir = Join-Path $PSScriptRoot 'raw_archives'
[System.IO.Directory]::CreateDirectory($archiveDir) | Out-Null
$records = @()
foreach ($experiment in $plan) {
    if ($experiment.raw.Count -eq 0) { continue }
    $zipPath = Join-Path $archiveDir ($experiment.name + '.zip')
    if (Test-Path -LiteralPath $zipPath) { throw "Archive already exists: $zipPath" }
    $zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
    try {
        foreach ($item in $experiment.raw) {
            $source = Join-Path (Join-Path $root $experiment.worktree) $item.path
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $source, $item.path, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
    } finally { $zip.Dispose() }
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        if ($zip.Entries.Count -ne $experiment.raw.Count) { throw 'Entry count mismatch' }
        foreach ($item in $experiment.raw) {
            $entry = $zip.GetEntry($item.path)
            if ($entry.Length -ne $item.bytes) { throw "Length mismatch: $($item.path)" }
            $stream = $entry.Open()
            $hasher = [System.Security.Cryptography.SHA256]::Create()
            try { $hash = ([BitConverter]::ToString($hasher.ComputeHash($stream))).Replace('-', '').ToLowerInvariant() }
            finally { $stream.Dispose(); $hasher.Dispose() }
            if ($hash -ne $item.sha256) { throw "SHA256 mismatch: $($item.path)" }
        }
    } finally { $zip.Dispose() }
    $records += [pscustomobject]@{ experiment=$experiment.name; zip=$zipPath; bytes=(Get-Item -LiteralPath $zipPath).Length; sha256=(Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant(); entries=$experiment.raw.Count; verified=$true }
    $records | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'raw_archive_verification.json')
    Write-Output "Verified $($experiment.name): $($experiment.raw.Count) entries"
}
