$ErrorActionPreference = 'Stop'
$context = Get-Content (Join-Path $PSScriptRoot 'build-context.json') -Raw | ConvertFrom-Json
function Equal-Manifest($a,$b) {
    $pa = @($a.PSObject.Properties); $pb = @($b.PSObject.Properties)
    if ($pa.Count -ne $pb.Count) { return $false }
    foreach ($p in $pa) { if ($p.Value -cne $b.($p.Name)) { return $false } }
    return $true
}
function Read-Summary($path) {
    $values = @{}
    foreach ($line in Get-Content -LiteralPath $path) {
        if ($line -match '^([^:]+) : (.*)$') { $values[$matches[1].Trim()]=$matches[2].Trim() }
    }
    return $values
}
function Read-Resource($content,$name) {
    $m=[regex]::Match($content,'(?m)^;\s*'+[regex]::Escape($name)+'\s*;\s*([^;\r\n]+)')
    if (-not $m.Success) { throw "Missing resource: $name" }
    return $m.Groups[1].Value.Trim()
}
function Normalize-Message($s,$label) {
    $s=$s.Replace((Join-Path $context.root $label),'<BUILD>').Replace((Join-Path $context.root $label).Replace('\','/'),'<BUILD>')
    $s=[regex]::Replace($s,'(?i)(File:\s*(?:[^\r\n]*?)mapper_ctrl\.vhd\s+Line:\s*)\d+','$1<N>')
    return [regex]::Replace($s.Trim(),'\s+',' ')
}
$results=@{}; $warningDifferences=@{}
foreach ($label in @('A','B')) {
    $dir=Join-Path $context.root $label
    $out=Join-Path $dir 'output_files'
    $before=Get-Content (Join-Path $PSScriptRoot "$label-inputs.json") -Raw | ConvertFrom-Json
    $after=Get-Content (Join-Path $PSScriptRoot "$label-inputs-after.json") -Raw | ConvertFrom-Json
    if (-not (Equal-Manifest $before $after)) { throw "$label inputs changed during compilation" }
    if ([IO.File]::ReadAllText((Join-Path $dir 'build_id.v')) -cne '`define BUILD_DATE "261006"') { throw 'Build date mismatch' }
    $dest=Join-Path $PSScriptRoot $label
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Get-ChildItem $out -File | Where-Object Extension -in '.rpt','.summary','.rbf','.smsg' | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $dest }
    $map=[IO.File]::ReadAllText((Join-Path $out 'SMS.map.rpt'))
    $fit=[IO.File]::ReadAllText((Join-Path $out 'SMS.fit.rpt'))
    $sta=[IO.File]::ReadAllText((Join-Path $out 'SMS.sta.rpt'))
    $mapSummary=Read-Summary (Join-Path $out 'SMS.map.summary')
    $fitSummary=Read-Summary (Join-Path $out 'SMS.fit.summary')
    if ($fit -notmatch "(?m)^; Fitter Initial Placement Seed\s*;\s*$($context.seed)\s*;\s*1\s*;") { throw 'Seed mismatch' }
    if ($mapSummary['Revision Name'] -ne 'SMS' -or $fitSummary['Revision Name'] -ne 'SMS') { throw 'Revision mismatch' }
    if ($mapSummary['Quartus Prime Version'] -ne '17.0.2 Build 602 07/19/2017 SJ Lite Edition') { throw 'Version mismatch' }
    $resources=@{
        fitted_alms=$fitSummary['Logic utilization (in ALMs)']; synthesis_registers=$mapSummary['Total registers']; fitted_registers=$fitSummary['Total registers'];
        synthesis_combinational_aluts=(Read-Resource $map 'Combinational ALUT usage for logic'); fitted_combinational_aluts=(Read-Resource $fit 'Combinational ALUT usage for logic');
        memory_bits=$fitSummary['Total block memory bits']; ram_blocks=$fitSummary['Total RAM Blocks']; dsp_blocks=$fitSummary['Total DSP Blocks']; plls=$fitSummary['Total PLLs']
    }
    $entities=@{}
    foreach ($pair in @(@('map',$map),@('fit',$fit))) {
        $rows=@($pair[1] -split '\r?\n' | Where-Object { $_ -match '^;\s+\|mapper_ctrl:mapper_banking\|' })
        if ($rows.Count -ne 1) { throw 'Missing/ambiguous mapper entity row' }
        $entities[$pair[0]]=[regex]::Replace($rows[0].Trim(),'\s+',' ')
        $headers=@($pair[1] -split '\r?\n' | Where-Object { $_ -match '^; Compilation Hierarchy Node\s*;' })
        $entities[$pair[0]+'-headers']=[regex]::Replace($headers[0].Trim(),'\s+',' ')
    }
    $timing=@{}
    foreach ($kind in @('Setup','Hold','Recovery','Removal','Minimum Pulse Width')) {
        $section=[regex]::Match($sta,'(?ms)^; '+[regex]::Escape($kind)+' Summary\s*;(.*?)(?:\r?\n\s*\r?\n)')
        if (-not $section.Success) { throw "Missing $kind timing summary" }
        $rows=@()
        foreach ($line in $section.Groups[1].Value -split '\r?\n') {
            $cells=@($line.Split(';') | ForEach-Object { $_.Trim() })
            if ($cells.Count -ge 5 -and $cells[2] -match '^-?\d+\.\d+$') { $rows += @{ clock=$cells[1]; slack=[double]::Parse($cells[2],[cultureinfo]::InvariantCulture); tns=[double]::Parse($cells[3],[cultureinfo]::InvariantCulture) } }
        }
        if (-not $rows.Count) { throw "No $kind timing rows" }
        $timing[$kind]=@{worst_slack=($rows.slack | Measure-Object -Minimum).Minimum; tns=($rows.tns | Measure-Object -Sum).Sum; rows=$rows}
    }
    $warnings=@{}; $counts=@{Error=0;Warning=0;'Critical Warning'=0}; $suppressedCounts=@{Error=0;Warning=0;'Critical Warning'=0}
    foreach ($stage in @('map','fit','asm','sta')) {
        $messages=@()
        foreach ($line in Get-Content (Join-Path $out "SMS.$stage.rpt")) {
            if ($line -match '^\s*(Critical Warning|Warning|Error) \(') {
                $counts[$matches[1]]++
                $messages += Normalize-Message $line $label
            }
        }
        $warnings[$stage]=$messages
        $suppressed=@()
        $smsg=Join-Path $out "SMS.$stage.smsg"
        if (Test-Path -LiteralPath $smsg) {
            foreach ($line in Get-Content -LiteralPath $smsg) {
                if ($line -match '^\s*(Critical Warning|Warning|Error) \(') {
                    $suppressedCounts[$matches[1]]++
                    $suppressed += Normalize-Message $line $label
                }
            }
        }
        $warnings["$stage-suppressed"]=$suppressed
    }
    $rbf=Join-Path $out 'SMS.rbf'
    $results[$label]=@{compile=(Get-Content (Join-Path $PSScriptRoot "$label-result.json") -Raw | ConvertFrom-Json);map=$mapSummary;fit=$fitSummary;resources=$resources;mapper_entity_rows=$entities;timing=$timing;warnings=$warnings;warning_counts=$counts;suppressed_warning_counts=$suppressedCounts;rbf=@{bytes=(Get-Item $rbf).Length;sha256=(Get-FileHash $rbf -Algorithm SHA256).Hash}}
}
foreach ($stage in $results.A.warnings.Keys) {
    $a=@{}; $b=@{}
    foreach ($m in $results.A.warnings[$stage]) { $a[$m]++ }
    foreach ($m in $results.B.warnings[$stage]) { $b[$m]++ }
    $added=@{}; $removed=@{}
    foreach ($m in @($a.Keys)+@($b.Keys) | Select-Object -Unique) {
        $delta=$b[$m]-$a[$m]
        if ($delta -gt 0) { $added[$m]=$delta }; if ($delta -lt 0) { $removed[$m]=-$delta }
    }
    $warningDifferences[$stage]=@{added=$added;removed=$removed}
}
$aBytes=[IO.File]::ReadAllBytes((Join-Path $context.root 'A/output_files/SMS.rbf'))
$bBytes=[IO.File]::ReadAllBytes((Join-Path $context.root 'B/output_files/SMS.rbf'))
$byteIdentical=$aBytes.Length -eq $bBytes.Length
if ($byteIdentical) { for ($i=0; $i -lt $aBytes.Length; $i++) { if ($aBytes[$i] -ne $bBytes[$i]) { $byteIdentical=$false; break } } }
$wb=Get-Content (Join-Path $PSScriptRoot 'workspace-before.json') -Raw | ConvertFrom-Json
$wa=Get-Content (Join-Path $PSScriptRoot 'workspace-after.json') -Raw | ConvertFrom-Json
if (-not (Equal-Manifest $wb $wa)) { throw 'Workspace changed' }
@{results=$results;warning_differences=$warningDifferences;rbf_byte_identical=$byteIdentical;workspace_preserved=$true} | ConvertTo-Json -Depth 12 | Set-Content (Join-Path $PSScriptRoot 'comparison.json')
foreach ($label in @('A','B')) { @{label=$label;resources=$results[$label].resources;warning_counts=$results[$label].warning_counts;suppressed_warning_counts=$results[$label].suppressed_warning_counts;rbf=$results[$label].rbf} | ConvertTo-Json -Depth 4; "${label} Setup=$($results[$label].timing.Setup.worst_slack) Hold=$($results[$label].timing.Hold.worst_slack)" }
"RBF byte-identical: $byteIdentical"
$warningDifferences | ConvertTo-Json -Depth 5
