const fs=require('fs'),p=require('path');const d=__dirname;
const source=fs.readFileSync(p.join(d,'baseline/rtl/savestates.sv'),'utf8');
let sim=source;
for(const name of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+name+';\\r?\\n','m');const decl=sim.match(re)[0];sim=sim.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
// ModelSim declaration-order adapter only. Both controllers otherwise retain exact baseline logic.
for(const v of ['baseline','candidate'])fs.writeFileSync(p.join(d,'controller_'+v+'.sv'),sim.replace('module savestates (','module savestates_'+v+' ('));
const ports=[...source.split(');')[0].replace(/\/\/[^\n]*/g,'').matchAll(/\b(input|output)\s+(?:reg\s+)?(\[[^\]]+\]\s*)?(\w+)\s*(?:,|$)/gm)];
const inputs=ports.filter(x=>x[1]==='input'),outputs=ports.filter(x=>x[1]==='output');
const declarations=inputs.map(([,kind,w,n])=>`reg ${w||''}${n}='0;`).concat(outputs.map(([,kind,w,n])=>`wire ${w||''}${n}_a,${n}_b; wire ${w||''}${n}=${n}_a;`)).join('\n');
fs.writeFileSync(p.join(d,'savestate_tb.sv'),`\`timescale 1ns/1ps
module savestate_tb;
${declarations}
${['baseline','candidate'].map((v,i)=>`savestates_${v} ${i?'b':'a'}(${ports.map(x=>'.'+x[3]+'('+x[3]+(x[1]==='output'?(i?'_b':'_a'):'')+')').join(',')});`).join('\n')}
wire [13:0] fm_a,fm_b; wire fm_ce=cpu_ce&&!ss_freeze;
opll_baseline fm1(clk,fm_ce,reset_n,fm_a);opll_candidate fm2(clk,fm_ce,reset_n,fm_b);
always #5 clk=~clk;
reg [63:0] memory[0:98303];integer cycles=0,pending=0;reg [28:0] ra;
integer writes=0,reads=0,loads=0,operations=0,busy_cycles=0,audio_checks=0;reg stalls=0;
reg [229:0] saved_cpu;reg [127:0] saved_vdp;reg [55:0] saved_psg;
always @(negedge clk)begin
 cycles=cycles+1;cpu_ce=cycles%15==0;vdp_ce=cycles%10==0;pix_ce=cycles%10==0;sp_ce=cycles%5==0;
 if(cycles%500000==0)$display("PROGRESS cycles=%0d state=%0d freeze=%b ops=%0d reads=%0d writes=%0d pending=%0d",cycles,a.state,ss_freeze,operations,reads,writes,pending);
 DDRAM_BUSY=stalls&&(cycles%97<5);if(DDRAM_BUSY)busy_cycles=busy_cycles+1;
 #1;
 ${outputs.map(x=>`if(${x[3]}_a!==${x[3]}_b)$fatal(1,"controller output mismatch ${x[3]} cycle%0d",cycles);`).join('\n ')}
 if(fm_a!==fm_b)$fatal(1,"FM difference over real savestate freeze at cycle%0d",cycles);audio_checks=audio_checks+1;
end
always @(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=memory[ra-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  for(integer byteindex=0;byteindex<8;byteindex=byteindex+1)if(DDRAM_BE[byteindex])memory[DDRAM_ADDR-29'h07c00000][byteindex*8+:8]<=DDRAM_DIN[byteindex*8+:8];writes<=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlapping DDR read");pending<=3;ra<=DDRAM_ADDR;reads<=reads+1;end
 if(z80_set)begin if(z80_dir!==saved_cpu)$fatal(1,"CPU roundtrip");loads<=loads+1;end
 if(vdp_regs_set&&vdp_regs_in!==saved_vdp)$fatal(1,"VDP roundtrip");
 if(psg_set&&psg_in!==saved_psg)$fatal(1,"PSG roundtrip");
end
task tick;begin @(negedge clk);#2;end endtask
task operation(input bit saving);begin
 force a.op_cooldown=0;force b.op_cooldown=0;
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(12)tick;
 release a.op_cooldown;release b.op_cooldown;operations=operations+1;$display("Completed operation%0d saving%b cycles%0d",operations,saving,cycles);
end endtask
initial begin
 reset_n=0;repeat(6)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;
 for(integer testcase=0;testcase<8;testcase=testcase+1)begin
  systeme=testcase%2;ss_bios_mode=(testcase/2)%2;ss_slot=testcase%4;stalls=testcase>=4;
  mapper_out=systeme?64'h60:64'h1000000000000;
  saved_cpu={102'h1923,128'h0123456789abcdef0011223344556677}^testcase;
  saved_vdp=128'hfedcba98765432100123456789abcdef^testcase;saved_psg=56'h0123456789abcd^testcase;
  z80_reg=saved_cpu;vdp_regs=saved_vdp;psg_out=saved_psg;vdp2_regs=~saved_vdp;psg2_out=~saved_psg;
  cram_out={384{1'b1}};cram2_out={384{1'b0}};video_state_out=22'h12345;
  operation(1);z80_reg=~saved_cpu;vdp_regs=~saved_vdp;psg_out=~saved_psg;operation(0);
  if(loads!=testcase+1)$fatal(1,"load was rejected testcase%0d loads%0d",testcase,loads);
 end
 if(loads!=8||operations!=16||busy_cycles==0||writes<1000||reads<1000)$fatal(1,"coverage incomplete");
 $display("PASS savestate/FM paired regression cycles=%0d audio_checks=%0d outputs=${outputs.length} operations=%0d restored=%0d DDRwrites=%0d DDRreads=%0d busy=%0d SMS/SystemE BIOS/cart slots0..3",cycles,audio_checks,operations,loads,writes,reads,busy_cycles);
 $finish;
end
initial begin #200000000;$fatal(1,"savestate timeout state=%0d freeze=%b operations=%0d pending=%0d",a.state,ss_freeze,operations,pending);end
endmodule
`);
fs.writeFileSync(p.join(d,'opll_wrappers.vhd'),`library ieee;use ieee.std_logic_1164.all;library baseline_work;
entity opll_baseline is port(clk,ce,rst:in std_logic;audio:out std_logic_vector(13 downto 0));end;
architecture test of opll_baseline is begin u:entity baseline_work.opll port map(clk,open,ce,x"00",'0','0','0',rst,audio);end;
library ieee;use ieee.std_logic_1164.all;library candidate_work;
entity opll_candidate is port(clk,ce,rst:in std_logic;audio:out std_logic_vector(13 downto 0));end;
architecture test of opll_candidate is begin u:entity candidate_work.opll port map(clk,open,ce,x"00",'0','0','0',rst,audio);end;
`);
console.log(JSON.stringify({inputs:inputs.length,comparedOutputs:outputs.length,adapters:'move two forward declarations, rename module only'}));
