$ErrorActionPreference='Stop'
$repo='C:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer'
$art=Join-Path $repo 'output_files\eeprom_fallback_five_seed'
$root=Join-Path $env:TEMP 'sms_eeprom_five_seed_261010'
$quartus='C:\intelFPGA_lite\17.0\quartus\bin64\quartus_sh.exe'
$sta='C:\intelFPGA_lite\17.0\quartus\bin64\quartus_sta.exe'
Set-Location $repo
if((git rev-parse HEAD) -ne 'f875eb70ccd9023802ee41bb28686d11d65ee717'){throw 'HEAD mismatch'}
if((git branch --show-current) -ne 'cleanup/mapper-eeprom-fallback'){throw 'Branch mismatch'}
if((git status --short | Out-String).Trim() -ne 'M rtl/mapper_ctrl.vhd'){throw 'Unexpected status'}
git diff --check
if($LASTEXITCODE){throw 'Diff check'}
$files=@(git ls-files --stage | Where-Object {$_ -match '^100' -and $_ -notmatch '\treleases/'} | ForEach-Object {($_ -split "`t",2)[1]})
function Manifest($dir){$h=@{};foreach($f in $files){$h[$f]=(Get-FileHash -LiteralPath (Join-Path $dir $f)).Hash};return $h}
$before=@{}
$m=Get-Content (Join-Path $art 'workspace-before.json') -Raw | ConvertFrom-Json
foreach($p in $m.PSObject.Properties){$before[$p.Name]=$p.Value}
foreach($f in $files){if((Get-FileHash (Join-Path $repo $f)).Hash -cne $before[$f]){throw 'Workspace changed'}}
'Seed 2 comparison completed after correcting default-column parser' | Tee-Object -FilePath (Join-Path $art 'progress.log') -Append
foreach($seed in 3..5){
 $sa=Join-Path $art "seed$seed"; $sr=Join-Path $root "seed$seed"
 New-Item -ItemType Directory -Path $sa,$sr | Out-Null
 Copy-Item (Join-Path $art 'compare-template.ps1') (Join-Path $sa 'compare.ps1')
 $before | ConvertTo-Json | Set-Content (Join-Path $sa 'workspace-before.json')
 foreach($label in @('A','B')){
  $dir=Join-Path $sr $label;New-Item -ItemType Directory -Path $dir | Out-Null
  tar --exclude=releases -xf (Join-Path $root 'baseline.tar') -C $dir
  if($LASTEXITCODE){throw 'Extract failed'}
  if($label -eq 'B'){Copy-Item (Join-Path $repo 'rtl/mapper_ctrl.vhd') (Join-Path $dir 'rtl/mapper_ctrl.vhd')}
  $p=Join-Path $dir 'sys/build_id.tcl';$s=[IO.File]::ReadAllText($p)
  $old='[clock format [ clock seconds ] -format %y%m%d]'
  if(-not $s.Contains($old)){throw 'Date expression missing'}
  [IO.File]::WriteAllText($p,$s.Replace($old,'261006'))
  [IO.File]::WriteAllText((Join-Path $dir 'build_id.v'),'`define BUILD_DATE "261006"')
  $p=Join-Path $dir 'SMS.qsf';$s=[IO.File]::ReadAllText($p)
  if([regex]::Matches($s,'(?m)^set_global_assignment -name SEED 1\r?$').Count -ne 1){throw 'Seed assignment missing'}
  [IO.File]::WriteAllText($p,$s.Replace('set_global_assignment -name SEED 1',"set_global_assignment -name SEED $seed"))
  $h=Manifest $dir;$h['build_id.v']=(Get-FileHash (Join-Path $dir 'build_id.v')).Hash
  $h | ConvertTo-Json | Set-Content (Join-Path $sa "$label-inputs.json")
 }
 $a=Get-Content (Join-Path $sa 'A-inputs.json') -Raw | ConvertFrom-Json
 $b=Get-Content (Join-Path $sa 'B-inputs.json') -Raw | ConvertFrom-Json
 $diff=@($a.PSObject.Properties | Where-Object {$_.Value -ne $b.($_.Name)} | ForEach-Object {$_.Name})
 if($diff.Count -ne 1 -or $diff[0] -ne 'rtl/mapper_ctrl.vhd'){throw 'Input mismatch'}
 @{root=$sr;date='261006';seed=$seed;revision='SMS';differences=$diff;version=(& $quartus --version | Out-String)} | ConvertTo-Json | Set-Content (Join-Path $sa 'build-context.json')
 foreach($label in @('A','B')){
  $dir=Join-Path $sr $label;Set-Location $dir;$start=Get-Date
  "Seed $seed $label started $($start.ToString('o'))" | Tee-Object -FilePath (Join-Path $art 'progress.log') -Append
  $ErrorActionPreference='Continue'
  & $quartus --flow compile SMS -c SMS *> (Join-Path $sa "$label-compile.log")
  $code=$LASTEXITCODE;$ErrorActionPreference='Stop'
  @{exit_code=$code;start=$start.ToString('o');end=(Get-Date).ToString('o')} | ConvertTo-Json | Set-Content (Join-Path $sa "$label-result.json")
  if($code){throw "Seed $seed $label compile failed: $code"}
  $h=Manifest $dir;$h['build_id.v']=(Get-FileHash (Join-Path $dir 'build_id.v')).Hash
  $h | ConvertTo-Json | Set-Content (Join-Path $sa "$label-inputs-after.json")
  $ErrorActionPreference='Continue'
  & $sta -t (Join-Path $art 'timing_paths.tcl') (Join-Path $sa "$label-setup-paths.txt") *> (Join-Path $sa "$label-timing-paths.log")
  $code=$LASTEXITCODE;$ErrorActionPreference='Stop'
  if($code){throw 'Path extraction failed'}
  "Seed $seed $label completed $(Get-Date -Format o)" | Tee-Object -FilePath (Join-Path $art 'progress.log') -Append
 }
 Set-Location $repo
 $after=Manifest $repo
 foreach($f in $files){if($before[$f] -ne $after[$f]){throw "Workspace changed $f"}}
 $after | ConvertTo-Json | Set-Content (Join-Path $sa 'workspace-after.json')
 & (Join-Path $sa 'compare.ps1') *> (Join-Path $sa 'comparison.log')
 "Seed $seed comparison completed" | Tee-Object -FilePath (Join-Path $art 'progress.log') -Append
}
Set-Location $repo
git status --short
git diff --stat
git diff --check
if($LASTEXITCODE){throw 'Final diff check failed'}
'ALL TEN BUILDS COMPLETE' | Tee-Object -FilePath (Join-Path $art 'progress.log') -Append
