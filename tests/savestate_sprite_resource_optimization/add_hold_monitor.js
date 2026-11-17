const fs=require('fs'),p=require('path'),d=__dirname,file=p.join(d,'phases/vdp_tb.sv');let s=fs.readFileSync(file,'utf8');
if(!s.includes('SAVE_TRANSPORT_HOLD PASS'))s=s.replace(/\nendmodule\s*$/,`
// Original G06 SAVE-transport hold assertion, retained alongside G05 monitors.
reg[N+41:0]save_sprite_held;reg[135:0]save_vdp_held;reg[229:0]save_cpu_held;
reg save_monitoring=0;integer frozen_samples=0;
always@(posedge clk)begin
 if(dut.state==41&&dut.do_save)begin
  save_sprite_held=g06_live;save_vdp_held=vdp_regs;save_cpu_held=z80_reg;save_monitoring=1;
 end
 if(save_monitoring&&frozen)begin
  frozen_samples++;
  if({g06_live,vdp_regs,z80_reg}!=={save_sprite_held,save_vdp_held,save_cpu_held})$fatal(1,"SAVE transport advanced guest state");
 end
 if(save_monitoring&&!frozen)begin
  save_monitoring=0;$display("SAVE_TRANSPORT_HOLD PASS profile%0d hostclocks%0d",STALL,frozen_samples);
 end
end
endmodule
`);fs.writeFileSync(file,s);console.log('Added original G06 hold monitor to unstarted phase/stall fixture.');
