const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'search_opll');fs.mkdirSync(dst,{recursive:true});
fs.writeFileSync(p.join(d,'audit_pkg.vhd'),`library ieee;use ieee.std_logic_1164.all;package audit_pkg is signal audit_action:integer:=0;signal audit_omit:integer:=0;end package;`);
const manifest=[];
for(const f of fs.readdirSync(p.join(d,'sim_opll')).filter(f=>f.endsWith('.vhd'))){let s=fs.readFileSync(p.join(d,'sim_opll',f),'latin1');let group=/^slotcounter/.test(f)?6:/^(controller|registermemory|voicememory|voicerom)/.test(f)?7:/^phase/.test(f)?2:/^(envelope|attack)/.test(f)?3:/^(output|feedback|linear)/.test(f)?4:/^(operator|sinetable)/.test(f)?5:/^temporalmixer/.test(f)?8:1;
 s=s.replace(/architecture\s+(\w+)\s+of\s+/gi,'use work.audit_pkg.all;\narchitecture $1 of ');
 s=s.replace(/process\s*\(([^)]*)\)([\s\S]*?)\bbegin\b([\s\S]*?)end process\s*;/gi,(whole,sens,decl,body)=>{
  const vars=[...decl.matchAll(/variable\s+(\w+)\s*:\s*([^;]+);/gi)].map(m=>({name:m[1],type:m[2]}));
  const sigs=[...new Set([...body.matchAll(/^\s*([a-zA-Z]\w*)(?:\([^;\n]*?\))?(?:\.\w+)?\s*<=/gm)].map(m=>m[1]))];
  if(!vars.length&&!sigs.length)return whole;
  manifest.push({file:f,group,signals:sigs,variables:vars.map(v=>v.name)});
  const ds=sigs.map(n=>`variable audit_s_${n} : ${n}'subtype;`).join('\n')+'\n'+vars.map(v=>`variable audit_v_${v.name} : ${v.type};`).join('\n');
  const take=sigs.map(n=>`audit_s_${n}:=${n};`).join('\n')+'\n'+vars.map(v=>`audit_v_${v.name}:=${v.name};`).join('\n');
  const caches={registermemory:['odata'],voicememory:['odata','rodata'],voicerom:['data'],phasememory:['memout'],envelopememory:['rdata'],feedbackmemory:['rdata'],outputmemory:['rdata','rdata2'],lineartable:['ff_sign','ff_weight','ff_data0','ff_data1','data']};
  const derived=caches[f.replace('.vhd','')]||[];
  const put=sigs.map(n=>f==='feedbackmemory.vhd'&&n==='data_array'?`if audit_omit/=10 then ${n}<=audit_s_${n}; end if;`:derived.includes(n)?`if audit_omit/=9 then ${n}<=audit_s_${n}; end if;`:`${n}<=audit_s_${n};`).join('\n')+'\n'+vars.map(v=>`${v.name}:=audit_v_${v.name};`).join('\n');
  return `process(${sens})${decl}\n${ds}\nbegin\nif audit_action=1 then\n if rising_edge(clk) then\n${take}\nend if;\nelsif audit_action=2 then\nif rising_edge(clk) and audit_omit/=${group} then\n${put}\nend if;\nelse\n${body}\nend if;\nend process;`.replaceAll('rising_edge(clk)',sens.includes('xin')?'rising_edge(xin)':'rising_edge(clk)');
 });
 fs.writeFileSync(p.join(dst,f),s,'latin1');
}
fs.writeFileSync(p.join(d,'search_manifest.json'),JSON.stringify(manifest,null,2));
const files=['vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll'];
fs.writeFileSync(p.join(d,'search_compile.do'),`onerror {quit -code 1}\nvlib search_work\nvcom -work search_work -2008 audit_pkg.vhd ${files.map(f=>'search_opll/'+f+'.vhd').join(' ')} search_tb.vhd\nquit -code 0\n`);
