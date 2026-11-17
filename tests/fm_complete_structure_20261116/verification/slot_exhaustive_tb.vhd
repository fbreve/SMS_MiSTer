library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;use std.env.all;
library candidate_work;library reference_work;
entity slot_exhaustive_tb is end;
architecture test of slot_exhaustive_tb is
 signal clk:std_logic:='0';signal reset:std_logic:='1';signal ce,hold,rd,wr:std_logic:='0';signal addr:std_logic_vector(7 downto 0):=(others=>'0');signal wd:std_logic_vector(31 downto 0):=(others=>'0');
 type slots is array(0 to 3) of std_logic_vector(4 downto 0);type stages is array(0 to 3) of std_logic_vector(1 downto 0);type words is array(0 to 3) of std_logic_vector(31 downto 0);signal ca,ra:slots;signal cb,rb:stages;signal cd,rr:words;
 type ints is array(0 to 3) of integer;constant delays:ints:=(0,2,5,8);
begin
 clk<=not clk after 5 ns;
 g:for i in 0 to 3 generate
 c:entity candidate_work.slotcounter generic map(delay=>delays(i)) port map(clk,reset,ce,ca(i),cb(i),hold,addr,rd,wr,wd,cd(i),open);
 r:entity reference_work.slotcounter generic map(delay=>delays(i)) port map(clk,reset,ce,ra(i),rb(i),hold,addr,rd,wr,wd,rr(i),open);
 end generate;
 process
 procedure tick is begin wait until rising_edge(clk);wait for 1 ns;for i in 0 to 3 loop assert ca(i)=ra(i) and cb(i)=rb(i) and cd(i)=rr(i) report "slotcounter external equivalence" severity failure;end loop;end;
 variable n:integer;
 begin
 tick;reset<='0';hold<='1';addr<=x"4e";wr<='1';rd<='1';
 for x in 0 to 127 loop wd<=std_logic_vector(to_unsigned(x,32));tick;
  for i in 0 to 3 loop if x<delays(i) then n:=x+72-delays(i);else n:=x-delays(i);end if;assert to_integer(unsigned(std_logic_vector'(ca(i)&cb(i))))=n mod 128 report "independent modulo oracle" severity failure;end loop;
 end loop;
 for a in 0 to 255 loop addr<=std_logic_vector(to_unsigned(a,8));wd<=std_logic_vector(to_unsigned((a*29) mod 128,32));tick;end loop;
 wr<='0';rd<='0';hold<='0';ce<='1';for i in 1 to 500 loop tick;end loop;
 ce<='0';for i in 1 to 50 loop tick;end loop;
 reset<='1';tick;reset<='0';tick;
 report "PASS exhaustive slot restore: 128 inputs x4 delays; all256 addresses; hold/read/write/run/reset equivalence";finish;
 end process;
end;

