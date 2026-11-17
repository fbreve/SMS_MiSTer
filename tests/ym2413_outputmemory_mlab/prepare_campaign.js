const fs=require('fs'),p=require('path'),c=require('crypto'),d=__dirname,td=p.join(d,'worktree/tests/ym2413_fullstate'),f=p.join(td,'output_tb.vhd');
let s=fs.readFileSync(f,'utf8');
s=s.replace('variable event_count,verified_events:integer:=0;','variable event_count,verified_events:integer:=0;variable feedback_nonzero:boolean:=false;');
s=s.replace('report "PASS SAVE shift="',`for j in 49 to 57 loop if unsigned(expected(j)(9 downto 0))/=0 then feedback_nonzero:=true;end if;end loop;\n   report "PASS OUTPUT PIPELINE shift="&integer'image(SHIFT)&" pass="&integer'image(pass)&" mo_wr="&std_logic'image(expected(100)(1))&" fb_wr="&std_logic'image(expected(100)(0))&" nonzero_feedback="&boolean'image(feedback_nonzero);\n   report "PASS SAVE shift="`);
s=s.replace('assert loads=2 report "repeated LOAD missing" severity failure;','assert loads=2 report "repeated LOAD missing" severity failure;assert feedback_nonzero report "nonzero feedback not exercised" severity failure;');
fs.writeFileSync(f,s);
const file=p.join(d,'source_manifest.json'),m=JSON.parse(fs.readFileSync(file)),sha=b=>c.createHash('sha256').update(b).digest('hex');m.files['output_tb.vhd']=sha(fs.readFileSync(f));m.files['output_bank_tb.vhd']=sha(fs.readFileSync(p.join(td,'output_bank_tb.vhd')));fs.writeFileSync(file,JSON.stringify(m,null,2)+'\n');
