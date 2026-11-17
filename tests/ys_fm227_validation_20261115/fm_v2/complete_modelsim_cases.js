const fs=require('fs');const changes={};
for(const f of fs.readdirSync('candidate').filter(q=>q.endsWith('.vhd'))){
 let s=fs.readFileSync('candidate/'+f,'utf8'),stack=[],inserts=[];
 const re=/\bend\s+case\s*;|\bcase\s+[^;\n]+?\s+is\b|\bwhen\s+others\s*=>/gi;let m;
 while((m=re.exec(s))){if(/^end/i.test(m[0])){const c=stack.pop();if(c&&!c.other)inserts.push(m.index);}else if(/^when/i.test(m[0])){if(stack.length)stack[stack.length-1].other=true;}else stack.push({other:false});}
 if(inserts.length){for(const at of inserts.reverse())s=s.slice(0,at)+'when others => null; '+s.slice(at);fs.writeFileSync('candidate/'+f,s);changes[f]=inserts.length;}
}
fs.writeFileSync('case_completion_adapter.json',JSON.stringify({reason:'ModelSim requires coverage of nonbinary std_logic values and unreachable integer alternatives; null complements add no valid-state transition',changes},null,2));
