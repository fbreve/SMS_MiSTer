const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,repo=p.resolve(d,'../..'),wt=p.join(d,'worktree'),td=p.join(wt,'tests/ym2413_fullstate'),old=p.join(repo,'tests/ym2413_registermemory_auto'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,stdio:['ignore','pipe','pipe']}),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(git(wt,'rev-parse','HEAD').toString().trim(),base);assert.equal(git(wt,'status','--porcelain').toString(),'');
const list=git(repo,'worktree','list','--porcelain').toString().split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9)).filter(w=>p.resolve(w)!==p.resolve(wt));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify({master:git(repo,'rev-parse','master').toString().trim(),worktrees:Object.fromEntries(list.map(w=>[w,{HEAD:git(w,'rev-parse','HEAD').toString().trim(),diff:hash(git(w,'diff','--binary','HEAD')),status:git(w,'status','--porcelain','--untracked-files=no').toString()}]))},null,2)+'\n');
const file=p.join(wt,'rtl/VM2413/feedbackmemory.vhd'),src=fs.readFileSync(file,'latin1');assert(src.includes('attribute ramstyle of data_array : signal is "logic";'));fs.writeFileSync(file,src.replace('attribute ramstyle of data_array : signal is "logic";','attribute ramstyle of data_array : signal is "MLAB";'),'latin1');
for(const f of ['prepare_tests.js','instrument_oracle.js'])fs.copyFileSync(p.join(old,'worktree/tests/ym2413_fullstate',f),p.join(td,f));
cp.execFileSync('node',['prepare_tests.js'],{cwd:td,stdio:'inherit'});cp.execFileSync('node',['instrument_oracle.js'],{cwd:td,stdio:'inherit'});
// Identical read-only instrumentation in both independently compiled libraries.
for(const lib of ['reference','candidate']){
 const pkg=p.join(td,lib,'vm2413.vhd');let s=fs.readFileSync(pkg,'latin1').replace('package VM2413 is','package VM2413 is\n signal verify_output_reads:std_logic_vector(29 downto 0);\n signal verify_feedback_read:std_logic_vector(9 downto 0);');fs.writeFileSync(pkg,s,'latin1');
 for(const [name,extra]of [['outputmemory','verify_output_reads <= CONV_SIGNED_LI_VECTOR(rdata) & CONV_SIGNED_LI_VECTOR(rdata2) & data_array(18);'],['feedbackmemory','verify_feedback_read <= CONV_SIGNED_LI_VECTOR(rdata);']]){const f=p.join(td,lib,name+'.vhd');let s=fs.readFileSync(f,'latin1'),i=s.toLowerCase().lastIndexOf('end rtl;');fs.writeFileSync(f,s.slice(0,i)+extra+'\n'+s.slice(i),'latin1');}
}
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
 text=text.replaceAll('output_tb','feedback_tb').replaceAll('PASS OUTPUT','PASS FEEDBACK');
 if(f==='compile.ps1')text=text.replace("'auto_tb.vhd'","'feedback_tb.vhd'");
 fs.writeFileSync(p.join(d,f),text);
}
fs.writeFileSync(p.join(d,'production.diff'),git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/'));
const files={};for(const lib of ['reference','candidate'])for(const f of fs.readdirSync(p.join(td,lib)))files[lib+'/'+f]=hash(fs.readFileSync(p.join(td,lib,f)));
for(const f of ['feedback_tb.vhd','reference_wrapper.vhd','candidate_wrapper.vhd'])files[f]=hash(fs.readFileSync(p.join(td,f)));
fs.writeFileSync(p.join(d,'source_manifest.json'),JSON.stringify({base,branch:'experiment/ym2413-feedbackmemory-mlab',files,productionDiffSHA256:hash(git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/'))},null,2)+'\n');
console.log('PASS isolated OutputMemory MLAB-only source, independent libraries, full state/read observers and 72-phase campaign prepared');
