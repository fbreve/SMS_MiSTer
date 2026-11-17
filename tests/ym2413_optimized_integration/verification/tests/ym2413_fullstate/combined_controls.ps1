$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass=[System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$g=(Resolve-Path ../../../tools/ghdl6/bin/ghdl.exe).Path
if(Test-Path controls){throw 'Refuse overwriting controls'}
New-Item -ItemType Directory controls | Out-Null
$names=@('vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll')
foreach($field in @('mix','mixout')){
 $dir="controls/$field";New-Item -ItemType Directory $dir | Out-Null
 Copy-Item -LiteralPath native_candidate -Destination $dir -Recurse
 $tm=Join-Path $PSScriptRoot "$dir/native_candidate/temporalmixer.vhd"
 $s=[IO.File]::ReadAllText($tm)
 $comment=if($field -eq 'mix'){'-- Combined experiment: accumulator heals at its normal clear.'}else{'-- Combined experiment: output heals after a complete mixer cycle.'}
 if(!$s.Contains($comment)){throw 'Control omission marker missing'}
 [IO.File]::WriteAllText($tm,$s.Replace($comment,"$field <= ss_v_$field;"))
 $args=@('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work',"--workdir=$dir",'-Pghdl_reference')
 foreach($name in $names){$args+="$dir/native_candidate/$name.vhd"}
 $args+=@('candidate_wrapper.vhd','../../rtl/video.vhd','combined_tb.vhd')
 $proc=Start-Process $g -ArgumentList $args -WindowStyle Hidden -PassThru -RedirectStandardOutput "$dir/compile.stdout.log" -RedirectStandardError "$dir/compile.stderr.log"
 $null=$proc.Handle;$priority=$proc.PriorityClass
 "PID=$($proc.Id) Priority=$priority" | Set-Content "$dir/compile.priority.log"
 if($priority -ne [System.Diagnostics.ProcessPriorityClass]::Idle){if(!$proc.HasExited){$proc.Kill()};throw 'Control compiler not Low priority'}
 $proc.WaitForExit();$proc.Refresh();$code=$proc.ExitCode;Set-Content "$dir/compile.exitcode" $code
 if($code -ne 0){throw 'Control compile failed'}
 & powershell.exe -NoProfile -ExecutionPolicy Bypass -File combined_one.ps1 -Shift 70 -FrameEvents 0 -RunDirectory "$dir/run" -Library $dir
 $code=$LASTEXITCODE
 $text=Get-Content "$dir/run/shift70.log" -Raw
 $message=if($field -eq 'mix'){'accumulator poison did not survive omitted restore'}else{'output poison did not survive omitted restore'}
 if($code -eq 0 -or $text -notmatch $message){throw "Control not rejected: $field"}
 Write-Output "PASS negative control: reinstated $field restore rejected before unfreeze"
}
