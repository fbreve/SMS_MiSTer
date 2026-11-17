const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const dir=__dirname,root=p.resolve(dir,'../..'),old=p.join(root,'tests/savestate_g02_g06_vdp');
const norm=s=>s.replace(/\r\n/g,'\n');const write=(d,f,s)=>fs.writeFileSync(p.join(d,f),s);
const d=p.join(dir,'reproduction');fs.mkdirSync(d,{recursive:true});
for(const f of ['rom.hex','rom.json','header.svh','vdp_tb.sv','T80_sim.vhd','T80s_sim.vhd','vdp_sim.vhd','savestates_sim.sv','reference.dat'])fs.copyFileSync(p.join(old,f),p.join(d,f));
fs.mkdirSync(p.join(d,'overflow9'),{recursive:true});
for(const f of ['rom.hex','reference.dat'])fs.copyFileSync(p.join(old,'overflow9',f),p.join(d,'overflow9',f));
for(const name of ['compile.do','run.do']){let s=norm(fs.readFileSync(p.join(old,name),'utf8')).replaceAll('../../rtl','../../../rtl');write(d,name,s);if(name==='run.do')write(p.join(d,'overflow9'),name,s);}
write(d,'run.ps1',`param([int]$Sprites=2,[int]$Reference=0,[switch]$Compile)
$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Compile){& "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log;if($LASTEXITCODE){throw 'compile failed'}}
if($Sprites -eq 9){Set-Location overflow9;& "$bin/vmap.exe" -c | Out-Null;& "$bin/vmap.exe" vdp_work ../vdp_work | Out-Null}
$env:VDP_GG=1;$env:VDP_PAL=0;$env:VDP_REQUEST_X=40;$env:VDP_SPRITE_X=120;$env:VDP_SPRITES=$Sprites;$env:VDP_REPLAYS=3;$env:VDP_REFERENCE=$Reference
& "$bin/vsim.exe" -c -do 'do run.do' -l $(if($Reference){'reference.log'}else{'dut.log'})
if($LASTEXITCODE){throw 'runtime failed'}
`);
const files=cp.execFileSync('git',['ls-files'],{cwd:root,encoding:'utf8'}).trim().split('\n');const hashes={};for(const f of files){const q=p.join(root,f);if(fs.existsSync(q)&&fs.statSync(q).isFile())hashes[f]=crypto.createHash('sha256').update(fs.readFileSync(q)).digest('hex');}
write(dir,'baseline.json',JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),format:13,hashes},null,2));
