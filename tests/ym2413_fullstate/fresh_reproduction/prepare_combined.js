// Extend the previously calibrated accumulator harness, only in simulation copies.
const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const get=f=>fs.readFileSync(p.join(d,f),'utf8'),put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
for(const lib of ['candidate','reference']){
 let f='native_'+lib+'/vm2413.vhd',s=fs.readFileSync(p.join(d,f),'latin1');
 assert(s.includes('signal verify_poison:'));
 if(!s.includes('signal verify_poison_out:'))s=s.replace('signal verify_poison:','signal verify_poison_out:std_logic_vector(13 downto 0):=(others=>\'0\');\n signal verify_poison:');
 fs.writeFileSync(p.join(d,f),s,'latin1');
 f='native_'+lib+'/temporalmixer.vhd';s=fs.readFileSync(p.join(d,f),'latin1');
 assert(s.includes('then mix<=verify_poison;'));
 fs.writeFileSync(p.join(d,f),s.replace('then mix<=verify_poison;end if;','then mix<=verify_poison;mixout<=verify_poison_out;end if;'),'latin1');
}
let s=get('acc_native_tb.vhd').replace(/\bacc_native_tb\b/g,'combined_tb').replace('"native_audio_"','"combined_audio_"');
function replace(a,b){assert(s.includes(a),'Missing bench anchor: '+a.slice(0,80));s=s.replace(a,b);}
replace('FRAME_EVENTS:integer:=6','FRAME_EVENTS:integer:=6;CALIBRATE:boolean:=false;TRACE_CSV:boolean:=false');
replace('variable row:line;',`type trace_row_type is array(0 to 11) of integer;
  type binary_trace_type is file of trace_row_type;
  file binary_trace:binary_trace_type open write_mode is "combined_trace_"&integer'image(SHIFT)&".bin";
  variable trace_values:trace_row_type;
  variable row:line;`);
replace('variable expected_words:image_type;variable injection,original,kind,checkpoints:integer:=0;',`variable expected_words:image_type;variable injection,original,kind,checkpoints:integer:=0;
 variable injected_out,original_out:integer:=0;
 variable last_state_host,last_raw_host,last_clamp_host,last_state_ce,last_raw_ce,last_clamp_ce:integer:=0;
 variable previous_c,previous_r,step_value,sum_value,overflow_count,saturation_count:integer:=0;
 variable late_events,late_checks:integer:=0;variable converged_at:time:=0 ns;
 type int_array is array(natural range <>) of integer;
 constant event_offsets:int_array:=(2000,8000,20000,50000,100000,150000,250000,300000,350000);
 constant event_regs:int_array:=(16#20#,16#20#,16#0e#,4,16#0e#,0,16#21#,16#21#,16#0e#);
 constant event_values:int_array:=(9,16#19#,16#3f#,16#94#,16#20#,16#21#,9,16#19#,16#35#);
 function signed14(n:integer) return integer is begin if n>=8192 then return n-16384;else return n;end if;end;
 function clamped13(n:integer) return integer is variable v:integer;begin v:=signed14(n);if v>4095 then v:=4095;elsif v< -4096 then v:=-4096;end if;return v mod 8192;end;
 procedure check_late(i:integer) is begin
  case i is
   when 0=>assert r_observe_0(12)='0' report "late key-off not applied" severity failure;
   when 1=>assert r_observe_0(12)='1' report "late key-on not applied" severity failure;
   when 2=>assert r_observe_84(5 downto 0)="111111" report "late rhythm-on not applied" severity failure;
   when 3=>assert r_observe_9(15 downto 8)=x"94" report "late custom AR/DR not applied" severity failure;
   when 4=>assert r_observe_84(5 downto 0)="100000" report "late rhythm change not applied" severity failure;
   when 5=>assert r_observe_9(31 downto 28)=x"1" and r_observe_10(3 downto 0)=x"2" report "late custom ML/flags not applied" severity failure;
   when 6=>assert r_observe_1(12)='0' report "late second key-off not applied" severity failure;
   when 7=>assert r_observe_1(12)='1' report "late second key-on not applied" severity failure;
   when 8=>assert r_observe_84(5 downto 0)="110101" report "late percussion change not applied" severity failure;
   when others=>assert false severity failure;
  end case;
  late_checks:=late_checks+1;report "PASS LATE EFFECT pass="&integer'image(pass_number)&" event="&integer'image(i)&" CE="&integer'image(elapsed);
 end;`);
replace('if checking=\'1\' then\n    -- Exactly',`if checking='1' then
    if all_equal/=(all_equal'range=>'1') then last_state_host:=host_elapsed;last_state_ce:=(host_elapsed-1)/15+1;end if;
    if cy/=ry then last_raw_host:=host_elapsed;last_raw_ce:=(host_elapsed-1)/15+1;end if;
    if ca/=ra then last_clamp_host:=host_elapsed;last_clamp_ce:=(host_elapsed-1)/15+1;end if;
    -- Exactly`);
