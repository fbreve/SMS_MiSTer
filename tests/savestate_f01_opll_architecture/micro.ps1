param([int]$Start=0)
$ErrorActionPreference='Stop'
foreach($variant in (@('base','parallel','ce','sequential','scan','ram','dualram','fullram') | Select-Object -Skip $Start)){
 Push-Location "$PSScriptRoot/micro_$variant"
 try {
  & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_map.exe' micro --read_settings_files=on --write_settings_files=off *> map.log
  if($LASTEXITCODE){throw "Map failed $variant"}
  & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_fit.exe' micro --read_settings_files=on --write_settings_files=off *> fit.log
  if($LASTEXITCODE){throw "Fit failed $variant"}
 }finally{Pop-Location}
 Write-Output "Completed isolated map/fit $variant"
}
