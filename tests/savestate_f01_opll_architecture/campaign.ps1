$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
foreach($c in 0..8){
 $dir=Join-Path $PSScriptRoot "case$c"
 New-Item -ItemType Directory -Force -Path $dir | Out-Null
 Copy-Item "$PSScriptRoot/rom.hex" "$dir/rom.hex"
 $ini=(Get-Content "$PSScriptRoot/modelsim.ini" -Raw).Replace('[Library]',("[Library]`nwork_fast = "+($PSScriptRoot.Replace('\','/'))+'/work_fast'))
 Set-Content "$dir/modelsim.ini" $ini
 Push-Location $dir
 try{
  $env:FMCASE="$c";$env:HISTORY='0';$env:REF='1';$env:STALL='0'
  & $bin -c -do 'do ../run.do' -l reference.log *> reference_stdout.log
  if($LASTEXITCODE -or !(Select-String -Quiet -Pattern 'PASS REFERENCE' reference.log)){throw "Reference failed $c"}
  $env:REF='0'
  & $bin -c -do 'do ../run.do' -l replay.log *> replay_stdout.log
  if($LASTEXITCODE -or !(Select-String -Quiet -Pattern 'PASS CHARACTERIZED' replay.log)){throw "Replay failed $c"}
 }finally{Pop-Location}
 Write-Output "Completed FM case$c reference + SAVE + three LOADs"
}
