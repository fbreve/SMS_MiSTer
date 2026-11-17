library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity dpram is
 generic(init_file:string:="UNUSED";widthad_a:natural;width_a:natural:=8;mixed_port_rdwr:string:="DONT_CARE";outdata_reg_a:string:="UNREGISTERED";outdata_reg_b:string:="UNREGISTERED");
 port(address_a,address_b:in std_logic_vector(widthad_a-1 downto 0);clock_a,clock_b:in std_logic;data_a,data_b:in std_logic_vector(width_a-1 downto 0);wren_a,wren_b:in std_logic:='1';q_a,q_b:out std_logic_vector(width_a-1 downto 0));
end;
architecture simulation of dpram is
 type memory_type is array(0 to 2**widthad_a-1)of std_logic_vector(width_a-1 downto 0);
 signal memory:memory_type:=(others=>(others=>'0'));
begin
 assert outdata_reg_a="UNREGISTERED" and outdata_reg_b="UNREGISTERED" report "unsupported registered RAM output" severity failure;
 process(clock_a,clock_b)
 variable aa,bb:integer;
 begin
  if rising_edge(clock_a)then
   aa:=to_integer(unsigned(address_a));q_a<=memory(aa);
   if wren_a='1'then memory(aa)<=data_a;q_a<=data_a;end if;
  end if;
  if rising_edge(clock_b)then
   bb:=to_integer(unsigned(address_b));q_b<=memory(bb);
   if wren_b='1'then memory(bb)<=data_b;q_b<=data_b;end if;
  end if;
 end process;
end;
