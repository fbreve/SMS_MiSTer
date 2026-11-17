library ieee;use ieee.std_logic_1164.all;library baseline_work;
entity opll_baseline_programmed is port(clk,ce,rst:in std_logic;audio:out std_logic_vector(13 downto 0));end;
architecture test of opll_baseline_programmed is
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
u:entity baseline_work.opll port map(clk,open,ce,data,addr,'0','0',rst,audio);end;

library ieee;use ieee.std_logic_1164.all;library mapped_work;
entity opll_mapped_programmed is port(clk,ce,rst:in std_logic;audio:out std_logic_vector(13 downto 0));end;
architecture test of opll_mapped_programmed is
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
u:entity mapped_work.opll port map(clk,open,ce,data,addr,'0','0',rst,audio);end;
