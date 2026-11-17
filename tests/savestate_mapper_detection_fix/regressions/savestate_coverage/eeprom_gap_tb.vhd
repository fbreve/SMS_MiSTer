library ieee; use ieee.std_logic_1164.all;
entity eeprom_gap_tb is end; architecture test of eeprom_gap_tb is
signal clk: std_logic := '0'; signal rst,serial,din,load: std_logic := '0';
signal ext,saved_ext: std_logic_vector(127 downto 0);
signal snap,ref_snap,saved: std_logic_vector(63 downto 0);
begin clk<=not clk after 5 ns;
dut: entity work.eeprom_93c46 port map(clk_sys => clk,
ce_cpu => '0',
reset_n => rst,
cs_in => '1',
clk_in => serial,
di => din,
do => open,
soft_reset => '0',
nvram_a => open,
nvram_di => open,
nvram_do => x"FF",
nvram_we => open,
ss_ext_out => ext,
ss_ext_in => saved_ext,
ss_full => '1',
ss_freeze => '0',
ss_out => snap,
ss_in => saved,
ss_set => load);
reference: entity work.eeprom_93c46 port map(clk_sys => clk,
ce_cpu => '0',
reset_n => rst,
cs_in => '1',
clk_in => serial,
di => din,
do => open,
soft_reset => '0',
nvram_a => open,
nvram_di => open,
nvram_do => x"FF",
nvram_we => open,
ss_ext_out => open,
ss_ext_in => (others=>'0'),
ss_full => '0',
ss_freeze => '0',
ss_out => ref_snap,
ss_in => (others=>'0'),
ss_set => '0');
process
procedure tick is begin wait until rising_edge(clk); wait for 1 ns; end;
procedure bit_in(b: std_logic) is begin serial<='0'; din<=b; tick; tick; serial<='1'; tick; tick; serial<='0'; tick; end;
begin tick; rst<='1'; tick;
bit_in('1'); -- start
bit_in('0'); bit_in('0'); bit_in('1'); bit_in('1'); -- first half of EWEN
saved<=snap; saved_ext<=ext; tick; load<='1'; tick; load<='0'; tick;
bit_in('0'); bit_in('0'); bit_in('0'); bit_in('0'); -- finish opcode 00110000
assert ref_snap(1)='1' and snap(1)='1' report "F03 full protocol restore failed" severity failure;
report "F03 restored partial EWEN: reference and DUT EWEN=1";
report "PASS eeprom_gap_tb (F03 fixed)"; std.env.stop; wait;
end process; end;
