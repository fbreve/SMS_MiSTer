library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; use ieee.std_logic_textio.all; use std.textio.all; use std.env.all;
entity calibration_v2_tb is generic(VARIANT:integer:=0;PROFILE:integer:=0;POINT:integer:=1;FOLLOW:integer:=7200);end;
architecture test of calibration_v2_tb is
 signal clk:std_logic:='0';signal reset_n:std_logic:='0';signal ena:std_logic:='1';signal a:std_logic:='0';signal cs:std_logic:='1';signal data:std_logic_vector(7 downto 0):=(others=>'0');
 type bits is array(0 to 2)of std_logic;type words is array(0 to 2)of std_logic_vector(31 downto 0);type audios is array(0 to 2)of std_logic_vector(13 downto 0);
 signal holds:bits:=('0','0','0');signal writes:bits:=('0','0','0');signal y:audios;signal q:words;signal rd:std_logic:='0';signal addr:std_logic_vector(7 downto 0):=(others=>'0');signal wd:std_logic_vector(31 downto 0):=(others=>'0');signal ready:bits;
 function mask(w:integer)return std_logic_vector is variable x:std_logic_vector(31 downto 0):=(others=>'1');begin
 case VARIANT is
 when 1=>if w>=91 and w<=92 then x:=(others=>'0');end if;
 when 2=>if w>=98 and w<=99 then x:=(others=>'0');end if;
 when 3=>if w=79 then x:=(others=>'0');end if;
 when 4=>if w>=31 and w<=48 then x:=(others=>'0');end if;
 when 5=>if w>=13 and w<=30 then x:=(others=>'0');end if;
 when 6=>if w>=49 and w<=57 then x:=(others=>'0');end if;
 when 7=>if w>=80 and w<=85 then x:=(others=>'0');end if;if w=84 then x:=x"0000003f";elsif w=85 then x:=x"04000000";end if;
 when 8=>if w>=58 then x:=(others=>'0');end if;case w is when 76|77|78|80|88|90|95=>x:=(others=>'1');when 81=>x:=x"0000000f";when 84=>x:=x"0000003f";when 85=>x:=x"04000000";when 87=>x:=x"7fffe000";when 93=>x:=x"fff80000";when others=>null;end case;
 when 9=>if w=79 or w=91 or w=92 or w=98 or w=99 then x:=(others=>'0');end if;
 when others=>null;end case;return x;end;
 function clip(x:integer)return integer is begin if x>4095 then return 4095;elsif x< -4096 then return -4096;else return x;end if;end;
