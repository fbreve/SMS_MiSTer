library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
library baseline_work;library mapped_work;
entity fm_gate_tb is end;
architecture test of fm_gate_tb is
signal clk:std_logic:='0';signal ic,ce,cs,we,addr:std_logic:='1';
signal data:std_logic_vector(7 downto 0):=(others=>'0');
signal qa,qb:std_logic_vector(13 downto 0);
begin
a:entity baseline_work.opll port map(clk,open,ce,data,addr,cs,we,ic,qa);
b:entity mapped_work.opll port map(clk,open,ce,data,addr,cs,we,ic,qb);
process
variable cycles,known,nonzero,pauses:natural:=0;
variable rng:unsigned(31 downto 0):=x"a58109ef";
procedure tick(n:natural) is begin
 for i in 1 to n loop
  clk<='0';wait for 3 ns;assert qa=qb report "OPLL off-edge mismatch" severity failure;
  clk<='1';wait for 3 ns;cycles:=cycles+1;
  assert qa=qb report "OPLL cycle mismatch at "&integer'image(cycles) severity failure;
  if not is_x(qa) then known:=known+1;if unsigned(qa)/=0 then nonzero:=nonzero+1;end if;end if;
 end loop;
end;
procedure regwrite(a,v:natural) is begin
 ce<='1';cs<='0';we<='0';addr<='0';data<=std_logic_vector(to_unsigned(a,8));tick(2);
 addr<='1';data<=std_logic_vector(to_unsigned(v mod 256,8));tick(8);
 cs<='1';we<='1';tick(80);
end;
begin
ic<='0';cs<='1';we<='1';tick(4);ic<='1';tick(300);
for program in 0 to 15 loop
 for ch in 0 to 8 loop
  regwrite(16+ch,40+ch*19);regwrite(32+ch,16+((ch mod 7)*2)+1);regwrite(48+ch,program*16+(ch mod 8));
 end loop;
 tick(20000);
 -- Freeze/unfreeze at different pipeline phases, as ce_cpu is gated by savestates.
 for phase in 0 to 71 loop
  tick(phase+1);ce<='0';tick(1+(phase mod 31));ce<='1';tick(73);pauses:=pauses+1;
 end loop;
 for ch in 0 to 8 loop regwrite(32+ch,(ch mod 7)*2);end loop;tick(3000);
end loop;
-- User instrument, all rhythm keys, mode changes, irregular clock enables.
for r in 0 to 7 loop regwrite(r,(r*37+91) mod 256);end loop;
for rhythm in 0 to 31 loop regwrite(14,32+rhythm);tick(5000);end loop;
for i in 0 to 149999 loop
 rng:=rng xor shift_left(rng,13);rng:=rng xor shift_right(rng,17);rng:=rng xor shift_left(rng,5);
 ce<=rng(0);tick(1);
end loop;
-- Repeated reset during operation/startup, with paused enables.
for cut in 0 to 18 loop
 ic<='0';ce<='0';tick(1+(cut mod 3));ic<='1';tick(cut);ic<='0';tick(2);ic<='1';ce<='1';tick(400);
 regwrite(48,16);regwrite(16,100+cut);regwrite(32,25);tick(3000);
end loop;
assert known>500000 and nonzero>10000 report "Vacuous audio coverage" severity failure;
report "PASS full OPLL with mapped candidate FeedbackMemory: cycles="&integer'image(cycles)&" known="&integer'image(known)&" nonzero="&integer'image(nonzero)&" freeze_phases="&integer'image(pauses)&" instruments=16 channels=9 rhythm_keys=32 reset_cuts=19";
wait;
end process;
end;
