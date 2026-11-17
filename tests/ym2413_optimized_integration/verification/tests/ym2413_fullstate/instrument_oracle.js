// Simulation-only observation wires. No serializer, ss_rdata or ss_read is used.
// Explicit architectural packing is cross-checked against oracle.tcl at stops.
const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
for(const lib of ['candidate','reference']){
 const files={},read=n=>files[n]??=fs.readFileSync(p.join(d,lib,n+'.vhd'),'latin1');
 function append(n,code){let s=read(n),i=s.toLowerCase().lastIndexOf('end rtl;');assert(i>=0,n);files[n]=s.slice(0,i)+code+'\n'+s.slice(i);}
 function word(n,i,e,width){append(n,`verify_words(${i}) <= ${width===32?'':`(${31-width} downto 0=>'0') & `}${e};`);}
 function mirror(n,items){let s=read(n);const decl=items.map(([name,width])=>`signal vo_${name}:std_logic_vector(${width-1} downto 0);`).join('\n');const b=s.search(/\bbegin\b/i);s=s.slice(0,b)+decl+'\n'+s.slice(b);s=s.replace(/end process;/i,items.map(([name,width])=>`vo_${name} <= ${width===1?'(0=>'+name+')':name==='vindex'?`conv_std_logic_vector(${name},${width})`:name};`).join('\n')+'\nend process;');files[n]=s;}
 let pkg=read('vm2413').replace('package VM2413 is',`package VM2413 is
 type verify_array is array(0 to 103) of std_logic_vector(31 downto 0);
 ${Array.from({length:104},(_,i)=>`signal verify_word_${i}:std_logic_vector(31 downto 0);`).join('\n')}
 signal verify_delays:std_logic_vector(20 downto 0);
 signal verify_factory_voices:std_logic_vector(1295 downto 0);
 signal verify_om_read:std_logic_vector(19 downto 0);
`);files.vm2413=pkg;
 append('outputmemory','verify_om_read <= CONV_SIGNED_LI_VECTOR(rdata) & CONV_SIGNED_LI_VECTOR(rdata2);');
 for(let i=0;i<9;i++)word('registermemory',i,`regs_array(${i})(23 downto 16) & regs_array(${i})(13 downto 0)`,22);
 files.registermemory=read('registermemory').replace('entity RegisterMemory is','use work.vm2413.all;\nentity RegisterMemory is');
 for(let i=0;i<2;i++){word('voicememory',9+2*i,`voices(${i})(31 downto 0)`,32);word('voicememory',10+2*i,`voices(${i})(35 downto 32)`,4);}
 for(let i=2;i<38;i++)append('voicememory',`verify_factory_voices(${(i-1)*36-1} downto ${(i-2)*36}) <= voices(${i});`);
 for(let i=0;i<18;i++){word('phasememory',13+i,`phase_array(${i})`,18);word('envelopememory',31+i,`egdata_set(${i})`,25);word('outputmemory',58+i,`data_array(${i})`,10);}
 for(let i=0;i<9;i++)word('feedbackmemory',49+i,`data_array(${i})`,10);
 // SlotCounter does not otherwise import the VM2413 package.
 files.slotcounter=read('slotcounter').replace('entity SlotCounter is','use work.vm2413.all;\nentity SlotCounter is');
 append('slotcounter',`vo_main: if delay=0 generate verify_words(78)<=(24 downto 0=>'0') & ff_count;end generate;
 vo_d2: if delay=2 generate verify_delays(6 downto 0)<=ff_count;end generate;
 vo_d5: if delay=5 generate verify_delays(13 downto 7)<=ff_count;end generate;
 vo_d8: if delay=8 generate verify_delays(20 downto 14)<=ff_count;end generate;`);
 word('opll',77,'opllwr & oplldat & opllptr',17);word('opll',79,"x\"00000000\"",32);word('opll',103,"x\"00000000\"",32);
 mirror('controller',[['extra_mode',1],['vindex',6]]);
 word('controller',80,Array.from({length:8},(_,j)=>`conv_std_logic_vector(inst_cache(${7-j}),4)`).join(' & '),32);
 word('controller',81,'user_voice_wr & conv_std_logic_vector(user_voice_addr,1) & conv_std_logic_vector(slot_voice_addr,6) & regs_addr & conv_std_logic_vector(inst_cache(8),4)',16);
 const voiceLow='user_voice_wdata.ML & user_voice_wdata.KL & user_voice_wdata.TL & user_voice_wdata.WF & user_voice_wdata.FB & user_voice_wdata.AR & user_voice_wdata.DR & user_voice_wdata.SL & user_voice_wdata.RR';
 word('controller',82,voiceLow,32);
 word('controller',83,'regs_wdata(23 downto 16) & regs_wdata(13 downto 0) & regs_wr & user_voice_wdata.AM & user_voice_wdata.PM & user_voice_wdata.EG & user_voice_wdata.KR',27);
 word('controller',84,'dr & ar & fb & tl & ml & wf & pm & am & rflag(5 downto 0)',31);
 word('controller',85,'vo_vindex(0) & vo_extra_mode & rhythm & key & rks & fnum & blk & rr & sl',28);
 mirror('envelopegenerator',[['lastkey',18],['amphase',20],['egphase',23],['egstate',2],['ntable',18]]);
 word('envelopegenerator',86,'memwr & memin.state & memin.phase & rslot',31);
 word('envelopegenerator',87,'vo_lastkey & egout',31);word('envelopegenerator',88,'vo_amphase',20);word('envelopegenerator',89,'vo_egstate & vo_egphase',25);word('envelopegenerator',90,'vo_ntable',18);
 word('attacktable',91,'ff_d2 & ff_d1 & ff_w',22);word('attacktable',92,'data',13);
 // Lookup-table files do not otherwise import VM2413.
 for(const [file,entity]of [['attacktable','AttackTable'],['sinetable','SineTable']])files[file]=read(file).replace(new RegExp('entity '+entity+' is','i'),'use work.vm2413.all;\nentity '+entity+' is');
 mirror('phasegenerator',[['lastkey',18],['noise14',1],['noise17',1]]);
 word('phasegenerator',93,'pmcount & memin & memwr',32);word('phasegenerator',94,'pgout & noise',19);word('phasegenerator',95,'vo_noise17 & vo_noise14 & vo_lastkey',20);
 word('operator',96,'ff_egout & addr',31);word('operator',97,'opout & conv_std_logic_vector(faddr,4)',18);
 word('sinetable',98,'ff_wf & ff_sign & ff_data1 & ff_data0',24);word('sinetable',99,'ff_data & ff_weight',23);
 word('outputgenerator',100,'mo_wdata.sign & mo_wdata.value & fb_wdata.sign & fb_wdata.value & mo_addr & conv_std_logic_vector(fb_addr,4) & mo_wr & fb_wr',31);
 word('temporalmixer',101,'mix & maddr & mute',20);word('temporalmixer',102,'mixout',14);
 const independent=s=>s.replace(/verify_words\((\d+)\)/g,(_,i)=>'verify_word_'+i);
 for(const [n,s]of Object.entries(files))fs.writeFileSync(p.join(d,lib,n+'.vhd'),independent(s),'latin1');
 const wrapper=lib+'_wrapper.vhd';let s=fs.readFileSync(p.join(d,wrapper),'latin1');const end=s.lastIndexOf('end;');s=s.slice(0,end)+"verify_words(76) <= (22 downto 0=>'0') & fm_d & fm_a;\n"+s.slice(end);fs.writeFileSync(p.join(d,wrapper),independent(s),'latin1');
}
console.log('Prepared independent, read-only continuous state observation buses');
