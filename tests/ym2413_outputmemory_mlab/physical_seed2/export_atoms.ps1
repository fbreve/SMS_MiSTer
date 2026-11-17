$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot
if(Test-Path Z:/){throw 'Z occupied'}
subst.exe Z: $taskRoot
try {& C:/intelFPGA_lite/17.0/quartus/bin64/quartus_cdb.exe -t Z:/export_atoms.tcl *> "$taskRoot/export_atoms.log";if($LASTEXITCODE){throw 'Atom query failed'}} finally {subst.exe Z: /D}

