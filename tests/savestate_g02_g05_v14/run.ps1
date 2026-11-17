param([string[]]$Cases=@('sanity_collision'),[int]$ReferenceOnly=0,[string]$Fixture='fixture')
$ErrorActionPreference='Stop'
$base=Join-Path $PSScriptRoot $Fixture
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
foreach($caseId in $Cases){foreach($ref in 1,0){
 if($ReferenceOnly -and !$ref){continue}
 $label=$(if($ref){'reference_'}else{'dut_'})+$caseId
 Set-Location (Join-Path $base $label)
 & "$bin/vmap.exe" -c|Out-Null
 & "$bin/vmap.exe" vdp_work ../vdp_work|Out-Null
 if(!$ref){Copy-Item -LiteralPath "$base/reference_$caseId/reference.dat" -Destination reference.dat}
 if(!$ref -and (Test-Path -LiteralPath "$base/reference_$caseId/native_reference.dat")){Copy-Item -LiteralPath "$base/reference_$caseId/native_reference.dat" -Destination native_reference.dat}
 if(!$ref){foreach($memoryFile in 'reference_events.dat','reference_memory.hex','reference_cram.hex'){if(Test-Path -LiteralPath "$base/reference_$caseId/$memoryFile"){Copy-Item -LiteralPath "$base/reference_$caseId/$memoryFile" -Destination $memoryFile}}}
 $doText=Get-Content -Raw run.do
 if($doText -notmatch 'simulation.pid'){
  $prefix='set pid_fd [open simulation.pid w]' + "`n" + 'puts $pid_fd [pid]' + "`n" + 'close $pid_fd' + "`n"
  [System.IO.File]::WriteAllText((Join-Path (Get-Location) run.do),$prefix+$doText)
 }
 & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
 $result=Get-Content -Raw simulation.log
 if($result -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $result -notmatch $(if($ref){'PASS UNINTERRUPTED REFERENCE'}else{'PASS (RICH )?V14 VDP'})){Get-Content simulation.log -Tail 18;throw "Failed $label"}
 Write-Output "PASS $label"
}}
