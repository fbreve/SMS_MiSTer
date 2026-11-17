param([int]$Worker=0,[int]$Workers=2)
$ErrorActionPreference='Stop'
$cases=@(
 @{CaseName='directed70_left_fm';Phase=70;Skew=0;FMOnly=1;Stall=0;N=48000;Replays=3},
 @{CaseName='directed70_right_fm';Phase=70;Skew=1;FMOnly=1;Stall=2;N=48000;Replays=3},
 @{CaseName='directed70_left_mixed';Phase=70;Skew=0;FMOnly=0;Stereo=1;Stall=1;N=48000;Replays=3},
 @{CaseName='directed70_right_mixed';Phase=70;Skew=1;FMOnly=0;Stereo=1;Stall=0;N=48000;Replays=3},
 @{CaseName='directed70_native10_left';Phase=70;Skew=10;FMOnly=0;Stereo=1;Stall=2;N=48000;Replays=3},
 @{CaseName='directed70_native10_right';Phase=70;Skew=11;FMOnly=1;Stall=1;N=48000;Replays=3},
 @{CaseName='turbo70_left';Phase=70;Skew=0;FMOnly=1;Seed=2;Stall=2;N=48000;Replays=1},
 @{CaseName='turbo70_right';Phase=70;Skew=1;FMOnly=0;Stereo=1;Seed=2;Stall=1;N=48000;Replays=1},
 @{CaseName='hidden_fm_systeme';Phase=70;Skew=0;FMOnly=0;Seed=5;Stall=2;N=48000;Replays=1},
 @{CaseName='production_full_flush';Phase=70;Skew=1;FMOnly=0;Stereo=1;Stall=1;N=48000;Replays=1;FullFlush=$true}
)
for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){$args=$cases[$i];& "$PSScriptRoot/known.ps1" @args}
