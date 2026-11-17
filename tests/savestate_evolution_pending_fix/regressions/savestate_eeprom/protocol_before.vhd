library ieee; use ieee.std_logic_1164.all;
entity protocol_before is end;
architecture test of protocol_before is
 signal clk:std_logic:='0';signal rst,sk,di,load:std_logic:='0';
 signal dut,ref,saved:std_logic_vector(63 downto 0);
begin
 clk<=not clk after 5 ns;
 d:entity work.eeprom_93c46 port map(clk_sys=>clk,ce_cpu=>'0',reset_n=>rst,cs_in=>'1',clk_in=>sk,di=>di,do=>open,nvram_a=>open,nvram_di=>open,nvram_do=>x"ff",nvram_we=>open,ss_out=>dut,ss_in=>saved,ss_set=>load);
 r:entity work.eeprom_93c46 port map(clk_sys=>clk,ce_cpu=>'0',reset_n=>rst,cs_in=>'1',clk_in=>sk,di=>di,do=>open,nvram_a=>open,nvram_di=>open,nvram_do=>x"ff",nvram_we=>open,ss_out=>ref);
 process
 procedure tick is begin wait until rising_edge(clk);wait for 1 ns;end;
 procedure bitin(b:std_logic) is begin sk<='0';di<=b;tick;tick;sk<='1';tick;tick;sk<='0';tick;end;
 begin
 tick;rst<='1';tick;bitin('1');bitin('0');bitin('0');bitin('1');bitin('1');
 saved<=dut;tick;load<='1';tick;load<='0';tick;
 bitin('0');bitin('0');bitin('0');bitin('0');
 assert ref(1)='1' and dut(1)='0' report "Expected pre-fix F03 divergence missing" severity failure;
 report "CONFIRMED F03: partial EWEN continues only on reference";
 report "PASS protocol_before";std.env.stop;wait;
 end process;
end;
