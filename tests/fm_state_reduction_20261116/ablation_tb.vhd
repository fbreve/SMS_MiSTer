library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; use std.textio.all; use std.env.all;
entity ablation_tb is generic(OMIT_LO:integer:=256; OMIT_HI:integer:=256; POINT:integer:=0; RHYTHM_MODE:boolean:=false; FOLLOW:integer:=72000; HOSTS:integer:=15; SUSTAIN:boolean:=false);end;
architecture test of ablation_tb is
signal clk:std_logic:='0';signal reset_n:std_logic:='0';signal ena:std_logic:='1';signal a:std_logic:='0';signal cs:std_logic:='1';signal data:std_logic_vector(7 downto 0):=(others=>'0');
type bit_array is array(0 to 2) of std_logic;type word_array is array(0 to 2) of std_logic_vector(31 downto 0);type audio_array is array(0 to 2) of std_logic_vector(13 downto 0);
signal holds:bit_array:=('0','0','0');signal writes:bit_array:=('0','0','0');signal outputs:audio_array;signal rd:word_array;signal read_en:std_logic:='0';signal addr:std_logic_vector(7 downto 0):=(others=>'0');signal wd:std_logic_vector(31 downto 0):=(others=>'0');signal ready:bit_array;
function sample(x:std_logic_vector) return integer is begin return to_integer(signed(x));end;
begin
clk<=not clk after 5 ns;
g:for i in 0 to 2 generate
u:entity work.opll port map(xin=>clk,xout=>open,xena=>ena,d=>data,a=>a,cs_n=>cs,we_n=>cs,ic_n=>reset_n,mixout=>outputs(i),ss_hold=>holds(i),ss_addr=>addr,ss_read=>read_en,ss_write=>writes(i),ss_wdata=>wd,ss_rdata=>rd(i),ss_initialized=>ready(i));end generate;
process
 type image_type is array(0 to 99) of std_logic_vector(31 downto 0);variable image,stale:image_type;variable changed:integer:=0;variable bad,badfull,lastbad,lastfull,peak,peakfull,diff,nz:integer:=0;variable sq:real:=0.0;variable row:line;file trace:text;
 procedure host(n:integer:=1) is begin for j in 1 to n loop wait until rising_edge(clk);wait for 1 ns;end loop;end;
 procedure tick(n:integer:=1) is begin for j in 1 to n loop ena<='1';host;ena<='0';host(HOSTS-1);end loop;end;
 procedure regwrite(r,v:integer) is begin a<='0';data<=std_logic_vector(to_unsigned(r,8));cs<='0';tick;cs<='1';tick(5);a<='1';data<=std_logic_vector(to_unsigned(v,8));cs<='0';tick;cs<='1';tick(150);end;
begin
 tick(5);reset_n<='1';tick(1000);
 -- Custom sustained voice with nonzero feedback, slow attack/decay, AM and PM.
 regwrite(0,16#e1#);regwrite(1,16#e1#);regwrite(2,0);regwrite(3,7);regwrite(4,16#74#);regwrite(5,16#74#);regwrite(6,16#24#);regwrite(7,16#24#);
 if SUSTAIN then regwrite(4,16#f0#);regwrite(5,16#f0#);regwrite(6,0);regwrite(7,0);end if;
 for ch in 0 to 8 loop regwrite(16#30#+ch,0);regwrite(16#10#+ch,80+ch*17);regwrite(16#20#+ch,16#17#);end loop;
 if RHYTHM_MODE then regwrite(14,16#3f#);end if;
 tick(1000+POINT);holds<=('1','1','1');tick;
 for w in 0 to 99 loop addr<=std_logic_vector(to_unsigned(w,8));read_en<='1';tick(3);image(w):=rd(0);end loop;read_en<='0';
 -- The uninterrupted control stays frozen at the capture boundary. Both load
 -- instances run into a different future before receiving the same image.
 holds<=('1','0','0');tick(21347);holds<=('1','1','1');tick;
 for w in 0 to 99 loop addr<=std_logic_vector(to_unsigned(w,8));read_en<='1';tick(3);stale(w):=rd(2);if w>=OMIT_LO and w<=OMIT_HI and stale(w)/=image(w) then changed:=changed+1;end if;end loop;read_en<='0';
 for w in 0 to 99 loop addr<=std_logic_vector(to_unsigned(w,8));wd<=image(w);writes(1)<='1';if w<OMIT_LO or w>OMIT_HI then writes(2)<='1';else writes(2)<='0';end if;tick;writes<=('0','0','0');tick;end loop;
 for w in 0 to 99 loop addr<=std_logic_vector(to_unsigned(w,8));read_en<='1';tick(3);assert rd(1)=image(w) report "full state roundtrip mismatch" severity failure;if w>=OMIT_LO and w<=OMIT_HI then assert rd(2)=stale(w) report "omission did not preserve stale state" severity failure;else assert rd(2)=image(w) report "unrelated word mismatch" severity failure;end if;end loop;read_en<='0';addr<=x"ff";tick(8);
 holds<=('0','0','0');
 file_open(trace,"audio.csv",write_mode);write(row,string'("ce,uninterrupted,full,reduced"));writeline(trace,row);
 for t in 1 to FOLLOW loop tick;
  assert not is_x(outputs(0)) and not is_x(outputs(1)) and not is_x(outputs(2)) report "unknown audio" severity failure;
  diff:=abs(sample(outputs(2))-sample(outputs(1)));if diff/=0 then bad:=bad+1;lastbad:=t;end if;if diff>peak then peak:=diff;end if;sq:=sq+real(diff)*real(diff);
  diff:=abs(sample(outputs(1))-sample(outputs(0)));if diff/=0 then badfull:=badfull+1;lastfull:=t;end if;if diff>peakfull then peakfull:=diff;end if;if sample(outputs(1))/=0 then nz:=nz+1;end if;
  if t mod 72=0 then write(row,t);write(row,string'(","));write(row,sample(outputs(0)));write(row,string'(","));write(row,sample(outputs(1)));write(row,string'(","));write(row,sample(outputs(2)));writeline(trace,row);end if;
 end loop;file_close(trace);
 report "RESULT omit="&integer'image(OMIT_LO)&":"&integer'image(OMIT_HI)&" point="&integer'image(POINT)&" rhythm="&boolean'image(RHYTHM_MODE)&" changed="&integer'image(changed)&" hosts="&integer'image(HOSTS)&" sustain="&boolean'image(SUSTAIN)&" follow="&integer'image(FOLLOW)&" bad="&integer'image(bad)&" last="&integer'image(lastbad)&" peak="&integer'image(peak)&" mse="&real'image(sq/real(FOLLOW))&" full_bad="&integer'image(badfull)&" full_last="&integer'image(lastfull)&" full_peak="&integer'image(peakfull)&" nonzero="&integer'image(nz);
 assert nz>0 report "silent reference" severity failure;finish;
end process;end;
