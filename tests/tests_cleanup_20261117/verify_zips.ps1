$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$old=Get-Content -LiteralPath (Join-Path $root 'tests/worktree_cleanup_20261117/raw_archive_verification.json') -Raw | ConvertFrom-Json
$plan=Get-Content -LiteralPath (Join-Path $root 'tests/worktree_cleanup_20261117/plan.json') -Raw | ConvertFrom-Json
$records=@()
foreach($archive in $old){
 $zipPath=Join-Path $root ('tests/worktree_cleanup_20261117/raw_archives/'+[IO.Path]::GetFileName($archive.zip))
 if((Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $archive.sha256){throw "ZIP hash mismatch: $zipPath"}
 $experiment=$plan | Where-Object {$_.name -eq $archive.experiment}
 $zip=[IO.Compression.ZipFile]::OpenRead($zipPath)
 try{foreach($item in $experiment.raw){
  $entry=$zip.GetEntry($item.path);if($null -eq $entry -or $entry.Length -ne $item.bytes){throw "Missing/changed entry: $($item.path)"}
  $stream=$entry.Open();$sha=[Security.Cryptography.SHA256]::Create()
  try{$hash=([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','').ToLowerInvariant()}finally{$stream.Dispose();$sha.Dispose()}
  if($hash -ne $item.sha256){throw "Entry hash mismatch: $($item.path)"}
 }}finally{$zip.Dispose()}
 $records+=[pscustomobject]@{zip=$zipPath;sha256=$archive.sha256;entries=$experiment.raw.Count;verified=$true}
 Write-Output "Verified $($archive.experiment)"
}
$records | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'previous_zip_verification.json')
