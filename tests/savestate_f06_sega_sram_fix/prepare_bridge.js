const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'../savestate_format_consolidation/prepare_miter.js'),'utf8');
s=s.replaceAll("p.join(d,'candidate/rtl/savestates.sv')","p.join(root,'rtl/savestates.sv')");
s=s.replace("adapter(p.join(root,'rtl/savestates.sv')).replace('module savestates #'","fs.readFileSync(p.join(d,'format/savestates_sim.sv'),'utf8').replace('module savestates #'");
fs.writeFileSync(p.join(d,'bridge_generated.js'),s);
require('./bridge_generated.js');
