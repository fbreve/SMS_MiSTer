library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
entity mcode_bound is end;
architecture test of mcode_bound is
signal ir_in,flags_in:std_logic_vector(7 downto 0):=(others=>'0');
signal iset_in,xy_in:std_logic_vector(1 downto 0):=(others=>'0');
signal nmi_in,int_in:std_logic:='0';signal states:std_logic_vector(2 downto 0);
begin
dut:entity work.T80_MCode generic map(Mode=>0)port map(IR => ir_in,ISet => iset_in,MCycle => "001",F => flags_in,NMICycle => nmi_in,IntCycle => int_in,XY_State => xy_in,MCycles => open,TStates => states,Prefix => open,Inc_PC => open,Inc_WZ => open,IncDec_16 => open,Read_To_Reg => open,Read_To_Acc => open,Set_BusA_To => open,Set_BusB_To => open,ALU_Op => open,Save_ALU => open,PreserveC => open,Arith16 => open,Set_Addr_To => open,IORQ => open,Jump => open,JumpE => open,JumpXY => open,Call => open,RstP => open,LDZ => open,LDW => open,LDSPHL => open,Special_LD => open,ExchangeDH => open,ExchangeRp => open,ExchangeAF => open,ExchangeRS => open,I_DJNZ => open,I_CPL => open,I_CCF => open,I_SCF => open,I_RETN => open,I_BT => open,I_BC => open,I_BTR => open,I_RLD => open,I_RRD => open,I_INRC => open,SetWZ => open,SetDI => open,SetEI => open,IMode => open,Halt => open,NoRead => open,Write => open,XYbit_undoc => open);
process variable count:integer:=0;variable minimum:integer:=7;begin
for iset_n in 0 to 2 loop for xy_n in 0 to 2 loop for nmi_n in 0 to 1 loop for int_n in 0 to 1 loop for flags_n in 0 to 255 loop for ir_n in 0 to 255 loop
iset_in<=std_logic_vector(to_unsigned(iset_n,2));xy_in<=std_logic_vector(to_unsigned(xy_n,2));ir_in<=std_logic_vector(to_unsigned(ir_n,8));flags_in<=std_logic_vector(to_unsigned(flags_n,8));
if nmi_n=0 then nmi_in<='0';else nmi_in<='1';end if;if int_n=0 then int_in<='0';else int_in<='1';end if;
wait for 1 ns;
assert unsigned(states)>=4 report "MC1 can end before T4" severity failure;
if to_integer(unsigned(states))<minimum then minimum:=to_integer(unsigned(states));end if;
count:=count+1;
end loop;end loop;end loop;end loop;end loop;end loop;
report "PASS MCODE_BOUND combinations"&integer'image(count)&" minimum"&integer'image(minimum);
std.env.stop;wait;end process;end;
