library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.sprite_state_pkg.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity vpd_sprite_shifter is
generic(SS_SEQUENTIAL:boolean:=true; SS_OFFSET:integer:=0);
Port(
 ss_state_addr: in std_logic_vector(7 downto 0) := (others=>'0');
 ss_state_read: in std_logic := '0';
 ss_state_write: in std_logic := '0';
 ss_state_wdata: in std_logic_vector(31 downto 0) := (others=>'0');
 ss_state_rdata: out std_logic_vector(31 downto 0);

	clk_sys:in  STD_LOGIC;
	ce_pix: in  STD_LOGIC;
	x		: in  std_logic_vector (7 downto 0);
	spr_x	: in  std_logic_vector (7 downto 0);
	load  : in  boolean;
	x248  : in  boolean; -- idem load but for shifted sprites
	x224  : in  boolean; -- idem load but for shifted mode2 sprites
	m4		: in  boolean; -- 1 if mode4
	wide_n: in  boolean; -- if sprites are wide reg1 bit 0
	spr_d0: in  std_logic_vector (7 downto 0);
	spr_d1: in  std_logic_vector (7 downto 0);
	spr_d2: in  std_logic_vector (7 downto 0);
	spr_d3: in  std_logic_vector (7 downto 0);
	color : out std_logic_vector (3 downto 0);
	active: out std_logic;
	ss_sprite_out: out std_logic_vector(32 downto 0);
 ss_sprite_in: in std_logic_vector(32 downto 0) := (others=>'0');
 ss_sprite_valid: in std_logic := '0';
 ss_regs_set: in std_logic := '0'
);
end vpd_sprite_shifter;

architecture Behavioral of vpd_sprite_shifter is
   signal wideclock : boolean := false ;
	signal shift0	: std_logic_vector (7 downto 0) := (others=>'0');
	signal shift1	: std_logic_vector (7 downto 0) := (others=>'0');
	signal shift2	: std_logic_vector (7 downto 0) := (others=>'0');
	signal shift3	: std_logic_vector (7 downto 0) := (others=>'0');

signal ss_local_data:std_logic_vector(31 downto 0);
begin
 ss_state_rdata<=ss_local_data;
process(clk_sys)
 variable r: std_logic_vector(31 downto 0);
begin
 if rising_edge(clk_sys) then
 r := (others=>'0');
 if SS_SEQUENTIAL and ss_state_read='1' then
r := r or ss_extract(shift0,SS_OFFSET,ss_state_addr);
r := r or ss_extract(shift1,SS_OFFSET+8,ss_state_addr);
r := r or ss_extract(shift2,SS_OFFSET+16,ss_state_addr);
r := r or ss_extract(shift3,SS_OFFSET+24,ss_state_addr);
r := r or ss_extract(ss_bool(wideclock),SS_OFFSET+32,ss_state_addr);
 end if;
 ss_local_data <= r;
 end if;
end process;

 ss_sprite_out <= '1' & shift3 & shift2 & shift1 & shift0 when wideclock else '0' & shift3 & shift2 & shift1 & shift0;

	process (clk_sys)	begin
		if rising_edge(clk_sys) then
			if SS_SEQUENTIAL and ss_state_write='1' then
shift0 <= ss_merge(shift0,SS_OFFSET,ss_state_addr,ss_state_wdata);
shift1 <= ss_merge(shift1,SS_OFFSET+8,ss_state_addr,ss_state_wdata);
shift2 <= ss_merge(shift2,SS_OFFSET+16,ss_state_addr,ss_state_wdata);
shift3 <= ss_merge(shift3,SS_OFFSET+24,ss_state_addr,ss_state_wdata);
wideclock <= ss_merge_bool(wideclock,SS_OFFSET+32,ss_state_addr,ss_state_wdata);
elsif ss_regs_set='1' then
if not SS_SEQUENTIAL then
            if ss_sprite_valid='1' then
              shift0<=ss_sprite_in(7 downto 0);shift1<=ss_sprite_in(15 downto 8);
              shift2<=ss_sprite_in(23 downto 16);shift3<=ss_sprite_in(31 downto 24);
              wideclock<=ss_sprite_in(32)='1';
            else
				shift0 <= (others => '0');
				shift1 <= (others => '0');
				shift2 <= (others => '0');
				shift3 <= (others => '0');
				wideclock <= false;
            end if;
			end if;
elsif ce_pix = '1' then
				-- In shifted mode, spr_x=x+8 is an 8-bit comparison.
				-- spr_x=0xFF corresponds to a sprite with VDP X=0, which
				-- should be completely off-screen after the 8-pixel shift.
				-- Do not let the 8-bit comparison wrap it onto the right edge.
				if (spr_x=x and ((load and (m4 or spr_d3(7)='0')) or 
									 (x224 and spr_d3(7)='1'))) or 
					((spr_x=x+8 and x248) and spr_x/=x"FF") then
					shift0 <= spr_d0;
					shift1 <= spr_d1;
					shift2 <= spr_d2;
					shift3 <= spr_d3;
					wideclock <= false ;
				else
					if (wide_n or wideclock) then
						shift0(7 downto 1) <= shift0(6 downto 0);
						if m4 then
							shift0(0) <= '0';
							shift3 <= shift3(6 downto 0)&"0";
						else -- mode 2 we use a 16-bit shift, shift2 is ignored and shift3 retains color 
							shift0(0) <= shift1(7) ;
						end if ;
						shift1 <= shift1(6 downto 0)&"0";
						shift2 <= shift2(6 downto 0)&"0";
					end if ;
					wideclock <= not wideclock ;
				end if;
			end if;
		end if;
	end process;

	process (m4,shift0,shift1,shift2,shift3) begin
		if m4 then
			color <= shift3(7)&shift2(7)&shift1(7)&shift0(7);
			active <= shift3(7) or shift2(7) or shift1(7) or shift0(7);
		else
			if shift0(7)='1' then
				color <= shift3(3 downto 0);
			else
				color <= "0000";
			end if;
			active <= shift0(7) ;
		end if;
	end process;
end Behavioral;
