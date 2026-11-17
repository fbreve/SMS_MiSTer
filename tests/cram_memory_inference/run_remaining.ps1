param([int]$Worker=0)
$ErrorActionPreference='Stop'
$taskRows=Get-Content "$PSScriptRoot/native_manifest.json" -Raw|ConvertFrom-Json
$taskCases=@($taskRows|Where-Object {($_.family+'/'+$_.name) -notin @('g03/dut_bus','g10/dut_phases','dual/dut_collision','g05/dut_mode4')})
for($taskIndex=0;$taskIndex -lt $taskCases.Count;$taskIndex++){
 if(($taskIndex%2) -eq $Worker){
  & "$PSScriptRoot/run_native.ps1" -Family $taskCases[$taskIndex].family -Name $taskCases[$taskIndex].name
 }
}
