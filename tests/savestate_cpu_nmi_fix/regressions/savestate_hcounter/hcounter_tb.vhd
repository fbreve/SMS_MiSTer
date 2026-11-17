library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity hcounter_tb is generic(expect_fixed: boolean := false; gg_mode: std_logic := '0'); end;
architecture test of hcounter_tb is
signal clk: std_logic := '0'; signal rst,hl,load,ce: std_logic := '0';
signal rd: std_logic := '1'; signal addr,dout: std_logic_vector(7 downto 0) := (others=>'0');
signal x: std_logic_vector(8 downto 0) := (others=>'0');
signal live,saved: std_logic_vector(135 downto 0);
signal ref_hl: std_logic := '0'; signal ref_x: std_logic_vector(8 downto 0) := (others=>'0');
signal ref_dout: std_logic_vector(7 downto 0);
begin clk<=not clk after 5 ns;
dut: entity work.vdp port map(clk_sys => clk,
ce_vdp => ce,
ce_pix => '0',
ce_sp => '0',
gg => gg_mode,
ggres => '0',
se_bank => '0',
sp64 => '0',
HL => hl,
mask_line_irq => '0',
capture_cpu_edges => '0',
legacy_ext_nt => '0',
RD_n => rd,
WR_n => '1',
IRQ_n => open,
WR_direct => '0',
A_direct => (others=>'0'),
A => addr,
D_in => (others=>'0'),
D_out => dout,
x => x,
y => "011001000",
vcounter_cpu => (others=>'0'),
color => open,
palettemode => '0',
y1 => open,
mask_column => open,
black_column => '0',
smode_M1 => open,
smode_M2 => open,
smode_M3 => open,
smode_M4 => open,
ysj_quirk => '0',
reset_n => rst,
ss_regs_out => live,
ss_regs_in => saved,
ss_regs_set => load,
ss_cram_out => open,
ss_cram_wr => '0',
ss_cram_A => (others=>'0'),
ss_cram_D => (others=>'0'),
ss_vram_en => '0',
ss_vram_A => (others=>'0'),
ss_vram_D => open,
ss_vram_WE => '0',
ss_vram_WA => (others=>'0'),
ss_vram_WD => (others=>'0'));
reference: entity work.vdp port map(clk_sys => clk,
ce_vdp => ce,
ce_pix => '0',
ce_sp => '0',
gg => gg_mode,
ggres => '0',
se_bank => '0',
sp64 => '0',
HL => ref_hl,
mask_line_irq => '0',
capture_cpu_edges => '0',
legacy_ext_nt => '0',
RD_n => rd,
WR_n => '1',
IRQ_n => open,
WR_direct => '0',
A_direct => (others=>'0'),
A => addr,
D_in => (others=>'0'),
D_out => ref_dout,
x => ref_x,
y => "011001000",
vcounter_cpu => (others=>'0'),
color => open,
palettemode => '0',
y1 => open,
mask_column => open,
black_column => '0',
smode_M1 => open,
smode_M2 => open,
smode_M3 => open,
smode_M4 => open,
ysj_quirk => '0',
reset_n => rst,
ss_regs_out => open,
ss_regs_in => saved,
ss_regs_set => '0',
ss_cram_out => open,
ss_cram_wr => '0',
ss_cram_A => (others=>'0'),
ss_cram_D => (others=>'0'),
ss_vram_en => '0',
ss_vram_A => (others=>'0'),
ss_vram_D => open,
ss_vram_WE => '0',
ss_vram_WA => (others=>'0'),
ss_vram_WD => (others=>'0'));
process
procedure tick is begin wait until rising_edge(clk); wait for 1 ns; end;
procedure latch_at(n: natural) is begin hl<='0';tick; x<=std_logic_vector(to_unsigned(n,9));hl<='1';tick;hl<='0';tick;end;
procedure read_h(want: natural) is begin rd<='1';ce<='1';tick;addr<=x"41";rd<='0';tick;
assert dout=std_logic_vector(to_unsigned(want,8)) report "HCounter mismatch actual="&integer'image(to_integer(unsigned(dout)))&" expected="&integer'image(want) severity failure;
rd<='1';tick;ce<='0';end;
variable point: natural;
begin tick;rst<='1';tick;
for n in 0 to 7 loop
case n is when 0=>point:=0; when 1=>point:=1; when 2=>point:=254; when 3=>point:=255; when 4=>point:=256; when 5=>point:=485; when 6=>point:=486; when others=>point:=511;end case;
ref_hl<='0';tick;ref_x<=std_logic_vector(to_unsigned(point,9));ref_hl<='1';tick;ref_hl<='0';tick;
latch_at(point); read_h(point/2);saved<=live;tick;
latch_at((point+96) mod 512);read_h(((point+96) mod 512)/2);
load<='1';tick;load<='0';tick;
if expect_fixed then read_h(point/2);assert dout=ref_dout report "reference replay HCounter mismatch" severity failure;
else read_h(((point+96) mod 512)/2);end if;
latch_at((point+2) mod 512);read_h(((point+2) mod 512)/2);
end loop;
-- Legacy controller supplies zero; simultaneous live HL must not override restore.
saved(135 downto 128)<=x"00";hl<='0';tick;
x<=std_logic_vector(to_unsigned(510,9));hl<='1';load<='1';tick;
load<='0';hl<='0';tick;read_h(0);
latch_at(510);read_h(255);
if expect_fixed then report "PASS: F07 fixed real latch/save/perturb/load/read, 8 boundaries and subsequent HL";
else report "REPRODUCED BEFORE FIX: load returns B instead of saved A, 8 boundaries";end if;
std.env.stop;wait;
end process;end;
