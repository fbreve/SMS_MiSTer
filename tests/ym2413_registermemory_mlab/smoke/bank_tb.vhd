library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
library candidate_work,reference_work;
entity bank_tb is end;
architecture test of bank_tb is
 signal clk:std_logic:='0';signal reset:std_logic:='1';
 signal a:std_logic_vector(3 downto 0):=(others=>'0');signal we,hold,rd,sw:std_logic:='0';
 signal din,cq,rq:std_logic_vector(23 downto 0):=(others=>'U');
 signal sa:std_logic_vector(7 downto 0):=x"ff";signal wd,cs,rs:std_logic_vector(31 downto 0):=(others=>'0');signal ci,ri:std_logic;
begin
 c:entity candidate_work.RegisterMemory port map(clk,reset,a,we,din,cq,hold,sa,rd,sw,wd,cs,ci);
 r:entity reference_work.RegisterMemory port map(clk,reset,a,we,din,rq,hold,sa,rd,sw,wd,rs,ri);
 process
  type mem_type is array(0 to 8) of std_logic_vector(23 downto 0);
  type counts_type is array(0 to 8) of integer;
  variable mem:mem_type:=(others=>(others=>'U'));
  variable normal_writes,snapshot_writes,collisions:counts_type:=(others=>0);
  variable expected:std_logic_vector(23 downto 0):=(others=>'U');variable initialized:std_logic:='0';
  variable init,cycles,checks:integer:=0;variable rng:unsigned(31 downto 0):=x"2413a170";
  function packed(v:std_logic_vector(23 downto 0)) return std_logic_vector is begin return (9 downto 0=>'0')&v(23 downto 16)&v(13 downto 0);end;
  procedure check is begin
   assert cq=rq and cq=expected report "independent registered old-data scoreboard" severity failure;
   assert ci=ri and ci=initialized report "independent initialization readiness" severity failure;
   checks:=checks+1;
  end;
  procedure step(address,index,value:integer;writing,frozen,savewrite:std_logic) is
   variable active:boolean;variable selected:integer;variable value32:std_logic_vector(31 downto 0);
  begin
   clk<='0';a<=std_logic_vector(to_unsigned(address,4));sa<=std_logic_vector(to_unsigned(index,8));
   din<=std_logic_vector(to_unsigned(value mod 16777216,24));wd<=std_logic_vector(to_unsigned(value,32));we<=writing;hold<=frozen;sw<=savewrite;rd<='1';
   wait for 2 ns;check; -- address and data changes must not affect registered q
   active:=frozen='1' and index<=8;selected:=address;if active then selected:=index;end if;
   if reset='0' then
    expected:=mem(selected);initialized:='0';if init=9 then initialized:='1';end if;
    if frozen='0' then
     if init<9 then mem(init):=(others=>'0');init:=init+1;
     elsif writing='1' then mem(address):=std_logic_vector(to_unsigned(value mod 16777216,24));normal_writes(address):=normal_writes(address)+1;collisions(address):=collisions(address)+1;end if;
    elsif active and savewrite='1' then value32:=std_logic_vector(to_unsigned(value,32));mem(index):=value32(21 downto 14)&"00"&value32(13 downto 0);snapshot_writes(index):=snapshot_writes(index)+1;collisions(index):=collisions(index)+1;end if;
   end if;
   clk<='1';wait for 1 ns;cycles:=cycles+1;check;
   if active then assert cs=packed(expected) and rs=packed(expected) report "independent snapshot packing" severity failure;
   else assert cs=x"00000000" and rs=x"00000000" report "inactive snapshot response" severity failure;end if;
   clk<='0';wait for 1 ns;check;
  end;
 begin
  wait for 1 ns;check;reset<='0';
  for i in 0 to 8 loop step(i,255,0,'0','0','0');end loop;step(0,255,0,'0','0','0');
  for i in 0 to 8 loop
   step(i,255,16#805500#+i,'1','0','0');step(i,255,0,'0','0','0');
   step(i,i,16#3fffff#-i,'1','1','1'); -- SS data must win over pending normal write
   step(i,i,0,'1','1','0'); -- frozen normal write must not change restored RAM
   step(i,255,16#123400#+i,'1','0','0'); -- first raw unfreeze edge consumes pending write
   step(i,255,0,'0','0','0');
  end loop;
  -- Long frozen interval, including invalid SS addresses and repeated pending WE.
  for i in 1 to 4000 loop step(i mod 9,255,i,'1','1','0');end loop;
  for i in 1 to 12000 loop
   rng:=rng xor shift_left(rng,13);rng:=rng xor shift_right(rng,17);rng:=rng xor shift_left(rng,5);
   if i mod 3=0 then step(i mod 9,(i/3) mod 9,to_integer(rng(21 downto 0)),rng(22),'1',rng(23));
   else step(i mod 9,255,to_integer(rng(23 downto 0)),rng(24),'0','0');end if;
  end loop;
  -- Reset starts initialization without clearing memory asynchronously; hold pauses it.
  reset<='1';init:=0;initialized:='0';wait for 1 ns;check;reset<='0';
  for i in 1 to 100 loop step(i mod 9,255,i,'1','1','0');end loop;
  for i in 0 to 8 loop step(i,255,0,'0','0','0');end loop;step(0,255,0,'0','0','0');
  for i in 0 to 8 loop assert normal_writes(i)>0 and snapshot_writes(i)>0 and collisions(i)>0 report "missing per-channel coverage" severity failure;end loop;
  report "PASS BANK ALL cycles="&integer'image(cycles)&" independent_checks="&integer'image(checks)&" channels=9";std.env.finish;
 end process;
 process begin wait for 1 ms;assert false report "BANK TIMEOUT" severity failure;end process;
end;
