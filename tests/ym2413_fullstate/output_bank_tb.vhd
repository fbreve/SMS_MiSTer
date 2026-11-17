library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
library candidate_work,reference_work;
entity output_bank_tb is end;
architecture test of output_bank_tb is
 signal clk:std_logic:='0';signal reset:std_logic:='1';signal wr,hold,rd,sw:std_logic:='0';
 signal addr,addr2:std_logic_vector(4 downto 0):=(others=>'0');signal data:std_logic_vector(9 downto 0):=(others=>'0');
 signal sa:std_logic_vector(7 downto 0):=x"ff";signal wd,cs,rs:std_logic_vector(31 downto 0):=(others=>'0');signal ci,ri:std_logic;
 signal cq1,cq2:candidate_work.vm2413.SIGNED_LI_TYPE;signal rq1,rq2:reference_work.vm2413.SIGNED_LI_TYPE;
begin
 c:entity candidate_work.OutputMemory port map(clk,reset,wr,addr,(sign=>data(9),value=>data(8 downto 0)),cq1,addr2,cq2,hold,sa,rd,sw,wd,cs,ci);
 r:entity reference_work.OutputMemory port map(clk,reset,wr,addr,(sign=>data(9),value=>data(8 downto 0)),rq1,addr2,rq2,hold,sa,rd,sw,wd,rs,ri);
 process
  type memory_type is array(0 to 18)of std_logic_vector(9 downto 0);variable mem:memory_type:=(others=>(others=>'U'));
  type counts_type is array(0 to 18)of integer;variable write_counts,read1_counts,read2_counts:counts_type:=(others=>0);
  variable expected1,expected2:std_logic_vector(9 downto 0):=(others=>'U');variable initialized:std_logic:='0';
  variable init,cycles,checks,first_collisions,second_collisions,both_collisions,invalid_ss,entry18_checks:integer:=0;
  variable rng:unsigned(31 downto 0):=x"19ab2413";
  procedure check is begin
   assert (cq1.sign&cq1.value)=expected1 and (rq1.sign&rq1.value)=expected1 report "independent first-port registered OLD_DATA" severity failure;
   assert (cq2.sign&cq2.value)=expected2 and (rq2.sign&rq2.value)=expected2 report "independent second-port registered OLD_DATA" severity failure;
   assert ci=initialized and ri=initialized report "independent initialization ready" severity failure;checks:=checks+3;
  end;
  procedure step(a,b,index,value:integer;writing,frozen,savewrite:std_logic) is
   variable active:boolean;variable selected,wa:integer;variable writing_now:boolean;
  begin
   clk<='0';addr<=std_logic_vector(to_unsigned(a,5));addr2<=std_logic_vector(to_unsigned(b,5));sa<=std_logic_vector(to_unsigned(index,8));
   data<=std_logic_vector(to_unsigned(value mod 1024,10));wd<=std_logic_vector(to_unsigned(value,32));wr<=writing;hold<=frozen;sw<=savewrite;rd<=not rd;
   wait for 2 ns;check;active:=frozen='1' and index>=58 and index<=75;selected:=a;if active then selected:=index-58;end if;
   writing_now:=false;wa:=0;
   if reset='0' then
    expected1:=mem(selected);expected2:=mem(b);initialized:='0';if init=18 then initialized:='1';end if;
    read1_counts(selected):=read1_counts(selected)+1;read2_counts(b):=read2_counts(b)+1;
    if frozen='0' then
     if init<18 then wa:=init;mem(wa):=(others=>'0');init:=init+1;writing_now:=true;
     elsif writing='1' then wa:=a;mem(wa):=std_logic_vector(to_unsigned(value mod 1024,10));writing_now:=true;end if;
    elsif active and savewrite='1' then wa:=index-58;mem(wa):=std_logic_vector(to_unsigned(value mod 1024,10));writing_now:=true;
    elsif frozen='1' and (writing='1' or savewrite='1') then invalid_ss:=invalid_ss+1;end if;
    if writing_now then
     write_counts(wa):=write_counts(wa)+1;
     if wa=selected then first_collisions:=first_collisions+1;end if;
     if wa=b then second_collisions:=second_collisions+1;end if;
     if wa=selected and wa=b then both_collisions:=both_collisions+1;end if;
    end if;
    if a=18 or b=18 then entry18_checks:=entry18_checks+1;end if;
   end if;
   clk<='1';wait for 1 ns;cycles:=cycles+1;check;
   if active then assert cs=(21 downto 0=>'0')&expected1 and rs=(21 downto 0=>'0')&expected1 report "independent snapshot value" severity failure;
   else assert cs=x"00000000" and rs=x"00000000" report "invalid/inactive snapshot response" severity failure;end if;
   clk<='0';wait for 1 ns;check;
  end;
  procedure reset_start is begin
   reset<='1';init:=0;initialized:='0';wait for 1 ns;check;reset<='0';
  end;
 begin
  wait for 1 ns;check;reset<='0';
  for i in 0 to 17 loop step(18,18,255,0,'0','0','0');end loop;step(18,18,255,0,'0','0','0');
  assert is_x(expected1) and is_x(expected2) report "entry18 unexpectedly initialized" severity failure;
  -- Entry 18 is declared and normally writable/readable, but is not in snapshot range.
  step(18,18,255,16#355#,'1','0','0');step(18,18,255,0,'0','0','0');assert expected1="1101010101" severity failure;
  -- Initialization: every pair of independent read addresses against all 18 writes.
  for a in 0 to 18 loop for b in 0 to 18 loop
   reset_start;step(a,b,255,0,'1','1','0'); -- hold pauses initialization and pending normal write
   for i in 0 to 17 loop step(a,b,255,1023,'1','0','0');end loop;
   step(18,18,255,0,'0','0','0');assert expected1="1101010101" report "reset/initialization overwrote entry18" severity failure;
  end loop;end loop;
  -- All operational address pairs; signs/extremes and back-to-back read/write.
  for pattern in 0 to 5 loop for a in 0 to 18 loop for b in 0 to 18 loop
   case pattern is when 0=>step(a,b,255,0,'1','0','0');when 1=>step(a,b,255,511,'1','0','0');
    when 2=>step(a,b,255,512,'1','0','0');when 3=>step(a,b,255,1023,'1','0','0');
    when 4=>step(a,b,255,16#155#,'1','0','0');when others=>step(a,b,255,16#2aa#,'1','0','0');end case;
   step(a,b,255,0,'0','0','0');
  end loop;end loop;end loop;
  for index in 58 to 75 loop for b in 0 to 18 loop
   step(18,b,index,1023-(index-58),'1','1','1');step(18,b,index,0,'1','1','0');
   step(18,b,255,512+index,'1','0','0'); -- first raw edge consumes pending normal write
  end loop;end loop;
  for index in 0 to 255 loop if index<58 or index>75 then
   step(18,18,index,index,'1','1','1');step(18,18,255,0,'0','1','0');
  end if;end loop;
  -- No CE exists here: keep a pending write asserted over long raw-clock runs.
  for i in 1 to 4000 loop step(7,i mod 19,255,16#3ff#,'1','0','0');end loop;
  for i in 1 to 4000 loop step(i mod 19,(i/19)mod 19,255,0,'1','1','0');end loop;
  for i in 1 to 12000 loop
   rng:=rng xor shift_left(rng,13);rng:=rng xor shift_right(rng,17);rng:=rng xor shift_left(rng,5);
   if i mod 3=0 then step(i mod 19,(i/19)mod 19,58+i mod 18,to_integer(rng(21 downto 0)),rng(22),'1',rng(23));
   else step(i mod 19,(i/19)mod 19,255,to_integer(rng(21 downto 0)),rng(24),'0','0');end if;
  end loop;
  for i in 0 to 18 loop assert write_counts(i)>0 and read1_counts(i)>0 and read2_counts(i)>0 report "declared entry coverage missing" severity failure;end loop;
  assert first_collisions>0 and second_collisions>0 and both_collisions>0 and invalid_ss>0 and entry18_checks>0 severity failure;
  report "PASS OUTPUT BANK cycles="&integer'image(cycles)&" checks="&integer'image(checks)&" entries=19 r1_collisions="&integer'image(first_collisions)&" r2_collisions="&integer'image(second_collisions)&" both="&integer'image(both_collisions)&" invalid_ss="&integer'image(invalid_ss)&" entry18_checks="&integer'image(entry18_checks);std.env.finish;
 end process;
 process begin wait for 1 ms;assert false report "OUTPUT BANK TIMEOUT" severity failure;end process;
end;
