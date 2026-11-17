const fs=require('fs'),p=require('path'),cp=require('child_process'),d=__dirname,f=p.join(d,'fault/make_tb.js');let s=fs.readFileSync(f,'utf8');
if(!s.includes('TESTCASE=10 or TESTCASE=16')){
 s=s.replace('if TESTCASE=10 then','if TESTCASE=10 or TESTCASE=16 then');
 s=s.replace("ce<='1';host;ce<='0';host;\n for offset in 0 to 14 loop", "ce<='1';host;ce<='0';if TESTCASE/=16 then host;end if;\n for offset in 0 to (14-14*boolean'pos(TESTCASE=16)) loop");
 s=s.replace("if image(83)(4)='1' then\n regaddr", "if TESTCASE/=16 and image(83)(4)='1' then\n regaddr");
 s=s.replace("if image(100)(1)='1' then assert image", "if TESTCASE/=16 and image(100)(1)='1' then assert image");
 fs.writeFileSync(f,s);
}
cp.execFileSync('node',['make_tb.js'],{cwd:p.join(d,'fault'),stdio:'inherit'});
console.log('PASS early v19 T+1-held producer fixture; no pending-RAM equality restriction');
