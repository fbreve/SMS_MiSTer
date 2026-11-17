library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library candidate_work,reference_work;
entity heal_tb is generic(SHIFT:integer:=0;FOLLOW:integer:=142728);end;
architecture test of heal_tb is
 signal clk:std_logic:='0';signal reset_n:std_logic:='0';signal ce:std_logic:='0';
 signal chold,rhold:std_logic:='0';signal cwr,rwr,rd:std_logic:='0';
 signal addr:std_logic_vector(7 downto 0):=x"ff";
 signal wd,cd,rr:std_logic_vector(31 downto 0):=(others=>'0');
 signal busd:std_logic_vector(7 downto 0):=(others=>'0');signal busa:std_logic_vector(15 downto 0):=x"00f0";signal buswr:std_logic:='1';
 signal cy,ry:std_logic_vector(13 downto 0);signal ca,ra:std_logic_vector(12 downto 0);signal cr,ready:std_logic;
 signal checkpoint:integer:=0;signal completed:std_logic:='0';
 type image_type is array(0 to 103) of std_logic_vector(31 downto 0);
 signal image:image_type;
 signal resumed:std_logic:='0';signal elapsed:integer:=0;signal convergence:integer:=0;signal pass_number:integer:=0;
begin
 clk<=not clk after 5 ns;
 u:entity candidate_work.candidate_wrapper port map(clk,reset_n,ce,chold,'0','0','1',busd,busa,buswr,addr,rd,cwr,wd,cd,cr,cy,ca);
 r:entity reference_work.reference_wrapper port map(clk,reset_n,ce,rhold,'0','0','1',busd,busa,buswr,addr,rd,rwr,wd,rr,ready,ry,ra);
 process
  file trace:text open write_mode is "heal_audio_"&integer'image(SHIFT)&".csv";
  variable row:line;variable all_ce:integer:=0;variable expected,first_equal,initial_count:integer;
  variable seen_update:boolean;variable sample:std_logic_vector(31 downto 0);
  procedure host is begin wait until falling_edge(clk);wait for 1 ns;end;
  procedure mark(n:integer) is begin checkpoint<=n;wait for 1 ns;report "CHECKPOINT "&integer'image(n);std.env.stop;checkpoint<=0;wait for 1 ns;end;
  procedure ticks(n:integer;checking:boolean:=false) is begin
   for i in 1 to n loop
    ce<='1';host;all_ce:=all_ce+1;
    if checking then
     elapsed<=elapsed+1;wait for 1 ns;
     if elapsed=expected then seen_update:=true;end if;
     if seen_update then assert cy=ry and ca=ra report "delayed audio divergence" severity failure;end if;
     if cy=ry and first_equal=0 then first_equal:=elapsed;end if;
     if true then -- Preserve every enabled-clock audio pair, not just samples.
      write(row,SHIFT);write(row,string'(","));write(row,pass_number);write(row,string'(","));write(row,elapsed);write(row,string'(","));write(row,to_integer(unsigned(cy)));write(row,string'(","));write(row,to_integer(unsigned(ry)));writeline(trace,row);
     end if;
    end if;
    ce<='0';for j in 1 to 14 loop host;if checking and seen_update then assert cy=ry and ca=ra report "host-clock audio divergence" severity failure;end if;end loop;
   end loop;
  end;
  procedure wr(regnum,value:integer) is begin
   busa<=x"00f0";busd<=std_logic_vector(to_unsigned(regnum,8));buswr<='0';host;host;buswr<='1';ticks(8);
   busa<=x"00f1";busd<=std_logic_vector(to_unsigned(value,8));buswr<='0';host;host;buswr<='1';ticks(160);
  end;
 begin
  host;for i in 1 to 6 loop host;end loop;reset_n<='1';for i in 1 to 130 loop host;end loop;
  assert cr='1' and ready='1' report "initialization failed" severity failure;
  wr(0,16#e1#);wr(1,16#f1#);wr(2,16#10#);wr(3,7);wr(4,16#f4#);wr(5,16#d3#);wr(6,16#25#);wr(7,16#36#);
  for c in 0 to 8 loop wr(16#30#+c,(c*16));wr(16#10#+c,16#81#+c*7);wr(16#20#+c,16#19#);end loop;
  ticks(4000);
  for pass in 0 to 2 loop
   pass_number<=pass;
   if pass=1 then wr(16#20#,9);wr(16#0e#,16#3f#);ticks(500);end if;
   if pass=2 then wr(16#20#,16#19#);wr(16#0e#,16#20#);wr(4,16#94#);ticks(1000);end if;
   ticks((SHIFT+72-((71+all_ce) mod 72)) mod 72);
   chold<='1';rhold<='1';host;
   for i in 0 to 103 loop addr<=std_logic_vector(to_unsigned(i,8));rd<='1';host;image(i)<=rr;assert cd=rr report "pre-save private state mismatch" severity failure;rd<='0';host;end loop;
   addr<=x"ff";host;assert to_integer(unsigned(image(78)))=SHIFT report "phase coverage failed" severity failure;
   for c in 0 to 8 loop
    if pass=1 and c=0 then assert image(c)(12)='0' report "key-off stimulus missing" severity failure;
    else assert image(c)(12)='1' report "key-on stimulus missing" severity failure;end if;
   end loop;
   assert image(9)/=x"00000000" report "custom instrument stimulus missing" severity failure;
   if pass=0 then assert image(84)(5 downto 0)="000000" report "sustain stimulus missing" severity failure;
   elsif pass=1 then assert image(84)(5 downto 0)="111111" report "rhythm stimulus missing" severity failure;
   else assert image(84)(5 downto 0)="100000" report "rhythm release stimulus missing" severity failure;end if;
   report "PASS STIMULUS shift="&integer'image(SHIFT)&" pass="&integer'image(pass)&" egstate="&integer'image(to_integer(unsigned(image(89)(24 downto 23))));
   mark(1);
   chold<='0';wr(16#30#,16#f0#);wr(16#20#,0);ticks(901+pass*97);chold<='1';host;
   mark(2); -- Tcl injects a deliberately unequal stale output before restore.
   for i in 0 to 103 loop addr<=std_logic_vector(to_unsigned(i,8));wd<=image(i);cwr<='1';rwr<='1';host;cwr<='0';rwr<='0';host;end loop;
   addr<=x"ff";for i in 1 to 8 loop host;end loop;
   mark(3);
   initial_count:=to_integer(unsigned(image(78)));expected:=((70-initial_count+72) mod 72)+1;
   convergence<=expected;elapsed<=0;first_equal:=0;seen_update:=false;resumed<='1';all_ce:=SHIFT+1;
   chold<='0';rhold<='0';ticks(expected,true);mark(4);
   assert seen_update and first_equal=expected report "unexpected measured convergence" severity failure;
   ticks(FOLLOW,true);mark(5); -- at least two PAL frames after convergence.
   report "PASS HEAL shift="&integer'image(SHIFT)&" pass="&integer'image(pass)&" convergence_ce="&integer'image(expected)&" first_equal_ce="&integer'image(first_equal)&" followed_ce="&integer'image(FOLLOW);
   resumed<='0';
   -- All subsequent inputs are identical, including fresh envelope/key events.
   wr(16#20#,9);ticks(300);wr(16#20#,16#19#);ticks(300);
   mark(6);
  end loop;
  completed<='1';wait for 1 ns;report "PASS HEAL ALL";std.env.finish;
 end process;
 process begin wait for 1 sec;assert false report "HEAL TIMEOUT" severity failure;end process;
end;
