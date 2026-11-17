const fs=require('fs'),p=require('path');const d=__dirname;
const wrappers=[];
for(const [name,lib] of [['opll_baseline_programmed','baseline_work'],['opll_mapped_programmed','mapped_work']])wrappers.push(`library ieee;use ieee.std_logic_1164.all;library ${lib};
entity ${name} is port(clk,ce,rst:in std_logic;audio:out std_logic_vector(13 downto 0));end;
architecture test of ${name} is
signal count:integer range 0 to 48:=0;
signal data:std_logic_vector(7 downto 0);signal addr:std_logic;
begin
process(clk,rst)begin if rst='0' then count<=0;elsif rising_edge(clk) then if ce='1' and count<48 then count<=count+1;end if;end if;end process;
process(count)begin
 if count<4 then addr<='0';data<=x"30";
 elsif count<12 then addr<='1';data<=x"10";
 elsif count<16 then addr<='0';data<=x"10";
 elsif count<24 then addr<='1';data<=x"80";
 elsif count<28 then addr<='0';data<=x"20";
 else addr<='1';data<=x"19";end if;
end process;
u:entity ${lib}.opll port map(clk,open,ce,data,addr,'0','0',rst,audio);end;
`);
fs.writeFileSync(p.join(d,'opll_gate_wrappers.vhd'),wrappers.join('\n'));
let tb=fs.readFileSync(p.join(d,'savestate_tb.sv'),'utf8').replaceAll('savestate_tb','savestate_gate_tb');
tb=tb.replace('opll_baseline fm1','opll_baseline_programmed fm1').replace('opll_candidate fm2','opll_mapped_programmed fm2');
// The separate eight-case RTL bench compares both serializers. Keep one exact controller here
// to stay below ModelSim Starter capacity while comparing native and mapped OPLL under real freeze.
tb=tb.replace(/^savestates_candidate b\([^\n]+\);\r?\n/m,'');
tb=tb.replace(/^\s*if\(\w+_a!==\w+_b\)\$fatal\([^\n]+\);\r?\n/gm,'');
tb=tb.replace('force b.op_cooldown=0;','').replace('release b.op_cooldown;','');
tb=tb.replace('outputs=58','paired_controllers=0');
// Stream a native reference in one pass, compare the mapped OPLL in the second pass.
// This removes the second full OPLL from elaboration and avoids Starter's 10k-statement slowdown.
tb=tb.replace('module savestate_gate_tb;','module savestate_gate_tb;parameter REF=0;integer oracle,scan;reg[13:0]reference_sample;');
tb=tb.replace('opll_baseline_programmed fm1(clk,fm_ce,reset_n,fm_a);','assign fm_a=reference_sample;');
tb=tb.replace('opll_mapped_programmed fm2(clk,fm_ce,reset_n,fm_b);','generate if(REF)begin opll_baseline_programmed fm2(clk,fm_ce,reset_n,fm_b);end else begin opll_mapped_programmed fm2(clk,fm_ce,reset_n,fm_b);end endgenerate');
tb=tb.replace('if(fm_a!==fm_b)',`if(REF)begin $fdisplay(oracle,"%h",fm_b);reference_sample=fm_b;end else begin scan=$fscanf(oracle,"%h\\n",reference_sample);if(scan!=1)$fatal(1,"oracle ended");end\n if(fm_a!==fm_b)`);
tb=tb.replace('if(fm_a!==fm_b)','if(reference_sample!==fm_b)');
tb=tb.replace('reset_n=0;repeat(6)tick;',`oracle=$fopen("savestate_oracle.trace",REF?"w":"r");if(!oracle)$fatal(1,"oracle open failed");\n reset_n=0;repeat(6)tick;`);
tb=tb.replace('$display("Nonzero audio checks=%0d",nonzero_audio);$finish;','$display("Nonzero audio checks=%0d REF=%0d",nonzero_audio,REF);$fclose(oracle);$finish;');
// Two mapped-system representatives complement all eight RTL serializer cases and full mapped FM sweep.
tb=tb.replace('testcase=testcase+1','testcase=testcase+7').replace('loads!=8||operations!=16','loads!=2||operations!=4');
tb=tb.replace('loads!=testcase+1','loads!=(testcase==0?1:2)');
tb=tb.replace('audio_checks=0;','audio_checks=0,nonzero_audio=0;');
tb=tb.replace('audio_checks=audio_checks+1;','audio_checks=audio_checks+1;if((^fm_a)!==1\'bx&&fm_a!=0)nonzero_audio=nonzero_audio+1;');
tb=tb.replace("if((^fm_a)!==1'bx&&fm_a!=0)","if((^fm_b)!==1'bx&&fm_b!=0)");
tb=tb.replace('if(loads!=2||operations!=4','if(nonzero_audio==0)$fatal(1,"vacuous FM output");\n if(loads!=2||operations!=4');
tb=tb.replace('for(integer testcase=0;','repeat(100000)tick; // Program and sound before the first freeze.\n for(integer testcase=0;');
tb=tb.replace('PASS savestate/FM paired regression','PASS savestate/FM mapped RegisterMemory regression');
tb=tb.replace('$finish;','$display("Nonzero audio checks=%0d REF=%0d",nonzero_audio,REF);$fclose(oracle);$finish;');
fs.writeFileSync(p.join(d,'savestate_gate_tb.sv'),tb);
