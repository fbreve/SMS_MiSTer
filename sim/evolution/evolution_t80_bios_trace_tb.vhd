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
    MAX_CYCLES : natural := 2000000;
    START_MODE : string := "BIOS_EVOLUTION" -- or DIRECT_SHINOBI
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
  signal media_control : std_logic_vector(7 downto 5) := "111";
  signal cart_precedence, cart_memory_selected : std_logic;
  signal bank0 : std_logic_vector(7 downto 0) := x"00";
  signal bank1 : std_logic_vector(7 downto 0) := x"01";
  signal bank2 : std_logic_vector(7 downto 0) := x"02";
  signal evo_bank61,evo_bank62,evo_game61,evo_game62,evo_prev61,evo_prev62 : std_logic_vector(7 downto 0);
  signal evo_3ffe,evo_8c,evo_cd,evo_63,evo_88,evo_8d,evo_8e,evo_8f : std_logic_vector(7 downto 0);
  signal evo_trace : std_logic_vector(63 downto 0);
  signal evo_launch_addr : std_logic_vector(15 downto 0);
  signal evo_launch : std_logic;
  signal evo_ss : std_logic_vector(159 downto 0);
  signal cycles : natural := 0;
  signal cart_handoff_seen : std_logic := '0';
  signal evolution_launch_count : natural := 0;
  signal post_launch_3e_count : natural := 0;
  signal first_post_launch_3e_seen : std_logic := '0';
  signal first_game_fetch_seen : std_logic := '0';
  signal last_boot : std_logic := '0';
  signal direct_shinobi : std_logic := '0';
  signal forced_launch_addr : std_logic_vector(15 downto 0) := (others=>'0');

  function source_name(cart_selected : std_logic) return string is
  begin
    if cart_selected='1' then return "CART";
    else return "BIOS";
    end if;
  end;

  function hx(v:std_logic_vector) return string is
    constant h : string := "0123456789ABCDEF";
    constant digits : natural := (v'length+3)/4;
    variable s : string(1 to digits);
    variable padded : unsigned(digits*4-1 downto 0) := (others=>'0');
    variable nibble : unsigned(3 downto 0);
  begin
    padded(v'length-1 downto 0) := unsigned(v);
    for i in 0 to digits-1 loop
      nibble := padded((digits-i)*4-1 downto (digits-i-1)*4);
      s(i+1) := h(to_integer(nibble)+1);
    end loop;
    return s;
  end;
begin
  direct_shinobi <= '1' when START_MODE="DIRECT_SHINOBI" else '0';
  forced_launch_addr <= x"1FF8" when direct_shinobi='1' else evo_launch_addr;
  clk <= not clk after 10 ns;

  cpu: entity work.T80s
    generic map(Mode=>0,T2Write=>1,IOWait=>1)
    port map(RESET_n=>reset_n,CLK=>clk,CEN=>'1',WAIT_n=>'1',INT_n=>'1',NMI_n=>'1',
      BUSRQ_n=>'1',M1_n=>m1_n,MREQ_n=>mreq_n,IORQ_n=>iorq_n,RD_n=>rd_n,WR_n=>wr_n,
      RFSH_n=>rfsh_n,HALT_n=>halt_n,BUSAK_n=>busak_n,A=>a,DI=>di,DO=>dout,
      REG=>regs,ISet_out=>iset);

  evo: entity work.evolution_mapper
    port map(clk=>clk, reset_n=>reset_n, enable=>'1', bios_active=>not bootloader_n,
      cpu_a=>a, mreq_n=>mreq_n, iorq_n=>iorq_n, rd_n=>rd_n, wr_n=>wr_n,
      d_in=>dout, m1_n=>m1_n, bank61=>evo_bank61, bank62=>evo_bank62,
      game_bank61=>evo_game61, game_bank62=>evo_game62,
      prev_game_bank61=>evo_prev61, prev_game_bank62=>evo_prev62,
      reg3ffe=>evo_3ffe, reg8c=>evo_8c, regcd=>evo_cd, reg63=>evo_63,
      reg88=>evo_88, reg8d=>evo_8d, reg8e=>evo_8e, reg8f=>evo_8f,
      launch_trace=>evo_trace, launch_fetch_addr=>evo_launch_addr,
      game_launch=>evo_launch, ss_out=>evo_ss);

  -- Exact external-SMS-BIOS cartridge visibility equations from system.vhd
  -- for this harness configuration: SMS, external BIOS present, dbr=1.
  cart_precedence <= '1' when bootloader_n='0' and media_control(6)='0' else '0';
  cart_memory_selected <=
    '0' when bootloader_n='0' and cart_precedence='0' else
    '0' when bootloader_n='1' and media_control(6)='1' else
    '1';

  -- ROM/I/O mux with Sega 16 KiB banking. This mirrors the relevant source
  -- selection instead of assuming bootloader_n alone chooses BIOS vs cart.
  process(all)
    variable ai : natural;
  begin
    di <= x"FF";
    ai := to_integer(unsigned(a));
    if mreq_n='0' and rd_n='0' then
      -- rom_a_i equivalent: external BIOS and cartridge both see the same
      -- Sega mapper translation in system.vhd. This matters for the 128 KiB
      -- Hang On/Safari Hunt BIOS, whose upper half is unreachable if BIOS
      -- reads are incorrectly treated as a flat 64 KiB CPU window.
      case a(15 downto 14) is
        when "00" =>
          if a(13 downto 10)="0000" then
            ai := to_integer(unsigned(a));
          else
            ai := to_integer(unsigned(bank0 & a(13 downto 0)));
          end if;
        when "01" => ai := to_integer(unsigned(bank1 & a(13 downto 0)));
        when others => ai := to_integer(unsigned(bank2 & a(13 downto 0)));
      end case;

      if cart_memory_selected='0' then
        di <= bios(ai mod bios'length);
      else
        -- Control experiment: direct Shinobi is a conventional cartridge
        -- view from the first handoff, with no Evolution menu state involved.
        if direct_shinobi='1' then
          ai := 16#05C000# + (ai mod 16#100000#);
        -- Attract path: selected-game translation only after Evolution's
        -- delayed $3FFE mode switch has actually entered game view.
        elsif evo_3ffe=x"87" or evo_3ffe=x"97" or evo_3ffe=x"C7" then
          if forced_launch_addr=x"1FE8" then ai := 16#01C000# + (ai mod 16#100000#);
          elsif forced_launch_addr=x"1FF8" then ai := 16#05C000# + (ai mod 16#100000#);
          end if;
        end if;
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
        if START_MODE="DIRECT_SHINOBI" then
          -- Control experiment: conventional BIOS hands off directly to a
          -- Shinobi cartridge image, bypassing Evolution menu/attract state.
          bootloader_n <= '0';
          media_control <= "111";
        else
          bootloader_n <= '0';
          media_control <= "111";
        end if;
        last_boot <= '0';
        cycles <= 0;
        cart_handoff_seen <= '0';
        evolution_launch_count <= 0;
        post_launch_3e_count <= 0;
        first_post_launch_3e_seen <= '0';
        first_game_fetch_seen <= '0';
      else
        cycles <= cycles+1;

        -- Mirrors the relevant external SMS BIOS controls in system.vhd.
        if iorq_n='0' and wr_n='0' and a(7 downto 0)=x"3E" then
          bootloader_n <= dout(3);
          media_control <= dout(7 downto 5);
          report "OUT 3E="&hx(dout)&" PC="&hx(a)&
                 " boot->"&std_logic'image(dout(3))&" media="&hx(dout(7 downto 5))&
                 " launches="&integer'image(evolution_launch_count);
          if cart_handoff_seen='1' and
             (evolution_launch_count>0 or direct_shinobi='1') then
            post_launch_3e_count <= post_launch_3e_count+1;
            report "POST-LAUNCH $3E write #"&integer'image(post_launch_3e_count+1)&
                   " value="&hx(dout)&" A="&hx(a)&
                   " boot_before="&std_logic'image(bootloader_n)&
                   " cartsel_before="&std_logic'image(cart_memory_selected)&
                   " media_before="&hx(media_control)&
                   " banks="&hx(bank0)&"/"&hx(bank1)&"/"&hx(bank2)&
                   " evo_mode="&hx(evo_3ffe)&
                   " evo_sel="&hx(evo_game62&evo_game61)&
                   " record="&hx(forced_launch_addr) severity warning;
            if first_post_launch_3e_seen='0' then
              first_post_launch_3e_seen <= '1';
              report "FIRST POST-LAUNCH $3E SNAPSHOT mode="&START_MODE&
                     " value="&hx(dout)&
                     " boot_before="&std_logic'image(bootloader_n)&
                     " cartsel_before="&std_logic'image(cart_memory_selected)&
                     " media_before="&hx(media_control)&
                     " banks="&hx(bank0)&"/"&hx(bank1)&"/"&hx(bank2)&
                     " evo_mode="&hx(evo_3ffe)&
                     " evo61="&hx(evo_bank61)&" evo62="&hx(evo_bank62)&
                     " record="&hx(forced_launch_addr) severity warning;
            end if;
          end if;
          if dout(3)='1' then cart_handoff_seen <= '1'; end if;
        end if;

        -- Standard Sega mapper writes. The real core resets these banks to
        -- 0/1/2 on a BIOS 0->1 handoff; model that below as well.
        if mreq_n='0' and wr_n='0' then
          if a=x"FFFD" then bank0<=dout;
          elsif a=x"FFFE" then bank1<=dout;
          elsif a=x"FFFF" then bank2<=dout;
          end if;
        end if;
        if bootloader_n='0' and last_boot='0' and iorq_n='0' and wr_n='0' and
           a(7 downto 0)=x"3E" and dout(3)='1' then
          bank0<=x"00"; bank1<=x"01"; bank2<=x"02";
        end if;

        -- Snapshot the first opcode fetch from Shinobi itself. This is
        -- earlier than its first OUT $3E and tells us whether the two paths
        -- already enter the game with different inherited machine state.
        if first_game_fetch_seen='0' and cart_memory_selected='1' and
           m1_n='0' and mreq_n='0' and rd_n='0' and
           ((direct_shinobi='1' and a=x"0000") or
            (direct_shinobi='0' and forced_launch_addr=x"1FF8" and
             (evo_3ffe=x"87" or evo_3ffe=x"97" or evo_3ffe=x"C7"))) then
          first_game_fetch_seen <= '1';
          report "SHINOBI ENTRY SNAPSHOT mode="&START_MODE&
                 " cpu_a="&hx(a)&" op="&hx(di)&
                 " boot="&std_logic'image(bootloader_n)&
                 " cartsel="&std_logic'image(cart_memory_selected)&
                 " media="&hx(media_control)&
                 " banks="&hx(bank0)&"/"&hx(bank1)&"/"&hx(bank2)&
                 " evo_mode="&hx(evo_3ffe)&
                 " evo61="&hx(evo_bank61)&" evo62="&hx(evo_bank62)&
                 " record="&hx(forced_launch_addr) severity warning;
        end if;

        if evo_launch='1' then
          evolution_launch_count <= evolution_launch_count+1;
          report "EVO LAUNCH #"&integer'image(evolution_launch_count+1)&
                 " record="&hx(evo_launch_addr)&
                 " sel="&hx(evo_game62&evo_game61)&" mode="&hx(evo_3ffe);
        end if;
        if mreq_n='0' and wr_n='0' and a=x"3FFE" then
          report "EVO 3FFE="&hx(dout)&" PC="&hx(a)&
                 " bios="&std_logic'image(not bootloader_n);
        end if;
        if iorq_n='0' and wr_n='0' and
           (a(7 downto 0)=x"61" or a(7 downto 0)=x"62") then
          report "EVO OUT "&hx(a(7 downto 0))&"="&hx(dout)&
                 " PC="&hx(a);
        end if;

        if bootloader_n/=last_boot then
          report "SOURCE "&source_name(bootloader_n)&
                 " PC="&hx(a);
          last_boot <= bootloader_n;
        end if;

        if m1_n='0' and mreq_n='0' and rd_n='0' then
          report "M1 PC="&hx(a)&" OP="&hx(di)&" SRC="&source_name(cart_memory_selected)&
                 " boot="&std_logic'image(bootloader_n)&
                 " cartsel="&std_logic'image(cart_memory_selected)&
                 " media="&hx(media_control);
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
