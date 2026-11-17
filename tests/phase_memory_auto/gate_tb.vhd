library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
library baseline_work; library candidate_work;
entity gate_tb is end;
architecture test of gate_tb is
component PhaseMemory_gate is port(clk,reset:in std_logic;slot:in std_logic_vector(4 downto 0);memwr:in std_logic;memout:out std_logic_vector(17 downto 0);memin:in std_logic_vector(17 downto 0));end component;
signal clk: std_logic:='0'; signal reset: std_logic:='1';
signal slot: std_logic_vector(4 downto 0):=(others=>'0');
signal wr: std_logic:='0'; signal din,qa,qb: std_logic_vector(17 downto 0):=(others=>'U');
begin
a: entity baseline_work.PhaseMemory port map(clk,reset,slot,wr,qa,din);
b: PhaseMemory_gate port map(clk,reset,slot,wr,qb,din);
process
type mem_t is array(0 to 17) of std_logic_vector(17 downto 0);
type counts_t is array(0 to 17) of natural;
variable mem:mem_t:=(others=>(others=>'U'));
variable reads,writes,collisions:counts_t:=(others=>0);
variable init:natural:=0; variable expected,prior:std_logic_vector(17 downto 0):=(others=>'U');
variable cycles,checks,unknown_reads:natural:=0;
variable rng:unsigned(31 downto 0):=x"12345678";
procedure check is begin
 assert qa=qb or is_x(qa) report "RTL pair mismatch" severity failure;
 assert qa=expected report "Independent old-data/latency scoreboard mismatch cycle="&integer'image(cycles) severity failure;
 checks:=checks+1;
end;
procedure tick(addr:natural;we:std_logic;value:natural) is begin
 clk<='0';slot<=std_logic_vector(to_unsigned(addr,5));wr<=we;din<=std_logic_vector(to_unsigned(value mod 262144,18));
 prior:=expected; wait for 2 ns;check; -- read address/data must not propagate asynchronously
 if reset='0' then
  expected:=mem(addr);reads(addr):=reads(addr)+1;
  if is_x(expected) then unknown_reads:=unknown_reads+1;end if;
  if init<18 then
   if init=addr then collisions(addr):=collisions(addr)+1;end if;
   mem(init):=(others=>'0');init:=init+1;
  elsif we='1' then mem(addr):=std_logic_vector(to_unsigned(value mod 262144,18));writes(addr):=writes(addr)+1;collisions(addr):=collisions(addr)+1;
  end if;
 end if;
 clk<='1';cycles:=cycles+1;wait for 1 ns;check;wait for 2 ns;check;
 clk<='0';wait for 1 ns;check;
end;
procedure assert_reset is begin
 clk<='0';reset<='1';init:=0;wait for 1 ns;check;
end;
procedure release_reset is begin reset<='0';wait for 1 ns;check;end;
begin
wait for 1 ns;check;
-- Reset hold; unwritten reads remain U, not coerced to zero.
tick(17,'1',262143);tick(0,'1',1);release_reset;
for i in 0 to 17 loop tick(17-i,'1',1000+i);end loop;
for i in 0 to 17 loop tick(i,'0',0);end loop;
-- All addresses and all payload bit positions, write/read collisions and old-data.
for bitno in 0 to 17 loop
 for i in 0 to 17 loop tick(i,'1',2**bitno);tick(i,'0',0);end loop;
end loop;
-- Interrupt startup after every possible number of initialization writes.
for cut in 0 to 18 loop
 assert_reset;tick(cut mod 18,'1',42);release_reset;
 for i in 1 to cut loop tick((i+cut) mod 18,'1',12345+i);end loop;
 assert_reset; -- short off-edge pulse, memory is retained, output holds
 release_reset;
 for i in 0 to 17 loop tick(i,'1',262143-i);end loop;
 tick(17,'1',123456);tick(17,'0',0);
end loop;
-- Deterministic random traffic with frequent resets, holds, and reset pulses.
for i in 0 to 99999 loop
 rng:=rng xor shift_left(rng,13);rng:=rng xor shift_right(rng,17);rng:=rng xor shift_left(rng,5);
 if i mod 997=0 then assert_reset;tick(i mod 18,'1',i);tick((i+1) mod 18,'0',0);release_reset;end if;
 tick(to_integer(rng(7 downto 0)) mod 18,rng(8),to_integer(rng(26 downto 9)));
end loop;
for i in 0 to 17 loop assert reads(i)>0 and writes(i)>0 and collisions(i)>0 report "Coverage hole" severity failure;end loop;
assert unknown_reads>0 report "Unknown initialization was not exercised" severity failure;
report "PASS mapped candidate vs RTL defined-state equivalence: cycles="&integer'image(cycles)&" checks="&integer'image(checks)&" unknown_reads="&integer'image(unknown_reads)&" all18 read/write/collision addresses;18 payload bits;19 startup interruption cuts";
wait;
end process;
end;
