param([string]$Fixture='.',[string]$Cases='cases.json',[switch]$Compile,[int]$Shard=0,[int]$Shards=1)
$ErrorActionPreference='Stop'
$main=Join-Path $PSScriptRoot $Fixture
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Compile){Push-Location $main;try {
 & "$bin/vmap.exe" -c | Out-Null
 & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if($LASTEXITCODE -or (Get-Content -Raw compile.log) -match '\*\* (Error|Fatal|Failure)'){throw 'Compile failure'}
 & "$bin/vmap.exe" pause_work "$main/pause_work" | Out-Null
}finally{Pop-Location}}
$items=Get-Content -Raw (Join-Path $main $Cases) | ConvertFrom-Json
$idx=0
foreach($case in $items){$current=$idx;$idx++;if($current%$Shards -ne $Shard){continue}
 $dst=Join-Path $main $case.id
 New-Item -ItemType Directory -Force $dst | Out-Null
 Copy-Item (Join-Path $main 'rom.hex') (Join-Path $dst 'rom.hex')
 if($case.args.BUS -eq 1){
  $rom=Get-Content (Join-Path $dst 'rom.hex')
  $program=@('3e','90','d3','7f','3e','f0','d3','06','3e','9a','d3','7f','3e','0f','d3','06','c3','2e','00')
  if($case.psgPort){$program[3]=$case.psgPort;$program[11]=$case.psgPort}
  for($n=0;$n -lt $program.Count;$n++){$rom[46+$n]=$program[$n]}
  [IO.File]::WriteAllLines((Join-Path $dst 'rom.hex'),$rom)
 }
 $argsList=foreach($prop in $case.args.PSObject.Properties){'-g'+$prop.Name+'='+$prop.Value}
 Push-Location $dst
 try {
 foreach($ref in @(1,0)){
  $name=if($ref){'reference'}else{'replay'}
  $fast=if($case.fullFlush){0}else{1}
  $lines=@('onerror {quit -code 1}','onbreak {quit -code 1}',"vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gREF=$ref -g/pause_tb/dut/TB_FAST=$fast $($argsList -join ' ')",'set NumericStdNoWarnings 1','set StdArithNoWarnings 1','run -all','quit -code 0')
  [IO.File]::WriteAllLines((Join-Path $dst "$name.do"),$lines)
  & "$bin/vsim.exe" -c -modelsimini "$main/modelsim.ini" -do "do $name.do" -l "$name.log" *> "$name`_stdout.log"
  $s=Get-Content -Raw "$name.log"
  if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)' -or $s -notmatch 'PASS MATRIX' -or $s -notmatch '# End time:'){throw "Failed $Fixture/$($case.id)/$name"}
 }
 Write-Output "PASS $Fixture/$($case.id)"
 }finally{Pop-Location}
}
