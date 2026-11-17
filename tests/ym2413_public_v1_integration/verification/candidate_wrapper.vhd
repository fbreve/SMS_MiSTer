library ieee;use ieee.std_logic_1164.all;use work.vm2413.all;
entity candidate_wrapper is port(clk_sys,RESET_n,ce_raw,ss_freeze,fm_initialization_run,fm_legacy_reset,fm_ena:in std_logic;
 D_in:in std_logic_vector(7 downto 0);A:in std_logic_vector(15 downto 0);fm_WR_n:in std_logic;
 fm_state_addr:in std_logic_vector(7 downto 0);fm_state_read,fm_state_write:in std_logic;
 fm_state_wdata:in std_logic_vector(31 downto 0);fm_state_rdata:out std_logic_vector(31 downto 0);
 fm_initialized:out std_logic;FM_out:out std_logic_vector(13 downto 0);audible:out std_logic_vector(12 downto 0));end;
architecture test of candidate_wrapper is
 signal ce_cpu,fm_a:std_logic;signal fm_d:std_logic_vector(7 downto 0);
 signal fm_local_rdata,fm_wrapper_rdata:std_logic_vector(31 downto 0);
 signal FM_gated:std_logic_vector(12 downto 0);
 alias FM_sign:std_logic is FM_out(13);alias FM_adj:std_logic is FM_out(12);
 constant mapper_evolution:std_logic:='0';constant det_D:std_logic_vector(2 downto 0):="001";
begin
 ce_cpu<=ce_raw and not ss_freeze;
	fm: entity work.opll
	port map
	(
		xin		=> clk_sys,
		xena		=> ce_cpu,
		d        => fm_d,
		a        => fm_a,
		cs_n     => '0',
		we_n		=> '0',
		ic_n		=> RESET_n and not fm_legacy_reset,
		mixout   => FM_out,
        ss_hold => ss_freeze and not fm_initialization_run,
        ss_addr => fm_state_addr, ss_read => fm_state_read,
        ss_write => fm_state_write, ss_wdata => fm_state_wdata,
        ss_rdata => fm_local_rdata, ss_initialized => fm_initialized
	);
	
	process (clk_sys)
	begin
		if rising_edge(clk_sys) then
			if RESET_n='0' or fm_legacy_reset='1' then
				fm_d <= (others => '0');
				fm_a <= '0';
			elsif ss_freeze='1' and fm_state_write='1' and fm_state_addr=x"4c" then
                fm_a <= fm_state_wdata(0); fm_d <= fm_state_wdata(8 downto 1);
            elsif ss_freeze = '0' and fm_WR_n='0' then
				fm_d <= D_in;
				fm_a <= A(0);
			end if;
		end if;
	end process;
	
	
fm_state_rdata <= fm_local_rdata or fm_wrapper_rdata;
    process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            fm_wrapper_rdata <= (others=>'0');
            if ss_freeze='1' and fm_state_read='1' and fm_state_addr=x"4c" then
                fm_wrapper_rdata <= (31 downto 9=>'0') & fm_d & fm_a;
            end if;
        end if;
    end process;

-- AMR - Clamped volume boosting - if the top two bits match, truncate the topmost bit.
-- If the top two bits don't match, duplicate the second bit across the output.


FM_gated <= (others=>'0') when fm_ena='0' or mapper_evolution='1' or det_D(0)='0' else  -- All zero if FM is disabled
				FM_out(FM_out'high-1 downto 0) when FM_sign=FM_adj else -- Pass through
				(FM_gated'high=>FM_sign,others=>FM_adj);
audible<=FM_gated;
verify_word_76 <= (22 downto 0=>'0') & fm_d & fm_a;
end;
