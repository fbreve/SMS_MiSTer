const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,s=fs.readFileSync(p.join(d,'synthesis/candidate/functional_netlist/SMS.vo'),'utf8');
const modules=new Map();for(const m of s.matchAll(/^module\s+(\S+)\s*\([\s\S]*?^endmodule/gm))modules.set(m[1],m[0]);
const text=modules.get('FeedbackMemory');assert(text);fs.writeFileSync(p.join(d,'synthesis/FeedbackMemory_mapped.v'),text+'\n');
const names=[];for(const m of text.matchAll(/^([\w$]+)\s+(\\[^\s]+\s|[\w$]+)\s*\(/gm))names.push([m[1],m[2].trim()]);
console.log(JSON.stringify({bytes:text.length,instances:names},null,2));
for(const [type]of names)if(modules.has(type))fs.writeFileSync(p.join(d,'synthesis',type+'_mapped.v'),modules.get(type)+'\n');
