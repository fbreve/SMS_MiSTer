$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass=[System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
if(Test-Path models_calibration){throw 'Refuse overwriting calibration'}
Copy-Item combined_audio_71.csv,combined_trace_71.bin pilot_binary71/
New-Item -ItemType Directory models_calibration | Out-Null
Push-Location models_calibration
try{
 & $sim -c -do ../combined_models.do -l models.log *> models_stdout.log;if($LASTEXITCODE){throw 'ModelSim compile failed'}
 $env:COMBINED_SHIFT='71'
 & $sim -c -do ../combined_oracle.do -l oracle.log *> oracle_stdout.log;$code=$LASTEXITCODE
 $s=Get-Content oracle.log -Raw
 if($code -or $s -notmatch 'PASS COMBINED TCL ORACLE ALL 28 checkpoints' -or $s -match '\*\* (Fatal|Error|Failure):'){throw 'ModelSim Tcl oracle failed'}
}finally{Remove-Item Env:COMBINED_SHIFT -ErrorAction SilentlyContinue;Pop-Location}
$norm={param($f) (Get-Content $f -Raw) -replace "`r`n","`n"}
$a=& $norm pilot_binary71/combined_audio_71.csv
$b=& $norm models_calibration/combined_audio_71.csv
$ha=[BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::ASCII.GetBytes($a))).Replace('-','').ToLower()
$hb=[BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::ASCII.GetBytes($b))).Replace('-','').ToLower()
@{ghdl=$ha;modelsim=$hb;identical=($ha -eq $hb);rows=($a -split "`n").Count} | ConvertTo-Json | Set-Content cross_engine.json
if($ha -ne $hb){throw 'GHDL and ModelSim pilot CSV differ'}
Write-Output "PASS ModelSim independent Tcl oracle (28 checkpoints) and GHDL/ModelSim CSV identical sha=$ha"
