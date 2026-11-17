$ErrorActionPreference='Stop'
$rows=@()
function Number($s){return [double](([regex]::Match($s.Replace(',',''),'^[\d.-]+')).Value)}
foreach($seed in 1..5){
 $dir=Join-Path $PSScriptRoot "seed$seed"
 $c=Get-Content (Join-Path $dir 'comparison.json') -Raw | ConvertFrom-Json
 foreach($label in @('A','B')){
  $r=$c.results.$label
  $line=Get-Content (Join-Path $dir "$label-setup-paths.txt") | Where-Object {$_ -match '^;\s*-?\d+\.\d+\s*;'} | Select-Object -First 1
  if(-not $line){throw 'No path'}
  $cells=@($line.Split(';') | ForEach-Object {$_.Trim()})
  if([double]::Parse($cells[1],[cultureinfo]::InvariantCulture) -ne $r.timing.Setup.worst_slack){throw 'Path slack mismatch'}
  $entity=@($r.mapper_entity_rows.map.Split(';') | ForEach-Object {$_.Trim()})
  $rows += [pscustomobject]@{seed=$seed;version=$label;setup=$r.timing.Setup.worst_slack;setup_tns=$r.timing.Setup.tns;hold=$r.timing.Hold.worst_slack;hold_tns=$r.timing.Hold.tns;from=$cells[2];to=$cells[3];launch_clock=$cells[4];latch_clock=$cells[5];alms=(Number $r.resources.fitted_alms);registers=(Number $r.resources.fitted_registers);aluts=(Number $r.resources.fitted_combinational_aluts);mapper_aluts=(Number $entity[2]);mapper_registers=(Number $entity[3]);warning_counts=$r.warning_counts;warning_differences=$c.warning_differences}
 }
}
$stats=@{}
foreach($label in @('A','B')){
 $v=@($rows | Where-Object version -eq $label);$s=@($v.setup | Sort-Object)
 $stats[$label]=@{minimum=$s[0];maximum=$s[4];mean=($s | Measure-Object -Average).Average;median=$s[2];range=($s[4]-$s[0]);passing=@($v | Where-Object {$_.setup -ge 0 -and $_.hold -ge 0 -and $_.setup_tns -eq 0 -and $_.hold_tns -eq 0}).Count;failing=@($v | Where-Object {$_.setup -lt 0 -or $_.hold -lt 0 -or $_.setup_tns -ne 0 -or $_.hold_tns -ne 0}).Count;mean_alms=($v.alms | Measure-Object -Average).Average;mean_aluts=($v.aluts | Measure-Object -Average).Average}
}
@{rows=$rows;statistics=$stats} | ConvertTo-Json -Depth 12 | Set-Content (Join-Path $PSScriptRoot 'study.json')
$rows | Select-Object seed,version,setup,hold,alms,registers,aluts,mapper_aluts,mapper_registers | Format-Table -AutoSize
$stats | ConvertTo-Json
