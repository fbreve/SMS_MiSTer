param([int]$Worker=0,[int]$Workers=4)
$ErrorActionPreference='Stop'
$base=$PSScriptRoot;$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$cases=Get-Content -Raw "$base/cases.json"|ConvertFrom-Json
for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){
 $c=$cases[$i]
 foreach($ref in 1,0){
  $label=$(if($ref){'reference_'}else{'dut_'})+$c.id
  Set-Location (Join-Path $base $label)
  if(Test-Path simulation.log){$prior=Get-Content -Raw simulation.log;if($prior -notmatch '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -and $prior -match $(if($ref){'PASS UNINTERRUPTED REFERENCE'}else{'DONE VDP'})){Write-Output "PASS retained $label";continue}}
  & "$bin/vmap.exe" -c|Out-Null;& "$bin/vmap.exe" vdp_work ../vdp_work|Out-Null
  if(!$ref){Copy-Item -LiteralPath "$base/reference_$($c.id)/reference.dat" -Destination reference.dat}
  & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
  $s=Get-Content -Raw simulation.log
  if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch $(if($ref){'PASS UNINTERRUPTED REFERENCE'}else{'DONE VDP'})){Get-Content simulation.log -Tail 16;throw "Failed $label"}
  Write-Output "PASS $label"
 }
}
Write-Output "SPRITE WORKER COMPLETE $Worker"
