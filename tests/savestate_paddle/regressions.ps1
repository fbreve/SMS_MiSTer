param([string]$Group)
$ErrorActionPreference='Stop'
$root=Resolve-Path "$PSScriptRoot/../.."
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
function Run-Sim([string]$Folder,[string]$Do,[string]$Label) {
    Push-Location "$root/tests/$Folder"
    try {
        & $sim -c -do $Do *> "f10_$Label.log"
        $code=$LASTEXITCODE
        $log=Get-Content -Raw "f10_$Label.log"
        if($code -ne 0 -or $log -match '\*\* (Error|Fatal)|Failure:|assertion failure' -or $log -notmatch 'PASS') {
            Get-Content "f10_$Label.log" -Tail 25
            throw "Failed $Folder $Label code=$code"
        }
        Write-Output "PASS $Folder $Label"
    } finally {Pop-Location}
}
switch -Regex ($Group) {
 '^paddle([12])$' {Run-Sim savestate_paddle "stalls$($Matches[1]).do" "ddr$($Matches[1])"}
 '^sc([012])$' {$env:SC_STALL=$Matches[1];Run-Sim savestate_sc_ram "f10_stalls$($Matches[1]).do" "stalls$($Matches[1])"}
 '^tap([012])$' {$env:TAP_STALL=$Matches[1];$env:TAP_CASE='-1';Run-Sim savestate_master_tap "f10_stalls$($Matches[1]).do" "stalls$($Matches[1])"}
 '^ee([012])$' {$env:EEPROM_STALL=$Matches[1];$env:EEPROM_CASE='-1';Run-Sim savestate_eeprom "f10_stalls$($Matches[1]).do" "stalls$($Matches[1])"}
 '^general$' {
   Run-Sim savestate_paddle ordinary.do ordinary
   $env:HCOUNTER_FIXED='true';$env:HCOUNTER_GG='0';Run-Sim savestate_hcounter vdp.do sms
   $env:HCOUNTER_GG='1';Run-Sim savestate_hcounter vdp.do gg
   Run-Sim savestate_hcounter controller.do controller
   Run-Sim savestate_hcounter integration.do integration
   $env:GG_FIXED='true';Run-Sim savestate_gg_io gg.do replay
   $env:DDRAM_STALLS='0';Run-Sim savestate_gg_io integration.do ddr0
   $env:DDRAM_STALLS='1';Run-Sim savestate_gg_io integration.do ddr1
   Run-Sim savestate_md6 f10_replay.do replay64
   Run-Sim savestate_md6 f10_real.do replay80540
   Run-Sim savestate_md6 integration.do integration
   Run-Sim savestate_master_tap ordinary.do ordinary
   $env:TAP_TIMEOUT='8';Run-Sim savestate_master_tap replay.do replay8
   $env:TAP_TIMEOUT='57000';Run-Sim savestate_master_tap replay.do replay57000
   Run-Sim savestate_eeprom replay.do replay
   Run-Sim savestate_eeprom persistence.do persistence
   Run-Sim savestate_sc_ram f10_controls.do controls
   Run-Sim savestate_sc_ram f10_persistence.do persistence
   Run-Sim savestate_coverage psg.do psg
   Run-Sim savestate_coverage run.do audit
 }
 default {throw "Unknown group $Group"}
}
