library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
entity gg_tb is generic(expect_fixed:boolean:=false);end;architecture test of gg_tb is
signal clk:std_logic:='0';signal rst1,rst2,ce1,ce2,load,freeze1,freeze2:std_logic:='0';
signal wr1,wr2,rd:std_logic:='1';signal addr,din,data1,data2:std_logic_vector(7 downto 0):=(others=>'0');
signal link,pins1,pins2:std_logic_vector(6 downto 0):=(others=>'1');signal nmi1,nmi2:std_logic;
signal state1,state2,saved:std_logic_vector(31 downto 0);
signal ggstate1,ggstate2,ggsaved:std_logic_vector(127 downto 0);
begin clk<=not clk after 5 ns;dut:entity work.io port map(clk => clk,
ce_cpu => ce1,
WR_n => wr1,
RD_n => rd,
A => addr,
D_in => din,
D_out => data1,
HL_out => open,
vdp1_bank => open,
vdp2_bank => open,
vdp_cpu_bank => open,
rom_bank => open,
J1_tr_out => open,
J1_th_out => open,
J2_tr_out => open,
J2_th_out => open,
J1_up => '0',
J1_down => '0',
J1_left => '0',
J1_right => '0',
J1_tl => '0',
J1_tr => '0',
J1_th => '0',
j1_start => '0',
j1_coin => '0',
j1_a3 => '0',
J2_up => '0',
J2_down => '0',
J2_left => '0',
J2_right => '0',
J2_tl => '0',
J2_tr => '0',
J2_th => '0',
j2_start => '0',
j2_coin => '0',
j2_a3 => '0',
Pause => '0',
soft_reset => '0',
E0Type => (others=>'0'),
E1Use => '0',
E2Use => '0',
E0 => (others=>'0'),
F2 => (others=>'0'),
F3 => (others=>'0'),
has_paddle => '0',
has_pedal => '0',
paddle => (others=>'0'),
paddle2 => (others=>'0'),
pedal => (others=>'0'),
palettemode => '0',
sc3000_en => '0',
sc_multicart_en => '0',
sc_megacart_en => '0',
sk1100_en => '0',
sc_multicart_page => open,
sk1100_row_sel => open,
sk1100_row_data => (others=>'0'),
pal => '0',
gg => '1',
gg_link_en => '1',
gg_link_in => link,
gg_link_out => pins1,
gg_link_nmi_n => nmi1,
systeme => '0',
region => '0',
se_mapper_in => (others=>'0'),
se_mapper_set => '0',
vdp_enables => (others=>'0'),
psg_enables => (others=>'0'),
gg_state_out => ggstate1,
gg_state_in => ggsaved,
gg_state_set => load,
io_state_out => state1,
io_state_in => saved,
io_state_set => load,
mapper_evolution_force => '0',
evolution_menu_io => '0',
evolution_bank61 => (others=>'0'),
evolution_bank62 => (others=>'0'),
evolution_reg8c => (others=>'0'),
evolution_regcd => (others=>'0'),
evolution_reg63 => (others=>'0'),
evolution_reg88 => (others=>'0'),
evolution_reg8d => (others=>'0'),
evolution_reg8e => (others=>'0'),
evolution_reg8f => (others=>'0'),
ss_freeze => freeze1,
RESET_n => rst1); reference:entity work.io port map(clk => clk,
ce_cpu => ce2,
WR_n => wr2,
RD_n => rd,
A => addr,
D_in => din,
D_out => data2,
HL_out => open,
vdp1_bank => open,
vdp2_bank => open,
vdp_cpu_bank => open,
rom_bank => open,
J1_tr_out => open,
J1_th_out => open,
J2_tr_out => open,
J2_th_out => open,
J1_up => '0',
J1_down => '0',
J1_left => '0',
J1_right => '0',
J1_tl => '0',
J1_tr => '0',
J1_th => '0',
j1_start => '0',
j1_coin => '0',
j1_a3 => '0',
J2_up => '0',
J2_down => '0',
J2_left => '0',
J2_right => '0',
J2_tl => '0',
J2_tr => '0',
J2_th => '0',
j2_start => '0',
j2_coin => '0',
j2_a3 => '0',
Pause => '0',
soft_reset => '0',
E0Type => (others=>'0'),
E1Use => '0',
E2Use => '0',
E0 => (others=>'0'),
F2 => (others=>'0'),
F3 => (others=>'0'),
has_paddle => '0',
has_pedal => '0',
paddle => (others=>'0'),
paddle2 => (others=>'0'),
pedal => (others=>'0'),
palettemode => '0',
sc3000_en => '0',
sc_multicart_en => '0',
sc_megacart_en => '0',
sk1100_en => '0',
sc_multicart_page => open,
sk1100_row_sel => open,
sk1100_row_data => (others=>'0'),
pal => '0',
gg => '1',
gg_link_en => '1',
gg_link_in => link,
gg_link_out => pins2,
gg_link_nmi_n => nmi2,
systeme => '0',
region => '0',
se_mapper_in => (others=>'0'),
se_mapper_set => '0',
vdp_enables => (others=>'0'),
psg_enables => (others=>'0'),
gg_state_out => ggstate2,
gg_state_in => ggsaved,
gg_state_set => '0',
io_state_out => state2,
io_state_in => saved,
io_state_set => '0',
mapper_evolution_force => '0',
evolution_menu_io => '0',
evolution_bank61 => (others=>'0'),
evolution_bank62 => (others=>'0'),
evolution_reg8c => (others=>'0'),
evolution_regcd => (others=>'0'),
evolution_reg63 => (others=>'0'),
evolution_reg88 => (others=>'0'),
evolution_reg8d => (others=>'0'),
evolution_reg8e => (others=>'0'),
evolution_reg8f => (others=>'0'),
ss_freeze => freeze2,
RESET_n => rst2);
process
variable mismatches,total,divisor,age,which,position:integer:=0;
procedure tick is begin wait until rising_edge(clk);wait for 1 ns;end;
procedure put(a,d:integer;both:boolean:=true) is begin ce1<='0';ce2<='0';addr<=std_logic_vector(to_unsigned(a,8));din<=std_logic_vector(to_unsigned(d,8));wr1<='0';if both then wr2<='0';end if;tick;wr1<='1';wr2<='1';tick;end;
procedure compare is begin
if pins1/=pins2 or nmi1/=nmi2 or ggstate1/=ggstate2 or state1/=state2 then mismatches:=mismatches+1;end if;
end;
procedure get(a:integer) is begin ce1<='0';ce2<='0';addr<=std_logic_vector(to_unsigned(a,8));rd<='0';tick;tick;if data1/=data2 then mismatches:=mismatches+1;report "port "&integer'image(a)&" DUT="&integer'image(to_integer(unsigned(data1)))&" reference="&integer'image(to_integer(unsigned(data2)));end if;rd<='1';tick;end;
procedure external_at(t,d:integer;bad:boolean) is variable b:integer;variable sample:std_logic;begin
b:=t/(d+1);sample:='1';if b=0 then sample:='0';elsif b<=8 then if ((16#5A#/(2**(b-1))) mod 2)=0 then sample:='0';end if;elsif b=9 and bad then sample:='0';end if;
link<=(others=>'1');link(5)<=sample;if t>=7 then link(6)<='0';end if;
end;
begin
for baud in 0 to 3 loop
case baud is when 0=>divisor:=745;when 1=>divisor:=1491;when 2=>divisor:=2982;when others=>divisor:=11931;end case;
for phase in 0 to 5 loop
mismatches:=0;rst1<='0';rst2<='0';freeze1<='0';freeze2<='0';link<=(others=>'1');rd<='1';tick;rst1<='1';rst2<='1';tick;
put(2,0);put(1,16#35#);put(2,16#40#);put(5,baud*64+16#38#);put(3,16#A6#);put(3,16#93#);
case phase is when 0=>age:=0;when 1=>age:=divisor/2;when 2=>age:=3*(divisor+1)+1;when 3=>age:=7*(divisor+1)+13;when 4=>age:=11*(divisor+1)+4;when others=>age:=23*(divisor+1)+4;end case;
for t in 0 to age loop external_at(t,divisor,(phase mod 2)=1);ce1<='1';ce2<='1';tick;end loop;
ce1<='0';ce2<='0';freeze1<='1';freeze2<='1';tick;saved<=state1;ggsaved<=ggstate1;tick;
-- Perturb only the DUT using reset and normal writes; never force protocol state.
rst1<='0';tick;rst1<='1';freeze1<='0';tick;put(2,0,false);put(1,16#6A#,false);put(2,16#FF#,false);put(3,16#55#,false);
freeze1<='1';load<='1';tick;load<='0';tick;
-- Even with a held guest RX read, freeze must preserve restored status.
addr<=x"04";rd<='0';for t in 0 to 3 loop tick;compare;end loop;rd<='1';tick;
freeze1<='0';freeze2<='0';tick;compare;
get(1);get(2);get(3);get(5);get(4); -- status before RX-data read/clear
for t in age+1 to age+24*(divisor+1) loop external_at(t,divisor,(phase mod 2)=1);ce1<='1';ce2<='1';tick;compare;end loop;
ce1<='0';ce2<='0';get(5);get(4);
if expect_fixed then assert mismatches=0 report "replay divergence baud="&integer'image(baud)&" phase="&integer'image(phase)&" mismatches="&integer'image(mismatches) severity failure;
else assert mismatches>0 report "expected omission not reached" severity failure;end if;
report "CASE baud="&integer'image(baud)&" phase="&integer'image(phase)&" differences="&integer'image(mismatches);total:=total+mismatches;
-- Save the evolved point and load again without resetting the reference.
ce1<='0';ce2<='0';freeze1<='1';freeze2<='1';tick;saved<=state1;ggsaved<=ggstate1;tick;
freeze1<='0';put(1,16#6A#,false);freeze1<='1';load<='1';tick;load<='0';tick;compare;
assert mismatches=0 report "repeated save/load mismatch" severity failure;
freeze1<='0';freeze2<='0';tick;
-- A reset and a new transaction after restore must remain equivalent.
rst1<='0';rst2<='0';tick;rst1<='1';rst2<='1';tick;put(5,16#10#);put(3,16#81#);ce1<='1';ce2<='1';for t in 0 to 18000 loop tick;compare;end loop;
if expect_fixed then assert mismatches=0 report "reset/new transaction mismatch" severity failure;end if;
end loop;end loop;
if expect_fixed then report "PASS F02 local replay: 24 baud/phase/error/status/NMI scenarios";else report "REPRODUCED F02 omissions: 24 scenarios total differences="&integer'image(total);end if;
std.env.stop;wait;end process;end;
