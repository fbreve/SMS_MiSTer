-- Evolution BIOS arbitration regression harness
-- This is intentionally a small state-machine test, not a full-system simulation.
-- It locks down the $3E behaviour that caused the Hang On/Safari Hunt + Evolution
-- regression before a full T80/ROM harness is added.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity evolution_bios_arb_tb is
end entity;

architecture tb of evolution_bios_arb_tb is
  signal bootloader_n : std_logic := '0';

  procedure write_3e(
    signal boot : inout std_logic;
    constant value : in std_logic_vector(7 downto 0)) is
  begin
    -- Mirrors the external-BIOS branch in rtl/system.vhd.
    boot <= value(3);
    wait for 1 ns;
  end procedure;
begin
  process
  begin
    -- External BIOS owns reset.
    assert bootloader_n = '0'
      report "external BIOS must be active at reset" severity failure;

    -- BIOS disables itself to inspect/run the cartridge.
    write_3e(bootloader_n, x"08");
    assert bootloader_n = '1'
      report "$3E bit 3 must hand control to the cartridge" severity failure;

    -- A BIOS is allowed to select itself again while probing media.
    -- The previous Evolution-specific lockout broke exactly this transition.
    write_3e(bootloader_n, x"00");
    assert bootloader_n = '0'
      report "external BIOS must be able to re-enable itself during probing" severity failure;

    -- And hand control out again.
    write_3e(bootloader_n, x"08");
    assert bootloader_n = '1'
      report "second BIOS-to-cart handoff failed" severity failure;

    -- This is the unresolved Evolution case: an embedded game may legitimately
    -- write bit 3 low (Shinobi writes $04/$00). The current SMS BIOS model then
    -- selects the external BIOS again. Keep this assertion as documentation of
    -- the behaviour we need the ROM/T80 harness to resolve, rather than hiding
    -- it with another mapper-specific lockout.
    write_3e(bootloader_n, x"04");
    assert bootloader_n = '0'
      report "current model no longer reproduces Shinobi's BIOS re-selection" severity failure;

    report "Evolution BIOS arbitration regression harness passed" severity note;
    wait;
  end process;
end architecture;
