const fs=require('fs'),p=require('path'),here=__dirname,src=p.join(here,'candidate'),d=p.join(here,'sprites');fs.mkdirSync(d,{recursive:true});
for(const f of fs.readdirSync(src))if(/\.(sv|svh|vhd|do|hex)$/.test(f)&&fs.statSync(p.join(src,f)).isFile())fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
const read=f=>fs.readFileSync(p.join(src,f),'utf8').replace(/\r\n/g,'\n'),put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
put('header.svh',read('header.svh').replace('NATURAL_PHASE=0;', 'NATURAL_PHASE=0,OBSERVATIONS=1000,LEGACY=0,NEAR=0,TERMINATED=0,SP64=0,SPRITE_Y=167,FIRST_VISIBLE=0;'));
let s=read('vdp_tb.sv');
s=s.replaceAll('[0:3000]','[0:OBSERVATIONS-1]').replaceAll('j<1000','j<OBSERVATIONS').replace(".sp64(1'b0)",'.sp64(SP64!=0)');
s=s.replace('end endfunction', `
 if(!LEGACY)begin
  if(n>=14'h3f00&&n<14'h3f40)begin off=n-14'h3f00;pattern=off<SPRITES?SPRITE_Y:(off==SPRITES||!TERMINATED?208:SPRITE_Y);end
  if(n>=14'h3f80&&n<16384)begin off=(n-14'h3f80)/2;pattern=n[0]?0:SPRITE_X+((NEAR&&off%2)?8:0);end
 end else begin
  if(n>=14'h2000&&n<14'h2400)pattern=8'hff;
  if(n>=14'h3f00&&n<14'h3f80)begin
   off=(n-14'h3f00)/4;
   case(n%4)
   0:pattern=off<SPRITES?SPRITE_Y:(off==SPRITES||!TERMINATED?208:SPRITE_Y);
   1:pattern=SPRITE_X+((NEAR&&off%2)?8:0);
   2:pattern=0;
   3:pattern=5;
   endcase
  end
 end
end endfunction`);
s=s.replace(/^ if\(SPRITES>2&&PROTO\).*\n/m,'')
 .replace(/ if\(SPRITES>2\)begin\n  if\(saveflags==0[\s\S]*?\n end\n/,'');
s=s.replace('reg scoring=0;', 'reg scoring=0;integer visible_line0=0;');
s=s.replace('  savechecks++;', '  if(y==0&&x<256)visible_line0++;\n  savechecks++;');
s=s.replace(' if(REFERENCE)begin $fclose(f);', ' if(FIRST_VISIBLE&&visible_line0==0)$fatal(1,"first visible line was not observed");\n if(REFERENCE)begin $fclose(f);');
put('vdp_tb.sv',s);
const baseRom=fs.readFileSync(p.join(src,'rom.hex'),'utf8').trim().split(/\r?\n/).map(x=>parseInt(x,16));
const defs=[
 ['zero', {SPRITES:0}],['one',{SPRITES:1}],['collision',{SPRITES:2}],['near',{SPRITES:2,NEAR:1}],
 ['overflow8',{SPRITES:8}],['overflow9',{SPRITES:9}],['terminated',{SPRITES:2,TERMINATED:1}],
 ['tall',{SPRITES:2,R1:0x42}],['legacy_graphics1',{LEGACY:1,R0:0,GG:0}],
 ['legacy_graphics2',{LEGACY:1,R0:2,GG:0}],['legacy_tall',{LEGACY:1,R0:2,R1:0x42,GG:0}],
 ['first_visible',{GG:0,SPRITE_Y:255,OBSERVATIONS:25000,FIRST_VISIBLE:1}],
 ['line_transition',{REQUEST_X:230,SPRITE_X:248}],
 ['accelerated64',{SLOTS:64,SP64:1,SPRITES:64}]
];
const cases=[];
for(const [id,options] of defs){
 const cfg={GG:1,PAL:0,REQUEST_X:40,SPRITE_X:120,SPRITES:2,REPLAYS:3,PROTO:1,TURBO:1,FIX:1,EXT_REFERENCE:1,WARMUP:1,PAUSE_CAPTURE:0,NATURAL_PHASE:0,SLOTS:8,OBSERVATIONS:1000,LEGACY:0,NEAR:0,TERMINATED:0,SP64:0,SPRITE_Y:167,FIRST_VISIBLE:0,...options};
 const rom=[...baseRom];
 for(const [r,value] of [[0,cfg.R0],[1,cfg.R1]])if(value!==undefined){let found=false;
  for(let i=0;i<150;i++)if(rom[i]===0x3e&&rom[i+2]===0xd3&&rom[i+3]===0xbf&&rom[i+4]===0x3e&&rom[i+5]===(0x80|r)){rom[i+1]=value;found=true;break;}
  if(!found)throw Error('Missing VDP register initializer '+r);
 }
 delete cfg.R0;delete cfg.R1;
 for(const ref of [1,0]){
  const label=(ref?'reference_':'dut_')+id,dir=p.join(d,label);fs.mkdirSync(dir,{recursive:true});
  fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');
  const args=Object.entries({...cfg,REFERENCE:ref}).map(([k,v])=>'-g'+k+'='+v).join(' ');
  fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb ${args} -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);
 }
 cases.push({id,cfg});
}
put('cases.json',JSON.stringify(cases,null,2));
put('matrix.ps1',`param([int]$Worker=0,[int]$Workers=4)
$ErrorActionPreference='Stop'
$base=$PSScriptRoot;$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$cases=Get-Content -Raw "$base/cases.json"|ConvertFrom-Json
for($i=$Worker;$i -lt $cases.Count;$i+=$Workers){
 $c=$cases[$i]
 foreach($ref in 1,0){
  $label=$(if($ref){'reference_'}else{'dut_'})+$c.id
  Set-Location (Join-Path $base $label)
  if(Test-Path simulation.log){$prior=Get-Content -Raw simulation.log;if($prior -notmatch '\\*\\* (Error|Fatal|Failure)|Errors: [1-9]' -and $prior -match $(if($ref){'PASS UNINTERRUPTED REFERENCE'}else{'DONE VDP'})){Write-Output "PASS retained $label";continue}}
  & "$bin/vmap.exe" -c|Out-Null;& "$bin/vmap.exe" vdp_work ../vdp_work|Out-Null
  if(!$ref){Copy-Item -LiteralPath "$base/reference_$($c.id)/reference.dat" -Destination reference.dat}
  & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
  $s=Get-Content -Raw simulation.log
  if($LASTEXITCODE -or $s -match '\\*\\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch $(if($ref){'PASS UNINTERRUPTED REFERENCE'}else{'DONE VDP'})){Get-Content simulation.log -Tail 16;throw "Failed $label"}
  Write-Output "PASS $label"
 }
}
Write-Output "SPRITE WORKER COMPLETE $Worker"
`);
console.log('Fourteen initialized sprite families prepared.');
