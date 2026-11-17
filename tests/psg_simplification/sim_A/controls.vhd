library ieee;use ieee.std_logic_1164.all;
entity controls is port(clk_sys,RESET_n,ss_freeze,psg_set,audio_ext_set,det_WR_n,bal_WR_n:in std_logic;D_in:in std_logic_vector(7 downto 0);audio_control_in:in std_logic_vector(10 downto 0);audio_control_out:out std_logic_vector(10 downto 0));end;
architecture extracted of controls is signal det_D:std_logic_vector(2 downto 0);signal PSG_mux:std_logic_vector(7 downto 0);begin
audio_control_out<=det_D & PSG_mux;
	process (clk_sys)
	begin
		if rising_edge(clk_sys) then
			if RESET_n='0' then 
				det_D <= "111";
				PSG_mux <= x"FF";
            elsif audio_ext_set='1' then
                det_D <= audio_control_in(10 downto 8);
                PSG_mux <= audio_control_in(7 downto 0);
			elsif ss_freeze = '0' and det_WR_n='0' then
				det_D <= D_in(2 downto 0);
			elsif ss_freeze = '0' and bal_WR_n='0' then
				PSG_mux <= D_in;
			end if;
		end if;
	end process;
end;
