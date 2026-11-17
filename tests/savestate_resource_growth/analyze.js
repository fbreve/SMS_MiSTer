const fs=require('fs'),p=require('path'),d=__dirname,root=p.resolve(d,'../..'),rows=JSON.parse(fs.readFileSync(p.join(d,'measurements.json'))),out=[];
for(const r of rows){const tree={'g06_g10_fix':'quartus','g05_background_fix':'quartus_v15','g08_release_fix':'quartus_v16','g12_sdram_fix':'quartus_candidate'}[r.checkpoint]||'candidate',b=r.builds.find(b=>b.tree===tree),base=p.join(root,'tests/savestate_'+r.checkpoint,tree),fit=fs.readFileSync(p.join(base,'output_files/SMS.fit.rpt'),'utf8'),map=fs.readFileSync(p.join(base,'output_files/SMS.map.rpt'),'utf8');
 const start=fit.indexOf('; Non-Global High Fan-Out Signals'),end=fit.indexOf('\n\n',start),fanout=fit.slice(start,end<0?start+8000:end).split(/\r?\n/).filter(x=>/;\s*\d+\s*;/.test(x)).slice(0,20);
 const hierarchy=fit.split(/\r?\n/).filter(x=>/^;\s*\|/.test(x)&&(/;\s*(savestates|vdp_background|vdp_sprites|system|T80)\s*;/.test(x)));
 const mux=map.split(/\r?\n/).filter(x=>/;\s*\d+:1\s*;/.test(x)&&/sprite.*snap|evolution_snap|bg.*snap/.test(x));
 const global=fit.split(/\r?\n/).filter(x=>/ALMs used in final placement|Estimate of ALMs recoverable|Estimate of ALMs unavailable|ALUTs used for routing|ALUTs used for logic/.test(x)).slice(0,12);
 out.push({checkpoint:r.checkpoint,fanout,hierarchy,mux,global});
}
fs.writeFileSync(p.join(d,'hierarchy_fanout_mux.json'),JSON.stringify(out,null,2));
const s=fs.readFileSync(p.join(root,'rtl/savestates.sv'),'utf8'),lines=s.split(/\r?\n/),names=[...s.matchAll(/localparam \[23:0\] (\w+) = 24'h([a-f0-9]+);/g)].map(m=>({name:m[1],value:m[2],comparisons:[...s.matchAll(new RegExp('(?:==|!=)\\s*'+m[1]+'\\b','g'))].length}));
fs.writeFileSync(p.join(d,'compatibility_inventory.json'),JSON.stringify({tagConstants:names,flags:[...new Set(s.match(/\bhas_\w+\b/g))].sort(),sites:lines.map((text,i)=>({line:i+1,text})).filter(x=>/modern_.*tag|load_ext_magic|is_old_format|has_restart|has_background|has_nmi_history|has_evolution_history/.test(x.text))},null,2));
console.log(JSON.stringify(out.filter(x=>['g06_g10_fix','g12_sdram_fix'].includes(x.checkpoint)),null,2));
