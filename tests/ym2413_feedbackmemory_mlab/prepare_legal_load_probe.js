const fs=require('fs'),p=require('path'),c=require('crypto'),d=__dirname,td=p.join(d,'worktree/tests/ym2413_fullstate');let s=fs.readFileSync(p.join(td,'feedback_collision_tb.vhd'),'utf8').replaceAll('feedback_collision_tb','feedback_legal_load_probe');
s=s.replace('live_consumptions<=live_consumptions+1;assert false report "UNDEFINED COLLISION REACHES ENABLED OPERATOR" severity failure;', 'live_consumptions<=live_consumptions+1;report "PASS RANGE-LEGAL LOAD HAZARD: collision-tainted read reaches enabled Operator; no silicon data corruption asserted";std.env.finish;');
s=s.replace('   -- Independent candidate evolution',`   -- Deliberately constructed format-range-legal payload, not a coherent SAVE-produced pending pipeline.
   expected(100)(0):='1';expected(100)(5 downto 2):=expected(97)(3 downto 0);
   expected(100)(20 downto 11):=not expected(49+to_integer(unsigned(expected(97)(3 downto 0))))(9 downto 0);
   image(100)<=expected(100);host;
   -- Independent candidate evolution`);
s=s.replace('   for i in 1 to 1000 loop host;end loop; -- long CE gap, pending writes may repeat',`   ce<='1';host;assert false report "range-legal hazard not reached" severity failure;`);
fs.writeFileSync(p.join(td,'feedback_legal_load_probe.vhd'),s);const f=p.join(d,'source_manifest.json'),m=JSON.parse(fs.readFileSync(f));m.files['feedback_legal_load_probe.vhd']=c.createHash('sha256').update(s).digest('hex');fs.writeFileSync(f,JSON.stringify(m,null,2)+'\n');