replace('for i in 0 to 103 loop expected_words(i):=oracle_word(false,i);',`for i in 0 to 103 loop assert not is_x(oracle_word(false,i)) and not is_x(oracle_word(true,i)) report "unknown architectural state" severity failure;expected_words(i):=oracle_word(false,i);`);
const start=s.indexOf('  original:=to_integer(unsigned(expected_words(101)'),end=s.indexOf('\n elsif n=3 then',start);assert(start>=0&&end>start);
s=s.slice(0,start)+`  original:=to_integer(unsigned(expected_words(101)(19 downto 6)));original_out:=to_integer(unsigned(expected_words(102)(13 downto 0)));kind:=pass_number;
  case pass_number is
   when 0=>injection:=8191;injected_out:=8192;
   when 1=>injection:=8192;injected_out:=8191;
   when 2=>kind:=2+(SHIFT mod 4);case SHIFT mod 4 is
    when 0=>injection:=8191;injected_out:=8191;
    when 1=>injection:=8192;injected_out:=8192;
    when 2=>injection:=0;injected_out:=16383;
    when others=>injection:=16383;injected_out:=0;end case;
   when 3=>kind:=6+(SHIFT mod 6);case SHIFT mod 6 is
    when 0=>injection:=5461;injected_out:=10922;
    when 1=>injection:=10922;injected_out:=5461;
    when 2=>injection:=(original+8192) mod 16384;injected_out:=(original_out+8192) mod 16384;
    when 3=>injection:=(16#2413#+SHIFT*7919) mod 16384;injected_out:=(16#1234#+SHIFT*1277) mod 16384;
    when 4=>injection:=0;injected_out:=8191;
    when others=>injection:=8192;injected_out:=0;end case;
   when others=>assert false severity failure;
  end case;
  if injection=original then injection:=to_integer(to_unsigned(injection,14) xor to_unsigned(1,14));end if;
  if injected_out=original_out then injected_out:=to_integer(to_unsigned(injected_out,14) xor to_unsigned(1,14));end if;
  candidate_work.vm2413.verify_poison<=std_logic_vector(to_unsigned(injection,14));candidate_work.vm2413.verify_poison_out<=std_logic_vector(to_unsigned(injected_out,14));candidate_work.vm2413.verify_poison_en<='1';
  report "POISON BOTH shift="&integer'image(SHIFT)&" pass="&integer'image(pass_number)&" kind="&integer'image(kind)&" saved_mix="&integer'image(original)&" mix="&integer'image(injection)&" saved_out="&integer'image(original_out)&" out="&integer'image(injected_out);
`+s.slice(end);
replace('else assert oracle_word(true,i)=expected_words(i) report "unrelated candidate restoration" severity failure;end if;',`elsif i=102 then null;else assert oracle_word(true,i)=expected_words(i) report "unrelated candidate restoration" severity failure;end if;`);
replace('assert to_integer(unsigned(c_observe_101(19 downto 6)))=injection and injection/=original report "poison did not survive omitted restore" severity failure;',`assert to_integer(unsigned(c_observe_101(19 downto 6)))=injection and injection/=original report "accumulator poison did not survive omitted restore" severity failure;
  assert to_integer(unsigned(c_observe_102(13 downto 0)))=injected_out and injected_out/=original_out report "output poison did not survive omitted restore" severity failure;
  assert c_observe_101/=r_observe_101 and c_observe_102/=r_observe_102 and cy/=ry report "initial simultaneous mismatch absent" severity failure;`);
replace('if elapsed<expected_reset or elapsed>=expected_full then assert cy=ry and ca=ra report "audio outside bounded transient" severity failure;','if elapsed>=expected_full then assert cy=ry and ca=ra report "audio outside bounded transient" severity failure;');
replace('if pal_edges>=2 or ntsc_edges>=2 then',`assert to_integer(unsigned(ca))=clamped13(to_integer(unsigned(cy))) and to_integer(unsigned(ra))=clamped13(to_integer(unsigned(ry))) report "independent clamp mismatch" severity failure;
     if elapsed<expected_reset then
      step_value:=(to_integer(unsigned(r_observe_101(19 downto 6)))-previous_r+16384) mod 16384;
      sum_value:=signed14(previous_c)+signed14(step_value);
      if sum_value>8191 or sum_value< -8192 then overflow_count:=overflow_count+1;end if;
      previous_c:=to_integer(unsigned(c_observe_101(19 downto 6)));previous_r:=to_integer(unsigned(r_observe_101(19 downto 6)));
     end if;
     if elapsed<expected_full and cy(13)/=cy(12) then saturation_count:=saturation_count+1;end if;
     if late_checks<9 then if elapsed=expected_full+event_offsets(late_checks)+180 then check_late(late_checks);end if;end if;
     if pal_edges>=2 or ntsc_edges>=2 then`);
