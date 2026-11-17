$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$g=(Resolve-Path ../../../tools/ghdl6/bin/ghdl.exe).Path
if(Test-Path negative_control){throw 'Refuse overwriting negative control'}
New-Item -ItemType Directory negative_control | Out-Null
Copy-Item -LiteralPath native_candidate -Destination negative_control -Recurse
$tm=Join-Path $PSScriptRoot 'negative_control/native_candidate/temporalmixer.vhd'
$source=[IO.File]::ReadAllText($tm)
$marker='-- Accumulator-only experiment: mix is cleared by its normal end-of-cycle update.'
if(!$source.Contains($marker)){throw 'Missing exact omission marker'}
[IO.File]::WriteAllText($tm,$source.Replace($marker,'mix <= ss_v_mix;'))
New-Item -ItemType Directory negative_control/ghdl_candidate | Out-Null
$names=@('vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll')
foreach($name in $names){
 & $g -a --std=08 -fsynopsys -fexplicit --work=candidate_work --workdir=negative_control/ghdl_candidate "negative_control/native_candidate/$name.vhd"
 if($LASTEXITCODE){throw 'Negative control compile failure'}
}
& $g -a --std=08 -fsynopsys -fexplicit --work=candidate_work --workdir=negative_control/ghdl_candidate -Pghdl_reference candidate_wrapper.vhd ../../rtl/video.vhd acc_native_tb.vhd
if($LASTEXITCODE){throw 'Negative control bench compile failure'}
Set-Location negative_control
$ErrorActionPreference='Continue'
& $g -r --std=08 -fsynopsys -fexplicit --work=candidate_work --workdir=ghdl_candidate '-P../ghdl_reference' acc_native_tb -gSHIFT=70 -gFRAME_EVENTS=0 --assert-level=error --ieee-asserts=disable *> restored_mix.log
$code=$LASTEXITCODE
$ErrorActionPreference='Stop'
Set-Content restored_mix.exitcode $code
$log=Get-Content restored_mix.log -Raw
if($code -eq 0 -or $log -notmatch 'poison did not survive omitted restore'){throw 'Negative control did not reject restored accumulator'}
Write-Output 'PASS NEGATIVE CONTROL: restoring mix is rejected before unfreeze; expected assertion and nonzero exit preserved.'
