library ieee;use ieee.std_logic_1164.all;use ieee.std_logic_unsigned.all;use ieee.numeric_std.all;use std.textio.all;use work.audit_pkg.all;
entity search_tb is generic(OMIT:integer:=0;MODE:integer:=0;SHIFT:integer:=0);end;
architecture tb of search_tb is
 signal clk:std_logic:='0';signal reset_n:std_logic:='0';signal reset_dut:std_logic:='0';signal ce,rce:std_logic:='0';signal a,ra:std_logic:='0';signal d,rd:std_logic_vector(7 downto 0):=(others=>'0');signal y,ry:std_logic_vector(13 downto 0);
begin
 clk<=not clk after 5 ns;
 u:entity work.opll port map(xin=>clk,xout=>open,xena=>ce,d=>d,a=>a,cs_n=>'0',we_n=>'0',ic_n=>reset_n and not reset_dut,mixout=>y);
 r:entity work.opll port map(xin=>clk,xout=>open,xena=>rce,d=>rd,a=>ra,cs_n=>'0',we_n=>'0',ic_n=>reset_n,mixout=>ry);
 process
  variable errors,first,n:integer:=0;variable l:line;
  procedure host is begin wait until falling_edge(clk);end;
  procedure ticks(count:integer;reference:boolean:=true) is begin
   for i in 1 to count loop ce<='1';if reference then rce<='1';else rce<='0';end if;host;ce<='0';rce<='0';for j in 1 to 14 loop host;end loop;end loop;
  end;
  procedure wr(addr,data:integer;reference:boolean:=true) is begin
   a<='0';d<=std_logic_vector(to_unsigned(addr,8));if reference then ra<='0';rd<=std_logic_vector(to_unsigned(addr,8));end if;ticks(8,reference);
   a<='1';d<=std_logic_vector(to_unsigned(data,8));if reference then ra<='1';rd<=std_logic_vector(to_unsigned(data,8));end if;ticks(160,reference);
  end;
 begin
  host;for i in 1 to 6 loop host;end loop;reset_n<='1';ticks(100);
  wr(0,16#e1#);wr(1,16#e1#);wr(2,16#10#);wr(3,7);wr(4,16#f4#);wr(5,16#f4#);wr(6,4);wr(7,4);wr(16#30#,0);wr(16#10#,16#91#);wr(16#20#,16#19#);ticks(2000);
  ticks(SHIFT);ce<='0';rce<='0';host;audit_action<=1;host;audit_action<=0;
  -- Both behavioral snapshots are captured without advancing a guest tick.
  -- Naturally evolve only the DUT through legal program writes.
  wr(16#30#,16#f0#,false);wr(16#10#,16#37#,false);ticks(901,false);
  if MODE=2 then
   reset_dut<='1';for i in 1 to 6 loop host;end loop;reset_dut<='0';ticks(100,false);
   wr(0,16#e1#,false);wr(1,16#e1#,false);wr(2,16#10#,false);wr(3,7,false);wr(4,16#f4#,false);wr(5,16#f4#,false);wr(6,4,false);wr(7,4,false);wr(16#30#,0,false);wr(16#10#,16#91#,false);wr(16#20#,16#19#,false);
  else
   a<=ra;d<=rd;audit_omit<=OMIT;audit_action<=2;host;audit_action<=0;
  end if;
  if MODE=3 then ticks(72,false);end if;
  -- Restore omits exactly one category. MODE1 tests a stationary host refill.
  if MODE=1 then for i in 1 to 8 loop host;end loop;end if;
  for i in 0 to 3999 loop
   ce<='1';rce<='1';host;wait for 1 ns;
   if y/=ry then errors:=errors+1;if errors=1 then first:=i*15;end if;end if;
   ce<='0';rce<='0';for j in 1 to 14 loop host;wait for 1 ns;if y/=ry then errors:=errors+1;if errors=1 then first:=i*15+j;end if;end if;end loop;
  end loop;
  report "SEARCH_RESULT omit="&integer'image(OMIT)&" mode="&integer'image(MODE)&" shift="&integer'image(SHIFT)&" errors="&integer'image(errors)&" first="&integer'image(first);
  if OMIT=0 and MODE<2 then assert errors=0 report "full snapshot failed" severity failure;end if;
  report "PASS SEARCH";std.env.finish;
 end process;
end;
