const fs=require('fs'),p=require('path'),d=__dirname,root=p.resolve(d,'../..'),src=p.join(root,'tests/savestate_g06_g10_fix/matrix_g01'),dst=p.join(d,'g01');
fs.mkdirSync(dst,{recursive:true});
for(const f of fs.readdirSync(src))if(/\.(sv|vhd)$/.test(f))fs.copyFileSync(p.join(src,f),p.join(dst,f));
let s=require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv'),false).replace("20'd900000;","20'd0;");
fs.writeFileSync(p.join(dst,'savestates_integrated.sv'),s);
s=fs.readFileSync(p.join(dst,'trace_tb.sv'),'utf8').replace("24'h48430e","24'h484310").replace('savestates dut(','savestates dut(.bg_out(139\'d0),.bg2_out(139\'d0),');
fs.writeFileSync(p.join(dst,'trace_tb.sv'),s);
fs.copyFileSync(p.join(src,'compile.do'),p.join(dst,'compile.do'));
const all=JSON.parse(fs.readFileSync(p.join(src,'cases.json'),'utf8'));
const chosen=[];
for(const program of [10,11,12,13,16,18,28,29,30,31]){
 const c=all.find(c=>c.args.PROGRAM===program&&(program!==28||c.args.INTCASE===1));
 if(!c)throw Error('missing program '+program);chosen.push(c);
}
fs.writeFileSync(p.join(dst,'cases.json'),JSON.stringify(chosen,null,2));
fs.writeFileSync(p.join(dst,'run.ps1'),`$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
& $bin -c -do 'do compile.do' -l compile.log *> compile_stdout.log
if($LASTEXITCODE -or (Get-Content -Raw compile.log) -match '\\*\\* (Error|Fatal|Failure)'){throw 'compile failed'}
foreach($c in (Get-Content -Raw cases.json|ConvertFrom-Json)){
 $label="p$($c.args.PROGRAM)";$argsList=foreach($prop in $c.args.PSObject.Properties){'-g'+$prop.Name+'='+$prop.Value}
 [IO.File]::WriteAllLines((Join-Path $PSScriptRoot "$label.do"),@('onerror {quit -code 1}','onbreak {quit -code 1}',"vsim -c -t 1ps trace_work.fixed_tb $($argsList -join ' ')",'set NumericStdNoWarnings 1','run -all','quit -code 0'))
 & $bin -c -do "do $label.do" -l "$label.log" *> "$label.stdout.log"
 $s=Get-Content -Raw "$label.log"
 if($LASTEXITCODE -or $s -match '\\*\\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS G01 TRACE'){throw "failed $label"}
 Write-Output "PASS G01 $label"
}
`);
console.log('Prepared ten current-controller G01 targeted regressions; CPU fixture retains registered ROM.');
