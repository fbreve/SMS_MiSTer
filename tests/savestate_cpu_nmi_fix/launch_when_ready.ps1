$ErrorActionPreference='Stop'
while($true){
 $expected=@{'regress'=19;'broad_a'=5;'broad_b'=11;'broad_format'=2;'extras'=3;'stalls'=2;'old_reader'=2;'rerun'=1;'rerun_other'=1;'legacy_valid'=4}
 for($i=0;$i -lt 8;$i++){$expected["final_batch$i"]=if($i -lt 4){33}else{32}}
 $ready=$true
 foreach($n in $expected.Keys){
  if(!(Test-Path "$PSScriptRoot/$n.out")){$ready=$false;continue}
  if((Get-Item "$PSScriptRoot/$n.err").Length -gt 0){throw "Simulation failed: $n"}
  if(@(Select-String -Path "$PSScriptRoot/$n.out" -Pattern '^PASS ').Count -ne $expected[$n]){$ready=$false}
 }
 if($ready){break}
 Start-Sleep -Seconds 5
}
& "$PSScriptRoot/build.ps1"
