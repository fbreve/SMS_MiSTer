param([string]$Fixture='matrix',[string]$Cases='cases.json',[string]$ReferenceFrom='',[switch]$Compile,[int]$Shard=0,[int]$Shards=1)
$ErrorActionPreference='Stop';$main=Join-Path $PSScriptRoot $Fixture;$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Compile){Push-Location $main;try{
 & "$bin/vmap.exe" -c | Out-Null
 & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if($LASTEXITCODE -or (Get-Content -Raw compile.log) -match '\*\* (Error|Fatal|Failure)'){throw 'compile failed'}
 & "$bin/vmap.exe" pause_work "$main/pause_work" | Out-Null
}finally{Pop-Location}}
$items=Get-Content -Raw (Join-Path $PSScriptRoot $Cases)|ConvertFrom-Json;$index=0
foreach($case in $items){$n=$index;$index++;if($n%$Shards -ne $Shard){continue}
 $leaf=Join-Path $main $case.id;New-Item -ItemType Directory -Force $leaf | Out-Null
 Get-ChildItem -LiteralPath $main -Filter '*.hex'|Copy-Item -Destination $leaf
 if($ReferenceFrom){Copy-Item -LiteralPath $ReferenceFrom -Destination (Join-Path $leaf reference.dat);Set-Content (Join-Path $leaf reference_source.txt) $ReferenceFrom}
 $arguments=foreach($prop in $case.args.PSObject.Properties){'-g/pause_tb/'+$prop.Name+'='+$prop.Value}
 Push-Location $leaf
 try{foreach($ref in $(if($ReferenceFrom){@(0)}else{@(1,0)})){
  $name=if($ref){'reference'}else{'replay'};$fast=if($case.fullFlush){0}else{1}
  [IO.File]::WriteAllLines((Join-Path $leaf "$name.do"),@('onerror {quit -code 1}','onbreak {quit -code 1}',"vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gREF=$ref -g/pause_tb/dut/TB_FAST=$fast $($arguments -join ' ')",'set NumericStdNoWarnings 1','set StdArithNoWarnings 1','run -all','quit -code 0'))
  & "$bin/vsim.exe" -c -modelsimini "$main/modelsim.ini" -do "do $name.do" -l "$name.log" *> "$name`_stdout.log"
  $s=Get-Content -Raw "$name.log"
  if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)' -or $s -notmatch 'PASS MATRIX'){throw "Failed $($case.id)/$name; retain and classify before continuing"}
 }
 Write-Output "PASS G11 $($case.id)"
 }finally{Pop-Location}
}

