$ErrorActionPreference='Stop'
if(Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta -ErrorAction SilentlyContinue){throw 'Another Quartus build is active'}
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $repoRoot;if($LASTEXITCODE){throw 'Short-path mapping failed'}}
$line=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $line -or ($line -split ' => ',2)[1].TrimEnd('\') -ne $repoRoot.TrimEnd('\')){throw 'Z: does not map this repository'}
Push-Location "$PSScriptRoot/quartus_A"
try {
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile Z:/tests/savestate_sprite_resource_optimization/quartus_A/SMS *> compile.log
 $result=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 if($result){throw "Full candidate fit failed ($result); STOP"}
}finally{Pop-Location}
Write-Output 'PASS full controlled candidateA Quartus'
