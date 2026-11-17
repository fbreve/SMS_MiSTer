param([int[]]$Cases=@(0,1,2,3,4,5,6,7,8,9),[int]$Stall=0,[int]$Full=0,[int]$Offset=0,[int]$Delay=6)
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 & 'C:/Program Files/nodejs/node.exe' prepare.js
 if($LASTEXITCODE -ne 0){throw 'Fixture generation failed'}
 foreach($case in $Cases){
  $env:PAUSE_CASE="$case";$env:PAUSE_KEEP='0';$env:PAUSE_FULL="$Full";$env:PAUSE_STALL="$Stall";$env:PAUSE_OFFSET="$Offset";$env:PAUSE_DELAY="$Delay"
  $label="fixed_case${case}_stall${Stall}_full${Full}_offset${Offset}_delay${Delay}"
  $body=(Get-Content -Raw fixed.do).Replace('pause_work',"${label}_work")
  if($Full){$body=$body.Replace('-gFULL=$env(PAUSE_FULL)','-gFULL=$env(PAUSE_FULL) -g/pause_tb/fullvdps/vdp1/vdp_vram_inst/init_file=UNUSED -g/pause_tb/fullvdps/vdp2/vdp_vram_inst/init_file=UNUSED -g/pause_tb/fullvdps/refvdp1/vdp_vram_inst/init_file=UNUSED -g/pause_tb/fullvdps/refvdp2/vdp_vram_inst/init_file=UNUSED')}
  [IO.File]::WriteAllText("$PSScriptRoot/$label.do",$body)
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do "$label.do" *> "$label.log"
  $code=$LASTEXITCODE;$s=Get-Content -Raw "$label.log"
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)' -or $s -notmatch 'PASS FIXED'){Get-Content "$label.log" -Tail 20;throw "Failed $label"}
  Write-Output "PASS $label"
 }
}finally{Pop-Location}
