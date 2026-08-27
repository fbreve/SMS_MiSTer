library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Master System Evolution / Noza mapper.
--
-- This first-stage implementation only models the register latches that
-- have been established by the reverse engineering.  The address mux is
-- intentionally left inactive until the exact ROM mapping is verified.
entity evolution_mapper is
    port (
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        enable     : in  std_logic;
        cpu_a      : in  std_logic_vector(15 downto 0);
        mreq_n     : in  std_logic;
        iorq_n     : in  std_logic;
        wr_n       : in  std_logic;
        d_in       : in  std_logic_vector(7 downto 0);
        bank61     : out std_logic_vector(7 downto 0);
        bank62     : out std_logic_vector(7 downto 0);
        reg3ffe    : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of evolution_mapper is
    signal bank61_r  : std_logic_vector(7 downto 0) := (others => '0');
    signal bank62_r  : std_logic_vector(7 downto 0) := (others => '0');
    signal reg3ffe_r : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                bank61_r  <= (others => '0');
                bank62_r  <= (others => '0');
                reg3ffe_r <= (others => '0');
            elsif enable = '1' then
                -- $61/$62 are I/O address latches on the Evolution hardware.
                if wr_n = '0' and iorq_n = '0' then
                    case cpu_a(7 downto 0) is
                        when x"61" => bank61_r <= d_in;
                        when x"62" => bank62_r <= d_in;
                        when others => null;
                    end case;
                -- $3FFE is a memory-mapped Evolution control register.
                elsif wr_n = '0' and mreq_n = '0' and cpu_a = x"3FFE" then
                    reg3ffe_r <= d_in;
                end if;
            end if;
        end if;
    end process;

    bank61  <= bank61_r;
    bank62  <= bank62_r;
    reg3ffe <= reg3ffe_r;
end architecture;
