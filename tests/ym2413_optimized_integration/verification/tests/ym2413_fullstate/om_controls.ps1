$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass=[System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$g=(Resolve-Path ../../../tools/ghdl6/bin/ghdl.exe).Path
if(Test-Path om_controls){throw 'Refuse overwriting OutputMemory controls'}
New-Item -ItemType Directory om_controls | Out-Null
$names=@('vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll')
$faults=@{
 rdata2=@{old='rdata2 <= CONV_SIGNED_LI(data_array(conv_integer(addr2)));';new='rdata2 <= CONV_SIGNED_LI(data_array(conv_integer(addr2)) xor fault_mask_a);'}
 rdata=@{old='else rdata <= CONV_SIGNED_LI(data_array(conv_integer(addr))); end if;';new='else rdata <= CONV_SIGNED_LI(data_array(conv_integer(addr)) xor fault_mask_b); end if;'}
}
foreach($field in @('rdata2','rdata')){
 $dir="om_controls/$field";New-Item -ItemType Directory $dir | Out-Null
 Copy-Item -LiteralPath native_candidate -Destination $dir -Recurse
 $om=Join-Path $PSScriptRoot "$dir/native_candidate/outputmemory.vhd"
 $s=[IO.File]::ReadAllText($om)
 if(!$s.Contains($faults[$field].old)){throw "Control anchor missing: $field"}
 $s=$s.Replace($faults[$field].old,$faults[$field].new)
 # The fault is armed by the poison hook and becomes active only after restoration, when checking starts.
 $decl="signal ss_mem_ready : std_logic := '0';"
 if(!$s.Contains($decl)){throw 'Declaration anchor missing'}
 $mask=if($field -eq 'rdata2'){'fault_mask_a <= "0000000001" when (om_fault_armed=''1'' and verify_poison_en=''0'') else "0000000000"; fault_mask_b <= "0000000000";'}else{'fault_mask_b <= "0000000010" when (om_fault_armed=''1'' and verify_poison_en=''0'') else "0000000000"; fault_mask_a <= "0000000000";'}
 $s=$s.Replace($decl,"$decl signal om_fault_armed : std_logic := '0'; signal fault_mask_a,fault_mask_b : std_logic_vector(9 downto 0) := (others=>'0');")
 $i=$s.ToLower().LastIndexOf('end rtl;');if($i -lt 0){throw 'architecture end missing'}
 $s=$s.Substring(0,$i)+"om_fault_arm: process(verify_poison_en) begin if verify_poison_en='1' then om_fault_armed<='1'; end if; end process;`n$mask`n"+$s.Substring($i)
 [IO.File]::WriteAllText($om,$s)
 $args=@('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work',"--workdir=$dir",'-Pghdl_reference')
 foreach($name in $names){$args+="$dir/native_candidate/$name.vhd"}
 $args+=@('candidate_wrapper.vhd','../../rtl/video.vhd','combined_tb.vhd')
 $proc=Start-Process $g -ArgumentList $args -WindowStyle Hidden -PassThru -RedirectStandardOutput "$dir/compile.stdout.log" -RedirectStandardError "$dir/compile.stderr.log"
 $null=$proc.Handle;$priority=$proc.PriorityClass
 "PID=$($proc.Id) Priority=$priority" | Set-Content "$dir/compile.priority.log"
 if($priority -ne [System.Diagnostics.ProcessPriorityClass]::Idle){if(!$proc.HasExited){$proc.Kill()};throw 'Control compiler not Low priority'}
 $proc.WaitForExit();$proc.Refresh();$code=$proc.ExitCode;Set-Content "$dir/compile.exitcode" $code
 if($code -ne 0){Get-Content "$dir/compile.stderr.log" -Tail 10;throw "Control compile failed: $field"}
 & powershell.exe -NoProfile -ExecutionPolicy Bypass -File combined_one.ps1 -Shift 70 -FrameEvents 0 -RunDirectory "$dir/run" -Library $dir
 $code=$LASTEXITCODE
 $text=Get-Content "$dir/run/shift70.log" -Raw
 if($code -eq 0 -or $text -notmatch 'OutputMemory read/feedback path divergence'){throw "OutputMemory fault not rejected by the dedicated assertion: $field"}
 Write-Output "PASS negative control: injected OutputMemory $field fault rejected by the continuous read/feedback assertion"
}
