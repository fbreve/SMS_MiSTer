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
      if cart_memory_selected='0' then
        di <= bios(ai mod bios'length);
      else
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
        -- Selected-game bases observed in the deterministic attract sequence.
        -- Menu/service view remains linear. Once $3FFE enters game view, use
        -- the captured launch record as the authoritative base, matching
        -- evolution_record_page() in system.vhd for Sonic and Shinobi.
        if evo_3ffe=x"87" or evo_3ffe=x"97" or evo_3ffe=x"C7" then
          if evo_launch_addr=x"1FE8" then ai := 16#01C000# + (ai mod 16#100000#);
          elsif evo_launch_addr=x"1FF8" then ai := 16#05C000# + (ai mod 16#100000#);
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
        bootloader_n <= '0';
        media_control <= "111";
        last_boot <= '0';
        cycles <= 0;
        cart_handoff_seen <= '0';
        evolution_launch_count <= 0;
        post_launch_3e_count <= 0;
      else
        cycles <= cycles+1;

        -- Mirrors the relevant external SMS BIOS controls in system.vhd.
        if iorq_n='0' and wr_n='0' and a(7 downto 0)=x"3E" then
          bootloader_n <= dout(3);
          media_control <= dout(7 downto 5);
          report "OUT 3E="&hx(dout)&" PC="&hx(regs(45 downto 30))&
                 " boot->"&std_logic'image(dout(3))&" media="&hx(dout(7 downto 5))&
                 " launches="&integer'image(evolution_launch_count);
          if cart_handoff_seen='1' and evolution_launch_count>0 then
            post_launch_3e_count <= post_launch_3e_count+1;
            report "POST-LAUNCH $3E write #"&integer'image(post_launch_3e_count+1)&
                   " value="&hx(dout)&" PC="&hx(regs(45 downto 30)) severity warning;
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

        if evo_launch='1' then
          evolution_launch_count <= evolution_launch_count+1;
          report "EVO LAUNCH #"&integer'image(evolution_launch_count+1)&
                 " record="&hx(evo_launch_addr)&
                 " sel="&hx(evo_game62&evo_game61)&" mode="&hx(evo_3ffe);
        end if;
        if mreq_n='0' and wr_n='0' and a=x"3FFE" then
          report "EVO 3FFE="&hx(dout)&" PC="&hx(regs(45 downto 30))&
                 " bios="&std_logic'image(not bootloader_n);
        end if;
        if iorq_n='0' and wr_n='0' and
           (a(7 downto 0)=x"61" or a(7 downto 0)=x"62") then
          report "EVO OUT "&hx(a(7 downto 0))&"="&hx(dout)&
                 " PC="&hx(regs(45 downto 30));
        end if;

        if bootloader_n/=last_boot then
          report "SOURCE "&("CART" when bootloader_n='1' else "BIOS")&
                 " PC="&hx(regs(45 downto 30));
          last_boot <= bootloader_n;
        end if;

        if m1_n='0' and mreq_n='0' and rd_n='0' then
          report "M1 PC="&hx(a)&" OP="&hx(di)&" SRC="&
                 ("CART" when cart_memory_selected='1' else "BIOS")&
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
