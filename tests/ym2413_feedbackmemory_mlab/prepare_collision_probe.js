const fs=require('fs'),p=require('path'),c=require('crypto'),d=__dirname,td=p.join(d,'worktree/tests/ym2413_fullstate');let s=fs.readFileSync(p.join(td,'feedback_tb.vhd'),'utf8').replaceAll('feedback_tb','feedback_collision_tb');
s=s.replace(' signal safe_equal,all_equal:',` signal previous_collision:std_logic:='0';signal collision_cycles,live_consumptions,normal_collisions:integer:=0;
 signal safe_equal,all_equal:`);
const marker=' -- Continuous architectural equality';
s=s.replace(marker,` process(clk) variable selected,wa,count:integer;variable collided:boolean;
 begin if rising_edge(clk) then
  if reset_n='0' then previous_collision<='0';
  elsif ready='1' then
   if checking='1' and rhold='0' and ce='1' and not is_x(r_observe_78(6 downto 0)) then
    count:=to_integer(unsigned(r_observe_78(6 downto 0)));
    if ((count+72-5) mod 72) mod 4=0 and previous_collision='1' then live_consumptions<=live_consumptions+1;assert false report "UNDEFINED COLLISION REACHES ENABLED OPERATOR" severity failure;end if;
   end if;
   collided:=false;
   if rhold='1' and unsigned(addr)>=49 and unsigned(addr)<=57 then collided:=rwr='1';
   elsif rhold='0' and not is_x(r_observe_100(5 downto 0)) and not is_x(r_observe_97(3 downto 0)) then
    selected:=to_integer(unsigned(r_observe_97(3 downto 0)));wa:=to_integer(unsigned(r_observe_100(5 downto 2)));
    collided:=r_observe_100(0)='1' and wa=selected;if collided then normal_collisions<=normal_collisions+1;end if;
   end if;
   previous_collision<='0';if collided then previous_collision<='1';collision_cycles<=collision_cycles+1;end if;
  end if;
 end if;end process;
`+marker);
s=s.replace('for k in 1 to 411000 loop','for k in 1 to 3000 loop').replace('assert now-follow_start>=115 ms report "follow-up below 115 ms" severity failure;','null; -- Short reachability probe supplements the unchanged 115ms campaign.').replace('assert event_count=9 and verified_events=9 report "late musical scenarios incomplete" severity failure;','null;');
s=s.replace("  completed<='1';report",`  assert live_consumptions=0 and collision_cycles>=18 report "collision-consumption coverage" severity failure;
  report "PASS COLLISION CONSUMPTION shift="&integer'image(SHIFT)&" snapshot_or_raw_collisions="&integer'image(collision_cycles)&" normal_collisions="&integer'image(normal_collisions)&" consumed="&integer'image(live_consumptions);
  completed<='1';report`);
fs.writeFileSync(p.join(td,'feedback_collision_tb.vhd'),s);
const mfile=p.join(d,'source_manifest.json'),m=JSON.parse(fs.readFileSync(mfile));m.files['feedback_collision_tb.vhd']=c.createHash('sha256').update(Buffer.from(s)).digest('hex');fs.writeFileSync(mfile,JSON.stringify(m,null,2)+'\n');
