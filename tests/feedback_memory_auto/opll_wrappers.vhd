library ieee;use ieee.std_logic_1164.all;library baseline_work;
entity opll_baseline is port(clk,ce,rst:in std_logic;audio:out std_logic_vector(13 downto 0));end;
architecture test of opll_baseline is begin u:entity baseline_work.opll port map(clk,open,ce,x"00",'0','0','0',rst,audio);end;
library ieee;use ieee.std_logic_1164.all;library candidate_work;
entity opll_candidate is port(clk,ce,rst:in std_logic;audio:out std_logic_vector(13 downto 0));end;
architecture test of opll_candidate is begin u:entity candidate_work.opll port map(clk,open,ce,x"00",'0','0','0',rst,audio);end;
