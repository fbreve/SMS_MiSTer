const fs=require('fs'),p=require('path'),d=__dirname,adapter=require('../savestate_g06_g10_fix/controller_adapter'),root=p.resolve(d,'../..');
for(const family of ['reg_g05','reg_sprites','reg_g10','reg_dual','reg_g04']){
 const dst=p.join(d,family),file=p.join(dst,'vdp_tb.sv');let s=fs.readFileSync(file,'utf8');
 s=s.replace("request(1);mem[26][63:40]=24'h48430d;", "request(1);mem[26][63:22]=0;mem['he][63:52]=0;mem[5][63:38]=0;").replace('A genuine v13 LOAD','A public96 fallback LOAD');fs.writeFileSync(file,s);
 fs.writeFileSync(p.join(dst,'golden_controller.sv'),adapter(p.join(root,'rtl/savestates.sv')).replace('900000','0'));
 let compile=fs.readFileSync(p.join(dst,'compile.do'),'utf8').replaceAll('vdp_work','golden_work').replace('savestates_sim.sv','golden_controller.sv');fs.writeFileSync(p.join(dst,'compile_golden.do'),compile);
}
let r=fs.readFileSync(p.join(d,'regress.ps1'),'utf8');r=r.replace("'do compile.do'","'do compile_golden.do'").replace('compile.log','compile_golden.log').replace('compile_stdout.log','compile_golden_stdout.log');
r=r.replace('$families=@($rows.family|Select-Object -Unique)',"$families=@('reg_g05','reg_sprites','reg_g10','reg_dual','reg_g04')");
r=r.replace('& "$bin/vmap.exe" $r.library "../$($r.library)" *>> vmap.log','& "$bin/vmap.exe" $r.library "../golden_work" *>> vmap.log');
r=r.replace("& \"$bin/vsim.exe\" -c -do 'do run.do' -l simulation.log *> simulation_stdout.log",`$do=(Get-Content run.do -Raw).Replace('-gREFERENCE=0','-gREFERENCE=1')
   Set-Content reference.do $do
   & "$bin/vsim.exe" -c -do 'do reference.do' -l reference_new.log *> reference_new_stdout.log`);
r=r.replaceAll('simulation.log','reference_new.log').replaceAll('$r.marker',"'REFERENCE'").replace('($r.also -and $s -notmatch $r.also)',"$false");
r=r.replace('$compile=Get-Content compile.log','$compile=Get-Content compile_golden.log');
r=r.replace('& "$bin/vmap.exe" -c *> vmap.log','if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}');
fs.writeFileSync(p.join(d,'references.ps1'),r);
