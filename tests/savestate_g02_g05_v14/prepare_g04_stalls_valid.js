const fs=require('fs'),p=require('path'),d=p.join(__dirname,'g04_stalls_valid'),src=p.join(__dirname,'g04_native');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8').replace(/always@\(negedge clk\)if\(STALL\)DDRAM_BUSY<=.*?;\n/,'');
const donor=fs.readFileSync(p.join(__dirname,'stalls_valid/vdp_tb.sv'),'utf8');const block=donor.slice(donor.indexOf("reg[15:0]stall_rng=16'h1ace"),donor.lastIndexOf('\nendmodule'));
if(!block.startsWith('reg[15:0]stall_rng'))throw Error('stall monitor anchor');
s=s.replace(/\nendmodule\s*$/, '\n'+block+'\nendmodule\n');fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
const dir=p.join(d,'dut_pending');fs.mkdirSync(dir,{recursive:true});for(const f of['rom.hex','reference.dat','native_reference.dat'])fs.copyFileSync(p.join(src,'dut_pending',f),p.join(dir,f));let run=fs.readFileSync(p.join(src,'dut_pending/run.do'),'utf8').replace('-gREFERENCE=0','-gREFERENCE=0 -gSTALL=1');fs.writeFileSync(p.join(dir,'run.do'),run);
console.log('Nonzero G04 delay with transaction stalls and every-host-clock oracle prepared');
