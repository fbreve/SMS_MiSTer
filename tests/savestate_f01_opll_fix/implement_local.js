// Reproducible local-access transformation against the frozen Git baseline.
// No parallel snapshot bank: only one registered 32-bit response per hierarchy node.
const fs=require('fs'),p=require('path'),cp=require('child_process');
const dir=__dirname,root=p.resolve(dir,'../..'),map=require('./state_map.json');
const base=require('./baseline.json').head;
const original=f=>cp.execFileSync('git',['show',base+':'+f],{cwd:root}).toString('latin1');
const units={opll:'opll',slotcounter:'opll/s0',controller:'ct',envelopegenerator:'eg',phasegenerator:'pg',operator:'op',outputgenerator:'og',temporalmixer:'tm',attacktable:'eg/u_attack_table',sinetable:'op/u_sine_table',registermemory:'ct/u_register_memory',voicememory:'ct/vmem',phasememory:'pg/MEM',envelopememory:'eg/u_envelope_memory',feedbackmemory:'og/Fmem',outputmemory:'og/Mmem'};
const memoryNames=['registermemory','voicememory','phasememory','envelopememory','feedbackmemory','outputmemory'];
const tree={opll:[['s0','slotcounter'],['s2','slotcounter'],['s5','slotcounter'],['s8','slotcounter'],['ct','controller'],['eg','envelopegenerator'],['pg','phasegenerator'],['op','operator'],['og','outputgenerator'],['tm','temporalmixer']],controller:[['u_register_memory','registermemory'],['vmem','voicememory']],envelopegenerator:[['u_envelope_memory','envelopememory'],['u_attack_table','attacktable']],phasegenerator:[['MEM','phasememory']],operator:[['u_sine_table','sinetable']],outputgenerator:[['Fmem','feedbackmemory'],['Mmem','outputmemory']]};
const ports=`;
        -- F01 private, fixed-latency 32-bit access; no emulated clock enables.
        ss_hold : in std_logic := '0';
        ss_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        ss_read : in std_logic := '0';
        ss_write : in std_logic := '0';
        ss_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        ss_rdata : out std_logic_vector(31 downto 0);
        ss_initialized : out std_logic`;
