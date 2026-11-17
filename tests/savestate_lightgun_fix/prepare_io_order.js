const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'hcounter_guard_tb.sv'),'utf8').replace('module hcounter_guard;','module io_order_tb;');
s=s.replace('// Let discarded execution reach',`addr=8'h3f;data=0;wr=0;repeat(30)tick;wr=1;repeat(30)tick;
if(io_out[7:0]!==0)$fatal(1,"discarded IO control write missed");
// Let discarded execution reach`);
fs.writeFileSync(path.join(d,'io_order_tb.sv'),s);
for(let i=0;i<2;i++)fs.writeFileSync(path.join(d,'io_order'+i+'.do'),fs.readFileSync(path.join(d,'stalls0.do'),'utf8').replaceAll('boundary0_work','io_order'+i+'_work').replaceAll('boundary_tb','io_order_tb').replace('-gSTALL=0',`-gSTALL=${i?3:0} -gPORT=${i}`));
