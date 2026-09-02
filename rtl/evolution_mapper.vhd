library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Master System Evolution / Noza mapper support.
--
-- On Master System Evolution / Noza hardware:
--   * Port $61 latches flash address bits A[15:8]
--   * Port $62 low five bits select flash address bits A[20:16].
--     Bits 7:5 are control flags; the launcher explicitly preserves them
--     with IN ($62) / AND $E0 while replacing the page bits.
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
        game_bank61 : out std_logic_vector(7 downto 0);
        game_bank62 : out std_logic_vector(7 downto 0);
        prev_game_bank61 : out std_logic_vector(7 downto 0);
        prev_game_bank62 : out std_logic_vector(7 downto 0);
        reg3ffe    : out std_logic_vector(7 downto 0);
        reg8c      : out std_logic_vector(7 downto 0);
        regcd      : out std_logic_vector(7 downto 0);
        reg63      : out std_logic_vector(7 downto 0);
        reg88      : out std_logic_vector(7 downto 0);
        reg8d      : out std_logic_vector(7 downto 0);
        reg8e      : out std_logic_vector(7 downto 0);
        reg8f      : out std_logic_vector(7 downto 0);
        launch_trace : out std_logic_vector(63 downto 0);
        launch_fetch_addr : out std_logic_vector(15 downto 0);
        game_launch : out std_logic
    );
end entity;

architecture rtl of evolution_mapper is
    signal bank61_r        : std_logic_vector(7 downto 0) := (others => '0');
    signal bank62_r        : std_logic_vector(7 downto 0) := (others => '0');
    signal game_bank61_r   : std_logic_vector(7 downto 0) := (others => '0');
    signal game_bank62_r   : std_logic_vector(7 downto 0) := (others => '0');
    signal prev_game_bank61_r : std_logic_vector(7 downto 0) := (others => '0');
    signal prev_game_bank62_r : std_logic_vector(7 downto 0) := (others => '0');
    signal candidate_bank61_r : std_logic_vector(7 downto 0) := (others => '0');
    signal candidate_bank62_r : std_logic_vector(7 downto 0) := (others => '0');
    signal prior_candidate_bank61_r : std_logic_vector(7 downto 0) := (others => '0');
    signal prior_candidate_bank62_r : std_logic_vector(7 downto 0) := (others => '0');
    signal reg3ffe_r       : std_logic_vector(7 downto 0) := (others => '0');
    signal reg8c_r         : std_logic_vector(7 downto 0) := (others => '0');
    signal regcd_r         : std_logic_vector(7 downto 0) := (others => '0');
    signal reg63_r         : std_logic_vector(7 downto 0) := (others => '0');
    signal reg88_r         : std_logic_vector(7 downto 0) := (others => '0');
    signal reg8d_r         : std_logic_vector(7 downto 0) := (others => '0');
    signal reg8e_r         : std_logic_vector(7 downto 0) := (others => '0');
    signal reg8f_r         : std_logic_vector(7 downto 0) := (others => '0');
    signal reg3ffe_pending : std_logic_vector(7 downto 0) := (others => '0');
    signal switch_pending  : std_logic := '0';
    signal switch_armed    : std_logic := '0';
    signal old_m1_n        : std_logic := '1';
    signal game_started    : std_logic := '0';
    signal game_launch_r   : std_logic := '0';
    signal launch_trace_r  : std_logic_vector(63 downto 0) := (others => '0');
    signal trace_frozen_r  : std_logic := '0';
    signal trace_last_event_r : std_logic_vector(11 downto 0) := (others => '0');
    signal trace_io_code   : std_logic_vector(3 downto 0);
    signal launch_fetch_addr_r : std_logic_vector(15 downto 0) := (others => '0');
    signal record_read_pending_r : std_logic := '0';