replace('write(row,ntsc_edges);writeline(trace,row);',`write(row,ntsc_edges);write(row,string'(","));write(row,to_integer(unsigned(ca)));write(row,string'(","));write(row,to_integer(unsigned(ra)));writeline(trace,row);`);
replace("ce<='0';for j in 1 to 14 loop host;end loop;",`ce<='0';for j in 1 to 14 loop
     if checking='1' then
      if j=1 and late_events<9 then
       if elapsed=expected_full+event_offsets(late_events) then
        busa<=x"00f0";busd<=std_logic_vector(to_unsigned(event_regs(late_events),8));buswr<='0';
       elsif elapsed=expected_full+event_offsets(late_events)+8 then
        busa<=x"00f1";busd<=std_logic_vector(to_unsigned(event_values(late_events),8));buswr<='0';
        report "LATE WRITE pass="&integer'image(pass_number)&" event="&integer'image(late_events)&" CE="&integer'image(elapsed);late_events:=late_events+1;
       end if;
      elsif j=3 then buswr<='1';end if;
     end if;
     host;
    end loop;`);
replace("saved_mix:=unsigned(r_observe_101",`last_state_host:=0;last_raw_host:=0;last_clamp_host:=0;last_state_ce:=0;last_raw_ce:=0;last_clamp_ce:=0;
   overflow_count:=0;saturation_count:=0;late_events:=0;late_checks:=0;
   previous_c:=injection;previous_r:=original;
   saved_mix:=unsigned(r_observe_101`);
replace('ticks(expected_reset);mark(4);ticks(72);mark(5);','ticks(expected_reset);mark(4);ticks(72);mark(5);converged_at:=now;');
replace('if FRAME_EVENTS=0 then ticks(1000);else while pal_edges<FRAME_EVENTS or ntsc_edges<FRAME_EVENTS loop ticks(1);end loop;end if;',`if FRAME_EVENTS=0 then ticks(1000);else
    while elapsed<expected_full+411000 or pal_edges<FRAME_EVENTS or ntsc_edges<FRAME_EVENTS loop ticks(1);end loop;
    assert now-converged_at>=115 ms report "short post-convergence follow-up" severity failure;
    assert late_events=9 and late_checks=9 report "incomplete late stimulus coverage" severity failure;
   end if;
   assert last_state_ce=expected_full-1 and last_raw_ce=expected_full-1 report "last mismatch convergence mismatch" severity failure;
   assert last_state_host=(expected_full-1)*15 and last_raw_host=(expected_full-1)*15 report "last host mismatch boundary" severity failure;`);
replace('mark(6);report "PASS ACC shift="',`report "LAST MISMATCH pass="&integer'image(pass_number)&" state_ce="&integer'image(last_state_ce)&" raw_ce="&integer'image(last_raw_ce)&" clamp_ce="&integer'image(last_clamp_ce)&" state_host="&integer'image(last_state_host)&" raw_host="&integer'image(last_raw_host)&" clamp_host="&integer'image(last_clamp_host)&" overflow="&integer'image(overflow_count)&" saturated="&integer'image(saturation_count)&" follow_ns="&integer'image(integer((now-converged_at)/1 ns));
   mark(6);report "PASS COMBINED shift="`);
replace('PASS ACC_NATIVE ALL checkpoints=28','PASS COMBINED ALL checkpoints=28');
replace('ACC TIMEOUT','COMBINED TIMEOUT');
replace('checkpoint<=0;wait for 1 ns;\nend;',"if CALIBRATE then std.env.stop;end if;checkpoint<=0;wait for 1 ns;\nend;");
const traceStart=s.indexOf('     write(row,SHIFT);'),traceEnd=s.indexOf('writeline(trace,row);',traceStart)+'writeline(trace,row);'.length;
assert(traceStart>=0&&traceEnd>traceStart);
s=s.slice(0,traceStart)+`     trace_values:=(SHIFT,pass_number,elapsed,to_integer(unsigned(cy)),to_integer(unsigned(ry)),to_integer(unsigned(c_observe_101(19 downto 6))),to_integer(unsigned(r_observe_101(19 downto 6))),host_elapsed,pal_edges,ntsc_edges,to_integer(unsigned(ca)),to_integer(unsigned(ra)));
     write(binary_trace,trace_values);
     if TRACE_CSV then\n`+s.slice(traceStart,traceEnd)+`\n     end if;`+s.slice(traceEnd);
put('combined_tb.vhd',s);
console.log('Prepared combined simultaneous-poison bench, late stimuli and last-mismatch monitors');
