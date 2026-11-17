const fs=require('fs'),p=require('path'),d=__dirname,root=p.resolve(d,'../..'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const original=fs.readFileSync(p.join(root,'tests/savestate_g08_fm/format/format_tb.sv'),'utf8');
let prefix=original.slice(0,original.indexOf('initial begin\n for(integer i=0;i<12288;i++)'));
if(prefix===original)throw Error('initial block not found');
prefix=prefix.replace('module vdp_tb;',"module vdp_tb;\nreg[383:0]palette1=0,palette2=0,keep1,keep2;\nreg[1:0]test_phase=0;reg test_tick=1;\ninteger profile=0,wallcycle=0,images=0,load_count=0,stream;\nreg[31:0]rng=32'h6384a117;\nreg[11:0]serial1,serial2;\n");
prefix=prefix.replace('assign cram_out=0;','assign cram_out=palette1;');
prefix=prefix.replace("reg [383:0] cram2_out = '0;",'wire [383:0] cram2_out=palette2;');
prefix=prefix.replace(".clock_phase(clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0)",'.clock_phase(test_phase)').replace(".z80_tick_active(!logical_pause)",'.z80_tick_active(test_tick)');
prefix=prefix.replace('pending<=3;readaddr<=DDRAM_ADDR;','pending<=1+(profile%5);readaddr<=DDRAM_ADDR;');
const tail=`

function[31:0]rnd;begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};rnd=rng;end endfunction
always@(negedge clk)begin wallcycle++;DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&profile%3!=0&&(wallcycle%8<(profile%3==1?2:7));end
always@(posedge clk)begin
 if(cram_wr)palette1[12*cram_A+:12]<=cram_D;
 if(cram2_wr)palette2[12*cram2_A+:12]<=cram2_D;
end
initial begin
 for(integer i=0;i<12288;i++)mem[i]=0;
 for(integer i=0;i<139;i++)begin bg_live[i]=(i%3)==0;bg2_live[i]=(i%5)==0;end
 bg_live[22:15]=179;bg2_live[22:15]=239;
 repeat(4)tick;reset_n=1;
 stream=$fopen("images.hex","w");
 for(profile=0;profile<16;profile++)begin
  systeme=profile[2];test_phase=profile[1:0];test_tick=profile[3];
  for(integer a=0;a<32;a++)begin palette1[12*a+:12]=rnd();palette2[12*a+:12]=rnd();end
  keep1=palette1;keep2=palette2;
  transfer(1);
  if(mem[47][1:0]!==test_phase||mem[47][3]!==test_tick)$fatal(1,"phase profile encoding");
  if({mem[13],mem[12],mem[11],mem[10],mem[9],mem[8]}!==keep1)$fatal(1,"SAVE primary packing profile%0d",profile);
  if(systeme&&{mem[23],mem[22],mem[21],mem[20],mem[19],mem[18]}!==keep2)$fatal(1,"SAVE secondary packing");
  for(integer w=0;w<12288;w++)begin
   if($isunknown(mem[w]))$fatal(1,"unknown complete image profile%0d word%0h",profile,w);
   saved_image[w]=mem[w];$fdisplay(stream,"%016h",mem[w]);
  end
  images++;
  for(integer rep=0;rep<3;rep++)begin
   for(integer a=0;a<32;a++)begin palette1[12*a+:12]=rnd();palette2[12*a+:12]=rnd();end
   transfer(0);
   if(palette1!==keep1||(systeme&&palette2!==keep2))$fatal(1,"LOAD contents profile%0d rep%0d",profile,rep);
   for(integer w=0;w<12288;w++)if(mem[w]!==saved_image[w])$fatal(1,"image mutated");
   load_count++;
  end
  $display("PASS CRAM IMAGE profile%0d phase%0d owner%b tick%b loads3",profile,test_phase,systeme,test_tick);
 end
 // Old64 with System E must preserve the current secondary palette.
 systeme=1;expect_background=0;want_history=0;
 for(integer a=0;a<32;a++)begin palette1[12*a+:12]=rnd();palette2[12*a+:12]=rnd();end
 keep2=palette2;
 mem[0][63:32]=32'h3ffe;mem[14][63:56]=0;mem[5][63:20]=0;
 for(integer w=18;w<=23;w++)mem[w]='1;
 transfer(0);
 if(palette2!==keep2)$fatal(1,"legacy64 System E changed live secondary palette");
 $display("PASS CRAM LEGACY64 SYSTEME secondary_retained");
 $fclose(stream);$display("PASS CRAM IMAGE ALL images%0d loads%0d",images,load_count);$finish;
end
initial begin #2000000000;$fatal(1,"image proof watchdog");end
always@(posedge clk)if(loading&&audio_phase_set)begin
 if(history_valid!==want_history)$fatal(1,"history presence");
 if(want_history&&history_restored!==history_source)$fatal(1,"history contents");
end
endmodule
`;
for(const candidate of [false,true]){
 const out=p.join(d,candidate?'image_candidate':'image_reference');fs.mkdirSync(out,{recursive:true});let s=prefix+tail;
 if(candidate){s=s.replace('wire [383:0] cram_out;','wire[11:0]cram_out;wire[383:0]palette_source1=palette1;');s=s.replace('assign cram_out=palette1;','always@(posedge clk)begin serial1<=palette1[12*cram_A+:12];serial2<=palette2[12*cram2_A+:12];end\nassign cram_out=serial1;');s=s.replace('wire [383:0] cram2_out=palette2;','wire[11:0]cram2_out=serial2;');}
 fs.writeFileSync(p.join(out,'image_tb.sv'),s);
 fs.writeFileSync(p.join(out,'savestates_sim.sv'),adapter(p.join(d,candidate?'../../rtl/savestates.sv':'baseline/rtl/savestates.sv')));
 fs.writeFileSync(p.join(out,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib image_work\nvlog -work image_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv image_tb.sv\nvsim -t 1ps image_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1\nrun -all\nquit -code 0\n`);
}
console.log('Prepared paired v19 complete-image16-profile/48-LOAD protocol proof.');
