const fs=require('fs'),p=require('path'),d=__dirname;
const adapter=require('../savestate_g06_g10_fix/controller_adapter');
const old=p.join(d,'../savestate_f06_sega_sram');
let s=fs.readFileSync(p.join(old,'sram_tb.sv'),'utf8').replace(/\r\n/g,'\n');
const tail=s.indexOf('integer payload=0;');
s=s.slice(0,tail);
s=s.replace('module sram_tb;','module sram_tb; parameter STALL=0,OLD=0;');
s=s.replace(".clock_b(clk),.address_b(15'd0),.data_b(8'd0),.wren_b(1'b0),.q_b()",'.clock_b(clk),.address_b(host_addr),.data_b(host_data),.wren_b(host_we),.q_b()');
s=s.replace('reg mapper_reset_n=0;', 'reg[14:0]host_addr=0;reg[7:0]host_data=0;reg host_we=0;\nreg mapper_reset_n=0;');
s=s.replace('.q_b()', '.q_b(physical_q)').replace('reg[14:0]host_addr=0;', 'wire[7:0]physical_q;reg[14:0]host_addr=0;');
s=s.replace('integer pending=0;','integer pending=0;');
s=s.replace('always@(negedge clk)phase_ready<=phase_set;',`always@(negedge clk)phase_ready<=phase_set;
reg[15:0]stall_lfsr=16'h1ace;integer cyc=0;
always@(negedge clk)begin
 cyc++;stall_lfsr={stall_lfsr[14:0],stall_lfsr[15]^stall_lfsr[13]^stall_lfsr[12]^stall_lfsr[10]};
 DDRAM_BUSY=(DDRAM_WE||DDRAM_RD)&&(STALL==1?cyc%31<13:STALL==2?stall_lfsr[3:0]<12:0);
end`);
s=s.replace('pending<=3;readaddr<=DDRAM_ADDR;', 'pending<=STALL==0?3:STALL==1?17:3+stall_lfsr[3:0];readaddr<=DDRAM_ADDR;');
fs.writeFileSync(p.join(d,'f06_tb.sv'),s+fs.readFileSync(p.join(d,'f06_tail.sv'),'utf8'));
for(const name of ['current','old']){
 const dest=p.join(d,name);fs.mkdirSync(dest,{recursive:true});
 fs.writeFileSync(p.join(dest,'savestates_sim.sv'),adapter(name==='current'?'rtl/savestates.sv':p.join(d,'baseline/savestates.sv')));
 fs.copyFileSync(p.join(old,'mapper_sim.vhd'),p.join(dest,'mapper_sim.vhd'));
 // MIF is relative to simulator working directory.
 fs.writeFileSync(p.join(dest,'f06_tb.sv'),fs.readFileSync(p.join(d,'f06_tb.sv'),'utf8').replace('../../rtl/nvram_ff.mif','../../../rtl/nvram_ff.mif'));
 fs.writeFileSync(p.join(dest,'compile.do'),`onerror {quit -code 1}\nvlib work\nvcom -2008 -quiet ../../../rtl/dpram.vhd mapper_sim.vhd ../../../rtl/memory_bus.vhd\nvlog -sv -suppress 2244 -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv f06_tb.sv\nquit -code 0\n`);
 for(const stall of [0,1,2])fs.writeFileSync(p.join(dest,'run'+stall+'.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf -gSTALL=${stall} -gOLD=${name==='old'?1:0} work.sram_tb\nset StdArithNoWarnings 1\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);
}
console.log('Prepared actual controller/mapper/bus/RAM F06 fixtures');
