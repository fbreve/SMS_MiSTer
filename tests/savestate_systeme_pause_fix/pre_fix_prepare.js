const fs=require('fs'),path=require('path'),cp=require('child_process'),d=__dirname,r=path.resolve(d,'../..');
for(const [src,dst]of[['SMS.sv','SMS.sv'],['rtl/savestates.sv','savestates.sv']]){
 const p=path.join(d,'baseline',dst);if(!fs.existsSync(p))fs.writeFileSync(p,cp.execFileSync('git',['show','dcbe06d:'+src],{cwd:r}));
}
let s=fs.readFileSync(path.join(d,'baseline/prepare.js'),'utf8');
s=s.replace("path.join(r,'SMS.sv')","path.join(d,'baseline/SMS.sv')").replace("path.join(r,'rtl/savestates.sv')","path.join(d,'baseline/savestates.sv')").replace("path.join(d,'scenario.sv.in')","path.join(d,'baseline/scenario.sv.in')");
s=s.replace("path.join(r,'tests/savestate_hcounter/controller_tb.sv')","path.join(d,'baseline/controller_tb.sv')");
new Function('require','__dirname',s)(require,d);
for(const n of ['pause_tb.sv','pause_fixture.sv','savestates_sim.sv'])fs.copyFileSync(path.join(d,n),path.join(d,'red_'+n));
let run=fs.readFileSync(path.join(d,'run.do'),'utf8');for(const n of ['pause_tb.sv','pause_fixture.sv','savestates_sim.sv'])run=run.replace(n,'red_'+n);fs.writeFileSync(path.join(d,'red_run.do'),run);
