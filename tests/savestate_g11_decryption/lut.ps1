$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
 & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do 'do lut.do' -l lut.log *> lut_stdout.log
 if($LASTEXITCODE -or (Get-Content -Raw lut.log) -notmatch 'PASS LUT entries131072'){throw 'LUT generation failed'}
}finally{Pop-Location}
