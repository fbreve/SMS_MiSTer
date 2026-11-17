$ErrorActionPreference='Stop'
$repo='C:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer'
Set-Location $repo
$initial=Get-Content (Join-Path $PSScriptRoot 'workspace-before.json') -Raw | ConvertFrom-Json
foreach($p in $initial.PSObject.Properties){if((Get-FileHash -LiteralPath (Join-Path $repo $p.Name)).Hash -cne $p.Value){throw "Workspace changed: $($p.Name)"}}
$cross=@()
foreach($label in @('A','B')){
 $first=Get-Content (Join-Path $PSScriptRoot "seed1/$label-inputs.json") -Raw | ConvertFrom-Json
 foreach($seed in 1..5){
  $m=Get-Content (Join-Path $PSScriptRoot "seed$seed/$label-inputs.json") -Raw | ConvertFrom-Json
  if(@($m.PSObject.Properties).Count -ne @($first.PSObject.Properties).Count){throw 'Manifest count mismatch'}
  $diff=@($first.PSObject.Properties | Where-Object {$_.Value -cne $m.($_.Name)} | ForEach-Object {$_.Name})
  if($seed -eq 1){if($diff.Count){throw 'Seed1 mismatch'}}elseif($diff.Count -ne 1 -or $diff[0] -ne 'SMS.qsf'){throw 'Unexpected cross-seed differences'}
  $ctx=Get-Content (Join-Path $PSScriptRoot "seed$seed/build-context.json") -Raw | ConvertFrom-Json
  $qsf=[IO.File]::ReadAllText((Join-Path $ctx.root "$label/SMS.qsf"))
  $base=[IO.File]::ReadAllText((Join-Path $repo 'SMS.qsf'))
  if($qsf.Replace("set_global_assignment -name SEED $seed",'set_global_assignment -name SEED 1') -cne $base){throw 'QSF differs beyond seed'}
  $cross+=@{seed=$seed;version=$label;cross_seed_input_differences=$diff}
 }
}
$head=git rev-parse HEAD;$branch=git branch --show-current;$status=(git status --short | Out-String).Trim();$numstat=(git diff --numstat | Out-String).Trim()
if($head -ne 'f875eb70ccd9023802ee41bb28686d11d65ee717' -or $branch -ne 'cleanup/mapper-eeprom-fallback' -or $status -ne 'M rtl/mapper_ctrl.vhd' -or $numstat -ne "6`t8`trtl/mapper_ctrl.vhd"){throw 'Final baseline mismatch'}
git diff --check
if($LASTEXITCODE){throw 'Final diff check'}
@{head=$head;branch=$branch;status=$status;numstat=$numstat;diff_check='pass';all_tracked_file_hashes_preserved=$true;cross_seed_checks=$cross;quartus_sha256=(Get-FileHash 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe').Hash} | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $PSScriptRoot 'verification.json')
'Final verification passed'
