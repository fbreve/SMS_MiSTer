const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,repo=p.resolve(d,'../..'),wt=p.join(d,'worktree'),td=p.join(wt,'tests/ym2413_fullstate'),old=p.join(repo,'tests/ym2413_registermemory_auto'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,stdio:['ignore','pipe','pipe']}),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
let tb=fs.readFileSync(p.join(repo,'tests/ym2413_outputmemory_mlab/worktree/tests/ym2413_fullstate/output_tb.vhd'),'utf8').replaceAll('output_tb','feedback_tb').replaceAll('PASS OUTPUT','PASS FEEDBACK').replaceAll('OUTPUT TIMEOUT','FEEDBACK TIMEOUT');
const inject=`   for j in 49 to 57 loop
    addr<=std_logic_vector(to_unsigned(j,8));wd<=std_logic_vector(to_unsigned(feedback_pattern(j-49,pass),32));cwr<='1';rwr<='1';host;cwr<='0';rwr<='0';host;
   end loop;
   addr<=x"ff";host;
`;
tb=tb.replace('   for i in 0 to 103 loop addr<=',inject+'   for i in 0 to 103 loop addr<=');
tb=tb.replace('  procedure host is begin',`  function feedback_pattern(i,pass:integer) return integer is
   type patterns_type is array(0 to 8) of integer;constant patterns:patterns_type:=(0,511,512,1023,341,682,1,513,510);
  begin return patterns((i+SHIFT+pass) mod 9);end;
  procedure host is begin`);
tb=tb.replace('   for j in 49 to 57 loop if',`   for j in 49 to 57 loop assert expected(j)=std_logic_vector(to_unsigned(feedback_pattern(j-49,pass),32)) report "independent feedback sign/magnitude snapshot expectation" severity failure;end loop;
   for j in 49 to 57 loop if`);
fs.writeFileSync(p.join(td,'feedback_tb.vhd'),tb);

for(const f of ['run_ghdl.ps1','compile.ps1','one.ps1','campaign.ps1','check_process_tree.ps1']){
 let text=fs.readFileSync(p.join(repo,'tests/ym2413_outputmemory_mlab',f),'utf8').replaceAll('auto_tb','feedback_tb').replaceAll('auto_tb.vhd','feedback_tb.vhd').replaceAll('PASS AUTO ALL','PASS FEEDBACK ALL').replaceAll('AUTO CAMPAIGN','FEEDBACK CAMPAIGN');
 if(f==='compile.ps1')text=text.replace("'auto_tb.vhd'","'feedback_tb.vhd'");
 fs.writeFileSync(p.join(d,f),text);
}
fs.writeFileSync(p.join(d,'production.diff'),git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/'));
const files={};for(const lib of ['reference','candidate'])for(const f of fs.readdirSync(p.join(td,lib)))files[lib+'/'+f]=hash(fs.readFileSync(p.join(td,lib,f)));
for(const f of ['feedback_tb.vhd','reference_wrapper.vhd','candidate_wrapper.vhd'])files[f]=hash(fs.readFileSync(p.join(td,f)));
fs.writeFileSync(p.join(d,'source_manifest.json'),JSON.stringify({base,branch:'experiment/ym2413-feedbackmemory-mlab',files,productionDiffSHA256:hash(git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/'))},null,2)+'\n');
console.log('PASS isolated OutputMemory MLAB-only source, independent libraries, full state/read observers and 72-phase campaign prepared');
