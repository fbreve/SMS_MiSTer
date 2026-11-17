const fs=require('fs'),p=require('path'),d=__dirname,old=p.resolve(d,'../ym2413_outputmemory_mlab');let s=fs.readFileSync(p.join(old,'prepare.js'),'utf8');s=s.replaceAll('rtl/VM2413/outputmemory.vhd','rtl/VM2413/feedbackmemory.vhd').replaceAll('experiment/ym2413-outputmemory-mlab','experiment/ym2413-feedbackmemory-mlab');
const start=s.indexOf('let tb='),end=s.indexOf("fs.writeFileSync(p.join(td,'output_tb.vhd'),tb);")+"fs.writeFileSync(p.join(td,'output_tb.vhd'),tb);".length;
s=s.slice(0,start)+`let tb=fs.readFileSync(p.join(repo,'tests/ym2413_outputmemory_mlab/worktree/tests/ym2413_fullstate/output_tb.vhd'),'utf8').replaceAll('output_tb','feedback_tb').replaceAll('PASS OUTPUT','PASS FEEDBACK').replaceAll('OUTPUT TIMEOUT','FEEDBACK TIMEOUT');
const inject=\`   for j in 49 to 57 loop
    addr<=std_logic_vector(to_unsigned(j,8));wd<=std_logic_vector(to_unsigned(feedback_pattern(j-49,pass),32));cwr<='1';rwr<='1';host;cwr<='0';rwr<='0';host;
   end loop;
   addr<=x"ff";host;
\`;
tb=tb.replace('   for i in 0 to 103 loop addr<=',inject+'   for i in 0 to 103 loop addr<=');
tb=tb.replace('  procedure host is begin',\`  function feedback_pattern(i,pass:integer) return integer is
   type patterns_type is array(0 to 8) of integer;constant patterns:patterns_type:=(0,511,512,1023,341,682,1,513,510);
  begin return patterns((i+SHIFT+pass) mod 9);end;
  procedure host is begin\`);
tb=tb.replace('   for j in 49 to 57 loop if',\`   for j in 49 to 57 loop assert expected(j)=std_logic_vector(to_unsigned(feedback_pattern(j-49,pass),32)) report "independent feedback sign/magnitude snapshot expectation" severity failure;end loop;
   for j in 49 to 57 loop if\`);
fs.writeFileSync(p.join(td,'feedback_tb.vhd'),tb);\n`+s.slice(end);
s=s.replaceAll('output_tb','feedback_tb').replaceAll('PASS OUTPUT ALL','PASS FEEDBACK ALL').replaceAll('OUTPUT CAMPAIGN','FEEDBACK CAMPAIGN');
// Use the tested active-time watchdog and campaign runners from OutputMemory.
s=s.replace("p.join(old,f)","p.join(repo,'tests/ym2413_outputmemory_mlab',f)");
s=s.replace("for(const f of ['run_ghdl.ps1','compile.ps1','one.ps1','campaign.ps1','check_process_tree.ps1'])", "for(const f of ['run_ghdl.ps1','compile.ps1','one.ps1','campaign.ps1','check_process_tree.ps1'])");
s=s.replace("replaceAll('feedback_tb','feedback_tb')", "replaceAll('output_tb','feedback_tb')").replace("replaceAll('feedback_tb.vhd','feedback_tb.vhd')", "replaceAll('output_tb.vhd','feedback_tb.vhd')");
fs.writeFileSync(p.join(d,'prepare.js'),s);
let v=fs.readFileSync(p.join(old,'verify.js'),'utf8').replaceAll('rtl/VM2413/outputmemory.vhd','rtl/VM2413/feedbackmemory.vhd').replace("if(f==='outputmemory.vhd')","if(f==='feedbackmemory.vhd')").replaceAll('OutputMemory MLAB-only','FeedbackMemory MLAB-only');fs.writeFileSync(p.join(d,'verify.js'),v);
