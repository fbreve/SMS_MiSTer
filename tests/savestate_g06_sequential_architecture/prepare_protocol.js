const fs=require('fs'),p=require('path'),d=__dirname,adapter=require('../savestate_g06_g10_fix/controller_adapter');
const dst=p.join(d,'protocol');fs.mkdirSync(dst,{recursive:true});
fs.writeFileSync(p.join(dst,'candidate.sv'),adapter(p.join(d,'candidate_A/rtl/savestates.sv')));
fs.writeFileSync(p.join(dst,'golden.sv'),adapter(p.join(d,'baseline/rtl/savestates.sv')).replace('module savestates #','module savestates_reference #'));
let s=fs.readFileSync(p.join(d,'../savestate_f01_opll_fix/format/format_tb.sv'),'utf8');
const a=s.indexOf('savestates dut('),b=s.indexOf('\n\nalways #5',a);let inst=s.slice(a,b);
inst=inst.replace('.sprite_out({{(4778-(N+42)){1\'b0}},g06_live})','.sprite_out(sp_live1[4777:0])').replace('.sprite2_out(4778\'d0)','.sprite2_out(sp_live2[4777:0])').replace('.sprite2_in()','.sprite2_in(sp_restored2)');
const ports='.sprite_state_addr(sp_addr),.sprite_state_second(sp_second),.sprite_state_read(sp_read),.sprite_state_write(sp_write),.sprite_state_wdata(sp_wdata),.sprite_state_rdata(sp_rdata),';
const decl=`reg[4799:0]sp_live1=0,sp_live2=0;wire[4777:0]sp_restored2;
wire[7:0]sp_addr;wire sp_second,sp_read,sp_write;wire[31:0]sp_wdata;reg[31:0]sp_rdata=0;
generate if(BASELINE)begin:impl
assign sp_addr=0;assign sp_second=0;assign sp_read=0;assign sp_write=0;assign sp_wdata=0;
${inst.replace('savestates dut(','savestates_reference dut(')}
end else begin:impl
${inst.replace('savestates dut(','savestates dut('+ports)}
end endgenerate
always@(posedge clk)begin
 if(sp_read)sp_rdata<=sp_second?sp_live2[32*sp_addr+:32]:sp_live1[32*sp_addr+:32];
 if(sp_write)begin
  if(!ss_freeze)$fatal(1,"private write outside hold");
  if(sp_second)sp_live2[32*sp_addr+:32]<=sp_wdata;else sp_live1[32*sp_addr+:32]<=sp_wdata;
 end
 if(BASELINE&&vdp_regs_set)sp_live1<={22'd0,sprite_restored};
 if(BASELINE&&vdp2_regs_set)sp_live2<={22'd0,sp_restored2};
end
integer host=0,start_host=0,last_frozen=0;
always@(posedge clk)host++;
always@(posedge ss_freeze)start_host=host;
always@(negedge ss_freeze)last_frozen=host-start_host;
`;
s=s.slice(0,a)+decl+s.slice(b);
s=s.replace('module vdp_tb;','module protocol_tb;parameter BASELINE=0;');
s=s.replaceAll('dut.','impl.dut.');
s=s.replace('assign vblank=1;','assign restart_out=0;\nassign vblank=1;');
s=s.replace('loading&&(fm_write','loading&&(sp_write||fm_write');
// Complete inherited v17 rejection/compatibility suite, candidate only.
fs.writeFileSync(p.join(dst,'format_tb.sv'),s);
let prefix=s.slice(0,s.indexOf('initial begin'));
prefix=prefix.replace('pending<=3;readaddr<=DDRAM_ADDR;','pending<=3+(stall_profile==0?0:transport_rng[7:4]);readaddr<=DDRAM_ADDR;');
const test=`reg[31:0]rng=32'h91c05a37,transport_rng=32'h134a79ce;integer stall_profile=0;
reg active_profiles=0;reg[4777:0]expected1,expected2;reg[63:0]immutable[0:12287];
function[31:0]next32;begin rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);next32=rng;end endfunction
always@(negedge clk)if(active_profiles)begin
 transport_rng={transport_rng[30:0],transport_rng[31]^transport_rng[21]^transport_rng[1]^transport_rng[0]};
 DDRAM_BUSY<=(DDRAM_RD||DDRAM_WE)&&(stall_profile==0?0:stall_profile==1?(transport_rng[2:0]==0):(transport_rng[2:0]!=0));
end
initial begin
 for(integer i=0;i<12288;i++)mem[i]=0;
 repeat(4)tick;reset_n=1;active_profiles=1;
 for(integer profile=0;profile<16;profile++)begin
  systeme=(profile>>2)&1;logical_pause=(profile>>3)&1;stall_profile=profile%3;
  case(profile%4)0:clkd=0;1:clkd=10;2:clkd=20;3:clkd=25;endcase
  for(integer b=0;b<4778;b++)begin sp_live1[b]=next32()&1;sp_live2[b]=next32()&1;end
  sp_live1[4799:4778]=0;sp_live2[4799:4778]=0;
  expected1=sp_live1[4777:0];expected2=systeme?sp_live2[4777:0]:4778'd0;
  transfer(1);
  $display("LATENCY baseline%0d profile%0d SAVE frozen%0d",BASELINE,profile,last_frozen);
  for(integer w=0;w<75;w++)begin
   if(mem['h2901+w]!==({22'd0,expected1}>>(64*w)) [63:0])begin end
  end
  for(integer w=0;w<12288;w++)begin if($isunknown(mem[w]))$fatal(1,"unknown full image word%h value%h",w,mem[w]);immutable[w]=mem[w];end
  $writememh($sformatf("image_%0d.hex",profile),mem);
  for(integer replaynum=0;replaynum<3;replaynum++)begin
   for(integer b=0;b<4778;b++)begin sp_live1[b]=next32()&1;sp_live2[b]=next32()&1;end
   transfer(0);
   if(sp_live1[4777:0]!==expected1||(systeme&&sp_live2[4777:0]!==expected2))$fatal(1,"coherent full sprite LOAD profile%0d replay%0d",profile,replaynum);
   for(integer w=0;w<12288;w++)if(mem[w]!==immutable[w])$fatal(1,"image changed");
   $display("LATENCY baseline%0d profile%0d LOAD%0d frozen%0d",BASELINE,profile,replaynum,last_frozen);
  end
  $display("PASS PROTOCOL profile%0d owner%b phase%0d stalls%0d",profile,systeme,profile%4,stall_profile);
 end
 $display("PASS PROTOCOL ALL profiles16 loads48 full_images16");$finish;
end
initial begin #1000000000;$fatal(1,"protocol watchdog");end
endmodule
`;
// Use explicit padded vectors for portable SV slicing.
let out=prefix+test;
const early="reg[31:0]rng=32'h91c05a37,transport_rng=32'h134a79ce;integer stall_profile=0;";
out=out.replace(early,'').replace('reg[4777:0]expected1,expected2;','');
out=out.replace('parameter BASELINE=0;','parameter BASELINE=0;\n'+early+'\nreg[4777:0]expected1,expected2;');
out=out.replace('reg active_profiles=0;',"wire[4799:0]packed1={22'd0,expected1},packed2={22'd0,expected2};reg active_profiles=0;");
out=out.replace("if(mem['h2901+w]!==({22'd0,expected1}>>(64*w)) [63:0])begin end",`if(mem['h2901+w]!==packed1[64*w+:64]||mem['h294c+w]!==packed2[64*w+:64])$fatal(1,"v17 sprite image word%0d",w);`);
fs.writeFileSync(p.join(dst,'protocol_tb.sv'),out);
fs.writeFileSync(p.join(dst,'compile.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib protocol_work\nvlog -work protocol_work -sv -quiet ../../../rtl/opll_snapshot.sv ../candidate_A/rtl/sprite_snapshot.sv golden.sv candidate.sv protocol_tb.sv\nquit -code 0\n`);
for(const mode of [0,1]){const dir=p.join(dst,mode?'golden':'candidate');fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -t 1ps protocol_work.protocol_tb -gBASELINE=${mode} -g/protocol_tb/impl/dut/TB_FAST=1\nrun -all\nquit -code 0\n`);}
console.log('Prepared coherent current-v17/candidate protocol miter and inherited format suite.');
