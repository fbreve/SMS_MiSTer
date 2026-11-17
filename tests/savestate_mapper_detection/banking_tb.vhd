library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity tb is end;
architecture test of tb is
signal RESET_n : std_logic := '0';
signal clk_sys : std_logic := '0';
signal evolution_game_launch : std_logic := '0';
signal mapper_set : std_logic := '0';
signal mapper_evolution : std_logic := '0';
signal evolution_ss_in : std_logic_vector(95 downto 0) := (others => '0');
signal mapper_in : std_logic_vector(63 downto 0) := (others => '0');
signal mapper_janggun : std_logic := '0';
signal systeme : std_logic := '0';
signal bootloader_n : std_logic := '0';
signal mapper_wonderkid : std_logic := '0';
signal mapper_lock : std_logic := '0';
signal detect_codies_static : std_logic := '0';
signal mapper_codies_force : std_logic := '0';
signal mapper_eeprom : std_logic := '0';
signal mapper_zemina_force : std_logic := '0';
signal mapper_nemesis_auto : std_logic := '0';
signal rom_size_pages : std_logic_vector(7 downto 0) := (others => '0');
signal ce_z80 : std_logic := '0';
signal WR_n : std_logic := '0';
signal MREQ_n : std_logic := '0';
signal A : std_logic_vector(15 downto 0) := (others => '0');
signal ss_freeze : std_logic := '0';
signal D_in : std_logic_vector(7 downto 0) := (others => '0');
signal sc3000_en : std_logic := '0';
signal mapper_castle : std_logic := '0';
signal mapper_linear : std_logic := '0';
signal mapper_dahjee_a : std_logic := '0';
signal mapper_sega_locked : std_logic := '0';
signal use_zem : std_logic := '0';
signal mapper_manual_force : std_logic := '0';
signal sega_mapper_write_seen : std_logic := '0';
signal bank0_out, ref_bank0_out : std_logic_vector(7 downto 0);
signal bank1_out, ref_bank1_out : std_logic_vector(7 downto 0);
signal bank2_out, ref_bank2_out : std_logic_vector(7 downto 0);
signal bank3_out, ref_bank3_out : std_logic_vector(7 downto 0);
signal jang_bank1_out, ref_jang_bank1_out : std_logic_vector(5 downto 0);
signal jang_bank2_out, ref_jang_bank2_out : std_logic_vector(5 downto 0);
signal jang_bank3_out, ref_jang_bank3_out : std_logic_vector(5 downto 0);
signal jang_bank4_out, ref_jang_bank4_out : std_logic_vector(5 downto 0);
signal jang_rev1_out, ref_jang_rev1_out : std_logic;
signal jang_rev2_out, ref_jang_rev2_out : std_logic;
signal jang_rev3_out, ref_jang_rev3_out : std_logic;
signal jang_rev4_out, ref_jang_rev4_out : std_logic;
signal nvram_e_out, ref_nvram_e_out : std_logic;
signal nvram_ex_out, ref_nvram_ex_out : std_logic;
signal nvram_p_out, ref_nvram_p_out : std_logic;
signal nvram_cme_out, ref_nvram_cme_out : std_logic;
signal lock_mapper_B_out, ref_lock_mapper_B_out : std_logic;
signal mapper_codies_out, ref_mapper_codies_out : std_logic;
signal mapper_codies_lock_out, ref_mapper_codies_lock_out : std_logic;
signal mapper_4pak_out, ref_mapper_4pak_out : std_logic;
signal pak4_reg2_out, ref_pak4_reg2_out : std_logic_vector(7 downto 0);
signal nem_bank0_out, ref_nem_bank0_out : std_logic_vector(7 downto 0);
signal eeprom_soft_reset_out, ref_eeprom_soft_reset_out : std_logic;
begin
dut: entity work.mapper_ctrl port map (RESET_n => RESET_n, clk_sys => clk_sys, evolution_game_launch => evolution_game_launch, mapper_set => mapper_set, mapper_evolution => mapper_evolution, mapper_in => mapper_in, mapper_janggun => mapper_janggun, systeme => systeme, bootloader_n => bootloader_n, mapper_wonderkid => mapper_wonderkid, mapper_lock => mapper_lock, detect_codies_static => detect_codies_static, mapper_codies_force => mapper_codies_force, mapper_eeprom => mapper_eeprom, mapper_zemina_force => mapper_zemina_force, mapper_nemesis_auto => mapper_nemesis_auto, rom_size_pages => rom_size_pages, ce_z80 => ce_z80, WR_n => WR_n, MREQ_n => MREQ_n, A => A, ss_freeze => ss_freeze, D_in => D_in, sc3000_en => sc3000_en, mapper_castle => mapper_castle, mapper_linear => mapper_linear, mapper_dahjee_a => mapper_dahjee_a, mapper_sega_locked => mapper_sega_locked, use_zem => use_zem, mapper_manual_force => mapper_manual_force, sega_mapper_write_seen => sega_mapper_write_seen, bank0_out => bank0_out, bank1_out => bank1_out, bank2_out => bank2_out, bank3_out => bank3_out, jang_bank1_out => jang_bank1_out, jang_bank2_out => jang_bank2_out, jang_bank3_out => jang_bank3_out, jang_bank4_out => jang_bank4_out, jang_rev1_out => jang_rev1_out, jang_rev2_out => jang_rev2_out, jang_rev3_out => jang_rev3_out, jang_rev4_out => jang_rev4_out, nvram_e_out => nvram_e_out, nvram_ex_out => nvram_ex_out, nvram_p_out => nvram_p_out, nvram_cme_out => nvram_cme_out, lock_mapper_B_out => lock_mapper_B_out, mapper_codies_out => mapper_codies_out, mapper_codies_lock_out => mapper_codies_lock_out, mapper_4pak_out => mapper_4pak_out, pak4_reg2_out => pak4_reg2_out, nem_bank0_out => nem_bank0_out, eeprom_soft_reset_out => eeprom_soft_reset_out);
baseline: entity work.mapper_baseline port map (RESET_n => RESET_n, clk_sys => clk_sys, evolution_game_launch => evolution_game_launch, mapper_set => mapper_set, mapper_evolution => mapper_evolution, evolution_ss_in => evolution_ss_in, mapper_in => mapper_in, mapper_janggun => mapper_janggun, systeme => systeme, bootloader_n => bootloader_n, mapper_wonderkid => mapper_wonderkid, mapper_lock => mapper_lock, detect_codies_static => detect_codies_static, mapper_codies_force => mapper_codies_force, mapper_eeprom => mapper_eeprom, mapper_zemina_force => mapper_zemina_force, mapper_nemesis_auto => mapper_nemesis_auto, rom_size_pages => rom_size_pages, ce_z80 => ce_z80, WR_n => WR_n, MREQ_n => MREQ_n, A => A, ss_freeze => ss_freeze, D_in => D_in, sc3000_en => sc3000_en, mapper_castle => mapper_castle, mapper_linear => mapper_linear, mapper_dahjee_a => mapper_dahjee_a, mapper_sega_locked => mapper_sega_locked, use_zem => use_zem, mapper_manual_force => mapper_manual_force, sega_mapper_write_seen => sega_mapper_write_seen, bank0_out => ref_bank0_out, bank1_out => ref_bank1_out, bank2_out => ref_bank2_out, bank3_out => ref_bank3_out, jang_bank1_out => ref_jang_bank1_out, jang_bank2_out => ref_jang_bank2_out, jang_bank3_out => ref_jang_bank3_out, jang_bank4_out => ref_jang_bank4_out, jang_rev1_out => ref_jang_rev1_out, jang_rev2_out => ref_jang_rev2_out, jang_rev3_out => ref_jang_rev3_out, jang_rev4_out => ref_jang_rev4_out, nvram_e_out => ref_nvram_e_out, nvram_ex_out => ref_nvram_ex_out, nvram_p_out => ref_nvram_p_out, nvram_cme_out => ref_nvram_cme_out, lock_mapper_B_out => ref_lock_mapper_B_out, mapper_codies_out => ref_mapper_codies_out, mapper_codies_lock_out => ref_mapper_codies_lock_out, mapper_4pak_out => ref_mapper_4pak_out, pak4_reg2_out => ref_pak4_reg2_out, nem_bank0_out => ref_nem_bank0_out, eeprom_soft_reset_out => ref_eeprom_soft_reset_out);
stimulus: process
variable cycles : natural := 0;
variable rng : unsigned(31 downto 0) := x"12345678";
procedure tick is begin
clk_sys <= '0'; wait for 5 ns; clk_sys <= '1'; wait for 5 ns;
assert bank0_out = ref_bank0_out report "Differential mismatch: bank0_out" severity failure;
assert bank1_out = ref_bank1_out report "Differential mismatch: bank1_out" severity failure;
assert bank2_out = ref_bank2_out report "Differential mismatch: bank2_out" severity failure;
assert bank3_out = ref_bank3_out report "Differential mismatch: bank3_out" severity failure;
assert jang_bank1_out = ref_jang_bank1_out report "Differential mismatch: jang_bank1_out" severity failure;
assert jang_bank2_out = ref_jang_bank2_out report "Differential mismatch: jang_bank2_out" severity failure;
assert jang_bank3_out = ref_jang_bank3_out report "Differential mismatch: jang_bank3_out" severity failure;
assert jang_bank4_out = ref_jang_bank4_out report "Differential mismatch: jang_bank4_out" severity failure;
assert jang_rev1_out = ref_jang_rev1_out report "Differential mismatch: jang_rev1_out" severity failure;
assert jang_rev2_out = ref_jang_rev2_out report "Differential mismatch: jang_rev2_out" severity failure;
assert jang_rev3_out = ref_jang_rev3_out report "Differential mismatch: jang_rev3_out" severity failure;
assert jang_rev4_out = ref_jang_rev4_out report "Differential mismatch: jang_rev4_out" severity failure;
assert nvram_e_out = ref_nvram_e_out report "Differential mismatch: nvram_e_out" severity failure;
assert nvram_ex_out = ref_nvram_ex_out report "Differential mismatch: nvram_ex_out" severity failure;
assert nvram_p_out = ref_nvram_p_out report "Differential mismatch: nvram_p_out" severity failure;
assert nvram_cme_out = ref_nvram_cme_out report "Differential mismatch: nvram_cme_out" severity failure;
assert lock_mapper_B_out = ref_lock_mapper_B_out report "Differential mismatch: lock_mapper_B_out" severity failure;
assert mapper_codies_out = ref_mapper_codies_out report "Differential mismatch: mapper_codies_out" severity failure;
assert mapper_codies_lock_out = ref_mapper_codies_lock_out report "Differential mismatch: mapper_codies_lock_out" severity failure;
assert mapper_4pak_out = ref_mapper_4pak_out report "Differential mismatch: mapper_4pak_out" severity failure;
assert pak4_reg2_out = ref_pak4_reg2_out report "Differential mismatch: pak4_reg2_out" severity failure;
assert nem_bank0_out = ref_nem_bank0_out report "Differential mismatch: nem_bank0_out" severity failure;
assert eeprom_soft_reset_out = ref_eeprom_soft_reset_out report "Differential mismatch: eeprom_soft_reset_out" severity failure;
cycles := cycles + 1; clk_sys <= '0'; end procedure;
procedure reset is begin
RESET_n <= '0';
evolution_game_launch <= '0';
mapper_set <= '0';
mapper_evolution <= '0';
evolution_ss_in <= (others => '0');
mapper_in <= (others => '0');
mapper_janggun <= '0';
systeme <= '0';
bootloader_n <= '0';
mapper_wonderkid <= '0';
mapper_lock <= '0';
detect_codies_static <= '0';
mapper_codies_force <= '0';
mapper_eeprom <= '0';
mapper_zemina_force <= '0';
mapper_nemesis_auto <= '0';
rom_size_pages <= (others => '0');
ce_z80 <= '0';
WR_n <= '0';
MREQ_n <= '0';
A <= (others => '0');
ss_freeze <= '0';
D_in <= (others => '0');
sc3000_en <= '0';
mapper_castle <= '0';
mapper_linear <= '0';
mapper_dahjee_a <= '0';
mapper_sega_locked <= '0';
use_zem <= '0';
mapper_manual_force <= '0';
sega_mapper_write_seen <= '0';
WR_n <= '1'; MREQ_n <= '1'; ce_z80 <= '1'; tick; RESET_n <= '1'; bootloader_n <= '1'; tick; tick; end procedure;
procedure wr(addr, data : natural) is begin
A <= std_logic_vector(to_unsigned(addr, 16)); D_in <= std_logic_vector(to_unsigned(data, 8));
WR_n <= '0'; MREQ_n <= '0'; tick; WR_n <= '1'; MREQ_n <= '1'; tick; end procedure;
procedure banks(b0,b1,b2,b3 : natural) is begin
assert unsigned(bank0_out)=b0 and unsigned(bank1_out)=b1 and unsigned(bank2_out)=b2 and unsigned(bank3_out)=b3
report "Unexpected bank state at cycle " & integer'image(cycles) severity failure; end procedure;
begin
reset; banks(0,1,2,3);
wr(16#FFFD#, 9); wr(16#FFFE#, 10); wr(16#FFFF#, 11); banks(9,10,11,3);
wr(16#FFFC#, 28);
assert nvram_e_out='1' and nvram_ex_out='1' and nvram_p_out='1' severity failure;
ss_freeze <= '1'; wr(16#FFFD#, 99); banks(9,10,11,3);
mapper_in <= x"1E7C554433221100"; mapper_set <= '1'; tick;
banks(0,17,34,51);
assert pak4_reg2_out=x"44" and nem_bank0_out=x"55" and nvram_p_out='1' and nvram_e_out='1'
and nvram_ex_out='1' and nvram_cme_out='1' and mapper_4pak_out='1' and mapper_codies_out='1'
and lock_mapper_B_out='1' and mapper_codies_lock_out='1' severity failure;
mapper_set <= '0'; tick; banks(0,17,34,51);
report "PASS Sega, NVRAM, freeze, standard restore";

reset; mapper_codies_force <= '1'; bootloader_n <= '0'; tick; bootloader_n <= '1'; tick;
banks(0,1,0,3); assert mapper_codies_out='1' and mapper_codies_lock_out='1' severity failure;
wr(0,7); wr(16#4000#,16#85#); wr(16#8000#,9); banks(7,5,9,3);
assert nvram_cme_out='1' severity failure;
wr(16#FFFF#,22); banks(7,5,9,3);
reset; detect_codies_static <= '1'; bootloader_n <= '0'; tick; bootloader_n <= '1'; tick;
assert mapper_codies_out='1' severity failure; wr(16#8000#,13); banks(0,1,13,3);
report "PASS forced/static Codemasters";

reset; mapper_wonderkid <= '1'; tick; banks(0,0,0,3);
assert lock_mapper_B_out='1' severity failure;
wr(0,17); wr(16#4000#,18); banks(0,0,0,3);
wr(16#8000#,19); banks(0,0,19,3);
ss_freeze <= '1'; wr(16#8000#,20); banks(0,0,19,3);
ss_freeze <= '0'; mapper_lock <= '1'; wr(16#8000#,20); banks(0,0,19,3);
mapper_lock <= '0'; wr(16#FFFC#,8); wr(16#8000#,20); banks(0,0,19,3);
mapper_eeprom <= '1'; wr(16#8000#,21); banks(0,0,19,3);
wr(16#FFFF#,22); banks(0,0,22,3);
report "PASS Wonder Kid $8000 and gating";

reset; use_zem <= '1'; wr(0,12); wr(1,13); wr(2,14); wr(3,15); banks(14,15,12,13);
wr(16#FFFF#,99); banks(14,15,12,13);
RESET_n <= '0'; mapper_nemesis_auto <= '1'; rom_size_pages <= x"20"; tick; RESET_n <= '1'; tick;
assert nem_bank0_out=x"1F" severity failure;
RESET_n <= '0'; mapper_zemina_force <= '1'; tick; RESET_n <= '1'; tick;
assert nem_bank0_out=x"00" severity failure;
RESET_n <= '0'; mapper_zemina_force <= '0'; rom_size_pages <= x"00"; tick; RESET_n <= '1'; tick;
assert nem_bank0_out=x"00" severity failure;
report "PASS Zemina and Nemesis defaults";

reset; wr(16#3FFE#,16#20#); banks(32,1,32,3); assert mapper_4pak_out='1' severity failure;
wr(16#BFFF#,5); banks(32,1,37,3); assert pak4_reg2_out=x"05" severity failure;
wr(16#3FFE#,16#10#); wr(16#7FFF#,7); banks(16,7,21,3);
wr(16#BFFF#,255); banks(16,7,15,3);
reset; mapper_manual_force <= '1'; wr(16#3FFE#,32); banks(0,1,2,3);
assert mapper_4pak_out='0' severity failure;
reset; sega_mapper_write_seen <= '1'; wr(16#3FFE#,32); assert mapper_4pak_out='0' severity failure;
report "PASS 4-PAK writes and trigger exclusion";

reset; mapper_janggun <= '1'; wr(16#4000#,16#89#); wr(16#6000#,10); wr(16#8000#,16#8B#); wr(16#A000#,12);
assert jang_bank1_out="001001" and jang_bank2_out="001010" and jang_bank3_out="001011" and jang_bank4_out="001100"
and jang_rev1_out='1' and jang_rev2_out='0' and jang_rev3_out='1' and jang_rev4_out='0' severity failure;
wr(16#FFFE#,16#43#); wr(16#FFFF#,16#85#);
assert unsigned(jang_bank1_out)=6 and unsigned(jang_bank2_out)=7 and unsigned(jang_bank3_out)=10 and unsigned(jang_bank4_out)=11
and jang_rev1_out='1' and jang_rev2_out='1' and jang_rev3_out='1' and jang_rev4_out='1' severity failure;
mapper_in <= x"000000008C0B8A09"; mapper_set <= '1'; ss_freeze <= '1'; tick;
assert unsigned(jang_bank1_out)=9 and unsigned(jang_bank2_out)=10 and unsigned(jang_bank3_out)=11 and unsigned(jang_bank4_out)=12
and jang_rev1_out='0' and jang_rev2_out='1' and jang_rev3_out='0' and jang_rev4_out='1' severity failure;
report "PASS Janggun banks, reversal, paired writes and restore";
reset; mapper_castle <= '1'; wr(16#FFFD#,9); wr(16#8000#,8); wr(16#3FFE#,32); banks(0,1,2,3);
assert mapper_4pak_out='0' severity failure; report "PASS mapper_castle inhibits banking";
reset; mapper_dahjee_a <= '1'; wr(16#FFFD#,9); wr(16#8000#,8); wr(16#3FFE#,32); banks(0,1,2,3);
assert mapper_4pak_out='0' severity failure; report "PASS mapper_dahjee_a inhibits banking";
reset; mapper_linear <= '1'; wr(16#FFFD#,9); wr(16#8000#,8); wr(16#3FFE#,32); banks(0,1,2,3);
assert mapper_4pak_out='0' severity failure; report "PASS mapper_linear inhibits banking";
reset; mapper_sega_locked <= '1'; wr(16#FFFD#,9); wr(16#8000#,8); wr(16#3FFE#,32); banks(0,1,2,3);
assert mapper_4pak_out='0' severity failure; report "PASS mapper_sega_locked inhibits banking";
reset; systeme <= '1'; wr(16#FFFD#,9); wr(16#8000#,8); wr(16#3FFE#,32); banks(0,1,2,3);
assert mapper_4pak_out='0' severity failure; report "PASS systeme inhibits banking";
reset; sc3000_en <= '1'; wr(16#FFFD#,9); wr(16#8000#,8); wr(16#3FFE#,32); banks(0,1,2,3);
assert mapper_4pak_out='0' severity failure; report "PASS sc3000_en inhibits banking";
reset; wr(16#FFFD#,9); bootloader_n <= '0'; tick; wr(16#FFFE#,10); banks(9,10,2,3);
bootloader_n <= '1'; ss_freeze <= '1'; tick; banks(0,1,2,3);
bootloader_n <= '0'; tick; mapper_in <= x"0000000033221109"; mapper_set <= '1'; bootloader_n <= '1'; tick;
banks(9,17,34,51); mapper_set <= '0'; tick; banks(9,17,34,51);
reset; use_zem <= '1'; bootloader_n <= '0'; tick; wr(16#FFFD#,7); banks(7,1,2,3);
bootloader_n <= '1'; tick; banks(0,1,2,3);
report "PASS BIOS handoff, frozen handoff, restore edge suppression and BIOS Sega writes";

reset; mapper_eeprom <= '1'; mapper_castle <= '1'; use_zem <= '1'; mapper_codies_force <= '1';
wr(16#3FFE#,32); wr(16#8000#,20); banks(0,1,2,3); assert mapper_4pak_out='0' severity failure;
wr(16#FFFD#,7); wr(16#FFFE#,8); wr(16#FFFF#,9); banks(7,8,9,3);
A <= x"FFFC"; D_in <= x"9C"; WR_n <= '0'; MREQ_n <= '0'; tick;
assert eeprom_soft_reset_out='1' and nvram_e_out='0' and nvram_ex_out='0' and nvram_p_out='0' severity failure;
WR_n <= '1'; tick; assert eeprom_soft_reset_out='0' severity failure;
WR_n <= '0'; ss_freeze <= '1'; tick; assert eeprom_soft_reset_out='0' severity failure;
ss_freeze <= '0'; mapper_janggun <= '1'; tick; assert eeprom_soft_reset_out='0' severity failure;
report "PASS EEPROM priority, pulse and Janggun precedence";

reset; mapper_evolution <= '1'; evolution_ss_in(31 downto 16) <= x"E132";
mapper_in <= x"0000090807060000"; mapper_set <= '1'; tick; banks(9,8,7,6);
assert nvram_e_out='0' and mapper_4pak_out='0' and mapper_codies_out='0' severity failure;
mapper_set <= '0'; evolution_game_launch <= '1'; ss_freeze <= '1'; tick; banks(0,1,2,3);
ss_freeze <= '0'; A <= x"FFFF"; D_in <= x"19"; WR_n <= '0'; MREQ_n <= '0'; tick; banks(0,1,25,3);
reset; wr(16#FFFD#,9); systeme <= '1'; mapper_in <= x"0000000033221108"; mapper_set <= '1'; tick; banks(9,17,34,51);
report "PASS Evolution restore/launch priorities and System E restore layout";

reset; A <= x"A000"; WR_n <= '1'; MREQ_n <= '0'; tick;
wr(16#A000#,9); banks(0,1,2,3);
A <= x"9000"; MREQ_n <= '0'; tick; wr(16#A000#,9); banks(0,1,9,3);
report "PASS Korean anti-LDIR banking";

reset;
report "PASS current mapper directed regression complete"; wait; end process; end;