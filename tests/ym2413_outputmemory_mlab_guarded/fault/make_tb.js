const fs=require('fs'),p=require('path'),d=__dirname;
let decl='',func='';for(let i=0;i<104;i++){decl+=`alias r${i}:std_logic_vector(31 downto 0) is reference_work.vm2413.verify_word_${i};\nalias c${i}:std_logic_vector(31 downto 0) is candidate_work.vm2413.verify_word_${i};\n`;func+=`when ${i}=>if cand then return c${i};else return r${i};end if;\n`;}
fs.writeFileSync(p.join(d,'reach_tb.vhd'),`library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;use ieee.std_logic_textio.all;use std.textio.all;
library reference_work,candidate_work;
entity reach_tb is generic(TESTCASE:integer:=0;MODE:integer:=0;FOLLOW:integer:=4096;GAP:integer:=1);end;
architecture test of reach_tb is
signal clk:std_logic:='0';signal reset_n,ce,hold,swrite,sread:std_logic:='0';
signal initrun,legacyreset:std_logic:='0';
signal addr:std_logic_vector(7 downto 0):=x"ff";signal wd,rr,cr:std_logic_vector(31 downto 0):=(others=>'0');
signal busd:std_logic_vector(7 downto 0):=(others=>'0');signal busa:std_logic_vector(15 downto 0):=x"00f0";signal buswr:std_logic:='1';
signal ry,cy:std_logic_vector(13 downto 0);signal ra,ca:std_logic_vector(12 downto 0);signal ready,cready:std_logic;
${decl}
impure function obs(cand:boolean;i:integer) return std_logic_vector is begin case i is ${func} when others=>return x"00000000";end case;end;
begin
clk<=not clk after 9.312 ns;
r:entity reference_work.reference_wrapper port map(clk,reset_n,ce,hold,initrun,legacyreset,'1',busd,busa,buswr,addr,sread,swrite,wd,rr,ready,ry,ra);
c:entity candidate_work.candidate_wrapper port map(clk,reset_n,ce,hold,initrun,legacyreset,'1',busd,busa,buswr,addr,sread,swrite,wd,cr,cready,cy,ca);
process
type image_type is array(0 to 103) of std_logic_vector(31 downto 0);variable image:image_type;
type ints is array(0 to 103) of integer;variable first_diff,last_diff:ints:=(others=>-1);
variable raw,ena,origin,first_audio,last_audio,divergent,pending,consreg,consout1,consout2,saves,regpending,outpending:integer:=0;
variable check,trace,injecting:boolean:=false;variable linebuf:line;variable count,st,slot,postst,regaddr:integer;
file logf:text open write_mode is "trace_"&integer'image(TESTCASE)&"_"&integer'image(MODE)&"_gap"&integer'image(GAP)&".csv";
file payload:text open write_mode is "payload_"&integer'image(TESTCASE)&"_"&integer'image(MODE)&".hex";
file coherent:text open write_mode is "coherent_"&integer'image(TESTCASE)&"_"&integer'image(MODE)&".csv";
file allpayload:text open write_mode is "allpayload_"&integer'image(TESTCASE)&"_"&integer'image(MODE)&".hex";
procedure host is
 variable anydiff:boolean;variable preq:std_logic_vector(23 downto 0);variable preo1,preo2:std_logic_vector(9 downto 0);
 variable expreg,expmo,expf,expm,expmute,opcount,opslot:integer;
 type map_type is array(0 to 17) of integer;
 constant melodic:map_type:=(1,3,5,-1,-1,-1,7,9,11,-1,-1,-1,13,15,17,-1,-1,-1);
 constant percussion:map_type:=(1,3,5,15,17,-1,7,9,11,14,16,13,15,17,14,16,13,-1);
begin
 wait until rising_edge(clk);raw:=raw+1;
 count:=to_integer(unsigned(r78(6 downto 0)));st:=count mod 4;slot:=count/4;
 preq:=candidate_work.vm2413.probe_reg_q;preo1:=candidate_work.vm2413.probe_out_q1;preo2:=candidate_work.vm2413.probe_out_q2;
 expreg:=to_integer(unsigned(r81(7 downto 4)));expmo:=to_integer(unsigned(r100(10 downto 6)));expf:=to_integer(unsigned(r97(3 downto 0)));expm:=to_integer(unsigned(r101(5 downto 1)));expmute:=to_integer(unsigned(r101(0 downto 0)));
 if ce='1' and hold='0' then
 if st=0 then expreg:=slot/2;if r85(25)='0' then pending:=melodic(slot);else pending:=percussion(slot);end if;if pending<0 then expmute:=1;else expm:=pending;expmute:=0;end if;end if;
 expmo:=((count+64) mod 72)/4;
 opcount:=(count+67) mod 72;opslot:=opcount/4;if opcount mod 4=2 and opslot mod 2=1 then expf:=(opslot/2+1) mod 9;end if;
 ena:=ena+1;
 if candidate_work.vm2413.probe_reg_collision='1' and (st=2 or st=3) then consreg:=consreg+1;if trace and raw-origin<2000 then report "REG_CONSUMER raw="&integer'image(raw-origin)&" stage="&integer'image(st)&" q="&to_hstring(preq);end if;end if;
 if candidate_work.vm2413.probe_out_collision1='1' and st=3 and (((count+64) mod 72)/4) mod 2=0 then consout1:=consout1+1;if trace and raw-origin<2000 then report "OUT1_CONSUMER raw="&integer'image(raw-origin)&" q="&to_hstring(preo1);end if;end if;
 if candidate_work.vm2413.probe_out_collision2='1' and st=2 and slot/=17 and r101(0)='0' then consout2:=consout2+1;if trace and raw-origin<2000 then report "OUT2_CONSUMER raw="&integer'image(raw-origin)&" q="&to_hstring(preo2);end if;end if;
 end if;
 wait until falling_edge(clk);wait for 1 ns;
 if TESTCASE=10 and ready='1' and hold='0' then
 assert to_integer(unsigned(r81(7 downto 4)))=expreg report "independent controller address transition" severity failure;
 assert to_integer(unsigned(r100(10 downto 6)))=expmo report "independent OutputGenerator address transition" severity failure;
 assert to_integer(unsigned(r97(3 downto 0)))=expf report "independent Operator feedback address transition" severity failure;
 assert to_integer(unsigned(r101(5 downto 1)))=expm and to_integer(unsigned(r101(0 downto 0)))=expmute report "independent mixer address/control transition" severity failure;
 end if;
 if trace and raw-origin<65 then
 write(linebuf,raw-origin);write(linebuf,string'(","));write(linebuf,ce);write(linebuf,string'(","));write(linebuf,count);write(linebuf,string'(","));hwrite(linebuf,preq);write(linebuf,string'(","));hwrite(linebuf,preo1);write(linebuf,string'(","));hwrite(linebuf,preo2);
 for i in 0 to 103 loop if i=0 or i=49 or i=57 or i=80 or i=83 or i=84 or i=85 or i=100 or i=101 then write(linebuf,string'(","));hwrite(linebuf,obs(false,i));write(linebuf,string'(","));hwrite(linebuf,obs(true,i));end if;end loop;writeline(logf,linebuf);
 end if;
 if check then
 if TESTCASE=15 then
 for i in 0 to 103 loop assert obs(false,i)=obs(true,i) report "proposed guard cohort state mismatch word="&integer'image(i) severity failure;end loop;
 assert ry=cy and ra=ca report "proposed guard cohort audio mismatch" severity failure;
 end if;
 for i in 0 to 103 loop if obs(false,i)/=obs(true,i) then
 if first_diff(i)=-1 then first_diff(i):=raw-origin;report "FIRST_DIFF word="&integer'image(i)&" raw="&integer'image(raw-origin)&" ref="&to_hstring(obs(false,i))&" fault="&to_hstring(obs(true,i));end if;
 last_diff(i):=raw-origin;end if;end loop;
 if ry/=cy or ra/=ca then if first_audio=-1 then first_audio:=raw-origin;report "FIRST_AUDIO raw="&integer'image(raw-origin)&" ref="&to_hstring(ry)&" fault="&to_hstring(cy);end if;last_audio:=raw-origin;end if;
 end if;
end;
procedure ticks(n:integer) is begin for k in 1 to n loop ce<='1';host;ce<='0';for j in 1 to 14 loop host;end loop;end loop;end;
procedure wr(regnum,value:integer) is begin
 busa<=x"00f0";busd<=std_logic_vector(to_unsigned(regnum,8));buswr<='0';host;host;buswr<='1';ticks(8);
 busa<=x"00f1";busd<=std_logic_vector(to_unsigned(value,8));buswr<='0';host;host;buswr<='1';ticks(160);end;
procedure capture is begin
 hold<='1';ce<='0';host;
 for i in 0 to 103 loop addr<=std_logic_vector(to_unsigned(i,8));sread<='1';host;image(i):=rr;sread<='0';host;assert image(i)=obs(false,i) report "SAVE versus independent internal-state oracle word="&integer'image(i) severity failure;end loop;
 addr<=x"ff";host;
end;
procedure apply_image is begin
 for i in 0 to 103 loop addr<=std_logic_vector(to_unsigned(i,8));wd<=image(i);swrite<='0';host;swrite<='1';host;swrite<='0';end loop;
 addr<=x"ff";for j in 1 to 8 loop host;end loop;
 for i in 0 to 103 loop assert obs(false,i)=image(i) and obs(true,i)=image(i) report "exact LOAD word="&integer'image(i) severity failure;end loop;
end;
procedure record_coherent(scenario,phase,offset:integer) is begin
 write(linebuf,scenario);write(linebuf,string'(","));write(linebuf,phase);write(linebuf,string'(","));write(linebuf,offset);
 for i in 0 to 103 loop if i=77 or i=78 or i=81 or i=83 or i=97 or i=100 or i=101 then write(linebuf,string'(","));hwrite(linebuf,image(i));end if;end loop;writeline(coherent,linebuf);
 for i in 0 to 103 loop hwrite(linebuf,image(i));writeline(allpayload,linebuf);end loop;
 assert image(100)(1)='0' or unsigned(image(78)(1 downto 0))=0 report "mo_wr implies global stage zero FAILED" severity failure;
 assert image(100)(0)='0' or unsigned(image(78)(1 downto 0))=0 report "fb_wr implies global stage zero FAILED" severity failure;
 assert image(83)(4)='0' or unsigned(image(78)(1 downto 0))=0 or unsigned(image(78)(1 downto 0))=3 report "regs_wr stage invariant FAILED" severity failure;
 if TESTCASE/=16 and image(83)(4)='1' then
 regaddr:=to_integer(unsigned(image(81)(7 downto 4)));
 assert image(regaddr)(21 downto 0)=image(83)(26 downto 5) report "ARM_FREEZE register pending write must have reached RAM" severity failure;
 end if;
 if TESTCASE/=16 and image(100)(1)='1' then assert image(58+to_integer(unsigned(image(100)(10 downto 6))))(9 downto 0)=image(100)(30 downto 21) report "ARM_FREEZE output write must have reached RAM" severity failure;end if;
 if image(83)(4)='1' then regpending:=regpending+1;end if;if image(100)(1)='1' then outpending:=outpending+1;end if;saves:=saves+1;
end;
begin
first_audio:=-1;last_audio:=-1;
write(linebuf,string'("raw,ce,pre_count,reg_q,out_q1,out_q2,word0_ref,word0_fault,word49_ref,word49_fault,word57_ref,word57_fault,word80_ref,word80_fault,word83_ref,word83_fault,word84_ref,word84_fault,word85_ref,word85_fault,word100_ref,word100_fault,word101_ref,word101_fault"));writeline(logf,linebuf);
for i in 1 to 7 loop host;end loop;reset_n<='1';for i in 1 to 130 loop host;end loop;
assert ready='1' and cready='1' report "initialization timeout" severity failure;
wr(0,225);wr(1,241);wr(2,16);wr(3,7);wr(4,244);wr(5,211);wr(6,37);wr(7,54);
for ch in 0 to 8 loop wr(48+ch,ch*16);wr(16+ch,129+ch*7);wr(32+ch,25);end loop;ticks(1000);
if TESTCASE=10 or TESTCASE=16 then
 for scenario in 0 to 5 loop
 case scenario is when 0=>null;when 1=>wr(32,9);when 2=>wr(32,25);when 3=>wr(14,63);when 4=>wr(4,148);when others=>wr(14,32);end case;
 for phase in 0 to 71 loop
 -- Continuous asserted wrapper data produces real pending channel writes.
 busa<=x"00f0";busd<=std_logic_vector(to_unsigned(48+(phase/8 mod 9),8));buswr<='0';host;host;buswr<='1';ticks(8);
 busa<=x"00f1";busd<=std_logic_vector(to_unsigned(((phase mod 15)+1)*16,8));buswr<='0';host;host;buswr<='1';
 -- Reach the predecessor, execute the real enabled transition, then allow
 -- the ARM_FREEZE raw edge to finish pending RAM writes before asserting hold.
 while to_integer(unsigned(r78(6 downto 0)))/=((phase+71) mod 72) loop ticks(1);end loop;
 ce<='1';host;ce<='0';if TESTCASE/=16 then host;end if;
 for offset in 0 to (14-14*boolean'pos(TESTCASE=16)) loop
 if offset>0 then host;end if;
 capture;record_coherent(scenario,phase,offset);apply_image;hold<='0';host;
 end loop;
 end loop;end loop;
 report "PASS COHERENT saves="&integer'image(saves)&" register_pending="&integer'image(regpending)&" output_pending="&integer'image(outpending)&" normal_register_collision_consumers="&integer'image(consreg)&" output_consumers="&integer'image(consout1+consout2);
 assert regpending>0 and outpending>0 report "missing pending coverage" severity failure;
elsif TESTCASE=15 then
 -- Verification of a proposed acceptance condition, not a production validator
 -- change. All other relevant fields deliberately violate producer coherence.
 capture;
 for phase in 0 to 71 loop for poison in 0 to 5 loop
 check:=false;candidate_work.vm2413.fault_target<=0;hold<='1';ce<='0';host;
 image(78):=std_logic_vector(to_unsigned(phase,32));
 image(97)(3 downto 0):=std_logic_vector(to_unsigned((phase+4) mod 9,4));
 image(81)(7 downto 4):=std_logic_vector(to_unsigned((phase+3) mod 9,4));image(83)(4):='1';
 image(100):=x"7FE00001";
 image(100)(5 downto 2):=std_logic_vector(to_unsigned((phase+7) mod 9,4));
 image(100)(10 downto 6):=std_logic_vector(to_unsigned((phase*5+poison) mod 18,5));
 if phase mod 4=0 then image(100)(1):='1';end if;
 image(101):=x"000FFFC0";image(101)(5 downto 1):=std_logic_vector(to_unsigned((phase*7+poison) mod 18,5));
 for i in 0 to 103 loop hwrite(linebuf,image(i));writeline(allpayload,linebuf);end loop;
 apply_image;candidate_work.vm2413.fault_mode<=poison;candidate_work.vm2413.fault_target<=2;
 hold<='0';check:=true;for j in 1 to 7 loop host;end loop;ticks(16);
 candidate_work.vm2413.fault_target<=0;ticks(144);
 end loop;end loop;
 report "PASS PROPOSED_GUARD cohort=432 counter_positions=72 poison_modes=6 all104_and_audio_exact_every_raw_clock";
elsif TESTCASE=14 then
 origin:=raw;check:=true;candidate_work.vm2413.fault_mode<=MODE;candidate_work.vm2413.fault_target<=2;
 for offset in 0 to 14 loop
 reset_n<='0';ce<='0';for j in 1 to 6 loop host;end loop;reset_n<='1';
 for j in 0 to 1499 loop if (j+offset) mod 15=0 then ce<='1';else ce<='0';end if;host;end loop;
 end loop;
 for i in 0 to 103 loop assert first_diff(i)=-1 report "initialization collision affected architectural state" severity failure;end loop;
 assert first_audio=-1 severity failure;
 report "PASS INITIALIZATION all15_CE_offsets mode="&integer'image(MODE);
elsif TESTCASE>=11 then
 -- Coherent baseline state and genuine musical writes, rather than fabricated
 -- pending pipelines. Faults remain restricted to actual collision outputs.
 capture;apply_image;hold<='0';host;
 candidate_work.vm2413.fault_mode<=MODE;
 if TESTCASE=11 then candidate_work.vm2413.fault_target<=1;else candidate_work.vm2413.fault_target<=2;end if;
 origin:=raw;check:=true;trace:=true;consreg:=0;consout1:=0;consout2:=0;
 if TESTCASE=13 then
 -- Exact legacy reset/initialization handshake; legacy word values are
 -- independently checked against production legacy_word in validator.sv.
 check:=false;hold<='1';initrun<='1';legacyreset<='1';host;legacyreset<='0';
 for j in 1 to 130 loop host;end loop;assert ready='1' severity failure;
 initrun<='0';host;capture;
 for i in 76 to 103 loop image(i):=(others=>'0');end loop;
 image(78):=x"00000047";image(88):=x"00008000";image(90):=x"0003FFFF";image(101):=x"00000001";
 -- Disable injection during array application, matching production legacy
 -- which initializes RAM and applies only the controller/private tail.
 candidate_work.vm2413.fault_target<=0;apply_image;candidate_work.vm2413.fault_target<=2;
 hold<='0';host;check:=true;origin:=raw;
 end if;
 wr(16,85);wr(32,9);wr(32,25);wr(14,63);wr(4,148);ticks(500);
 candidate_work.vm2413.fault_target<=0;ticks(FOLLOW);
 for i in 0 to 103 loop if first_diff(i)>=0 then report "DIFF_SUMMARY word="&integer'image(i)&" first_raw="&integer'image(first_diff(i))&" last_raw="&integer'image(last_diff(i))&" remains="&boolean'image(obs(false,i)/=obs(true,i));divergent:=divergent+1;end if;end loop;
 report "PASS COHERENT_FAULT case="&integer'image(TESTCASE)&" mode="&integer'image(MODE)&" observed_words="&integer'image(divergent)&" first_audio="&integer'image(first_audio)&" last_audio="&integer'image(last_audio)&" reg_consumers="&integer'image(consreg)&" out1_consumers="&integer'image(consout1)&" out2_consumers="&integer'image(consout2);
 if TESTCASE/=11 or MODE=0 then assert divergent=0 and first_audio=-1 report "coherent collision independence failed" severity failure;end if;
else
capture;
case TESTCASE is
when 0=>image(78):=x"00000003";image(100):=x"7FE00402";image(74):=x"00000000";
when 1=>image(78):=x"00000002";image(100):=x"7FE00042";image(101):=x"00000002";image(59):=x"00000000";
when 2|3=>image(78):=std_logic_vector(to_unsigned(5-TESTCASE,32));image(81)(7 downto 4):="0000";image(83):=x"00800010";image(0):=x"00000000";image(77):=x"00018110";
when others=>assert false severity failure;end case;
for i in 0 to 103 loop hwrite(linebuf,image(i));writeline(payload,linebuf);end loop;file_close(payload);
apply_image;
candidate_work.vm2413.fault_mode<=MODE;
if TESTCASE<2 then candidate_work.vm2413.fault_target<=2;else candidate_work.vm2413.fault_target<=1;end if;
origin:=raw;check:=true;trace:=true;consreg:=0;consout1:=0;consout2:=0;hold<='0';ce<='0';
if GAP>0 then host;
-- Independent expectations for the first collision output, not SAVE-derived.
if TESTCASE<2 then
 if MODE=0 or MODE=2 then assert candidate_work.vm2413.probe_out_q1="0000000000" severity failure;
 elsif MODE=1 or MODE=3 or MODE=5 then assert candidate_work.vm2413.probe_out_q1="1111111111" severity failure;
 else assert candidate_work.vm2413.probe_out_q1="0101010101" severity failure;end if;
else
 if MODE=0 or MODE=2 then assert candidate_work.vm2413.probe_reg_q=x"000000" severity failure;
 elsif MODE=1 then assert candidate_work.vm2413.probe_reg_q=x"100000" severity failure;
 elsif MODE=3 or MODE=5 then assert candidate_work.vm2413.probe_reg_q=x"FFFFFF" severity failure;
 elsif MODE=6 then assert candidate_work.vm2413.probe_reg_q=x"FF3FFF" severity failure;
 else assert candidate_work.vm2413.probe_reg_q=x"555555" severity failure;end if;
end if;
for j in 2 to GAP loop host;end loop;
end if;
ce<='1';host;ce<='0';candidate_work.vm2413.fault_target<=0;
for j in 1 to 14 loop host;end loop;
ticks(FOLLOW);
for i in 0 to 103 loop if first_diff(i)>=0 then report "DIFF_SUMMARY word="&integer'image(i)&" first_raw="&integer'image(first_diff(i))&" last_raw="&integer'image(last_diff(i))&" remains="&boolean'image(obs(false,i)/=obs(true,i));divergent:=divergent+1;end if;end loop;
report "PASS FAULT_PROBE case="&integer'image(TESTCASE)&" mode="&integer'image(MODE)&" observed_words="&integer'image(divergent)&" first_audio="&integer'image(first_audio)&" last_audio="&integer'image(last_audio)&" reg_consumers="&integer'image(consreg)&" out1_consumers="&integer'image(consout1)&" out2_consumers="&integer'image(consout2)&" follow_enabled="&integer'image(FOLLOW);
if MODE=0 then assert divergent=0 and first_audio=-1 report "OLD_DATA control mismatch" severity failure;end if;
end if;
std.env.finish;
end process;
process begin wait for 1 sec;assert false report "bounded timeout" severity failure;end process;
end;
`);
