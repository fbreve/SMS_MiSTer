param([int]$Shard=0,[int]$Shards=3)
$ErrorActionPreference='Stop'
$cases=@(
 @{SavedPaused=0;CurrentPaused=0;Delay=8;Tac=1},
 @{SavedPaused=0;CurrentPaused=1;Delay=8;Tac=1},
 @{SavedPaused=1;CurrentPaused=1;Delay=8;Tac=1},
 @{SavedPaused=1;CurrentPaused=0;Delay=8;Tac=1},
 @{SavedPaused=1;CurrentPaused=0;Delay=8;Tac=0},
 @{SavedPaused=1;CurrentPaused=0;Delay=8;Tac=7}
)
foreach($delay in @(0,1,6,7,9,10,14,15,20,24,29)){$cases+=@{SavedPaused=1;CurrentPaused=0;Delay=$delay;Tac=1}}
for($n=0;$n -lt $cases.Count;$n++){
 if($n%$Shards -ne $Shard){continue}
 $arguments=$cases[$n]
 & (Join-Path $PSScriptRoot run.ps1) -Fixture final_protocol @arguments
}
