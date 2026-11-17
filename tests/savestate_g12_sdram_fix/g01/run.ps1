$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
& $bin -c -do 'do compile.do' -l compile.log *> compile_stdout.log
if($LASTEXITCODE -or (Get-Content -Raw compile.log) -match '\*\* (Error|Fatal|Failure)'){throw 'compile failed'}
foreach($c in (Get-Content -Raw cases.json|ConvertFrom-Json)){
 $label="p$($c.args.PROGRAM)";$argsList=foreach($prop in $c.args.PSObject.Properties){'-g'+$prop.Name+'='+$prop.Value}
 [IO.File]::WriteAllLines((Join-Path $PSScriptRoot "$label.do"),@('onerror {quit -code 1}','onbreak {quit -code 1}',"vsim -c -t 1ps trace_work.fixed_tb $($argsList -join ' ')",'set NumericStdNoWarnings 1','run -all','quit -code 0'))
 & $bin -c -do "do $label.do" -l "$label.log" *> "$label.stdout.log"
 $s=Get-Content -Raw "$label.log"
 if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS G01 TRACE'){throw "failed $label"}
 Write-Output "PASS G01 $label"
}
