-- T80 + ROM Evolution external-BIOS arbitration trace harness.
--
-- Loads exact binary images at simulation time (not committed):
--   hangon_bios.bin      external SMS BIOS
--   MS132X1E.sms         16 MiB Evolution flash
--
-- This is intentionally a bus/arbitration harness. VDP/PSG/controllers are
-- stubbed high/open so the trace can establish BIOS<->cart transitions first.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity evolution_t80_bios_trace_tb is
  generic (
    BIOS_FILE  : string := "hangon_bios.bin";
    FLASH_FILE : string := "MS132X1E.sms";
    MAX_CYCLES : natural := 2000000
  );
end entity;

architecture tb of evolution_t80_bios_trace_tb is
  type bios_t is array (0 to 262143) of std_logic_vector(7 downto 0);
  type flash_t is array (0 to 16777215) of std_logic_vector(7 downto 0);

  impure function load_bios(name : string) return bios_t is
    file f : file of character open read_mode is name;
    variable m : bios_t := (others => x"FF");
    variable ch : character;
    variable i : natural := 0;
  begin
    while not endfile(f) and i < m'length loop
      read(f,ch); m(i):=std_logic_vector(to_unsigned(character'pos(ch),8)); i:=i+1;
    end loop;
    report "loaded BIOS bytes: " & integer'image(i);
    return m;
  end;

  impure function load_flash(name : string) return flash_t is
    file f : file of character open read_mode is name;
    variable m : flash_t := (others => x"FF");
    variable ch : character;
    variable i : natural := 0;
  begin
    while not endfile(f) and i < m'length loop
      read(f,ch); m(i):=std_logic_vector(to_unsigned(character'pos(ch),8)); i:=i+1;
    end loop;
    report "loaded flash bytes: " & integer'image(i);
    return m;
  end;

  signal bios : bios_t := load_bios(BIOS_FILE);
  signal flash : flash_t := load_flash(FLASH_FILE);
  signal clk, reset_n : std_logic := '0';
  signal m1_n,mreq_n,iorq_n,rd_n,wr_n,rfsh_n,halt_n,busak_n : std_logic;
  signal a : std_logic_vector(15 downto 0);
  signal di,dout : std_logic_vector(7 downto 0);
  signal regs : std_logic_vector(229 downto 0);
  signal iset : std_logic_vector(1 downto 0);
  signal bootloader_n : std_logic := '0';
  signal media_control : std_logic_vector(2 downto 0) := "111";
  signal cycles : natural := 0;
  signal last_boot : std_logic := '0';

  function hx(v:std_logic_vector) return string is
    constant h:string:="0123456789ABCDEF"; variable s:string(1 to (v'length+3)/4);
    variable u:unsigned(v'length-1 downto 0):=unsigned(v);
  begin
    for i in s'reverse_range loop s(i):=h(to_integer(u(3 downto 0))+1); u:=shift_right(u,4); end loop;
    return s;
  end;
begin
  clk <= not clk after 10 ns;

  cpu: entity work.T80s
    generic map(Mode=>0,T2Write=>1,IOWait=>1)
    port map(RESET_n=>reset_n,CLK=>clk,CEN=>'1',WAIT_n=>'1',INT_n=>'1',NMI_n=>'1',
      BUSRQ_n=>'1',M1_n=>m1_n,MREQ_n=>mreq_n,IORQ_n=>iorq_n,RD_n=>rd_n,WR_n=>wr_n,
      RFSH_n=>rfsh_n,HALT_n=>halt_n,BUSAK_n=>busak_n,A=>a,DI=>di,DO=>dout,
      REG=>regs,ISet_out=>iset);

  -- Minimal ROM/I/O mux. BIOS is full-size external SPRAM in the real core.
  process(all)
    variable ai : natural;
  begin
    di <= x"FF";
    ai := to_integer(unsigned(a));
    if mreq_n='0' and rd_n='0' then
      if bootloader_n='0' then
        di <= bios(ai mod bios'length);
      else
        -- Before Evolution game selection this is enough to execute the menu
        -- at the base of the full flash image. Mapper/game-page modelling is
        -- deliberately the next increment after BIOS handoff is established.
        di <= flash(ai);
      end if;
    elsif iorq_n='0' and rd_n='0' then
      di <= x"FF"; -- open/stubbed peripherals
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset_n='0' then
        bootloader_n <= '0';
        media_control <= "111";
        last_boot <= '0';
        cycles <= 0;
      else
        cycles <= cycles+1;

        -- Mirrors the relevant external SMS BIOS controls in system.vhd.
        if iorq_n='0' and wr_n='0' and a(7 downto 0)=x"3E" then
          bootloader_n <= dout(3);
          media_control <= dout(7 downto 5);
          report "OUT 3E="&hx(dout)&" PC="&hx(regs(45 downto 30))&
                 " boot->"&std_logic'image(dout(3))&" media="&hx(dout(7 downto 5));
        end if;

        if bootloader_n/=last_boot then
          report "SOURCE "&("CART" when bootloader_n='1' else "BIOS")&
                 " PC="&hx(regs(45 downto 30));
          last_boot <= bootloader_n;
        end if;

        if m1_n='0' and mreq_n='0' and rd_n='0' then
          report "M1 PC="&hx(a)&" OP="&hx(di)&" SRC="&
                 ("CART" when bootloader_n='1' else "BIOS");
        end if;

        if cycles>=MAX_CYCLES then
          report "cycle limit reached" severity failure;
        end if;
      end if;
    end if;
  end process;

  process
  begin
    wait for 100 ns; reset_n<='1'; wait;
  end process;
end architecture;
