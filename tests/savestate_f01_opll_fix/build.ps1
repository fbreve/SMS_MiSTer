param([ValidateSet('early','final')][string]$Name='early')
$ErrorActionPreference='Stop'
if(Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta -ErrorAction SilentlyContinue){throw 'Another Quartus process is active'}
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $repoRoot;if($LASTEXITCODE){throw 'Short-path mapping failed'}}
$line=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $line -or ($line -split ' => ',2)[1].TrimEnd('\') -ne $repoRoot.TrimEnd('\')){throw 'Z: does not map this repository'}
Push-Location "$PSScriptRoot/quartus_$Name"
try {
 foreach($stage in @('map','fit','asm','sta')){
  $ErrorActionPreference='Continue'
  if($stage -eq 'sta'){
   & "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$stage.exe" "Z:/tests/savestate_f01_opll_fix/quartus_$Name/SMS" *> "$stage.log"
  }else{
   & "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$stage.exe" --read_settings_files=on --write_settings_files=off "Z:/tests/savestate_f01_opll_fix/quartus_$Name/SMS" *> "$stage.log"
  }
  $result=$LASTEXITCODE;$ErrorActionPreference='Stop'
  if($result){throw "Full $Name $stage failed ($result); STOP"}
  Write-Output "PASS $Name $stage"
 }
}finally{Pop-Location}
Write-Output "PASS full controlled $Name Quartus"
