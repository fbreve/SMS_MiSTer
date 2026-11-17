$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass=[System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$g=(Resolve-Path ../../../tools/ghdl6/bin/ghdl.exe).Path
if(Test-Path combined_compile){throw 'Refuse overwriting compilation'}
New-Item -ItemType Directory combined_compile | Out-Null
$names=@('vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll')
foreach($lib in @('reference','candidate')){
 $dir="ghdl_$lib";if(Test-Path $dir){throw 'Refuse existing library'}
 New-Item -ItemType Directory $dir | Out-Null
 $args=@('-a','--std=08','-fsynopsys','-fexplicit',"--work=${lib}_work","--workdir=$dir")
 if($lib -eq 'candidate'){$args+='-Pghdl_reference'}
 foreach($n in $names){$args+="native_$lib/$n.vhd"}
 $args+="${lib}_wrapper.vhd"
 if($lib -eq 'candidate'){$args+=@('../../rtl/video.vhd','combined_tb.vhd')}
 $log="combined_compile/$lib"
 $proc=Start-Process $g -ArgumentList $args -WindowStyle Hidden -PassThru -RedirectStandardOutput "$log.stdout.log" -RedirectStandardError "$log.stderr.log"
 $null=$proc.Handle
 $priority=$proc.PriorityClass
 "PID=$($proc.Id) Priority=$priority Executable=$g" | Set-Content "$log.priority.log"
 if($priority -ne [System.Diagnostics.ProcessPriorityClass]::Idle){if(!$proc.HasExited){$proc.Kill()};throw 'Compiler child not Low priority'}
 $proc.WaitForExit();$proc.Refresh();$code=$proc.ExitCode;Set-Content "$log.exitcode" $code
 if($code){throw "Compile failed: $lib"}
 Write-Output "PASS Low-priority compilation: $lib"
}
