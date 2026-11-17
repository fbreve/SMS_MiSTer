const fs=require('fs'),path=require('path');const d=__dirname,old=path.resolve(d,'../savestate_cpu_nmi_fix'),n=path.join(d,'nmi');fs.mkdirSync(n,{recursive:true});
const read=(base,f)=>fs.readFileSync(path.join(base,f),'utf8').replace(/\r\n/g,'\n'),put=(f,s)=>fs.writeFileSync(path.join(n,f),s);
for(const f of ['T80_integrated.vhd','T80s_integrated.vhd','savestates_integrated.sv'])put(f,read(d,f));
for(const f of ['io_instance.sv','sim.ps1'])put(f,read(old,f));
let m=read(old,'machine.sv').replace('input[229:0]cpu_dir,','input[2:0]restart_dir,input restart_valid,output[2:0]restart_out,input[229:0]cpu_dir,').replace('.DIRSet(cpu_set)', '.RestartContext(restart_out),.RestartDIR(restart_dir),.RestartValid(restart_valid),.DIRSet(cpu_set)');put('machine.sv',m);
let tb=read(old,'fixed_tb.sv').replace('savestates dut(',`wire[2:0]restart_out,restart_dir;wire restart_valid;
savestates dut(.z80_restart(restart_out),.z80_restart_dir(restart_dir),.z80_restart_valid(restart_valid),`);
tb=tb.replace('REPLAYS=3;','REPLAYS=3,RELEASE_SECOND=0;');
const second='begin while(cycle<ready_cycle+359+SECOND)tick;if(!accepted)begin dlevel(1);rlevel(1);end end';
if(!tb.includes(second))throw Error('Second-pulse stimulus anchor');
tb=tb.replace(second,'begin while(cycle<ready_cycle+359+SECOND)tick;if(!accepted)begin dlevel(1);rlevel(1);if(RELEASE_SECOND)begin repeat(5)tick;dlevel(0);rlevel(0);end end end');
tb=tb.replace(' core(', ' core(.restart_out(restart_out),.restart_dir(restart_dir),.restart_valid(restart_valid),').replace(' reference(', ' reference(.restart_out(),.restart_dir(3\'d0),.restart_valid(1\'b0),');
tb=tb.replace("24'h48430c||mem[5][63:41]!==0","24'h48430d||mem[5][63:44]!==0").replace('"v12 payload"','"v13 payload"');
tb=tb.replace('if(FORMAT>=100&&FORMAT<=122)mem[5][41+FORMAT-100]=1;',`if(FORMAT==12)begin mem['h1a][63:40]=24'h48430c;mem[5][63:41]=0;end
 if(FORMAT>=100&&FORMAT<=119)mem[5][44+FORMAT-100]=1;
 if(FORMAT==120)mem[5][43:41]=6;
 if(FORMAT==121)mem[5][43:41]=7;
 if(FORMAT==122)mem['h1a][39:38]=0;`);
// v12 already contains F16 history. Only the new CPU context is absent.
tb=tb.replaceAll('FORMAT==0','(FORMAT==0||FORMAT==12)');
put('fixed_tb.sv',tb);
put('compile.do',read(old,'fixed.do').replaceAll('../../rtl/','../../../rtl/').replace('T80_observed.vhd T80s_observed.vhd','T80_integrated.vhd T80s_integrated.vhd').replace('savestates_sim.sv','savestates_integrated.sv'));
const cases=JSON.parse(read(old,'cases.json')).filter(c=>c.format===0&&c.replays>0); cases.push({name:"both_released",source:0,program:0,edge:-60,width:5,second:-15,held:0,schedule:0,format:0,replays:3});
for(let format=100;format<=123;format++)cases.push({name:'invalid_'+format,source:0,program:0,edge:0,width:1,second:9999999,held:0,schedule:0,format,replays:3});
for(const format of [1,2,11,12,99])for(const source of[0,1])cases.push({name:`legacy_${format}_s${source}`,source,program:0,edge:source?-45:0,width:1,second:9999999,held:0,schedule:0,format,replays:3});
put('cases.json',JSON.stringify(cases,null,2));
put('batch.ps1',`param([int]$Worker=0,[int]$Workers=4)
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 $cases=Get-Content -Raw cases.json|ConvertFrom-Json
 for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){
  $c=$cases[$i];$label=$c.name;$releaseSecond=0;if($label -eq 'both_released'){$releaseSecond=1}
  @"
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps fixed_work.fixed_tb -gSOURCE=$($c.source) -gPROGRAM=$($c.program) -gEDGE=$($c.edge) -gWIDTH=$($c.width) -gSECOND=$($c.second) -gHELD=$($c.held) -gSCHEDULE=$($c.schedule) -gFORMAT=$($c.format) -gREPLAYS=$($c.replays) -gRELEASE_SECOND=$releaseSecond
set NumericStdNoWarnings 1
run -all
quit -code 0
"@|Set-Content "$label.sim.do"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do "$label.sim.do" -l "$label.transcript" -wlf "$label.wlf" *> "$label.log"
  $s=Get-Content -Raw "$label.log"
  if($LASTEXITCODE -ne 0 -or $s -match '\\*\\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS F16 fixed'){throw "Failed $label"}
  Write-Output "PASS $label"
 }
}finally{Pop-Location}
`);
console.log('Prepared '+cases.length+' F16/current-format, rejection and legacy cases.');

