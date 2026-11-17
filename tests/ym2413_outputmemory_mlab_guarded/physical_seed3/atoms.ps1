$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot
if(Test-Path W:/){throw 'Z occupied'}
subst.exe W: $taskRoot
try {& C:/intelFPGA_lite/17.0/quartus/bin64/quartus_cdb.exe -t W:/atoms.tcl *> "$taskRoot/atoms.log";if($LASTEXITCODE){throw 'Atom query failed'}} finally {subst.exe W: /D}
