param([int[]]$Cases=@(0,1,2,3,4,5,6,7,8,9),[int]$Keep=0,[int]$Full=0)
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
 & 'C:/Program Files/nodejs/node.exe' prepare.js
 foreach($case in $Cases){
  $env:PAUSE_CASE="$case";$env:PAUSE_KEEP="$Keep";$env:PAUSE_FULL="$Full"
  $label="case${case}_keep${Keep}_full${Full}"
  $body=(Get-Content -Raw run.do).Replace('pause_work',"${label}_work")
  if($Full){$body=$body.Replace('-gFULL=$env(PAUSE_FULL)','-gFULL=$env(PAUSE_FULL) -g/pause_tb/fullvdps/vdp1/vdp_vram_inst/init_file=UNUSED -g/pause_tb/fullvdps/vdp2/vdp_vram_inst/init_file=UNUSED')}
  [IO.File]::WriteAllText("$PSScriptRoot/$label.do",$body)
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do "$label.do" *> "$label.log"
  $code=$LASTEXITCODE;$log=Get-Content -Raw "$label.log"
  if($code -ne 0 -or $log -match '\*\* (Error|Fatal|Failure)' -or $log -notmatch 'PASS case'){Get-Content "$label.log" -Tail 20;throw "FAIL $label"}
  Write-Output "PASS $label"
 }
}finally{Pop-Location}
