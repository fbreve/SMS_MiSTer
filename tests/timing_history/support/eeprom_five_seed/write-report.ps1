$ErrorActionPreference='Stop'
$study=Get-Content (Join-Path $PSScriptRoot 'study.json') -Raw | ConvertFrom-Json
function F($n){return ([double]$n).ToString('0.000',[cultureinfo]::InvariantCulture)}
function Signed($n){return ([double]$n).ToString('+0.000;-0.000;0.000',[cultureinfo]::InvariantCulture)}
$lines=[collections.generic.list[string]]::new()
$lines.Add('# EEPROM fallback cleanup: controlled five-seed Quartus study')
$lines.Add('')
$lines.Add('Baseline HEAD: `f875eb70ccd9023802ee41bb28686d11d65ee717`. Branch: `cleanup/mapper-eeprom-fallback`. Baseline A is a fresh git-archive snapshot; cleanup B overlays only the current `rtl/mapper_ctrl.vhd`. All ten builds are fresh, sequential full compilations, without database reuse. Production files were not edited.')
$lines.Add('')
$lines.Add('Quartus Prime 17.0.2 Build 602 Lite; revision SMS; device 5CSEBA6U23I7; seeds 1–5; BUILD_DATE=261006. Command: `quartus_sh --flow compile SMS -c SMS`. Date is pinned in both copied generators and preinitialized build_id.v. Only copied SMS.qsf seed assignments change between seeds. Original constraints and remaining settings are preserved. Matched input hashes differ only in mapper_ctrl.vhd; pre/post-build inputs match. Cross-seed manifests differ only in SMS.qsf, verified to differ textually only in SEED. All tracked workspace hashes match before/after.')
$lines.Add('')
$lines.Add('## Setup timing')
$lines.Add('')
$lines.Add('All slacks and deltas are ns; delta = cleanup minus baseline. Full endpoints are listed below.')
$lines.Add('')
$lines.Add('| Seed | Baseline setup | Cleanup setup | Delta | Baseline worst path | Cleanup worst path |')
$lines.Add('|---|---:|---:|---:|---|---|')
foreach($seed in 1..5){
 $a=$study.rows | Where-Object {$_.seed -eq $seed -and $_.version -eq 'A'}
 $b=$study.rows | Where-Object {$_.seed -eq $seed -and $_.version -eq 'B'}
 $ap=($a.from.Split('|')[-1]+' → '+$a.to.Split('|')[-1]).Replace('|','\|')
 $bp=($b.from.Split('|')[-1]+' → '+$b.to.Split('|')[-1]).Replace('|','\|')
 $lines.Add("| $seed | $(Signed $a.setup) | $(Signed $b.setup) | $(Signed ($b.setup-$a.setup)) | $ap | $bp |")
}
$lines.Add('')
$lines.Add('| Statistic | Baseline | Cleanup |')
$lines.Add('|---|---:|---:|')
foreach($p in @('minimum','maximum','mean','median','range','passing','failing','mean_alms','mean_aluts')){
 $av=([double]$study.statistics.A.$p).ToString('0.####',[cultureinfo]::InvariantCulture)
 $bv=([double]$study.statistics.B.$p).ToString('0.####',[cultureinfo]::InvariantCulture)
 $lines.Add("| $p | $av | $bv |")
}
$lines.Add('')
$lines.Add('## Collected timing and resources')
$lines.Add('')
$lines.Add('TNS is summed over reported clock domains. Fitted combinational ALUTs are the usage-for-logic count. Mapper counts are synthesis per-entity counts, including dedicated registers.')
$lines.Add('')
$lines.Add('| Seed | Version | Setup TNS | Hold slack | Hold TNS | Fitted ALMs | Fitted registers | Fitted ALUTs | Mapper ALUTs | Mapper registers |')
$lines.Add('|---|---|---:|---:|---:|---:|---:|---:|---:|---:|')
foreach($r in $study.rows){$name=if($r.version -eq 'A'){'Baseline'}else{'Cleanup'};$lines.Add("| $($r.seed) | $name | $(F $r.setup_tns) | $(Signed $r.hold) | $(F $r.hold_tns) | $($r.alms) | $($r.registers) | $($r.aluts) | $($r.mapper_aluts) | $($r.mapper_registers) |")}
$lines.Add('')
$lines.Add('| Seed | ALM delta | Fitted register delta | Fitted ALUT delta | Mapper ALUT delta | Mapper register delta |')
$lines.Add('|---|---:|---:|---:|---:|---:|')
foreach($seed in 1..5){$a=$study.rows | Where-Object {$_.seed -eq $seed -and $_.version -eq 'A'};$b=$study.rows | Where-Object {$_.seed -eq $seed -and $_.version -eq 'B'};$lines.Add("| $seed | $($b.alms-$a.alms) | $($b.registers-$a.registers) | $($b.aluts-$a.aluts) | $($b.mapper_aluts-$a.mapper_aluts) | $($b.mapper_registers-$a.mapper_registers) |")}
$lines.Add('')
$lines.Add('## Full worst setup endpoints')
foreach($r in $study.rows){$name=if($r.version -eq 'A'){'Baseline'}else{'Cleanup'};$lines.Add('');$lines.Add("Seed $($r.seed), $name, $(Signed $r.setup) ns:");$lines.Add('');$lines.Add('From: `'+$r.from+'`');$lines.Add('');$lines.Add('To: `'+$r.to+'`');$lines.Add('');$lines.Add('Launch/latch clock: `'+$r.launch_clock+'` / `'+$r.latch_clock+'`.')}
$lines.Add('')
$lines.Add('## Warning comparison')
$lines.Add('')
$lines.Add('Warning comparison uses stage-specific multisets, including suppressed warnings. Normalization removes build-copy root paths, whitespace, and shifted mapper_ctrl.vhd line numbers only.')
$lines.Add('')
$lines.Add('| Seed | Version | Errors | Ordinary warnings | Critical warnings | A/B normalized additions/removals |')
$lines.Add('|---|---|---:|---:|---:|---|')
foreach($r in $study.rows){$add=0;$remove=0;foreach($p in $r.warning_differences.PSObject.Properties){foreach($m in $p.Value.added.PSObject.Properties){$add+=$m.Value};foreach($m in $p.Value.removed.PSObject.Properties){$remove+=$m.Value}};$lines.Add("| $($r.seed) | $($r.version) | $($r.warning_counts.Error) | $($r.warning_counts.Warning) | $($r.warning_counts.'Critical Warning') | $add / $remove |")}
$lines.Add('')
$lines.Add('## Scope of the result')
$lines.Add('')
$lines.Add('Prior cycle-by-cycle functional verification passed 402,603 cycles and 9,259,869 comparisons across all 23 outputs under the production binary mapper_eeprom contract. This study does not extend that equivalence claim to U/X/Z or other nonbinary std_logic values. Timing claims concern the existing reported constrained paths; constraints were not expanded or relaxed.')
$lines.Add('')
$lines.Add('The earlier Evolution readback study failed one of five refactor seeds, lost setup margin in four pairs, and reduced mean/median slack from 0.5598/0.539 ns to 0.3784/0.317 ns. It used another baseline commit, so it is a comparison of observed timing-risk patterns, not a controlled cross-candidate comparison.')
$lines.Add('')
$lines.Add('See study.json for numeric data, verification.json for final preservation checks, and seed1–seed5 directories for raw reports, input manifests, compile logs, result metadata, warning comparisons, RBFs, and independently extracted slow-model setup paths. No commit, push, or PR was performed.')
[IO.File]::WriteAllLines((Join-Path $PSScriptRoot 'report.md'),$lines,[text.UTF8Encoding]::new($false))
