 -- Continuous architectural equality, including every raw edge after unfreeze.
 postponed process(all_equal,checking,candidate_work.vm2413.verify_delays,reference_work.vm2413.verify_delays,candidate_work.vm2413.verify_factory_voices,reference_work.vm2413.verify_factory_voices)
 begin if checking='1' then
  assert all_equal=(all_equal'range=>'1') report "EXACT architectural divergence" severity failure;
  assert candidate_work.vm2413.verify_delays=reference_work.vm2413.verify_delays report "delay counter divergence" severity failure;
  assert candidate_work.vm2413.verify_factory_voices=reference_work.vm2413.verify_factory_voices report "factory voices divergence" severity failure;
 end if;end process;
 process
  type counts_type is array(0 to 8) of integer;
  variable hosts,enabled,checks,loads:integer:=0;
  variable expected:image_type;
  variable follow_start:time;
  type ints is array(natural range <>) of integer;
  constant offsets:ints:=(2000,8000,20000,50000,100000,150000,250000,300000,350000);
  constant regs:ints:=(16#20#,16#20#,16#0e#,4,16#0e#,0,16#21#,16#21#,16#0e#);
  constant values:ints:=(9,16#19#,16#3f#,16#94#,16#20#,16#21#,9,16#19#,16#35#);
  variable event_count,verified_events:integer:=0;
  procedure host is begin
   wait until falling_edge(clk);wait for 1 ns;hosts:=hosts+1;
   if checking='1' then
    assert cy=ry and ca=ra report "EXACT audio mismatch raw edge" severity failure;
    assert all_equal=(all_equal'range=>'1') report "EXACT state mismatch raw edge" severity failure;
    checks:=checks+1;
   end if;
  end;
  procedure ticks(n:integer) is begin
   for i in 1 to n loop ce<='1';host;enabled:=enabled+1;ce<='0';for j in 1 to 14 loop host;end loop;end loop;
  end;
  procedure wr(regnum,value:integer) is begin
   busa<=x"00f0";busd<=std_logic_vector(to_unsigned(regnum,8));buswr<='0';host;host;buswr<='1';ticks(8);
   busa<=x"00f1";busd<=std_logic_vector(to_unsigned(value,8));buswr<='0';host;host;buswr<='1';ticks(160);
  end;
  procedure exact is begin
   for i in 0 to 103 loop assert oracle_word(true,i)=oracle_word(false,i) report "independent full-state comparison" severity failure;end loop;
   assert cy=ry and ca=ra report "audio checkpoint" severity failure;
  end;
  procedure check_event(i:integer) is begin
   case i is
    when 0=>assert r_observe_0(12)='0' report "key-off effect missing" severity failure;
    when 1=>assert r_observe_0(12)='1' report "key-on effect missing" severity failure;
    when 2=>assert r_observe_84(5 downto 0)="111111" report "rhythm enable missing" severity failure;
    when 3=>assert r_observe_9(15 downto 8)=x"94" report "custom AR/DR missing" severity failure;
    when 4=>assert r_observe_84(5 downto 0)="100000" report "rhythm change missing" severity failure;
    when 5=>assert r_observe_9(31 downto 28)=x"1" and r_observe_10(3 downto 0)=x"2" report "custom flags missing" severity failure;
    when 6=>assert r_observe_1(12)='0' report "second key-off missing" severity failure;
    when 7=>assert r_observe_1(12)='1' report "second key-on missing" severity failure;
    when 8=>assert r_observe_84(5 downto 0)="110101" report "percussion change missing" severity failure;
    when others=>assert false severity failure;
   end case;verified_events:=verified_events+1;
  end;
 begin
  for i in 1 to 7 loop host;end loop;reset_n<='1';for i in 1 to 130 loop host;end loop;
  assert cr='1' and ready='1' report "initialization timeout" severity failure;
  wr(0,16#e1#);wr(1,16#f1#);wr(2,16#10#);wr(3,7);wr(4,16#f4#);wr(5,16#d3#);wr(6,16#25#);wr(7,16#36#);
  for c in 0 to 8 loop wr(16#30#+c,c*16);wr(16#10#+c,16#81#+c*7);wr(16#20#+c,16#19#);end loop;ticks(4000);
  checking<='1';host;
  for c in 0 to 8 loop
   assert unsigned(oracle_word(false,c)(21 downto 18))=to_unsigned(c,4) report "independent instrument entry" severity failure;
   assert oracle_word(false,c)(7 downto 0)=std_logic_vector(to_unsigned(16#81#+c*7,8)) report "independent fnum entry" severity failure;
   assert oracle_word(false,c)(12)='1' report "independent key entry" severity failure;
  end loop;
  report "PASS NINE INDEPENDENT REGISTER ENTRIES";
  for pass in 0 to 1 loop
   pass_number<=pass;
   if pass=1 then wr(16#20#,9);wr(16#0e#,16#3f#);wr(4,16#94#);end if;
   -- Launch an instrument write shortly before SAVE and preserve any pending stage.
   busa<=x"00f0";busd<=x"30";buswr<='0';host;host;buswr<='1';ticks(8);
   busa<=x"00f1";busd<=std_logic_vector(to_unsigned((SHIFT mod 15+1)*16,8));buswr<='0';host;host;buswr<='1';
   ticks((SHIFT+72-((71+enabled) mod 72)) mod 72);
   chold<='1';rhold<='1';host;
   assert to_integer(unsigned(r_observe_78))=SHIFT report "72 phase coverage" severity failure;
   for i in 0 to 103 loop addr<=std_logic_vector(to_unsigned(i,8));rd<='1';host;image(i)<=rr;rd<='0';host;end loop;
   addr<=x"ff";host;
   for i in 0 to 103 loop expected(i):=oracle_word(false,i);assert not is_x(expected(i)) report "unknown saved state" severity failure;assert image(i)=expected(i) report "capture versus independent internal oracle" severity failure;end loop;
   report "PASS SAVE shift="&integer'image(SHIFT)&" pass="&integer'image(pass)&" pending="&std_logic'image(expected(83)(4))&" envelope="&integer'image(to_integer(unsigned(expected(89)(24 downto 23))));
   -- Independent candidate evolution must really change the state before LOAD.
   checking<='0';chold<='0';wr(16#30#,16#f0#);wr(16#20#,0);ticks(901+pass*97);chold<='1';host;
   assert c_observe_0/=expected(0) report "no meaningful pre-LOAD corruption" severity failure;
   for i in 0 to 103 loop addr<=std_logic_vector(to_unsigned(i,8));wd<=image(i);cwr<='1';rwr<='1';host;cwr<='0';rwr<='0';host;end loop;
   addr<=x"ff";for i in 1 to 8 loop host;end loop;
   for i in 0 to 103 loop assert oracle_word(false,i)=expected(i) and oracle_word(true,i)=expected(i) report "independent exact restoration" severity failure;end loop;
   exact;loads:=loads+1;enabled:=SHIFT+1;
   checking<='1';chold<='0';rhold<='0';host; -- first raw edge, CE is still low
   for i in 1 to 1000 loop host;end loop; -- long CE gap, pending writes may repeat
   exact;wr(16#30#,(pass+1)*16); -- immediate post-LOAD instrument change
   assert r_observe_0(21 downto 18)=std_logic_vector(to_unsigned(pass+1,4)) report "post-LOAD instrument write missing" severity failure;
   follow_start:=now;event_count:=0;verified_events:=0;
   for k in 1 to 411000 loop
    ce<='1';host;enabled:=enabled+1;ce<='0';
    for j in 1 to 14 loop
     if j=1 and event_count<9 then
      if k=offsets(event_count) then busa<=x"00f0";busd<=std_logic_vector(to_unsigned(regs(event_count),8));buswr<='0';
      elsif k=offsets(event_count)+8 then busa<=x"00f1";busd<=std_logic_vector(to_unsigned(values(event_count),8));buswr<='0';event_count:=event_count+1;end if;
     elsif j=3 then buswr<='1';end if;host;
    end loop;
    if verified_events<9 then if k=offsets(verified_events)+180 then check_event(verified_events);end if;end if;
    if k mod 100000=0 then report "PROGRESS shift="&integer'image(SHIFT)&" pass="&integer'image(pass)&" CE="&integer'image(k);end if;
   end loop;
   assert now-follow_start>=115 ms report "follow-up below 115 ms" severity failure;
   assert event_count=9 and verified_events=9 report "late musical scenarios incomplete" severity failure;
   exact;report "PASS EXACT LOAD shift="&integer'image(SHIFT)&" pass="&integer'image(pass)&" follow_ns="&integer'image(integer((now-follow_start)/1 ns))&" checks="&integer'image(checks);
  end loop;
  assert loads=2 report "repeated LOAD missing" severity failure;
  completed<='1';report "PASS AUTO ALL loads=2 shift="&integer'image(SHIFT)&" raw_checks="&integer'image(checks);std.env.finish;
 end process;
 process begin wait for 1 sec;assert false report "AUTO TIMEOUT" severity failure;end process;
end;
