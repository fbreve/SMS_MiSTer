param([int]$Program=0,[int]$Offset=0,[int]$Period=15,[int]$Sys=0,[int]$Captures=0,[int]$IntCase=0,[int]$Signature=0,[switch]$Compile)
$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $PSScriptRoot
try {
 $env:G09_PROGRAM="$Program";$env:G09_OFFSET="$Offset";$env:G09_PERIOD="$Period";$env:G09_SYS="$Sys";$env:G09_CAPTURES="$Captures"
 $label="trace_p${Program}_o${Offset}_t${Period}_s${Sys}_c${Captures}_sig${Signature}_i${IntCase}"
 $env:G01_SIGNATURE="$Signature"
 $env:G01_INTCASE="$IntCase"
 $run=@()
 foreach($line in (Get-Content trace.do)){
  if($line -match '^(vlib|vcom|vlog) (.*)$'){
   if($Compile){$exe=$matches[1];$argv=$matches[2] -split ' ';& "$bin/$exe.exe" @argv *> "$label.compile.tmp";if($LASTEXITCODE -ne 0){throw (Get-Content -Raw "$label.compile.tmp")}}
  }else{$run+=$line}
 }
 $run | Set-Content "$label.sim.do"
 & "$bin/vsim.exe" -c -do "$label.sim.do" -l "$label.transcript" -wlf "$label.wlf" *> "$label.log"
 $s=Get-Content -Raw "$label.log"
 if($LASTEXITCODE -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS G01') {Get-Content "$label.log" -Tail 12;throw "Failed $label"}
 Write-Output "PASS $label"
}finally{Pop-Location}
