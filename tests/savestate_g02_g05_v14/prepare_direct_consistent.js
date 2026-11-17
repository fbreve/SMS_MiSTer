const fs=require('fs'),p=require('path'),d=p.join(__dirname,'direct_consistent'),src=p.join(__dirname,'direct');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8').replace('always #5 clk=~clk;',`// System E mapper bit5 is the production CPU VRAM-bank selector. Hold the
// preconfigured bank selection consistently in both the bus glue and image.
initial mapper_out[5]=(DIRECT_OWNER==0);
always #5 clk=~clk;`);fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
for(const ref of[1,0]){const name=(ref?'reference_':'dut_')+'owner0',dir=p.join(d,name);fs.mkdirSync(dir,{recursive:true});for(const f of['rom.hex','run.do'])fs.copyFileSync(p.join(src,name,f),p.join(dir,f));}
console.log('Primary System E direct-write witness with consistent saved CPU-bank ownership prepared');
