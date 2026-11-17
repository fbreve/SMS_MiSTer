// Use the transaction-qualified deterministic/LFSR backpressure mechanism from
// the committed v14 fix's successful stall witnesses. No DUT state is forced.
const fs=require('fs'),p=require('path'),d=p.join(__dirname,'stalls_valid'),src=p.join(__dirname,'bus');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replace(/always@\(negedge clk\)if\(STALL\)DDRAM_BUSY<=.*?;\n/,'');
s=s.replace('ss_load=!saveop;tick;ss_save=0;','ss_load=!saveop;do tick;while(dut.state==0);ss_save=0;');
s=s.replace(/\nendmodule\s*$/,`
reg[15:0]stall_rng=16'h1ace;integer frozen_start=0;reg[N+41:0]held_save_sprite;reg[135:0]held_save_vdp;reg[229:0]held_save_cpu;reg save_check=0;
always@(negedge clk)begin #0.001;
 stall_rng={stall_rng[14:0],stall_rng[15]^stall_rng[13]^stall_rng[12]^stall_rng[10]};
 DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%97<83:STALL==2?stall_rng[3:0]<13:0);
end
always@(posedge ss_freeze)frozen_start=cycle;
always@(negedge ss_freeze)if(hadfreeze)$display("TRANSPORT_DURATION save%b profile%0d hostclocks%0d",dut.do_save,STALL,cycle-frozen_start);
always@(posedge clk)begin
 if(dut.state==41&&dut.do_save)begin held_save_sprite=g06_live;held_save_vdp=vdp_regs;held_save_cpu=z80_reg;save_check=1;end
 if(save_check&&frozen&&{g06_live,vdp_regs,z80_reg}!=={held_save_sprite,held_save_vdp,held_save_cpu})$fatal(1,"SAVE transport changed guest history");
 if(save_check&&!frozen)save_check=0;
end
endmodule
`);fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
for(const profile of[1,2]){const dir=p.join(d,'dut_p'+profile);fs.mkdirSync(dir,{recursive:true});for(const f of['rom.hex','reference.dat'])fs.copyFileSync(p.join(src,'dut_clone',f),p.join(dir,f));let run=fs.readFileSync(p.join(src,'dut_clone/run.do'),'utf8').replace('-gSTALL=0','-gSTALL='+profile);fs.writeFileSync(p.join(dir,'run.do'),run);}
console.log('Two transaction-qualified stall replays prepared against the canonical clone reference');
