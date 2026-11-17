// Verification-only copies; never write a production/worktree source.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:root,encoding:'latin1'});
const hash=s=>crypto.createHash('sha256').update(s).digest('hex');
const names='vm2413 slotcounter voicerom voicememory registermemory attacktable envelopememory envelopegenerator phasememory phasegenerator sinetable operator feedbackmemory outputmemory lineartable outputgenerator temporalmixer controller opll'.split(' ');
const wts=git('worktree','list','--porcelain').split(/\r?\n/).filter(x=>x.startsWith('worktree ')).map(x=>x.slice(9));
const snapshot=()=>({master:git('rev-parse','master').trim(),trees:wts.map(w=>({path:w,head:cp.execFileSync('git',['--no-optional-locks','-C',w,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),diff:hash(cp.execFileSync('git',['--no-optional-locks','-C',w,'diff','HEAD','--binary'])),status:cp.execFileSync('git',['--no-optional-locks','-C',w,'status','--porcelain','--untracked-files=no'],{encoding:'utf8'})}))});
if(!fs.existsSync(p.join(d,'preservation_before.json')))fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify(snapshot(),null,2));
function adapt(s){s=s.replace(/\bRelease\b/g,'EG_Release').replace(/VOICE_ID_TYPE'range/gi,'0 to 37').replace(/ch_type'range/gi,'0 to 8');let stack=[],ins=[];const clean=s.replace(/--[^\r\n]*/g,m=>' '.repeat(m.length));for(const m of clean.matchAll(/\bcase\s+[^;\n]+?\bis\b|\bwhen\s+others\b|\bend\s+case\b/gi)){if(/^case/i.test(m[0]))stack.push(false);else if(/^when/i.test(m[0]))stack[stack.length-1]=true;else if(!stack.pop())ins.push(m.index);}for(const i of ins.reverse())s=s.slice(0,i)+'when others => null; '+s.slice(i);return s.replace(/\bprocess\(clk,reset\)/,'oracle_process: process(clk,reset)');}
for(const lib of ['reference','candidate']){fs.mkdirSync(p.join(d,lib),{recursive:true});for(const n of names)fs.writeFileSync(p.join(d,lib,n+'.vhd'),adapt(git('show',base+':rtl/VM2413/'+n+'.vhd')),'latin1');fs.copyFileSync(p.join(root,'tests/ym2413_feedbackmemory_mlab/worktree/tests/ym2413_fullstate',lib+'_wrapper.vhd'),p.join(d,lib+'_wrapper.vhd'));}
// Existing independent internal-state oracle; copied into this isolated harness.
let oracle=fs.readFileSync(p.join(root,'tests/ym2413_registermemory_auto/worktree/tests/ym2413_fullstate/instrument_oracle.js'),'utf8');
// Wrappers copied above already contain their observation wire.
oracle=oracle.slice(0,oracle.indexOf(" const wrapper=lib+'_wrapper.vhd'"))+"\n}\n";
fs.writeFileSync(p.join(d,'instrument_oracle.js'),oracle);cp.execFileSync('node',['instrument_oracle.js'],{cwd:d});
for(const lib of ['reference','candidate']){
 const pf=p.join(d,lib,'vm2413.vhd');let s=fs.readFileSync(pf,'latin1');s=s.replace('package VM2413 is',`package VM2413 is
 signal fault_mode:integer range 0 to 6:=0;
 signal fault_target:integer range 0 to 2:=0;
 signal probe_reg_q:std_logic_vector(23 downto 0);
 signal probe_out_q1,probe_out_q2:std_logic_vector(9 downto 0);
 signal probe_reg_collision,probe_out_collision1,probe_out_collision2:std_logic:='0';
 function collision_value(old_value,new_value:std_logic_vector;mode:integer) return std_logic_vector;
`);
 s=s.replace(/package body VM2413 is/i,`package body VM2413 is
 function collision_value(old_value,new_value:std_logic_vector;mode:integer) return std_logic_vector is
 variable v:std_logic_vector(old_value'range);begin
 case mode is when 0=>v:=old_value;when 1=>v:=new_value;when 2=>v:=(others=>'0');when 3=>v:=(others=>'1');when 4=>for i in v'range loop if i mod 2=0 then v(i):='1';else v(i):='0';end if;end loop;when 5=>v:=not old_value;when others=>v:=(others=>'1');if v'length=24 then v(15 downto 14):="00";end if;end case;return v;end;
`);fs.writeFileSync(pf,s,'latin1');
 for(const n of ['registermemory','outputmemory']){const f=p.join(d,lib,n+'.vhd');s=fs.readFileSync(f,'latin1');const pos=s.toLowerCase().lastIndexOf('end rtl;');s=s.slice(0,pos)+(n==='registermemory'?'probe_reg_q<=odata;':'probe_out_q1<=CONV_SIGNED_LI_VECTOR(rdata);probe_out_q2<=CONV_SIGNED_LI_VECTOR(rdata2);')+'\n'+s.slice(pos);
 if(n==='registermemory')s=s.replace("            ss_mem_ready <= '0'; if init_state",`            probe_reg_collision<='0';
            if init_state=9 and ((ss_hold='0' and wr='1') or (ss_hold='1' and ss_write='1' and ss_mem_active='1')) then probe_reg_collision<='1';end if;
            ss_mem_ready <= '0'; if init_state`);
 else s=s.replace("      ss_mem_ready <= '0'; if init_ch",`      probe_out_collision1<='0';probe_out_collision2<='0';
      if init_ch=18 then
       if ss_hold='0' and wr='1' then probe_out_collision1<='1';if addr=addr2 then probe_out_collision2<='1';end if;
       elsif ss_hold='1' and ss_write='1' and ss_mem_active='1' then probe_out_collision1<='1';if ss_mem_index=conv_integer(addr2) then probe_out_collision2<='1';end if;end if;
      end if;
      ss_mem_ready <= '0'; if init_ch`);
 if(lib==='candidate'){
 if(n==='registermemory')s=s.replace("if ss_mem_active='1' then odata <= regs_array(ss_mem_index); else odata <= regs_array( conv_integer(addr) ); end if;",`if ss_mem_active='1' then odata <= regs_array(ss_mem_index); else odata <= regs_array(conv_integer(addr));end if;
 if fault_target=1 and init_state=9 then
 if ss_hold='0' and wr='1' then odata<=collision_value(regs_array(conv_integer(addr)),idata,fault_mode);
 elsif ss_hold='1' and ss_write='1' and ss_mem_active='1' then odata<=collision_value(regs_array(ss_mem_index),ss_wdata(21 downto 14)&"00"&ss_wdata(13 downto 0),fault_mode);end if;end if;`);
 else s=s.replace('      rdata2 <= CONV_SIGNED_LI(data_array(conv_integer(addr2)));',`      rdata2 <= CONV_SIGNED_LI(data_array(conv_integer(addr2)));
 if fault_target=2 and init_ch=18 then
 if ss_hold='0' and wr='1' then
 rdata<=CONV_SIGNED_LI(collision_value(data_array(conv_integer(addr)),CONV_SIGNED_LI_VECTOR(wdata),fault_mode));
 if addr=addr2 then rdata2<=CONV_SIGNED_LI(collision_value(data_array(conv_integer(addr2)),CONV_SIGNED_LI_VECTOR(wdata),fault_mode));end if;
 elsif ss_hold='1' and ss_write='1' and ss_mem_active='1' then
 rdata<=CONV_SIGNED_LI(collision_value(data_array(ss_mem_index),ss_wdata(9 downto 0),fault_mode));
 if ss_mem_index=conv_integer(addr2) then rdata2<=CONV_SIGNED_LI(collision_value(data_array(ss_mem_index),ss_wdata(9 downto 0),fault_mode));end if;end if;end if;`);
 }
 // Initialization collisions are included as well. Preserve the pre-edge
 // initialization index because the production process increments its variable.
 if(n==='registermemory'){
 s=s.replace('variable init_state : integer range 0 to 9;','variable init_state : integer range 0 to 9;\n variable init_before:integer range 0 to 9;');
 s=s.replace('elsif rising_edge(clk) then','elsif rising_edge(clk) then\n init_before:=init_state;');
 if(lib==='candidate')s=s.replace(" if fault_target=1 and init_state=9 then",` if fault_target=1 and init_before<9 and ss_hold='0' and conv_integer(addr)=init_before then odata<=collision_value(regs_array(init_before),x"000000",fault_mode);end if;
 if fault_target=1 and init_before=9 then`);
 }else{
 s=s.replace('variable init_ch : integer range 0 to 18;','variable init_ch : integer range 0 to 18;\n variable init_before:integer range 0 to 18;');
 s=s.replace('elsif rising_edge(clk) then','elsif rising_edge(clk) then\n init_before:=init_ch;');
 if(lib==='candidate')s=s.replace(" if fault_target=2 and init_ch=18 then",` if fault_target=2 and init_before<18 and ss_hold='0' then
 if conv_integer(addr)=init_before then rdata<=CONV_SIGNED_LI(collision_value(data_array(init_before),"0000000000",fault_mode));end if;
 if conv_integer(addr2)=init_before then rdata2<=CONV_SIGNED_LI(collision_value(data_array(init_before),"0000000000",fault_mode));end if;end if;
 if fault_target=2 and init_before=18 then`);
 }
 fs.writeFileSync(f,s,'latin1');}
}
// Exact production validator, independently executed by ModelSim.
const src=git('show',base+':rtl/savestates.sv'),a=src.indexOf('function fm_word_valid;'),b=src.indexOf('endfunction',a)+11;
fs.writeFileSync(p.join(d,'validator_function.svh'),src.slice(a,b));
fs.writeFileSync(p.join(d,'source_manifest.json'),JSON.stringify({baseline:base,files:Object.fromEntries(names.map(n=>['rtl/VM2413/'+n+'.vhd',hash(Buffer.from(git('show',base+':rtl/VM2413/'+n+'.vhd'),'latin1'))])),instrumented:Object.fromEntries(['reference','candidate'].flatMap(l=>names.map(n=>[l+'/'+n+'.vhd',hash(fs.readFileSync(p.join(d,l,n+'.vhd')))])))},null,2));
console.log('Prepared isolated baseline copies, internal oracle, and test-only collision injection.');
