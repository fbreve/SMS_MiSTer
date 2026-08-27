library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Master System Evolution / Noza mapper support.
--
-- On Master System Evolution / Noza hardware:
--   * Port $61 latches flash address bits A[15:8]
--   * Port $62 latches flash address bits A[23:16]
--   * The observed $3FFE commands select the visible ROM space:
--       - $85: Menu / service space
--       - $87: Selected-game space
--   * Mode switches on $3FFE are armed on write and take effect on the M1
--     opcode fetch following the subsequent 3-byte jump instruction (JP nn),
--     ensuring the jump itself is fetched from the originating space and
--     execution lands cleanly in the target space.
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
        m1_n       : in  std_logic;
        bank61     : out std_logic_vector(7 downto 0);
        bank62     : out std_logic_vector(7 downto 0);
        reg3ffe    : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of evolution_mapper is
    signal bank61_r        : std_logic_vector(7 downto 0) := (others => '0');
    signal bank62_r        : std_logic_vector(7 downto 0) := (others => '0');
    signal reg3ffe_r       : std_logic_vector(7 downto 0) := (others => '0');
    signal reg3ffe_pending : std_logic_vector(7 downto 0) := (others => '0');
    signal switch_pending  : std_logic := '0';
    signal switch_armed    : std_logic := '0';
    signal old_m1_n        : std_logic := '1';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                bank61_r        <= (others => '0');
                bank62_r        <= (others => '0');
                reg3ffe_r       <= (others => '0');
                reg3ffe_pending <= (others => '0');
                switch_pending  <= '0';
                switch_armed    <= '0';
                old_m1_n        <= '1';
            elsif enable = '1' then
                old_m1_n <= m1_n;

                -- Delayed mode switch state machine:
                -- Detect falling edge of M1_n (start of opcode fetch)
                if old_m1_n = '1' and m1_n = '0' then
                    if switch_armed = '1' then
                        -- Do not infer a bit-field from the two commands seen in
                        -- the dumped software. Unknown writes leave the view alone.
                        if reg3ffe_pending = x"85" or reg3ffe_pending = x"87" then
                            reg3ffe_r <= reg3ffe_pending;
                        end if;
                        switch_armed <= '0';
                    elsif switch_pending = '1' then
                        switch_pending <= '0';
                        switch_armed   <= '1';
                    end if;
                end if;

                -- Port $61 / $62 I/O writes
                if wr_n = '0' and iorq_n = '0' then
                    case cpu_a(7 downto 0) is
                        when x"61" => bank61_r <= d_in;
                        when x"62" => bank62_r <= d_in;
                        when others => null;
                    end case;
                -- $3FFE memory write
                elsif wr_n = '0' and mreq_n = '0' and cpu_a = x"3FFE" then
                    reg3ffe_pending <= d_in;
                    switch_pending  <= '1';
                    switch_armed    <= '0';
                end if;
            end if;
        end if;
    end process;

    bank61  <= bank61_r;
    bank62  <= bank62_r;
    reg3ffe <= reg3ffe_r;

end architecture;
