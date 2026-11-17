const fs=require('fs'),p=require('path'),d=p.join(__dirname,'format');fs.mkdirSync(d,{recursive:true});
const adapter=require('../savestate_g06_g10_fix/controller_adapter');
fs.writeFileSync(p.join(d,'savestates_sim.sv'),adapter(p.join(__dirname,'proposed/rtl/savestates.sv')));
let s=fs.readFileSync(p.resolve(__dirname,'../savestate_g06_g10_fix/format/format_tb.sv'),'utf8');
s=s.replace('savestates dut(',`reg[138:0] bg_live=0,bg2_live=0;wire[138:0] bg_restored,bg2_restored;wire bg_valid;
reg expect_background=1;
savestates dut(.bg_out(bg_live),.bg2_out(bg2_live),.bg_in(bg_restored),.bg2_in(bg2_restored),.bg_valid(bg_valid),`);
s=s.replace('rejections=0,accepted=0;','rejections=0,accepted=0;');
s=s.replace('reg[63:0]oldtag;',`always@(posedge clk)if(loading&&vdp_regs_set)begin
 if(bg_valid!==expect_background)$fatal(1,"background validity mismatch");
 if(expect_background)begin
  if(bg_restored!==bg_live||(systeme&&bg2_restored!==bg2_live))$fatal(1,"background payload roundtrip mismatch");
 end else if(bg_restored!==0||bg2_restored!==0)$fatal(1,"legacy background history leaked");
end
reg[63:0]oldtag;reg[63:0]saved_image[0:12287];`);
s=s.replace("repeat(4)tick;reset_n=1;transfer(1);",`for(integer i=0;i<139;i++)begin bg_live[i]=(i%3)==0;bg2_live[i]=(i%5)==0;end
 bg_live[22:15]=179;bg2_live[22:15]=239;
 repeat(4)tick;reset_n=1;transfer(1);
 if(dut.bg_snap!==bg_live||dut.bg2_snap!==0)$fatal(1,"SAVE background ring did not return to capture");`);
s=s.replace("mem['h1a][63:40]!==24'h48430e","mem['h1a][63:40]!==24'h48430f").replace('"v14 format writer"','"v15 format writer"');
s=s.replace('transfer(0);if(!guest_writes||!sprite_valid)',`if(mem['h32]!==64'h008b0f0047354231||{mem['h35][10:0],mem['h34],mem['h33]}!==bg_live||mem['h35][63:11]!==0||{mem['h38],mem['h37],mem['h36]}!==0)$fatal(1,"v15 background writer packing");
 transfer(0);if(!guest_writes||!sprite_valid||!bg_valid)`);
s=s.replace(' // Every inherited tagged format',` // Background descriptor and every last-word padding bit reject before writes.
 for(integer b=0;b<64;b++)reject_bit('h32,b);
 for(integer b=11;b<64;b++)begin reject_bit('h35,b);reject_bit('h38,b);end
 for(integer b=0;b<139;b++)reject_bit('h36+(b/64),b%64);
 for(integer pos=240;pos<256;pos++)begin
  reg[7:0] oldpos;oldpos=mem['h33][22:15];mem['h33][22:15]=pos;
  transfer(0);if(guest_writes)$fatal(1,"invalid semantic text position accepted");rejections++;mem['h33][22:15]=oldpos;
 end
 // Every inherited tagged format`);
s=s.replace("oldtag=mem['h1a];",`oldtag=mem['h1a];expect_background=0;`);
s=s.replace("mem['h1a]=oldtag;mem['h2f][3]=0;",`// v14 keeps sprite/phase history and deterministically lacks G05.
 mem['h1a][63:40]=24'h48430e;mem['h1a][39:38]=3;
 transfer(0);if(!guest_writes||!sprite_valid||bg_valid)$fatal(1,"v14 compatibility");accepted++;
 expect_background=1;mem['h1a]=oldtag;mem['h2f][3]=0;`);
s=s.replace('$display("PASS V14 FORMAT rejected%0d accepted%0d",rejections,accepted);',`// Independent dual-device nonzero records and invalid second text position.
 systeme=1;transfer(1);
 if(dut.bg_snap!==bg_live||dut.bg2_snap!==bg2_live)$fatal(1,"dual SAVE ring mismatch");
 transfer(0);if(!guest_writes||!bg_valid)$fatal(1,"dual v15 rejected");accepted++;
 for(integer pos=240;pos<256;pos++)begin
  reg[7:0] oldpos;oldpos=mem['h36][22:15];mem['h36][22:15]=pos;
  transfer(0);if(guest_writes)$fatal(1,"invalid second semantic position accepted");rejections++;mem['h36][22:15]=oldpos;
 end
 // Full controller transfers for every payload bit in both independent banks.
 for(integer bitindex=0;bitindex<139;bitindex++)begin
  bg_live=139'd1<<bitindex;bg2_live=139'd1<<(138-bitindex);
  transfer(1);transfer(0);if(!guest_writes)$fatal(1,"one-hot roundtrip rejected");accepted++;
 end
 // Every semantic counter encoding, including the239 endpoint.
 for(integer pos=0;pos<240;pos++)begin
  bg_live=0;bg2_live=0;bg_live[22:15]=pos;bg2_live[22:15]=239-pos;
  transfer(1);transfer(0);if(!guest_writes)$fatal(1,"valid semantic position rejected");accepted++;
 end
 // Genuine oldest size route must ignore poisoned modern extension bytes.
 systeme=0;expect_background=0;mem[0][63:32]=32'h3ffe;
 mem['he][63:56]=0;mem[5][63:20]=0;mem['h32]='1;mem['h33]='1;
 transfer(0);if(!guest_writes||bg_valid||sprite_valid)$fatal(1,"old64 compatibility");accepted++;
 expect_background=1;transfer(1);transfer(0);if(!guest_writes||!bg_valid)$fatal(1,"modern after legacy failed");accepted++;
 $display("PASS V15 FORMAT rejected%0d accepted%0d two139bitRecords onehots139 positions240 inherited1to14 old64",rejections,accepted);`);
s=s.replace('#100000000;','#1000000000;');
fs.writeFileSync(p.join(d,'format_tb.sv'),s);
fs.writeFileSync(p.join(d,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib format_work\nvlog -work format_work -sv -quiet savestates_sim.sv format_tb.sv\nvsim -c format_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1\nrun -all\nquit -code 0\n`);
