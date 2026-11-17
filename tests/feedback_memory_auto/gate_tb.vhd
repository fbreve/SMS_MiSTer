library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
library baseline_work;library candidate_work;
entity gate_tb is end;
architecture test of gate_tb is
component FeedbackMemory_gate is port(clk,reset,wr:in std_logic;waddr:in std_logic_vector(3 downto 0);wdata:in std_logic_vector(9 downto 0);raddr:in std_logic_vector(3 downto 0);rdata:out std_logic_vector(9 downto 0));end component;
signal clk:std_logic:='0';signal reset:std_logic:='1';signal wr:std_logic:='0';
signal wa,ra:std_logic_vector(3 downto 0):=(others=>'0');signal din,qa,qb:std_logic_vector(9 downto 0):=(others=>'U');
begin
a:entity baseline_work.FeedbackMemory_flat port map(clk,reset,wr,wa,din,ra,qa);
b:FeedbackMemory_gate port map(clk,reset,wr,wa,din,ra,qb);
process
type mem_t is array(0 to 8)of std_logic_vector(9 downto 0);variable mem:mem_t:=(others=>(others=>'U'));
type cov_t is array(0 to 8,0 to 8,0 to 1023)of boolean;variable covered:cov_t:=(others=>(others=>(others=>false)));
variable init,cycles,checks,unknown_reads:natural:=0;variable expected:std_logic_vector(9 downto 0):=(others=>'U');variable rng:unsigned(31 downto 0):=x"29384756";
procedure check is begin assert qa=qb or is_x(qa) report "pair mismatch" severity failure;assert qa=expected report "old-data/latency scoreboard mismatch cycle="&integer'image(cycles) severity failure;checks:=checks+1;end;
procedure tick(w,r:natural;we:std_logic;value:natural)is begin
clk<='0';wa<=std_logic_vector(to_unsigned(w,4));ra<=std_logic_vector(to_unsigned(r,4));wr<=we;din<=std_logic_vector(to_unsigned(value mod 1024,10));wait for 2 ns;check;
if reset='0' then expected:=mem(r);if is_x(expected)then unknown_reads:=unknown_reads+1;end if;
if init<9 then mem(init):=(others=>'0');init:=init+1;elsif we='1'then mem(w):=std_logic_vector(to_unsigned(value mod 1024,10));covered(w,r,value mod 1024):=true;end if;end if;
clk<='1';cycles:=cycles+1;wait for 1 ns;check;wait for 2 ns;check;clk<='0';wait for 1 ns;check;
end;
procedure rst is begin clk<='0';reset<='1';init:=0;wait for 1 ns;check;end;
procedure release_reset is begin reset<='0';wait for 1 ns;check;end;
begin wait for 1 ns;check;tick(8,8,'1',1023);release_reset;
for i in 0 to 8 loop tick(i,8-i,'1',1023);end loop;
for w in 0 to 8 loop for r in 0 to 8 loop for value in 0 to 1023 loop tick(w,r,'1',value);tick(w,r,'0',0);end loop;end loop;end loop;
for cut in 0 to 9 loop rst;tick(cut mod 9,(cut+1)mod 9,'1',1023);release_reset;for i in 1 to cut loop tick(i mod 9,(i+cut)mod 9,'1',i);end loop;rst;release_reset;for i in 0 to 8 loop tick(i,i,'1',1023-i);end loop;tick(8,8,'1',1023);tick(0,8,'0',0);end loop;
for i in 0 to 49999 loop rng:=rng xor shift_left(rng,13);rng:=rng xor shift_right(rng,17);rng:=rng xor shift_left(rng,5);if i mod 997=0 then rst;tick(0,8,'1',i);release_reset;end if;tick(to_integer(rng(7 downto 0))mod 9,to_integer(rng(15 downto 8))mod 9,rng(16),to_integer(rng(26 downto 17)));end loop;
for w in 0 to 8 loop for r in 0 to 8 loop for v in 0 to 1023 loop assert covered(w,r,v)report "exhaustive port/payload coverage hole" severity failure;end loop;end loop;end loop;
assert unknown_reads>0 report "startup unknown coverage missing"severity failure;
report "PASS mapped bank equivalence: cycles="&integer'image(cycles)&" checks="&integer'image(checks)&" unknown_reads="&integer'image(unknown_reads)&" all81 port pairs x1024 payloads xwrite/read phases;10 reset interruption cuts";wait;
end process;end;