function closeParen(s,start){let depth=1,comment=false;for(let i=start;i<s.length;i++){if(s[i]==='\n')comment=false;if(s[i]==='-'&&s[i+1]==='-')comment=true;if(comment)continue;if(s[i]==='(')depth++;if(s[i]===')'&&!--depth)return i;}throw Error('parentheses');}
function addPort(s,regex){return s.replace(regex,(full,...args)=>{const start=/\bport\s*\(/i.exec(full);const end=closeParen(full,start.index+start[0].length);return full.slice(0,end)+ports+'\n'+full.slice(end);});}
const sl=(v,lo,w)=>w===1?`${v}(${lo})`:`${v}(${lo+w-1} downto ${lo})`;
const rowFields=unit=>map.rows.filter(r=>r.module===units[unit]&&r.stored&&r.count===1);
const name=r=>r.signal.split(' ')[0];
function fullWidth(r){return r.width;}
function kind(r){const n=name(r);if(r.width===1)return 'bit';if(['slot_voice_addr','user_voice_addr','fb_addr','faddr','vindex'].includes(n))return 'int';if(['user_voice_wdata'].includes(n))return 'voice';if(['fb_wdata','mo_wdata'].includes(n))return 'li';if(n==='memin'&&r.module==='eg')return 'eg';return 'vec';}
function vector(r){const n=name(r),k=kind(r);return k==='int'?`conv_std_logic_vector(${n},${r.width})`:k==='voice'?`CONV_VOICE_VECTOR(${n})`:k==='li'?`CONV_SIGNED_LI_VECTOR(${n})`:k==='eg'?`CONV_EGDATA_VECTOR(${n})`:k==='bit'?`(0 => ${n})`:n;}
function sourceBit(r,index){if(r.module==='ct'&&name(r)==='regs_wdata'&&index>=14)return index+2;return index;}
function readBits(r,s){const n=name(r),k=kind(r);if(k==='bit')return n;if(n==='regs_wdata')return 'regs_wdata(23 downto 16) & regs_wdata(13 downto 0)';const vec=vector(r);if(k==='vec')return sl(vec,sourceBit(r,s.sourceLo),s.width);return sl('ss_v_'+n,s.sourceLo,s.width);}
function assignment(r){const n=name(r),k=kind(r),v='ss_v_'+n;return k==='int'?`conv_integer(${v})`:k==='voice'?`CONV_VOICE(${v})`:k==='li'?`CONV_SIGNED_LI(${v})`:k==='eg'?`CONV_EGDATA(${v})`:k==='bit'?`${v}(0)`:v;}
for(const [unit,module] of Object.entries(units)){
 let s=original('rtl/VM2413/'+unit+'.vhd').replace(/\r\n/g,'\n');
 s=s.replace(new RegExp('entity\\s+'+unit+'\\s+is','i'),m=>'use ieee.std_logic_arith.conv_std_logic_vector;\n'+m);
 // Add ports to this entity and all declarations of accessor children.
 const accessorNames=[unit,...(tree[unit]||[]).map(x=>x[1])];
 for(const n of [...new Set(accessorNames)]){
  const re=new RegExp(`((?:entity\\s+${n}\\s+is|component\\s+${n}\\b)[\\s\\S]*?\\bport\\s*\\([\\s\\S]*?end\\s+(?:${n}|component)\\s*;)`,'gi');
  s=addPort(s,re);
 }
 // Outputs read by the accessor need VHDL-93 buffer mode, without changing QIP language settings.
 s=s.replace(/:\s*out\b/gi,': buffer');
 s=s.replace(/(ss_rdata\s*:\s*)buffer/gi,'$1out').replace(/(ss_initialized\s*:\s*)buffer/gi,'$1out');
 const children=tree[unit]||[];
 let declarations=`\n    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>'0');\n`;
 for(const [label,child] of children)declarations+=`    signal ss_${label}_data : std_logic_vector(31 downto 0);\n    signal ss_${label}_ready : std_logic;\n`;
 let fields=rowFields(unit);
 // Nine nibble entries are local controller scalar history, not a new memory port.
 if(unit==='controller')fields=[map.rows.find(r=>r.module==='ct'&&r.signal==='inst_cache'),...fields];
 const procs=[];
 s=s.replace(/process\s*\(([^)]*)\)([\s\S]*?)\bbegin\b([\s\S]*?)end process\s*;/gi,(whole,sens,decl,body)=>{procs.push({sens,decl,body});return procs.length===1?'-- F01_MERGED_PROCESSES':'';});
 if(!procs.length)throw Error('no process '+unit);
 let localReady="'1'",newProcess='';
 if(memoryNames.includes(unit)){
  const array=map.rows.find(r=>r.module===module&&r.stored&&r.count>1),first=array.slices[0].word,last=array.slices.at(-1).word;
  const cfg={registermemory:['regs_array','init_state',9,'odata','addr','vec',24],voicememory:['voices','init_id',38,'odata','rwaddr','voice',36],phasememory:['phase_array','init_slot',18,'memout','slot','vec',18],envelopememory:['egdata_set','init_slot',18,'rdata','raddr','eg',25],feedbackmemory:['data_array','init_ch',9,'rdata','raddr','li',10],outputmemory:['data_array','init_ch',18,'rdata','addr','li',10]}[unit];
  const [arr,init,limit,out,addr,type,width]=cfg;
  declarations+=`    signal ss_mem_active : std_logic;\n    signal ss_mem_index : integer range 0 to ${limit-1};\n    signal ss_mem_ready : std_logic := '0';\n`;
  if(unit==='voicememory')declarations+="    signal ss_voice_low : std_logic_vector(31 downto 0);\n";
  localReady='ss_mem_ready';
  const conv=type==='voice'?'CONV_VOICE':type==='eg'?'CONV_EGDATA':type==='li'?'CONV_SIGNED_LI':null;
  const readArr=conv?`${conv}(${arr}(ss_mem_index))`:`${arr}(ss_mem_index)`;
  // Reuse the first ordinary synchronous read port: exactly one array read at this site.
  let body=procs[0].body;
  const readRE=new RegExp(`\\b${out}\\s*<=[^;]+;`,'i');
  const oldRead=body.match(readRE)?.[0];if(!oldRead)throw Error('read '+unit);
  body=body.replace(oldRead,`if ss_mem_active='1' then ${out} <= ${readArr}; else ${oldRead} end if;`);
  const start=body.search(/if\s*\(?\s*(?:init_state|init_id|init_slot|init_ch)\b/i);
  const end=body.indexOf(`if ss_mem_active='1'`);
  if(start<0||end<start)throw Error('writer region '+unit);
  const writer=body.slice(start,end);
  const bits=unit==='registermemory'?"ss_wdata(21 downto 14) & \"00\" & ss_wdata(13 downto 0)":unit==='voicememory'?"ss_wdata(3 downto 0) & ss_voice_low":`ss_wdata(${width-1} downto 0)`;
  const lowHalf=`ss_addr(0)='${first%2}'`;
  const write=unit==='voicememory'?`if ${lowHalf} then ss_voice_low<=ss_wdata; else ${arr}(ss_mem_index)<=${bits}; end if;`:`${arr}(ss_mem_index)<=${bits};`;
  body=body.slice(0,start)+`ss_mem_ready <= '0'; if ${init}=${limit} then ss_mem_ready <= '1'; end if;\nif ss_hold='0' then\n${writer}\nelsif ss_write='1' and ss_mem_active='1' then\n${write}\nend if;\n`+body.slice(end);
  // Reset readiness immediately, including reset arriving in an existing VBlank.
  body=body.replace(/(if\s*\(?\s*reset\s*=\s*'1'\s*\)?\s*then)/i,"$1\nss_mem_ready <= '0';");
  newProcess=`process(${procs[0].sens})${procs[0].decl}begin${body}end process;\n`;
  const index=unit==='voicememory'?`(conv_integer(ss_addr)-${first})/2`:`conv_integer(ss_addr)-${first}`;
  newProcess+=`ss_mem_active <= '1' when ss_hold='1' and conv_integer(ss_addr)>=${first} and conv_integer(ss_addr)<=${last} else '0';\nss_mem_index <= ${index} when conv_integer(ss_addr)>=${first} and conv_integer(ss_addr)<=${last} else 0;\n`;
  let outvec=type==='voice'?`CONV_VOICE_VECTOR(${out})`:type==='eg'?`CONV_EGDATA_VECTOR(${out})`:type==='li'?`CONV_SIGNED_LI_VECTOR(${out})`:out;
  declarations+=`    signal ss_mem_vector : std_logic_vector(${width-1} downto 0);\n`;
  newProcess+=`ss_mem_vector <= ${outvec};\n`;
  const pad=n=>n?`(${n-1} downto 0 => '0') & `:'';
  const packed=unit==='registermemory'?`(9 downto 0 => '0') & ss_mem_vector(23 downto 16) & ss_mem_vector(13 downto 0)`:unit==='voicememory'?`ss_mem_vector(31 downto 0) when ss_addr(0)='0' else (27 downto 0 => '0') & ss_mem_vector(35 downto 32)`:`${pad(32-width)}ss_mem_vector`;
  // A separate conditional keeps the read response masked for non-owned addresses.
  newProcess+=unit==='voicememory'?`ss_local_data <= ss_mem_vector(31 downto 0) when ss_mem_active='1' and ${lowHalf} else (27 downto 0 => '0') & ss_mem_vector(35 downto 32) when ss_mem_active='1' else (others=>'0');\n`:`ss_local_data <= ${packed} when ss_mem_active='1' else (others=>'0');\n`;
 }else{
  const clock=unit==='opll'?'xin':'clk';
  let decl=procs.map(x=>x.decl).join('\n');
  for(const r of fields){const n=name(r);decl+=`\nvariable ss_v_${n} : std_logic_vector(${r.width*r.count-1} downto 0);`;}
  decl+='\nvariable ss_response : std_logic_vector(31 downto 0);';
  const varNames=[...decl.matchAll(/variable\s+(\w+)\s*:/gi)].map(x=>x[1]);
  let prepare='',reads='',writes='';
  const allWords=[...new Set(fields.flatMap(r=>r.slices.map(x=>x.word)))];
  for(const r of fields){const n=name(r);if(r.count>1){prepare+=Array.from({length:9},(_,i)=>`ss_v_${n}(${i*4+3} downto ${i*4}) := conv_std_logic_vector(${n}(${i}),4);`).join('\n')+'\n';}else prepare+=`ss_v_${n} := ${vector(r)};\n`;}
  for(const word of allWords){reads+=`when ${word} =>\n`;writes+=`when ${word} =>\n`;
   for(const r of fields)for(const part of r.slices.filter(x=>x.word===word)){
    reads+=`${sl('ss_response',part.wordLo,part.width)} := ${r.count>1?sl('ss_v_'+name(r),part.sourceLo,part.width):readBits(r,part)};\n`;
    if(r.module==='ct'&&name(r)==='regs_wdata'){
     writes+=`ss_v_regs_wdata(15 downto 14) := \"00\"; ss_v_regs_wdata(13 downto 0) := ss_wdata(${part.wordLo+13} downto ${part.wordLo}); ss_v_regs_wdata(23 downto 16) := ss_wdata(${part.wordLo+21} downto ${part.wordLo+14});\n`;
    }else writes+=`${sl('ss_v_'+name(r),part.sourceLo,part.width)} := ${sl('ss_wdata',part.wordLo,part.width)};\n`;
    const n=name(r),op=varNames.includes(n)?':=':'<=';
    if(r.count>1)writes+=Array.from({length:9},(_,i)=>`${n}(${i}) <= conv_integer(ss_v_${n}(${i*4+3} downto ${i*4}));`).join('\n')+'\n';
    else writes+=`${n} ${op} ${assignment(r)};\n`;
   }
  }
  if(unit==='slotcounter'){
   // All four counters consume the same saved base row; only s0 drives reads.
   writes=`when ${allWords[0]} => if conv_integer(ss_wdata(6 downto 0)) >= delay then ff_count <= conv_std_logic_vector(conv_integer(ss_wdata(6 downto 0))-delay,7); else ff_count <= conv_std_logic_vector(conv_integer(ss_wdata(6 downto 0))+72-delay,7); end if;\n`;
   reads=`when ${allWords[0]} => if delay=0 then ss_response(6 downto 0):=ff_count; end if;\n`;
  }
  // Original reset branches retain priority. Their original rising-edge branches
  // only run when hold is low. aridx alone is a permitted stationary cache.
  let resets='',normal='';
  for(const proc of procs){
   const b=proc.body.replace(/--[^\n]*/g,'').trim();
   let parsed=b.match(/^if\s*\(?\s*reset\s*=\s*'1'\s*\)?\s*then([\s\S]*?)elsif\s+rising_edge\(\w+\)\s+then([\s\S]*)end\s+if\s*;\s*$/i);
   if(parsed){resets+=parsed[1]+'\n';normal+=parsed[2]+'\n';}
   else {parsed=b.match(/^if\s+rising_edge\(\w+\)\s+then([\s\S]*)end\s+if\s*;\s*$/i);if(!parsed)throw Error('unsupported process '+unit);normal+=parsed[1]+'\n';}
  }
  let cache='';if(unit==='envelopegenerator'){normal=normal.replace(/aridx\s*<=\s*egphase\([^;]+;/i,'');cache='aridx <= egphase(21 downto 0);';}
  // Signal writes happen after the original bodies (which hold during access).
  // Variable reads must be before those bodies so the representation is pre-edge.
  const access=`ss_response := (others=>'0');\nif ss_hold='1' and (ss_read='1' or ss_write='1') then\n${prepare}\nif ss_read='1' then\ncase conv_integer(ss_addr) is\n${reads}when others => null; end case;\nend if;\nif ss_write='1' then\ncase conv_integer(ss_addr) is\n${writes}when others => null; end case;\nend if;\nend if;\nss_local_data <= ss_response;\n`;
  const hasReset=/\breset\b/.test(procs[0].sens);
  newProcess=`process(${clock}${hasReset?',reset':''})\n${decl}\nbegin\n${hasReset?"if reset='1' then\nss_local_data <= (others=>'0');\n"+resets+`elsif rising_edge(${clock}) then\n`:`if rising_edge(${clock}) then\n`}${cache}\n${access}\nif ss_hold='0' then\n${normal}\nend if;\nend if;\nend process;\n`;
 }
 s=s.replace('-- F01_MERGED_PROCESSES',newProcess);
 // Add narrow ports to each instance, preserving existing named/positional style.
 for(const [label,child] of children){
  const re=new RegExp(`\\b${label}\\s*:\\s*${child}\\b[\\s\\S]*?\\bport\\s+map\\s*\\(`,'i'),m=s.match(re);if(!m)throw Error('instance '+unit+'/'+label);
  const begin=m.index+m[0].length,end=closeParen(s,begin),args=s.slice(begin,end),named=args.includes('=>');
  const extra=named?`ss_hold=>ss_hold, ss_addr=>ss_addr, ss_read=>ss_read, ss_write=>ss_write, ss_wdata=>ss_wdata, ss_rdata=>ss_${label}_data, ss_initialized=>ss_${label}_ready`:`ss_hold,ss_addr,ss_read,ss_write,ss_wdata,ss_${label}_data,ss_${label}_ready`;
  s=s.slice(0,end)+',\n'+extra+s.slice(end);
 }
 let output='ss_rdata <= ss_local_data'+children.map(([l])=>' or ss_'+l+'_data').join('')+';\n';
 output+='ss_initialized <= '+localReady+children.map(([l])=>' and ss_'+l+'_ready').join('')+';\n';
 // Insert declarations before the architecture's begin, not a helper entity's.
 const arch=new RegExp(`architecture\\s+\\w+\\s+of\\s+${unit}\\s+is`,'i').exec(s);if(!arch)throw Error('arch '+unit);
 const idx=s.indexOf('\nbegin',arch.index);if(idx<0)throw Error('begin '+unit);
 s=s.slice(0,idx)+declarations+s.slice(idx);
 s=s.replace(/end\s+(?:rtl|RTL)\s*;\s*$/,output+'\nend rtl;\n');
 fs.writeFileSync(p.join(root,'rtl/VM2413',unit+'.vhd'),s,'latin1');
}
// The public package declaration must match the expanded OPLL component.
let pkg=original('rtl/VM2413/vm2413.vhd');pkg=addPort(pkg,/(component\s+opll\b[\s\S]*?end component\s*;)/gi).replace(/:\s*out\b/gi,': buffer').replace(/(ss_rdata\s*:\s*)buffer/gi,'$1out').replace(/(ss_initialized\s*:\s*)buffer/gi,'$1out');fs.writeFileSync(p.join(root,'rtl/VM2413/vm2413.vhd'),pkg,'latin1');
for(const unit of ['lineartable','voicerom'])fs.writeFileSync(p.join(root,'rtl/VM2413',unit+'.vhd'),original('rtl/VM2413/'+unit+'.vhd').replace(/:\s*out\b/gi,': buffer'),'latin1');
console.log('Generated local interface in '+Object.keys(units).length+' modules plus package.');