begin

    with cpu_a(7 downto 0) select trace_io_code <=
        x"1" when x"61", x"2" when x"62",
        x"6" when x"63", x"7" when x"8D",
        x"8" when x"8E", x"9" when x"8F", x"A" when x"CD",
        x"0" when others;

    process(clk)
    begin
        if rising_edge(clk) then
            game_launch_r <= '0';
            if reset_n = '0' then
                bank61_r        <= (others => '0');
                bank62_r        <= (others => '0');
                game_bank61_r   <= (others => '0');
                game_bank62_r   <= (others => '0');
                prev_game_bank61_r <= (others => '0');
                prev_game_bank62_r <= (others => '0');
                candidate_bank61_r <= (others => '0');
                candidate_bank62_r <= (others => '0');
                prior_candidate_bank61_r <= (others => '0');
                prior_candidate_bank62_r <= (others => '0');
                reg3ffe_r       <= (others => '0');
                reg8c_r         <= (others => '0');
                regcd_r         <= (others => '0');
                reg63_r         <= (others => '0');
                reg88_r         <= (others => '0');
                reg8d_r         <= (others => '0');
                reg8e_r         <= (others => '0');
                reg8f_r         <= (others => '0');
                reg3ffe_pending <= (others => '0');
                switch_pending  <= '0';
                switch_armed    <= '0';
                old_m1_n        <= '1';
                game_started    <= '0';
                launch_trace_r  <= (others => '0');
                trace_frozen_r  <= '0';
                trace_last_event_r <= (others => '0');
                launch_fetch_addr_r <= (others => '0');
                record_read_pending_r <= '0';
            elsif enable = '1' then
                old_m1_n <= m1_n;

                -- Delayed mode switch state machine:
                -- Detect falling edge of M1_n (start of opcode fetch)
                if old_m1_n = '1' and m1_n = '0' then
                    -- The menu launch routine fetches LD A,(DE) at $1380;
                    -- its following data cycle reads selected_record + 2.
                    -- Capture that address so colliding $61/$62 launch values
                    -- can be traced back to distinct menu records.
                    if cpu_a = x"1380" then
                        record_read_pending_r <= '1';
                    end if;
                    if switch_armed = '1' then
                        -- Do not infer a bit-field from the two commands seen in
                        -- the dumped software. Unknown writes leave the view alone.
                        if reg3ffe_pending = x"85" or reg3ffe_pending = x"87" or
                           reg3ffe_pending = x"97" then
                            reg3ffe_r <= reg3ffe_pending;
                            -- The menu uses $FFFA-$FFFF as workspace, overlapping
                            -- the normal Sega mapper registers. Re-initialize them
                            -- when a different selected-game base is launched.
                            -- Patched games also issue $85/$87 pairs from their
                            -- VBlank hook; the unchanged base keeps those harmless.
                            if (reg3ffe_pending = x"87" or reg3ffe_pending = x"97") and
                               game_started = '0' then
                                game_started  <= '1';
                                game_launch_r <= '1';
                            end if;
                            if reg3ffe_pending = x"87" or reg3ffe_pending = x"97" then
                                prev_game_bank61_r <= prior_candidate_bank61_r;
                                prev_game_bank62_r <= prior_candidate_bank62_r;
                                game_bank61_r <= bank61_r;
                                game_bank62_r <= bank62_r;
                            end if;
                        end if;
                        switch_armed <= '0';
                    elsif switch_pending = '1' then
                        switch_pending <= '0';
                        switch_armed   <= '1';
                    end if;
                end if;

				if record_read_pending_r = '1' and mreq_n = '0' and
				   m1_n = '1' and wr_n = '1' then
					launch_fetch_addr_r <= cpu_a;
					record_read_pending_r <= '0';
				end if;

                -- Port $61 / $62 I/O writes
                if wr_n = '0' and iorq_n = '0' then
                    if trace_frozen_r = '0' and trace_io_code /= x"0" and
                       (trace_io_code & d_in) /= trace_last_event_r then
                        launch_trace_r <= launch_trace_r(51 downto 0) & trace_io_code & d_in;
                        trace_last_event_r <= trace_io_code & d_in;
                    end if;
                    case cpu_a(7 downto 0) is
                        when x"61" => bank61_r <= d_in;
                        when x"62" =>
                            bank62_r <= d_in;
                            if bank61_r /= candidate_bank61_r or d_in /= candidate_bank62_r then
                                prior_candidate_bank61_r <= candidate_bank61_r;
                                prior_candidate_bank62_r <= candidate_bank62_r;
                                candidate_bank61_r <= bank61_r;
                                candidate_bank62_r <= d_in;
                            end if;
                        when x"8C" => reg8c_r  <= d_in;
                        when x"CD" => regcd_r  <= d_in;
                        when x"63" => reg63_r  <= d_in;
                        when x"88" => reg88_r  <= d_in;
                        when x"8D" => reg8d_r  <= d_in;
                        when x"8E" => reg8e_r  <= d_in;
                        when x"8F" => reg8f_r  <= d_in;
                        when others => null;
                    end case;
                -- $3FFE memory write
                elsif wr_n = '0' and mreq_n = '0' and cpu_a = x"3FFE" then
                    reg3ffe_pending <= d_in;
                    switch_pending  <= '1';
                    switch_armed    <= '0';
                    if trace_frozen_r = '0' then
                        if (x"3" & d_in) /= trace_last_event_r then
                            launch_trace_r <= launch_trace_r(51 downto 0) & x"3" & d_in;
                            trace_last_event_r <= x"3" & d_in;
                        end if;
                        if d_in = x"87" or d_in = x"97" then
                            trace_frozen_r <= '1';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    bank61  <= bank61_r;
    bank62  <= bank62_r;
    game_bank61 <= game_bank61_r;
    game_bank62 <= game_bank62_r;
    prev_game_bank61 <= prev_game_bank61_r;
    prev_game_bank62 <= prev_game_bank62_r;
    reg3ffe <= reg3ffe_r;
    reg8c <= reg8c_r;
    regcd <= regcd_r;
    reg63 <= reg63_r;
    reg88 <= reg88_r;
    reg8d <= reg8d_r;
    reg8e <= reg8e_r;
    reg8f <= reg8f_r;
    launch_trace <= launch_trace_r;
    launch_fetch_addr <= launch_fetch_addr_r;
    game_launch <= game_launch_r;

end architecture;
