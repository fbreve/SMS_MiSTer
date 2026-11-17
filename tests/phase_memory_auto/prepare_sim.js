// Simulation-only compatibility: expand scalar subtype 'range for ModelSim 10.5b VHDL-93.
const fs=require('fs'),p=require('path');const d=__dirname,changes=[];
for(const variant of ['baseline','candidate']){
 const dest=p.join(d,variant+'_sim');fs.mkdirSync(dest,{recursive:true});
 for(const f of fs.readdirSync(p.join(d,variant,'rtl/VM2413')).filter(x=>x.endsWith('.vhd'))){
  const original=fs.readFileSync(p.join(d,variant,'rtl/VM2413',f),'latin1');
  let modified=original.replace(/\b(VOICE_ID_TYPE|ch_type)'range/gi,(m,t)=>`${t}'low to ${t}'high`);
  const stack=[],insert=[];
  for(const m of modified.matchAll(/\bcase\s+[^;\n]+?\bis\b|\bwhen\s+others\b|\bend\s+case\b/gi)){
   if(/^case/i.test(m[0]))stack.push(false);else if(/^when/i.test(m[0]))stack[stack.length-1]=true;else if(!stack.pop())insert.push(m.index);
  }
  for(const i of insert.reverse())modified=modified.slice(0,i)+'when others => null; '+modified.slice(i);
  fs.writeFileSync(p.join(dest,f),modified,'latin1');if(original!==modified)changes.push({variant,file:f,change:"scalar 'range expanded if present; missing case meta-value branches given null behavior",addedNullCases:insert.length});
 }
}
fs.writeFileSync(p.join(d,'simulation_adapters.json'),JSON.stringify(changes,null,2)+'\n');
