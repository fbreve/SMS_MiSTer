const fs=require('fs'),p=require('path'),d=p.join(__dirname,'old_reader'),src=p.join(__dirname,'../savestate_evolution_pending_fix');fs.mkdirSync(d,{recursive:true});
for(const n of ['savestates_sim.sv','format_tb.sv','compat_tb.sv','regression_machine.sv','f13_machine.sv','f13_mapper_ctrl_sim.vhd','format.do','compat.do']){
 let s=fs.readFileSync(p.join(src,n),'utf8');if(n.endsWith('.do'))s=s.replaceAll('../../rtl/','../../../rtl/');
 fs.writeFileSync(p.join(d,n),s);
}
