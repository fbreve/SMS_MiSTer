const fs=require('fs'),p=require('path');const d=__dirname;
for(const v of ['B','C']){
 const wd=p.join(d,`analyze_${v}`);fs.mkdirSync(wd,{recursive:true});const base=p.join(d,v);
 const files=[];function walk(dir){for(const e of fs.readdirSync(p.join(base,dir),{withFileTypes:true})){const f=p.posix.join(dir,e.name);if(e.isDirectory())walk(f);else if(e.name.endsWith('.vhd'))files.push(f);}}
 walk('rtl');const text=Object.fromEntries(files.map(f=>[f,fs.readFileSync(p.join(base,f),'utf8')]));
 const names={};for(const f of files)for(const m of text[f].matchAll(/\b(?:entity|package)\s+(\w+)\s+is\b/gi))names[m[1].toLowerCase()]=f;
 const order=[],seen=new Set();function visit(f){if(seen.has(f))return;seen.add(f);const deps=[...text[f].matchAll(/(?:\bentity\s+|\buse\s+|:\s*)work\.(\w+)/gi),...text[f].matchAll(/:\s*(?:work\.)?(\w+)\s+(?:generic|port)\s+map/gi)];for(const m of deps){const child=names[m[1].toLowerCase()];if(child&&child!==f)visit(child);}order.push(f);}
 visit('rtl/system.vhd');
 const vlog=['rtl/jt89/jt89_vol.v','rtl/jt89/jt89_tone.v','rtl/jt89/jt89_noise.v','rtl/jt89/jt89_mixer.v','rtl/jt89/jt89.v','rtl/MC8123.v','rtl/SEGASYS1_PRGDEC.v','rtl/parts.v','rtl/sega_controller.sv'];
 const adapters=[];for(const f of order){let s=text[f];s=s.replace(/(:\s*)work\.(\w+)/g,(all,a,b)=>{adapters.push({file:f,from:all,to:a+'entity work.'+b});return a+'entity work.'+b;});
 if(f.startsWith('rtl/VM2413/')||f==='rtl/mapper_ctrl.vhd'){
  s=s.replace(/\b(VOICE_ID_TYPE|ch_type)'range/gi,(all,t)=>{const to=`${t}'low to ${t}'high`;adapters.push({file:f,from:all,to});return to;});
  const stack=[],insert=[];for(const m of s.matchAll(/\bcase\s+[^;\n]+?\bis\b|\bwhen\s+others\b|\bend\s+case\b/gi)){if(/^case/i.test(m[0]))stack.push(false);else if(/^when/i.test(m[0]))stack[stack.length-1]=true;else if(!stack.pop())insert.push(m.index);}
  for(const i of insert.reverse()){s=s.slice(0,i)+'when others => null; '+s.slice(i);adapters.push({file:f,insert:i,text:'when others => null;'});}
 }
 fs.mkdirSync(p.dirname(p.join(wd,f)),{recursive:true});fs.writeFileSync(p.join(wd,f),s);}
 fs.writeFileSync(p.join(wd,'adapters.json'),JSON.stringify(adapters,null,2));
 fs.writeFileSync(p.join(wd,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib work\nvlog -sv -suppress 2388 -quiet ${vlog.map(f=>`../${v}/${f}`).join(' ')}\n${order.map(f=>`vcom ${f.startsWith('rtl/VM2413/')?'-93':'-2008'} -quiet ${f}`).join('\n')}\necho "PASS production system VHDL analysis ${v}"\nquit -code 0\n`);
 fs.writeFileSync(p.join(wd,'order.json'),JSON.stringify(order,null,2));
}
