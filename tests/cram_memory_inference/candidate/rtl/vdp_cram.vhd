library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity vdp_cram is
 port(cpu_clk:in std_logic;cpu_WE:in std_logic;
 cpu_A:in std_logic_vector(4 downto 0);cpu_D:in std_logic_vector(11 downto 0);
 vdp_clk:in std_logic;vdp_A:in std_logic_vector(4 downto 0);vdp_D:out std_logic_vector(11 downto 0);
 ss_rd:in std_logic;ss_Q:out std_logic_vector(11 downto 0);
 ss_wr:in std_logic;ss_A:in std_logic_vector(4 downto 0);ss_wD:in std_logic_vector(11 downto 0));
end;
architecture rtl of vdp_cram is
 type t_ram is array(0 to 31)of std_logic_vector(11 downto 0);
 signal ram:t_ram:=(others=>(others=>'1'));
 attribute ramstyle:string;
 attribute ramstyle of ram:signal is "M10K";
 signal addr_a:std_logic_vector(4 downto 0);
begin
 addr_a<=ss_A when ss_rd='1' or ss_wr='1' else cpu_A;
 process(cpu_clk)begin
  if rising_edge(cpu_clk)then
   if ss_wr='1' then ram(to_integer(unsigned(addr_a)))<=ss_wD;
   elsif cpu_WE='1' then ram(to_integer(unsigned(addr_a)))<=cpu_D;
   else ss_Q<=ram(to_integer(unsigned(addr_a)));end if;
  end if;
 end process;
 process(vdp_clk)begin
  if rising_edge(vdp_clk)then vdp_D<=ram(to_integer(unsigned(vdp_A)));end if;
 end process;
end;