begin
 clk<=not clk after 5 ns;
 g:for i in 0 to 2 generate u:entity work.opll port map(xin=>clk,xout=>open,xena=>ena,d=>data,a=>a,cs_n=>cs,we_n=>cs,ic_n=>reset_n,mixout=>y(i),ss_hold=>holds(i),ss_addr=>addr,ss_read=>rd,ss_write=>writes(i),ss_wdata=>wd,ss_rdata=>q(i),ss_initialized=>ready(i));end generate;
 process
 type image_type is array(0 to 99)of std_logic_vector(31 downto 0);variable image,stale,cf,cr:image_type;variable row:line;file audio:text;file states:text;variable ardr,slrr:integer;variable v:integer;
 procedure host(n:integer:=1)is begin for i in 1 to n loop wait until rising_edge(clk);wait for 1 ns;end loop;end;
 procedure tick(n:integer:=1)is begin for i in 1 to n loop ena<='1';host;ena<='0';host(14);end loop;end;
 procedure regwrite(r,d:integer)is begin a<='0';data<=std_logic_vector(to_unsigned(r,8));cs<='0';tick;cs<='1';tick(5);a<='1';data<=std_logic_vector(to_unsigned(d,8));cs<='0';tick;cs<='1';tick(150);end;
 procedure capture(variable dest:out image_type;instance:integer)is begin for w in 0 to 99 loop addr<=std_logic_vector(to_unsigned(w,8));rd<='1';tick(3);dest(w):=q(instance);end loop;rd<='0';end;
 begin
 tick(5);reset_n<='1';tick(1000);assert ready=('1','1','1') severity failure;
 if PROFILE=6 then regwrite(0,16#21#);regwrite(1,16#21#);else regwrite(0,16#e1#);regwrite(1,16#e1#);end if;regwrite(2,0);regwrite(3,7);
 if PROFILE=1 then ardr:=16#54#;elsif PROFILE=2 then ardr:=16#f7#;else ardr:=16#f0#;end if;
 if PROFILE=2 then slrr:=16#85#;elsif PROFILE=3 then slrr:=5;elsif PROFILE=1 then slrr:=16#44#;else slrr:=0;end if;
 regwrite(4,ardr);regwrite(5,ardr);regwrite(6,slrr);regwrite(7,slrr);regwrite(16#30#,6);regwrite(16#10#,16#91#);regwrite(16#20#,16#19#);
 if PROFILE=4 then for ch in 6 to 8 loop regwrite(16#30#+ch,16#66#);regwrite(16#10#+ch,16#80#+ch*11);regwrite(16#20#+ch,16#19#);end loop;regwrite(14,16#3f#);end if;
 if PROFILE=3 then tick(2000);regwrite(16#20#,9);end if;
 tick(1000+POINT);holds<=('1','1','1');tick;capture(image,0);if PROFILE=5 then image(13):=x"0003ffff";image(14):=x"0003fffe";image(88):=x"000f7fff";image(93):=(image(93)and x"0007ffff")or x"fff80000";for w in 0 to 99 loop addr<=std_logic_vector(to_unsigned(w,8));wd<=image(w);writes<=('1','0','0');tick;writes<=('0','0','0');tick;end loop;end if;holds<=('1','0','0');
 regwrite(16#20#,9);regwrite(16#10#,16#37#);regwrite(16#30#,16#10#);regwrite(4,16#25#);regwrite(5,16#24#);if PROFILE=4 then regwrite(14,16#20#);else regwrite(14,16#3f#);end if;
 tick(21347);holds<=('1','1','1');tick;capture(stale,2);
 for w in 0 to 99 loop addr<=std_logic_vector(to_unsigned(w,8));wd<=image(w);writes<=('0','1','0');tick;writes<=('0','0','0');tick;if mask(w)/=x"00000000" then wd<=(image(w)and mask(w))or(stale(w)and not mask(w));writes<=('0','0','1');tick;writes<=('0','0','0');tick;end if;end loop;
 capture(cf,1);capture(cr,2);file_open(states,"state.csv",write_mode);write(row,string'("word,image,stale,mask,full,reduced"));writeline(states,row);
 for w in 0 to 99 loop assert cf(w)=image(w) report "full roundtrip" severity failure;assert cr(w)=((image(w)and mask(w))or(stale(w)and not mask(w))) report "reduced roundtrip" severity failure;write(row,w);write(row,string'(","));hwrite(row,image(w));write(row,string'(","));hwrite(row,stale(w));write(row,string'(","));hwrite(row,mask(w));write(row,string'(","));hwrite(row,cf(w));write(row,string'(","));hwrite(row,cr(w));writeline(states,row);end loop;file_close(states);
 rd<='0';addr<=x"ff";tick(8);holds<=('0','0','0');file_open(audio,"audio.csv",write_mode);write(row,string'("ce,uninterrupted,full,reduced,uninterrupted_clamped,full_clamped,reduced_clamped"));writeline(audio,row);
 for t in 1 to FOLLOW loop tick;for i in 0 to 2 loop assert not is_x(y(i)) report "unknown audio" severity failure;end loop;
 if t mod 72=0 or FOLLOW<=50000 then write(row,t);for i in 0 to 2 loop write(row,string'(","));write(row,to_integer(signed(y(i))));end loop;for i in 0 to 2 loop write(row,string'(","));write(row,clip(to_integer(signed(y(i)))));end loop;writeline(audio,row);end if;
 end loop;file_close(audio);report "PASS original VHDL convergence calibration";finish;
 end process;
end;
