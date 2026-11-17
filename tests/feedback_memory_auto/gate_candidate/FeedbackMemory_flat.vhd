library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;use work.vm2413.all;
entity FeedbackMemory_flat is port(clk,reset,wr:in std_logic;waddr:in std_logic_vector(3 downto 0);wdata:in std_logic_vector(9 downto 0);raddr:in std_logic_vector(3 downto 0);rdata:out std_logic_vector(9 downto 0));end;
architecture adapter of FeedbackMemory_flat is signal rd,wd:SIGNED_LI_TYPE;signal wi,ri:CH_TYPE;begin
wi<=to_integer(unsigned(waddr));ri<=to_integer(unsigned(raddr));wd<=CONV_SIGNED_LI(wdata);
u:entity work.FeedbackMemory port map(clk,reset,wr,wi,wd,ri,rd);
rdata<=CONV_SIGNED_LI_VECTOR(rd);end;
