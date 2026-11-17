$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
 node prepare_known.js baseline
 foreach($variant in 'baseline','candidate'){
  foreach($h in 0,1){
   $args=@{Variant=$variant;Phase=70;Skew=0;FMOnly=1;N=48000;Replays=2;History=$h;Converge=1;CaseName="equal_$($variant)_h$h"}
   if($variant -eq 'baseline' -and $h -eq 0){$args.Compile=$true}
   & ./known.ps1 @args
  }
 }
}finally{Pop-Location}
