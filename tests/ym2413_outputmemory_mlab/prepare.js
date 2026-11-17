const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,repo=p.resolve(d,'../..'),wt=p.join(d,'worktree'),td=p.join(wt,'tests/ym2413_fullstate'),old=p.join(repo,'tests/ym2413_registermemory_auto'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(cwd,...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd,stdio:['ignore','pipe','pipe']}),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(git(wt,'rev-parse','HEAD').toString().trim(),base);assert.equal(git(wt,'status','--porcelain').toString(),'');
const list=git(repo,'worktree','list','--porcelain').toString().split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9)).filter(w=>p.resolve(w)!==p.resolve(wt));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify({master:git(repo,'rev-parse','master').toString().trim(),worktrees:Object.fromEntries(list.map(w=>[w,{HEAD:git(w,'rev-parse','HEAD').toString().trim(),diff:hash(git(w,'diff','--binary','HEAD')),status:git(w,'status','--porcelain','--untracked-files=no').toString()}]))},null,2)+'\n');
const file=p.join(wt,'rtl/VM2413/outputmemory.vhd'),src=fs.readFileSync(file,'latin1');assert(src.includes('attribute ramstyle of data_array : signal is "logic";'));fs.writeFileSync(file,src.replace('attribute ramstyle of data_array : signal is "logic";','attribute ramstyle of data_array : signal is "MLAB";'),'latin1');
for(const f of ['prepare_tests.js','instrument_oracle.js'])fs.copyFileSync(p.join(old,'worktree/tests/ym2413_fullstate',f),p.join(td,f));
cp.execFileSync('node',['prepare_tests.js'],{cwd:td,stdio:'inherit'});cp.execFileSync('node',['instrument_oracle.js'],{cwd:td,stdio:'inherit'});
// Identical read-only instrumentation in both independently compiled libraries.
for(const lib of ['reference','candidate']){
 const pkg=p.join(td,lib,'vm2413.vhd');let s=fs.readFileSync(pkg,'latin1').replace('package VM2413 is','package VM2413 is\n signal verify_output_reads:std_logic_vector(29 downto 0);\n signal verify_feedback_read:std_logic_vector(9 downto 0);');fs.writeFileSync(pkg,s,'latin1');
 for(const [name,extra]of [['outputmemory','verify_output_reads <= CONV_SIGNED_LI_VECTOR(rdata) & CONV_SIGNED_LI_VECTOR(rdata2) & data_array(18);'],['feedbackmemory','verify_feedback_read <= CONV_SIGNED_LI_VECTOR(rdata);']]){const f=p.join(td,lib,name+'.vhd');let s=fs.readFileSync(f,'latin1'),i=s.toLowerCase().lastIndexOf('end rtl;');fs.writeFileSync(f,s.slice(0,i)+extra+'\n'+s.slice(i),'latin1');}
}
let tb=fs.readFileSync(p.join(old,'worktree/tests/ym2413_fullstate/auto_tb.vhd'),'utf8').replaceAll('auto_tb','output_tb').replaceAll('PASS AUTO ALL','PASS OUTPUT ALL').replaceAll('AUTO TIMEOUT','OUTPUT TIMEOUT');
tb=tb.replace("assert all_equal=(all_equal'range=>'1') report \"EXACT architectural divergence\" severity failure;","assert all_equal=(all_equal'range=>'1') report \"EXACT architectural divergence\" severity failure;\n  assert candidate_work.vm2413.verify_output_reads=reference_work.vm2413.verify_output_reads report \"OutputMemory read/entry18 divergence\" severity failure;\n  assert candidate_work.vm2413.verify_feedback_read=reference_work.vm2413.verify_feedback_read report \"FeedbackMemory read divergence\" severity failure;");
tb=tb.replace('postponed process(all_equal,checking,','postponed process(candidate_work.vm2413.verify_output_reads,reference_work.vm2413.verify_output_reads,candidate_work.vm2413.verify_feedback_read,reference_work.vm2413.verify_feedback_read,all_equal,checking,');
tb=tb.replace('report "PASS NINE INDEPENDENT REGISTER ENTRIES";',`report "PASS NINE INDEPENDENT REGISTER ENTRIES";\n  assert oracle_word(false,100)(0)='0' or oracle_word(false,100)(0)='1' severity failure;`);
fs.writeFileSync(p.join(td,'output_tb.vhd'),tb);
for(const f of ['run_ghdl.ps1','compile.ps1','one.ps1','campaign.ps1','check_process_tree.ps1']){
 let text=fs.readFileSync(p.join(old,f),'utf8').replaceAll('auto_tb','output_tb').replaceAll('auto_tb.vhd','output_tb.vhd').replaceAll('PASS AUTO ALL','PASS OUTPUT ALL').replaceAll('AUTO CAMPAIGN','OUTPUT CAMPAIGN');
 if(f==='compile.ps1')text=text.replace("'auto_tb.vhd'","'output_tb.vhd'");
 fs.writeFileSync(p.join(d,f),text);
}
fs.writeFileSync(p.join(d,'production.diff'),git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/'));
const files={};for(const lib of ['reference','candidate'])for(const f of fs.readdirSync(p.join(td,lib)))files[lib+'/'+f]=hash(fs.readFileSync(p.join(td,lib,f)));
for(const f of ['output_tb.vhd','reference_wrapper.vhd','candidate_wrapper.vhd'])files[f]=hash(fs.readFileSync(p.join(td,f)));
fs.writeFileSync(p.join(d,'source_manifest.json'),JSON.stringify({base,branch:'experiment/ym2413-outputmemory-mlab',files,productionDiffSHA256:hash(git(wt,'diff',base,'--','SMS.sv','files.qip','rtl/','sys/'))},null,2)+'\n');
console.log('PASS isolated OutputMemory MLAB-only source, independent libraries, full state/read observers and 72-phase campaign prepared');
