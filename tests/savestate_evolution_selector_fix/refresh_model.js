// Keep permanent drivers on the current production controller. Only declaration
// order is adapted for ModelSim; the baseline negative test is never refreshed.
const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
let s=fs.readFileSync(path.join(r,'rtl/savestates.sv'),'utf8');
for(const n of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=s.match(re)[0];s=s.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
fs.writeFileSync(path.join(d,'savestates_sim.sv'),s);
const regressions=path.join(d,'regressions');for(const ent of fs.readdirSync(regressions,{withFileTypes:true}))if(ent.isDirectory()&&fs.existsSync(path.join(regressions,ent.name,'savestates_sim.sv')))fs.writeFileSync(path.join(regressions,ent.name,'savestates_sim.sv'),s);
