$ErrorActionPreference='Stop'
$d=$PSScriptRoot
foreach($name in 'regress','extras','stalls'){
 Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$d/$name.ps1" -RedirectStandardOutput "$d/$name.out" -RedirectStandardError "$d/$name.err"
}
foreach($g in 'a','b','format'){
 Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$d/broad.ps1",'-Group',$g -RedirectStandardOutput "$d/broad_$g.out" -RedirectStandardError "$d/broad_$g.err"
}
$env:F15_OFFSET='0'
& "$d/sim.ps1" -Folder "$d/regression" -Do legacy_cpu.do -Label legacy_evolution
