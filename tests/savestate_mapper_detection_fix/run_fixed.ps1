param([string]$Group='core')
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
function Run([int]$Case,[int]$Iterations=2,[int]$Stall=0,[int]$Delay=0){
 $label="fixed_${Group}_case${Case}_iter${Iterations}_stall${Stall}_delay${Delay}"
 $body=(Get-Content -Raw run.do).Replace('vlib work',"vlib ${label}_work").Replace('vcom -2008',"vcom -work ${label}_work -2008").Replace('vlog -sv',"vlog -work ${label}_work -sv").Replace('work.history_tb',"${label}_work.history_tb").Replace('-gCASE=$env(F13_CASE)',"-gCASE=$Case -gITERATIONS=$Iterations -gSTALL=$Stall -gSAVE_DELAY=$Delay")
 [IO.File]::WriteAllText("$PSScriptRoot/$label.do",$body)
 & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do "$label.do" *> "$label.log"
 $code=$LASTEXITCODE;$s=Get-Content -Raw "$label.log"
 if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS FIXED F13'){Get-Content "$label.log" -Tail 16;throw "Failed $label"}
 Write-Output "PASS $label"
}
try{
 switch($Group){
  core {foreach($c in 0..11){Run $c}}
  deadline {foreach($c in 6,7,9){foreach($delay in 65460,65480,65500,65520,65534,65536){Run $c 2 0 $delay}}}
  stress {foreach($c in 1,8,9){Run $c 8 2 0}}
 }
}finally{Pop-Location}
