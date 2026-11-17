const fs=require('fs'),p=require('path'),here=__dirname,old=p.resolve(here,'../savestate_g01_cpu_restart_fix');
const logread=f=>{const b=fs.readFileSync(f);return b[0]===255&&b[1]===254?b.toString('utf16le'):b.toString('utf8');};
for(const family of ['g01','nmi']){
 if(process.argv.includes('--nmi-only')&&family!=='nmi')continue;
 const src=p.join(here,'candidate_'+family),d=p.join(here,'matrix_'+family);fs.mkdirSync(d,{recursive:true});
 for(const f of fs.readdirSync(src))if(/\.(sv|vhd)$/.test(f))fs.copyFileSync(p.join(src,f),p.join(d,f));
 const cfile=p.join(d,'savestates_integrated.sv');fs.writeFileSync(cfile,fs.readFileSync(cfile,'utf8').replace("FLUSH_MAX       = 20'd900000", "FLUSH_MAX       = 20'd0"));
 const original=fs.readFileSync(p.join(src,'run.do'),'utf8');
 fs.writeFileSync(p.join(d,'compile.do'),original.slice(0,original.indexOf('vsim -c'))+'quit -code 0\n');
 let cases=[];
 if(family==='g01'){
  const a=JSON.parse(fs.readFileSync(p.join(old,'matrix.json'))),b=JSON.parse(fs.readFileSync(p.join(old,'trace_cases.json')));
  cases=[...a,...b.map(x=>({period:15,sys:0,signature:0,...x}))].map((x,i)=>({id:i,args:{PROGRAM:x.program,OFFSET:x.offset,PERIOD:x.period,SYS:x.sys,CAPTURES:0,SIGNATURE:x.signature,INTCASE:x.intCase||0}}));
  const keys=new Set(cases.map(x=>JSON.stringify(x.args)));
  for(const f of fs.readdirSync(old)){
   const m=/^integrated_p(\d+)_o(\d+)_t(\d+)_s(\d+)_c0_sig(\d+)_i(\d+)\.log$/.exec(f);if(!m)continue;
   const log=logread(p.join(old,f));if(!/PASS G0[19] program/.test(log)||/\*\* (Fatal|Error|Failure)/.test(log))continue;
   const args={PROGRAM:+m[1],OFFSET:+m[2],PERIOD:+m[3],SYS:+m[4],CAPTURES:0,SIGNATURE:+m[5],INTCASE:+m[6]};
   if(!keys.has(JSON.stringify(args))){keys.add(JSON.stringify(args));cases.push({id:cases.length,args});}
  }
 }else{
  // Reuse the full scoped F16 cases and the final-source bridging cases.
  for(const provider of ['nmi_final','nmi'])for(const f of fs.readdirSync(p.join(old,provider))){
   if(!f.endsWith('.log'))continue;
   const log=logread(p.join(old,provider,f));
   if(!log.includes('PASS F16'))continue;
   const line=log.split(/\r?\n/).find(x=>x.includes('# vsim '));
   const args={};for(const m of line.matchAll(/-g([A-Z_]+)=(-?\d+)/g))args[m[1]]=Number(m[2]);
   if(!Object.keys(args).length)throw Error('No parameters in '+f);
   cases.push({id:provider+'_'+f.slice(0,-4),args});
  }
 }
 if(!cases.length)throw Error('Empty '+family+' matrix');
 for(const x of cases){const lib=family==='g01'?'trace_work':'final_work';const args=Object.entries(x.args).map(([k,v])=>'-g'+k+'='+v).join(' ');
  fs.writeFileSync(p.join(d,'case_'+x.id+'.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -voptargs=+acc ${lib}.fixed_tb ${args}\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);
 }
 fs.writeFileSync(p.join(d,'cases.json'),JSON.stringify(cases,null,2));
 fs.writeFileSync(p.join(d,'matrix.ps1'),`$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
& $bin -c -do 'do compile.do' -l compile.log
if($LASTEXITCODE){throw 'compile failed'}
$cases=Get-Content -Raw cases.json|ConvertFrom-Json
foreach($c in $cases){
 $label="case_$($c.id)"
 & $bin -c -do "do $label.do" -l "$label.transcript" *> "$label.log"
 $s=Get-Content -Raw "$label.log"
 if($LASTEXITCODE -or $s -match '\\*\\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS ${family==='g01'?'G01 TRACE':'F16 fixed'}'){Get-Content "$label.log" -Tail 16;throw "Failed $label"}
 Write-Output "PASS $label"
}
Write-Output "MATRIX COMPLETE ${family} $($cases.Count) cases"
`);
 console.log(family+': '+cases.length+' cases prepared; test-only flush reduction.');
}
