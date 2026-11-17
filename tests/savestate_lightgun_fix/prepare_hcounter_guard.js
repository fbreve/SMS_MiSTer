const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'boundary_tb.sv'),'utf8').replace('module boundary_tb;','module hcounter_guard;');
s=s.replace('integer frame=0;', 'integer frame=0;');
s=s.replace('integer frame=0,', 'integer guard_checks=0,legitimate_rises=0;reg restored_latch=0,previous_sensor=0,seen_freeze=0;reg[7:0]freeze_h;\ninteger frame=0,');
s=s.replace('$display("PASS F11 future frame and first legitimate event equivalence");$finish;',`if(guard_checks<900000||legitimate_rises==0)$fatal(1,"HCounter guard/event coverage missed");
$display("PASS F11 HCounter held after restore checks%0d legitimate rises%0d",guard_checks,legitimate_rises);
$display("PASS F11 future frame and first legitimate event equivalence");$finish;`);
s=s.replace('\nendmodule',`

always@(posedge ss_freeze)begin #1;restored_latch=0;seen_freeze=1;freeze_h=hval;end
always@(posedge clk)begin
 previous_sensor<=sensor;
 if(vdp_regs_set)begin #1;restored_latch=1;end
 if(!ss_freeze&&restored_latch&&!previous_sensor&&sensor)legitimate_rises=legitimate_rises+1;
end
always@(negedge clk)begin
 if(ss_freeze&&seen_freeze&&dut.do_save&&hval!==freeze_h)$fatal(1,"save transport changed HCounter latch");
 // Applying gun/TH state early can settle HL before F07 installs the saved latch.
 // Once F07 has installed it, transport must never overwrite that latch.
 if(ss_freeze&&restored_latch&&!vdp_regs_set)begin
  guard_checks=guard_checks+1;
  if(hval!==saved_h||sensor!==saved_sensor)$fatal(1,"false event after F07 restore");
 end
end
endmodule`);
fs.writeFileSync(path.join(d,'hcounter_guard_tb.sv'),s);
for(const i of [0,3])fs.writeFileSync(path.join(d,'hcounter_guard'+i+'.do'),fs.readFileSync(path.join(d,'stalls'+i+'.do'),'utf8').replaceAll('boundary'+i+'_work','hcounter_guard'+i+'_work').replace('boundary_tb.sv','hcounter_guard_tb.sv').replace('.boundary_tb','.hcounter_guard'));
