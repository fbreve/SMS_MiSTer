$ErrorActionPreference='Stop'
foreach($variant in @('baseline','A','B')){
 Push-Location "$PSScriptRoot/micro_$variant"
 try {
  & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_map.exe' micro --read_settings_files=on --write_settings_files=off *> map.log
  if($LASTEXITCODE){throw "Micro synthesis failed: $variant"}
 } finally {Pop-Location}
 Write-Output "Completed micro synthesis $variant"
}
