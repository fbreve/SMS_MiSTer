library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
library candidate_work,reference_work;
entity feedback_bank_tb is end;
architecture test of feedback_bank_tb is
 signal clk:std_logic:='0';signal reset:std_logic:='1';signal wr,hold,rd,sw:std_logic:='0';
 signal wa,ra:integer range 0 to 8:=0;signal data:std_logic_vector(9 downto 0):=(others=>'0');
 signal sa:std_logic_vector(7 downto 0):=x"ff";signal wd,cs,rs:std_logic_vector(31 downto 0):=(others=>'0');signal ci,ri:std_logic;
 signal cq:candidate_work.vm2413.SIGNED_LI_TYPE;signal rq:reference_work.vm2413.SIGNED_LI_TYPE;
begin
 c:entity candidate_work.FeedbackMemory port map(clk,reset,wr,wa,(sign=>data(9),value=>data(8 downto 0)),ra,cq,hold,sa,rd,sw,wd,cs,ci);
 r:entity reference_work.FeedbackMemory port map(clk,reset,wr,wa,(sign=>data(9),value=>data(8 downto 0)),ra,rq,hold,sa,rd,sw,wd,rs,ri);
 process
  type memory_type is array(0 to 8)of std_logic_vector(9 downto 0);variable mem:memory_type:=(others=>(others=>'U'));
  type counts_type is array(0 to 8)of integer;variable writes,reads:counts_type:=(others=>0);
  variable expected:std_logic_vector(9 downto 0):=(others=>'U');variable initialized:std_logic:='0';
  variable init,cycles,checks,collisions,snapshot_collisions,invalid_ss,negative_zero:integer:=0;
  variable rng:unsigned(31 downto 0):=x"fb241309";
  procedure check is begin
   assert (cq.sign&cq.value)=expected and (rq.sign&rq.value)=expected report "independent registered OLD_DATA / raw-edge stability" severity failure;
   assert ci=initialized and ri=initialized report "independent initialization ready" severity failure;checks:=checks+2;
  end;
  procedure step(a,b,index,value:integer;writing,frozen,savewrite:std_logic) is
   variable active:boolean;variable selected,w:integer;variable writing_now:boolean;
  begin
   clk<='0';wa<=a;ra<=b;sa<=std_logic_vector(to_unsigned(index,8));data<=std_logic_vector(to_unsigned(value mod 1024,10));wd<=std_logic_vector(to_unsigned(value,32));wr<=writing;hold<=frozen;sw<=savewrite;rd<=not rd;
   wait for 2 ns;check;active:=frozen='1' and index>=49 and index<=57;selected:=b;if active then selected:=index-49;end if;
   writing_now:=false;w:=0;
   if reset='0' then
    expected:=mem(selected);reads(selected):=reads(selected)+1;initialized:='0';if init=9 then initialized:='1';end if;
    if frozen='0' then
     if init<9 then w:=init;mem(w):=(others=>'0');init:=init+1;writing_now:=true;
     elsif writing='1' then w:=a;mem(w):=std_logic_vector(to_unsigned(value mod 1024,10));writing_now:=true;end if;
    elsif active and savewrite='1' then w:=index-49;mem(w):=std_logic_vector(to_unsigned(value mod 1024,10));writing_now:=true;
    elsif frozen='1' and (writing='1' or savewrite='1') then invalid_ss:=invalid_ss+1;end if;
    if writing_now then writes(w):=writes(w)+1;if w=selected then collisions:=collisions+1;if active then snapshot_collisions:=snapshot_collisions+1;end if;end if;end if;
    if expected="1000000000" then negative_zero:=negative_zero+1;end if;
   end if;
   clk<='1';wait for 1 ns;cycles:=cycles+1;check;
   if active then assert cs=(21 downto 0=>'0')&expected and rs=(21 downto 0=>'0')&expected report "independent snapshot value" severity failure;
   else assert cs=x"00000000" and rs=x"00000000" report "invalid/inactive snapshot response" severity failure;end if;
   clk<='0';wait for 1 ns;check;
  end;
  procedure reset_start is begin reset<='1';init:=0;initialized:='0';wait for 1 ns;check;reset<='0';end;
 begin
  wait for 1 ns;check;reset<='0';for i in 0 to 9 loop step(0,i mod 9,255,0,'0','0','0');end loop;
  -- Reset retains array/read register, resets controls asynchronously; all initialization read/write pairs.
  for a in 0 to 8 loop for b in 0 to 8 loop
   reset_start;step(a,b,255,1023,'1','1','0');
   -- Snapshot write while initialization is held, then resume normal clearing.
   step(a,b,49+b,512,'1','1','1');
   for i in 0 to 8 loop step(a,b,255,1023,'1','0','0');end loop;
   step(a,b,255,0,'0','0','0');assert initialized='1' severity failure;
  end loop;end loop;
  for pattern in 0 to 5 loop for a in 0 to 8 loop for b in 0 to 8 loop
   case pattern is when 0=>step(a,b,255,0,'1','0','0');when 1=>step(a,b,255,511,'1','0','0');when 2=>step(a,b,255,512,'1','0','0');when 3=>step(a,b,255,1023,'1','0','0');when 4=>step(a,b,255,341,'1','0','0');when others=>step(a,b,255,682,'1','0','0');end case;
   step(a,b,255,0,'0','0','0');
  end loop;end loop;end loop;
  for index in 49 to 57 loop for b in 0 to 8 loop
   step(b,b,index,512,'1','1','1');step(b,b,index,0,'1','1','0');step(b,b,255,1023,'1','0','0');
  end loop;end loop;
  for index in 0 to 255 loop if index<49 or index>57 then step(0,0,index,index,'1','1','1');step(0,0,255,0,'0','1','0');end if;end loop;
  for i in 1 to 4000 loop step(7,i mod 9,255,1023,'1','0','0');end loop;
  for i in 1 to 4000 loop step(i mod 9,(i/9)mod 9,255,0,'1','1','0');end loop;
  for i in 1 to 12000 loop
   rng:=rng xor shift_left(rng,13);rng:=rng xor shift_right(rng,17);rng:=rng xor shift_left(rng,5);
   if i mod 3=0 then step(i mod 9,(i/9)mod 9,49+i mod 9,to_integer(rng(21 downto 0)),rng(22),'1',rng(23));else step(i mod 9,(i/9)mod 9,255,to_integer(rng(21 downto 0)),rng(24),'0','0');end if;
  end loop;
  for i in 0 to 8 loop assert writes(i)>0 and reads(i)>0 report "entry coverage" severity failure;end loop;
  assert collisions>0 and snapshot_collisions>0 and invalid_ss>0 and negative_zero>0 severity failure;
  report "PASS FEEDBACK BANK cycles="&integer'image(cycles)&" checks="&integer'image(checks)&" entries=9 collisions="&integer'image(collisions)&" snapshot_collisions="&integer'image(snapshot_collisions)&" invalid_ss="&integer'image(invalid_ss)&" negative_zero="&integer'image(negative_zero);std.env.finish;
 end process;
 process begin wait for 1 ms;assert false report "FEEDBACK BANK TIMEOUT" severity failure;end process;
end;
