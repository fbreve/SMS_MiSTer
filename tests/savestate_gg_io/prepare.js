const fs=require('fs'),path=require('path');const dir=__dirname,root=path.resolve(dir,'../..');
const fields=[['gg_ddr',8,'FF'],['gg_txd',8,'00'],['gg_rxd',8,'FF'],['gg_pdr',8,'7F'],['gg_sctrl',5,'0'],['gg_tx_line',1,'1'],['gg_tx_busy',1,'0'],['gg_tx_shift',9,'1FF'],['gg_tx_cnt',14,'0'],['gg_tx_bits',4,'0'],['gg_tx_pending',1,'0'],['gg_tx_pending_data',8,'0'],['gg_rx_sync',3,'7'],['gg_pc6_sync',3,'7'],['gg_pc6_prev',1,'1'],['gg_rx_state',2,'0'],['gg_rx_cnt',14,'0'],['gg_rx_bits',3,'0'],['gg_rx_shift',8,'FF'],['gg_rx_ready',1,'0'],['gg_rx_frame_err',1,'0'],['gg_nmi_serial',1,'0'],['gg_nmi_pc6',1,'0'],['gg_tx_wr_d',1,'0']];
let bits=0,reset=0n;const inventory=fields.map(([name,width,hex])=>{const lo=bits;bits+=width;reset|=BigInt('0x'+hex)<<BigInt(lo);return {name,width,lo,hi:bits-1,reset:hex,classification:'A',purpose:name.includes('sync')||name.includes('prev')||name.includes('wr_d')?'Input/edge history; locally retained, not the external wire':'Local register/protocol state'};});
fs.writeFileSync(path.join(dir,'inventory.json'),JSON.stringify({bits,reset128:reset.toString(16).padStart(32,'0'),fields:inventory,derived:['gg_status','gg_baud_div','gg_baud_half','gg_pc_drive_en','gg_pc_drive_val','gg_pc_read','gg_pc_in_mux','gg_link_out','gg_link_nmi_n','D_out'],external:['gg_link_in','host pause/region/pal','gg_link_en configuration'],dead:['gg_tx_shift(0): discarded without being read; restore zero. Payload contains bits9:1 only.']},null,2));
const sourceRoot=process.argv.includes('--baseline')?path.join(dir,'baseline'):root;
const src=fs.readFileSync(path.join(sourceRoot,'rtl/io.vhd'),'utf8');
const width=Number(src.match(/io_state_out\s*:\s*out\s+STD_LOGIC_VECTOR\((\d+) downto/i)[1])+1;
const hasgg=src.includes('gg_state_out');
const ports=[...src.split('architecture')[0].matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)];
function io(n){const o={clk:'clk',reset_n:'rst'+n,ce_cpu:'ce'+n,wr_n:'wr'+n,rd_n:'rd',a:'addr',d_in:'din',d_out:'data'+n,gg:"'1'",gg_link_en:"'1'",gg_link_in:'link',gg_link_out:'pins'+n,gg_link_nmi_n:'nmi'+n,gg_state_out:'ggstate'+n,gg_state_in:'ggsaved',gg_state_set:n===1?'load':"'0'",io_state_out:'state'+n,io_state_in:'saved',io_state_set:n===1?'load':"'0'",ss_freeze:'freeze'+n};return `entity work.io port map(`+ports.map(m=>`${m[1]} => ${o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'open':m[3].toLowerCase().includes('vector')?"(others=>'0')":"'0'")}`).join(',\n')+');';}
fs.writeFileSync(path.join(dir,'gg_tb.vhd'),`library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
entity gg_tb is generic(expect_fixed:boolean:=false);end;architecture test of gg_tb is
signal clk:std_logic:='0';signal rst1,rst2,ce1,ce2,load,freeze1,freeze2:std_logic:='0';
signal wr1,wr2,rd:std_logic:='1';signal addr,din,data1,data2:std_logic_vector(7 downto 0):=(others=>'0');
signal link,pins1,pins2:std_logic_vector(6 downto 0):=(others=>'1');signal nmi1,nmi2:std_logic;
signal state1,state2,saved:std_logic_vector(${width-1} downto 0);
signal ggstate1,ggstate2,ggsaved:std_logic_vector(127 downto 0);
begin clk<=not clk after 5 ns;dut:${io(1)} reference:${io(2)}
process
variable mismatches,total,divisor,age,which,position:integer:=0;
procedure tick is begin wait until rising_edge(clk);wait for 1 ns;end;
procedure put(a,d:integer;both:boolean:=true) is begin ce1<='0';ce2<='0';addr<=std_logic_vector(to_unsigned(a,8));din<=std_logic_vector(to_unsigned(d,8));wr1<='0';if both then wr2<='0';end if;tick;wr1<='1';wr2<='1';tick;end;
procedure compare is begin
if pins1/=pins2 or nmi1/=nmi2 ${hasgg?'or ggstate1/=ggstate2 or state1/=state2':''} then mismatches:=mismatches+1;end if;
end;
procedure get(a:integer) is begin ce1<='0';ce2<='0';addr<=std_logic_vector(to_unsigned(a,8));rd<='0';tick;tick;if data1/=data2 then mismatches:=mismatches+1;report "port "&integer'image(a)&" DUT="&integer'image(to_integer(unsigned(data1)))&" reference="&integer'image(to_integer(unsigned(data2)));end if;rd<='1';tick;end;
procedure external_at(t,d:integer;bad:boolean) is variable b:integer;variable sample:std_logic;begin
b:=t/(d+1);sample:='1';if b=0 then sample:='0';elsif b<=8 then if ((16#5A#/(2**(b-1))) mod 2)=0 then sample:='0';end if;elsif b=9 and bad then sample:='0';end if;
link<=(others=>'1');link(5)<=sample;if t>=7 then link(6)<='0';end if;
end;
begin
for baud in 0 to 3 loop
case baud is when 0=>divisor:=745;when 1=>divisor:=1491;when 2=>divisor:=2982;when others=>divisor:=11931;end case;
for phase in 0 to 5 loop
mismatches:=0;rst1<='0';rst2<='0';freeze1<='0';freeze2<='0';link<=(others=>'1');rd<='1';tick;rst1<='1';rst2<='1';tick;
put(2,0);put(1,16#35#);put(2,16#40#);put(5,baud*64+16#38#);put(3,16#A6#);put(3,16#93#);
case phase is when 0=>age:=0;when 1=>age:=divisor/2;when 2=>age:=3*(divisor+1)+1;when 3=>age:=7*(divisor+1)+13;when 4=>age:=11*(divisor+1)+4;when others=>age:=23*(divisor+1)+4;end case;
for t in 0 to age loop external_at(t,divisor,(phase mod 2)=1);ce1<='1';ce2<='1';tick;end loop;
ce1<='0';ce2<='0';freeze1<='1';freeze2<='1';tick;saved<=state1;ggsaved<=ggstate1;tick;
-- Perturb only the DUT using reset and normal writes; never force protocol state.
rst1<='0';tick;rst1<='1';freeze1<='0';tick;put(2,0,false);put(1,16#6A#,false);put(2,16#FF#,false);put(3,16#55#,false);
freeze1<='1';load<='1';tick;load<='0';tick;
${hasgg?`-- Even with a held guest RX read, freeze must preserve restored status.
addr<=x"04";rd<='0';for t in 0 to 3 loop tick;compare;end loop;rd<='1';tick;`:''}
freeze1<='0';freeze2<='0';tick;compare;
get(1);get(2);get(3);get(5);get(4); -- status before RX-data read/clear
for t in age+1 to age+24*(divisor+1) loop external_at(t,divisor,(phase mod 2)=1);ce1<='1';ce2<='1';tick;compare;end loop;
ce1<='0';ce2<='0';get(5);get(4);
if expect_fixed then assert mismatches=0 report "replay divergence baud="&integer'image(baud)&" phase="&integer'image(phase)&" mismatches="&integer'image(mismatches) severity failure;
else assert mismatches>0 report "expected omission not reached" severity failure;end if;
report "CASE baud="&integer'image(baud)&" phase="&integer'image(phase)&" differences="&integer'image(mismatches);total:=total+mismatches;
${hasgg?`-- Save the evolved point and load again without resetting the reference.
ce1<='0';ce2<='0';freeze1<='1';freeze2<='1';tick;saved<=state1;ggsaved<=ggstate1;tick;
freeze1<='0';put(1,16#6A#,false);freeze1<='1';load<='1';tick;load<='0';tick;compare;
assert mismatches=0 report "repeated save/load mismatch" severity failure;
freeze1<='0';freeze2<='0';tick;`:''}
-- A reset and a new transaction after restore must remain equivalent.
rst1<='0';rst2<='0';tick;rst1<='1';rst2<='1';tick;put(5,16#10#);put(3,16#81#);ce1<='1';ce2<='1';for t in 0 to 18000 loop tick;compare;end loop;
if expect_fixed then assert mismatches=0 report "reset/new transaction mismatch" severity failure;end if;
end loop;end loop;
if expect_fixed then report "PASS F02 local replay: 24 baud/phase/error/status/NMI scenarios";else report "REPRODUCED F02 omissions: 24 scenarios total differences="&integer'image(total);end if;
std.env.stop;wait;end process;end;
`);
const rtl=path.relative(dir,path.join(sourceRoot,'rtl')).replaceAll('\\','/');
fs.writeFileSync(path.join(dir,'gg.do'),`onerror {quit -code 1}
onbreak {resume}
vlib work
vcom -2008 -quiet ${rtl}/io.vhd gg_tb.vhd
vsim -c -t 1ps work.gg_tb -gexpect_fixed=$env(GG_FIXED)
run -all
quit -code 0
`);
console.log('GG inventory bits='+bits+' reset='+reset.toString(16)+' IO width='+width);
