const fs=require('fs'),path=require('path');const d=__dirname;const get=n=>fs.readFileSync(path.join(d,n),'utf8').replace(/\r\n/g,'\n'),put=(n,s)=>fs.writeFileSync(path.join(d,n),s);
let tb=get('integrated_tb.sv').replace('task compare(input integer k);begin',`task compare(input integer k);begin
 if((^z80_reg)===1'bx||(^golden[k][552:323])===1'bx)$fatal(1,"Unknown architecture in suffix");
 if(iteration>0&&(k==0||k==PERIOD))$display("CANONICAL_TRACE iter%0d k%0d ctx%h CPU%h",iteration,k,du,z80_reg);`);
tb=tb.replace('if(core.ram[a]!==golden_ram[a])',"if((^core.ram[a])===1'bx||(^golden_ram[a])===1'bx||core.ram[a]!==golden_ram[a])");
tb=tb.replace('"image_p','"trace_image_p').replace('PASS G01 program','PASS G01 TRACE program');put('trace_tb.sv',tb);
put('trace.do',get('integrated.do').replaceAll('integrated_work','trace_work').replace('integrated_tb.sv','trace_tb.sv'));
put('trace.ps1',get('integrated.ps1').replace('Get-Content integrated.do','Get-Content trace.do').replace('"integrated_p','"trace_p'));
const cases=[];for(const[p,o]of[[10,719],[11,719],[12,2570],[13,2570],[14,61724],[15,61724],[17,600],[28,840],[30,1000],[31,1000]])cases.push({program:p,offset:o,intCase:p===28?1:p===30?4:0});for(let p=18;p<=25;p++)cases.push({program:p,offset:40496,intCase:0});put('trace_cases.json',JSON.stringify(cases,null,2));
put('trace_batch.ps1',`param([int]$Worker=0,[int]$Workers=3)
$ErrorActionPreference='Stop'
$cases=Get-Content -Raw "$PSScriptRoot/trace_cases.json"|ConvertFrom-Json
for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){$c=$cases[$i];& "$PSScriptRoot/trace.ps1" -Program $c.program -Offset $c.offset -IntCase $c.intCase;if($LASTEXITCODE -ne 0){throw "Failed trace $i"}}
`);console.log('Prepared 18 strict known-bit canonical/first-continuation traces.');
