param([int]$Seed,[string]$Tcl='guard_atoms.tcl',[string]$Out)
$ErrorActionPreference='Stop'
$here=$PSScriptRoot;$seedDir=(Resolve-Path "$here/../physical_seed$Seed").Path
if(Test-Path W:/){throw 'W: occupied'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'compilation active'}
$before=Get-ChildItem "$seedDir/candidate/output_files" -File | Where-Object {$_.Extension -in '.rpt','.rbf','.sof'} | ForEach-Object {"$($_.Name) $((Get-FileHash $_.FullName).Hash)"}
subst.exe W: $seedDir
try{& C:/intelFPGA_lite/17.0/quartus/bin64/quartus_cdb.exe -t "$here/$Tcl" W: "$here/$Out" *> "$here/$Out.log"; if($LASTEXITCODE){throw "cdb failed $LASTEXITCODE"}}finally{subst.exe W: /D}
$after=Get-ChildItem "$seedDir/candidate/output_files" -File | Where-Object {$_.Extension -in '.rpt','.rbf','.sof'} | ForEach-Object {"$($_.Name) $((Get-FileHash $_.FullName).Hash)"}
if(Compare-Object $before $after){throw 'Output files changed!'}
'PASS read-only; outputs unchanged'
