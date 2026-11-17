library ieee;use ieee.std_logic_1164.all;entity routing is port(fm_ena,mapper_evolution,systeme,gg:in std_logic;det_D:in std_logic_vector(2 downto 0);psg_enables:in std_logic_vector(1 downto 0);PSG_outL,PSG_outR,PSG2_outL,PSG2_outR:in std_logic_vector(10 downto 0);FM_out:in std_logic_vector(13 downto 0);FM_gated,mix_inL,mix_inR,mix2_inL,mix2_inR:out std_logic_vector(12 downto 0);PSG_disable:out std_logic);end;architecture extracted of routing is alias FM_sign:std_logic is FM_out(13);alias FM_adj:std_logic is FM_out(12);begin
FM_gated <= (others=>'0') when fm_ena='0' or mapper_evolution='1' or det_D(0)='0' else  -- All zero if FM is disabled
				FM_out(FM_out'high-1 downto 0) when FM_sign=FM_adj else -- Pass through
				(FM_gated'high=>FM_sign,others=>FM_adj); -- Clamp

PSG_disable <= '1' when (systeme='0' and gg='0' and fm_ena='1' and mapper_evolution='0' and (not det_D(1)=det_D(0))) else '0';
				 
mix_inL <= (others=>'0') when psg_enables(0)='1' or PSG_disable='1' else (PSG_outL(10) & PSG_outL & '0');
mix_inR <= (others=>'0') when psg_enables(0)='1' or PSG_disable='1' else (PSG_outR(10) & PSG_outR & '0');
mix2_inL <= (others=>'0') when psg_enables(1)='1' else (PSG2_outL(10) & PSG2_outL & '0') when systeme='1' else FM_gated;
mix2_inR <= (others=>'0') when psg_enables(1)='1' else (PSG2_outR(10) & PSG2_outR & '0') when systeme='1' else FM_gated;
				

end;
