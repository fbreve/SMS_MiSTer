library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; entity tb is end; library base; library cand; architecture sim of tb is
signal gg: std_logic := '0';
signal mapper_evolution: std_logic := '0';
signal gg_bios_en: std_logic := '0';
signal bios_en: std_logic := '0';
signal ext_bios_sel: std_logic := '0';
signal ext_bios_loaded: std_logic := '0';
signal dbr: std_logic := '0';
signal bootloader_n: std_logic := '0';
signal ext_gg_bios_loaded: std_logic := '0';
signal mapper_dahjee_a: std_logic := '0';
signal use_zem: std_logic := '0';
signal mapper_4pak: std_logic := '0';
signal mapper_codies: std_logic := '0';
signal systeme: std_logic := '0';
signal sc3000_en: std_logic := '0';
signal sc_multicart_en: std_logic := '0';
signal mapper_linear: std_logic := '0';
signal mapper_janggun: std_logic := '0';
signal A: std_logic_vector(15 downto 0) := (others=>'0');
signal media_control: std_logic_vector(7 downto 5) := (others=>'0');
signal bank0: std_logic_vector(7 downto 0) := (others=>'0');
signal bank1: std_logic_vector(7 downto 0) := (others=>'0');
signal bank2: std_logic_vector(7 downto 0) := (others=>'0');
signal bank3: std_logic_vector(7 downto 0) := (others=>'0');
signal nem_bank0: std_logic_vector(7 downto 0) := (others=>'0');
signal rom_bank: std_logic_vector(3 downto 0) := (others=>'0');
signal sc_multicart_page: std_logic_vector(6 downto 0) := (others=>'0');
signal jang_bank1: std_logic_vector(5 downto 0) := (others=>'0');
signal jang_bank2: std_logic_vector(5 downto 0) := (others=>'0');
signal jang_bank3: std_logic_vector(5 downto 0) := (others=>'0');
signal jang_bank4: std_logic_vector(5 downto 0) := (others=>'0');
signal cart_precedence_out_a: std_logic := '0';
signal cart_precedence_out_c: std_logic := '0';
signal cart_memory_selected_out_a: std_logic := '0';
signal cart_memory_selected_out_c: std_logic := '0';
signal dahjee_cart_access_out_a: std_logic := '0';
signal dahjee_cart_access_out_c: std_logic := '0';
signal rom_a_i_out_a: std_logic_vector(21 downto 0) := (others=>'0');
signal rom_a_i_out_c: std_logic_vector(21 downto 0) := (others=>'0');
begin
ubase: entity base.memory_decode port map (gg=>gg,mapper_evolution=>mapper_evolution,gg_bios_en=>gg_bios_en,bios_en=>bios_en,ext_bios_sel=>ext_bios_sel,ext_bios_loaded=>ext_bios_loaded,dbr=>dbr,bootloader_n=>bootloader_n,ext_gg_bios_loaded=>ext_gg_bios_loaded,mapper_dahjee_a=>mapper_dahjee_a,use_zem=>use_zem,mapper_4pak=>mapper_4pak,mapper_codies=>mapper_codies,systeme=>systeme,sc3000_en=>sc3000_en,sc_multicart_en=>sc_multicart_en,mapper_linear=>mapper_linear,mapper_janggun=>mapper_janggun,A=>A,media_control=>media_control,bank0=>bank0,bank1=>bank1,bank2=>bank2,bank3=>bank3,nem_bank0=>nem_bank0,rom_bank=>rom_bank,sc_multicart_page=>sc_multicart_page,jang_bank1=>jang_bank1,jang_bank2=>jang_bank2,jang_bank3=>jang_bank3,jang_bank4=>jang_bank4,cart_precedence_out=>cart_precedence_out_a,cart_memory_selected_out=>cart_memory_selected_out_a,dahjee_cart_access_out=>dahjee_cart_access_out_a,rom_a_i_out=>rom_a_i_out_a);
ucand: entity cand.memory_decode port map (gg=>gg,mapper_evolution=>mapper_evolution,gg_bios_en=>gg_bios_en,bios_en=>bios_en,ext_bios_sel=>ext_bios_sel,ext_bios_loaded=>ext_bios_loaded,dbr=>dbr,bootloader_n=>bootloader_n,ext_gg_bios_loaded=>ext_gg_bios_loaded,mapper_dahjee_a=>mapper_dahjee_a,use_zem=>use_zem,mapper_4pak=>mapper_4pak,mapper_codies=>mapper_codies,systeme=>systeme,sc3000_en=>sc3000_en,sc_multicart_en=>sc_multicart_en,mapper_linear=>mapper_linear,mapper_janggun=>mapper_janggun,A=>A,media_control=>media_control,bank0=>bank0,bank1=>bank1,bank2=>bank2,bank3=>bank3,nem_bank0=>nem_bank0,rom_bank=>rom_bank,sc_multicart_page=>sc_multicart_page,jang_bank1=>jang_bank1,jang_bank2=>jang_bank2,jang_bank3=>jang_bank3,jang_bank4=>jang_bank4,cart_precedence_out=>cart_precedence_out_c,cart_memory_selected_out=>cart_memory_selected_out_c,dahjee_cart_access_out=>dahjee_cart_access_out_c,rom_a_i_out=>rom_a_i_out_c);
process
variable expected,bank: integer;
procedure check is begin
assert rom_a_i_out_a=rom_a_i_out_c and cart_precedence_out_a=cart_precedence_out_c and cart_memory_selected_out_a=cart_memory_selected_out_c and dahjee_cart_access_out_a=dahjee_cart_access_out_c report "RTL mismatch" severity failure;
end;
begin
bootloader_n<='1'; dbr<='1';
-- Every selector equivalence class and every selected bank value. Distinct
-- bijections also catch accidental selection of a different bank register.
for flags in 0 to 3 loop
mapper_4pak<=std_logic(to_unsigned(flags,2)(1)); mapper_codies<=std_logic(to_unsigned(flags,2)(0));
for page in 0 to 63 loop
for b in 0 to 255 loop
A<=std_logic_vector(to_unsigned(page*1024,16));
bank0<=std_logic_vector(to_unsigned(b,8)); bank1<=std_logic_vector(to_unsigned((b+85) mod 256,8)); bank2<=std_logic_vector(to_unsigned((b+170) mod 256,8));
wait for 1 ns; check;
if page<16 then bank:=b; elsif page<32 then bank:=(b+85) mod 256; else bank:=(b+170) mod 256; end if;
if flags=0 and page=0 then bank:=0; end if;
expected:=bank*16384+(page*1024 mod 16384);
assert to_integer(unsigned(rom_a_i_out_c))=expected report "Mapper contract mismatch" severity failure;
end loop; end loop; end loop;
-- All byte addresses, including 0038/0066/03ff/0400 boundaries, each mapper.
for flags in 0 to 3 loop
mapper_4pak<=std_logic(to_unsigned(flags,2)(1)); mapper_codies<=std_logic(to_unsigned(flags,2)(0));
bank0<=x"35"; bank1<=x"a6"; bank2<=x"f1";
for address in 0 to 65535 loop A<=std_logic_vector(to_unsigned(address,16)); wait for 1 ns; check; end loop;
end loop;
report "PASS 327680 binary RTL comparisons; 65536 independent mapper contract checks";
wait;
end process; end;