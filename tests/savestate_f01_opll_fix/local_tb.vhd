library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library original_work;
entity local_tb is generic (SHIFT:integer:=0; STALL:integer:=0; NCE:integer:=4000; LOADS:integer:=3); end;
architecture tb of local_tb is
 signal clk:std_logic:='0'; signal rclk:std_logic;
 signal reset_n:std_logic:='0'; signal ce:std_logic:='0';
 signal runref:std_logic:='1'; signal hold:std_logic:='0';
 signal a,ra:std_logic:='0'; signal d,rd:std_logic_vector(7 downto 0):=(others=>'0');
 signal y,ry:std_logic_vector(13 downto 0);
 signal addr:std_logic_vector(7 downto 0):=(others=>'0');
 signal rdata,wdata:std_logic_vector(31 downto 0):=(others=>'0');
 signal read_en,write_en,initialized:std_logic:='0';
 type memory is array(0 to 103) of std_logic_vector(31 downto 0);
begin
 clk<=not clk after 5 ns; rclk<=clk when runref='1' else '0';
 u:entity work.opll port map(xin=>clk,xout=>open,xena=>ce and not hold,d=>d,a=>a,cs_n=>'0',we_n=>'0',ic_n=>reset_n,mixout=>y,ss_hold=>hold,ss_addr=>addr,ss_read=>read_en,ss_write=>write_en,ss_wdata=>wdata,ss_rdata=>rdata,ss_initialized=>initialized);
 r:entity original_work.opll port map(xin=>rclk,xout=>open,xena=>ce,d=>rd,a=>ra,cs_n=>'0',we_n=>'0',ic_n=>reset_n,mixout=>ry);
 process
  variable image:memory; variable baseline:memory;
  variable errors:integer:=0; variable transaction:integer:=0;
  procedure host is begin wait until falling_edge(clk); wait for 1 ns; end;
  procedure ticks(count:integer) is begin for i in 1 to count loop ce<='1';host;ce<='0';for j in 1 to 14 loop host;end loop;end loop;end;
  procedure wr(regnum,value:integer;both:boolean:=true) is begin a<='0';d<=std_logic_vector(to_unsigned(regnum,8));if both then ra<='0';rd<=std_logic_vector(to_unsigned(regnum,8));end if;ticks(8);a<='1';d<=std_logic_vector(to_unsigned(value,8));if both then ra<='1';rd<=std_logic_vector(to_unsigned(value,8));end if;ticks(160);end;
  procedure capture(variable target:out memory) is begin
   for i in 0 to 103 loop addr<=std_logic_vector(to_unsigned(i,8));read_en<='1';host;target(i):=rdata;read_en<='0';for j in 0 to STALL loop host;end loop;transaction:=transaction+1;end loop;
  end;
  procedure compare(count:integer) is begin
   for i in 0 to count-1 loop ce<='1';host;assert y=ry report "FM mismatch first CE at "&integer'image(i) severity failure;ce<='0';for j in 1 to 14 loop host;assert y=ry report "FM mismatch host at "&integer'image(i*15+j) severity failure;end loop;end loop;
  end;
 begin
  host;for i in 1 to 6 loop host;end loop;reset_n<='1';ticks(100);
  assert initialized='1' report "initializer readiness missing" severity failure;
  wr(0,16#e1#);wr(1,16#e1#);wr(2,16#10#);wr(3,7);wr(4,16#f4#);wr(5,16#f4#);wr(6,4);wr(7,4);wr(16#30#,0);wr(16#10#,16#91#);wr(16#20#,16#19#);ticks(2000+SHIFT);
  ce<='0';hold<='1';runref<='0';capture(image);
  assert transaction=104 report "capture coverage" severity failure;
  read_en<='0';addr<=x"ff";for i in 1 to 8 loop host;end loop;
  hold<='0';runref<='1';compare(NCE);
  report "PASS LOCAL SAVE shift="&integer'image(SHIFT);
  -- Recreate original reference T by restarting both through the saved image.
  hold<='1';runref<='0';capture(baseline);
  for pass in 1 to LOADS loop
   hold<='0';wr(16#30#,16#f0#,false);wr(16#10#,16#37#+pass,false);ticks(901+pass*97);
   hold<='1';host;
   for i in 0 to 103 loop addr<=std_logic_vector(to_unsigned(i,8));wdata<=baseline(i);write_en<='1';host;write_en<='0';for j in 0 to STALL loop host;end loop;end loop;
   addr<=x"ff";a<=ra;d<=rd;for i in 1 to 8 loop host;end loop;
   hold<='0';runref<='1';compare(NCE);report "PASS LOCAL LOAD "&integer'image(pass);
   -- Reference remains at each new endpoint; subsequent repeated LOAD targets
   -- that endpoint, retaining the same independent exact-future comparison.
   hold<='1';runref<='0';capture(baseline);
  end loop;
  report "PASS LOCAL ALL";std.env.finish;
 end process;
end;
