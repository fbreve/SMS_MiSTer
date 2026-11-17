param([int]$Shard=0,[int]$Shards=3)
$ErrorActionPreference='Stop'
$delays=@(0,1,6,7,9,10,14,15,20,24,29)
for($n=0;$n -lt $delays.Count;$n++){
 if($n%$Shards -ne $Shard){continue}
 & (Join-Path $PSScriptRoot run.ps1) -Fixture protocol -Delay $delays[$n]
}
