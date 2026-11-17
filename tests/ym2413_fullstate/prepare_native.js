// Native VHDL runner of the same calibrated bench. The only write hook replaces
// ModelSim's force-deposit and is deasserted after restore word 0, before word101.
const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
for(const lib of ['candidate','reference']){
 const dest=p.join(d,'native_'+lib);assert(!fs.existsSync(dest),'Refuse overwriting native sources');fs.mkdirSync(dest);
 for(const f of fs.readdirSync(p.join(d,lib)).filter(f=>f.endsWith('.vhd'))){
  let s=fs.readFileSync(p.join(d,lib,f),'latin1');
  if(f==='vm2413.vhd')s=s.replace('package VM2413 is',"package VM2413 is\n signal verify_poison_en:std_logic:='0';\n signal verify_poison:std_logic_vector(13 downto 0):=(others=>'0');");
  if(f==='temporalmixer.vhd')s=s.replace(/end process;/i,"if rising_edge(clk) and ss_hold='1' and verify_poison_en='1' then mix<=verify_poison;end if;\nend process;");
  fs.writeFileSync(p.join(dest,f),s,'latin1');
 }
}
let s=fs.readFileSync(p.join(d,'acc_tb.vhd'),'utf8').replace(/\bacc_tb\b/g,'acc_native_tb').replace('"acc_audio_"','"native_audio_"');
const func=`impure function oracle_word(candidate:boolean;idx:integer) return std_logic_vector is begin case idx is\n${Array.from({length:104},(_,i)=>`when ${i} => if candidate then return c_observe_${i};else return r_observe_${i};end if;`).join('\n')}\nwhen others=>assert false report "oracle address" severity failure;return x"00000000";end case;end;\n`;
s=s.replace('\nbegin\n', '\n'+func+'begin\n');
s=s.replace('variable poison,saved_mix,delta:unsigned(13 downto 0);','variable poison,saved_mix,delta:unsigned(13 downto 0);\n variable expected_words:image_type;variable injection,original,kind,checkpoints:integer:=0;');
const old='procedure mark(n:integer) is begin checkpoint<=n;wait for 1 ns;report "CHECKPOINT "&integer\'image(n);std.env.stop;checkpoint<=0;wait for 1 ns;end;';assert(s.includes(old));
s=s.replace(old,`procedure mark(n:integer) is begin
 checkpoint<=n;wait for 1 ns;
 if n=1 then
  for i in 0 to 103 loop expected_words(i):=oracle_word(false,i);assert image(i)=expected_words(i) report "independent capture packing" severity failure;assert oracle_word(true,i)=expected_words(i) report "pre-save oracle mismatch" severity failure;end loop;
 elsif n=2 then
  original:=to_integer(unsigned(expected_words(101)(19 downto 6)));kind:=pass_number;
  case pass_number is
   when 0=>injection:=8191;
   when 1=>injection:=8192;
   when 2=>if original<8192 then injection:=8192;else injection:=8191;end if;
   when 3=>kind:=3+(SHIFT mod 6);case SHIFT mod 6 is when 0=>injection:=0;when 1=>injection:=16383;when 2=>injection:=5461;when 3=>injection:=10922;when 4=>injection:=(16#2413#+SHIFT*7919) mod 16384;when others=>injection:=(-original) mod 16384;end case;
   when others=>assert false severity failure;
  end case;
  if injection=original then injection:=to_integer(to_unsigned(injection,14) xor to_unsigned(1,14));end if;
  if pass_number=2 then assert (injection<8192)/=(original<8192) report "opposite sign absent" severity failure;end if;
  candidate_work.vm2413.verify_poison<=std_logic_vector(to_unsigned(injection,14));candidate_work.vm2413.verify_poison_en<='1';
  report "POISON shift="&integer'image(SHIFT)&" pass="&integer'image(pass_number)&" kind_id="&integer'image(kind)&" saved="&integer'image(original)&" injected="&integer'image(injection);
 elsif n=3 then
  assert candidate_work.vm2413.verify_poison_en='0' report "poison hook still active during restore" severity failure;
  for i in 0 to 103 loop
   assert oracle_word(false,i)=expected_words(i) report "full reference restoration" severity failure;
   if i=101 then assert (oracle_word(true,i) and x"fff0003f")=(expected_words(i) and x"fff0003f") report "mute/maddr not restored" severity failure;
   else assert oracle_word(true,i)=expected_words(i) report "unrelated candidate restoration" severity failure;end if;
  end loop;
  assert to_integer(unsigned(c_observe_101(19 downto 6)))=injection and injection/=original report "poison did not survive omitted restore" severity failure;
 elsif n=4 then
  for i in 0 to 103 loop if i/=102 then assert oracle_word(true,i)=oracle_word(false,i) report "first reset state divergence" severity failure;end if;end loop;
  assert c_observe_102/=r_observe_102 report "poison did not propagate to output" severity failure;
 elsif n=5 or n=6 or n=7 then assert all_equal=(all_equal'range=>'1') report "full state convergence" severity failure;
 else assert false severity failure;end if;
 checkpoints:=checkpoints+1;report "PASS NATIVE ORACLE checkpoint="&integer'image(n);checkpoint<=0;wait for 1 ns;
end;`);
const clear="cwr<='0';rwr<='0';host;end loop;";assert(s.includes(clear));s=s.replace(clear,"cwr<='0';rwr<='0';if i=0 then candidate_work.vm2413.verify_poison_en<='0';end if;host;end loop;");
s=s.replace('completed<=\'1\';wait for 1 ns;report "PASS ACC ALL";std.env.finish;',`assert checkpoints=28 report "incomplete native oracle coverage" severity failure;completed<='1';wait for 1 ns;report "PASS ACC_NATIVE ALL checkpoints=28";std.env.finish;`);
fs.writeFileSync(p.join(d,'acc_native_tb.vhd'),s);
console.log('Prepared native runner; production and existing ModelSim source libraries unchanged');
