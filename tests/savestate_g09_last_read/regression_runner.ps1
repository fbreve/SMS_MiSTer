param([string]$Do='cpu.do',[string]$Label='cpu_offset0',[string]$Folder=$PSScriptRoot)
$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $Folder
try {
 if(Test-Path -LiteralPath "$Label.compile.log"){Remove-Item -LiteralPath "$Label.compile.log"}
 $lines=Get-Content $Do
 $run=@()
 foreach($line in $lines){
  if($line -match '^(vlib|vcom|vlog) (.*)$'){
   $exe=$matches[1];$argv=$matches[2] -split ' '
   & "$bin/$exe.exe" @argv *> "$Label.compile.tmp"
   $s=Get-Content -Raw "$Label.compile.tmp"
   Add-Content "$Label.compile.log" $s
   if($LASTEXITCODE -ne 0 -or $s -match '\*\* (Error|Fatal)'){throw $s}
  }else{$run+=$line}
 }
 $run | Set-Content "$Label.sim.do"
 & "$bin/vsim.exe" -c -do "$Label.sim.do" *> "$Label.log"
 $s=Get-Content -Raw "$Label.log"
 if($LASTEXITCODE -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){Get-Content "$Label.log" -Tail 20;throw "Failed $Label"}
 Write-Output "PASS $Label"
}finally{Pop-Location}
