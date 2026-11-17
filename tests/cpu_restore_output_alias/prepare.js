const fs=require('fs'),p=require('path'),assert=require('assert'),cp=require('child_process');const d=__dirname,r=p.resolve(d,'../..');
require('./verify');
const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n');
assert(read(p.join(d,'consumer_proof.md')).includes('source proof PASSES'));
const base=read(p.join(r,'rtl/savestates.sv'));
let candidate=base.replace(/output reg(\s+\[229:0\]\s+z80_dir)/,'output wire$1');
assert(candidate!==base,'exact output declaration');
candidate=candidate.replace('reg [229:0] z80_snap;','reg [229:0] z80_snap;\nassign z80_dir = z80_snap;');
assert.equal((candidate.match(/z80_dir\s*<=\s*z80_snap;/g)||[]).length,1);
candidate=candidate.replace(/^.*z80_dir\s*<=\s*z80_snap;\n/m,'');
const out=p.join(d,'candidate/rtl/savestates.sv');fs.mkdirSync(p.dirname(out),{recursive:true});fs.writeFileSync(out,candidate);
const adapter=require('../savestate_g06_g10_fix/controller_adapter');
fs.writeFileSync(p.join(d,'baseline_sim.sv'),adapter(p.join(r,'rtl/savestates.sv')));
fs.writeFileSync(p.join(d,'candidate_sim.sv'),adapter(out).replace('module savestates #','module savestates_alias #'));
assert(read(p.join(d,'candidate_sim.sv')).includes('module savestates_alias #'));
const header=base.slice(base.indexOf('module savestates'),base.indexOf('\n);')).replace(/\/\/[^\n]*/g,'');
const outputs=[],inputs=[];
for(const m of header.matchAll(/\b(input|output)\s+(?:(?:reg|wire)\s+)?(\[[^\]]+\])?\s*([\s\S]*?)(?=\binput\b|\boutput\b|$)/g)){
 for(const name of m[3].split(',').map(x=>x.trim()).filter(Boolean)){assert(/^\w+$/.test(name),name);if(m[1]==='input')inputs.push(name);else outputs.push({width:m[2]||'',name});}
}
assert(outputs.some(x=>x.name==='z80_dir'));assert(inputs.includes('DDRAM_BUSY'));
function miter(){return `\n// Complete controller outputs: four-state equality, except inactive CPU data.\n`+
 outputs.map(x=>`wire ${x.width} alias_${x.name};`).join('\n')+
 `\nsavestates_alias #(.TB_FAST(dut.TB_FAST)) alias_ctl(\n`+[...inputs.map(n=>`.${n}(dut.${n})`),...outputs.map(x=>`.${x.name}(alias_${x.name})`)].join(',\n')+`);\n`+
 `integer alias_cycles=0,alias_consumes=0,alias_inactive=0,alias_writes=0,alias_reads=0;\nalways @(posedge clk)begin\n alias_cycles++;\n`+
 outputs.filter(x=>x.name!=='z80_dir').map(x=>`if(dut.${x.name} !== alias_${x.name})$fatal(1,"ALIAS controller output ${x.name} cycle%0d",alias_cycles);`).join('\n')+
 `\nif(dut.z80_set)begin alias_consumes++;if(dut.z80_dir!==alias_z80_dir)$fatal(1,"ALIAS consumed DIR mismatch");end\nelse if(dut.z80_dir!==alias_z80_dir)alias_inactive++;\nif(dut.DDRAM_WE&&!dut.DDRAM_BUSY)alias_writes++;\nif(dut.DDRAM_RD&&!dut.DDRAM_BUSY)alias_reads++;\nend\nfinal $display("ALIAS MITER cycles%0d consumes%0d inactive%0d writes%0d reads%0d",alias_cycles,alias_consumes,alias_inactive,alias_writes,alias_reads);\n`;}
function shadowCPU(s,vhdl){
 const m=s.match(/T80s\s*(?:#\([\s\S]*?\))?\s+cpu\s*\(/);assert(m,'real T80s instance');let start=m.index,end=start+m[0].length,depth=1;
 while(depth){if(s[end]==='(')depth++;if(s[end]===')')depth--;end++;}assert.equal(s[end],';');
 let inst=s.slice(start,end+1),ports=[];const re=/\.(\w+)\(/g;let x;while((x=re.exec(inst))){let at=re.lastIndex,j=at,n=1;while(n){if(inst[j]==='(')n++;if(inst[j]===')')n--;j++;}ports.push({name:x[1],expr:inst.slice(at,j-1),at,end:j-1});re.lastIndex=j;}
 const outnames=[...vhdl.matchAll(/(\w+)\s*:\s*out\s+(?:std_logic|std_logic_vector)/gi)].map(x=>x[1].toLowerCase());
 let decl='',checks='';for(const x of ports.slice().reverse()){
  let expr=x.expr;if(outnames.includes(x.name.toLowerCase())){if(expr){const n='alias_cpu_'+x.name;decl+=`wire[$bits(${expr})-1:0]${n};\n`;checks+=`if(${n}!==${expr})$fatal(1,"ALIAS real CPU ${x.name}");\n`;expr=n;}}
  else {expr=expr.replace(/\bdut\./g,'alias_ctl.');for(const o of outputs){const n=o.name;if(expr===n)expr='alias_'+n;}}
  inst=inst.slice(0,x.at)+expr+inst.slice(x.end);
 }
 inst=inst.replace(/\bcpu\s*\(/,'alias_cpu(');
 return decl+inst+'\nalways@(posedge clk)begin #1;'+checks+'end\n';
}
function copyFiles(src,dst){fs.mkdirSync(dst,{recursive:true});for(const name of fs.readdirSync(src)){const f=p.join(src,name);if(fs.statSync(f).isFile()&&/\.(sv|svh|vhd|v|hex|do)$/.test(name))fs.copyFileSync(f,p.join(dst,name));}}
const specs=[['g03','savestate_g05_background_fix/integrated_g03',['dut_bus']],['g10','savestate_f01_opll_fix/reg_g10',['dut_phases','dut_deterministic','dut_full_flush']],['dual','savestate_f01_opll_fix/reg_dual',['dut_collision']]];
let manifest=[];
for(const[fam,rel,cases]of specs){const src=p.join(r,'tests',rel),dst=p.join(d,'native_'+fam);copyFiles(src,dst);fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
 fs.copyFileSync(p.join(d,'baseline_sim.sv'),p.join(dst,'savestates_sim.sv'));fs.copyFileSync(p.join(d,'candidate_sim.sv'),p.join(dst,'candidate_sim.sv'));
 for(const name of fs.readdirSync(dst).filter(x=>/\.(sv|svh)$/.test(x)&&!x.endsWith('_sim.sv'))){let s=read(p.join(dst,name));
  if(/savestates\s+dut\(/.test(s)){let pins='';if(!s.includes('.fm_initialized('))pins+=".fm_initialized(1'b1),.fm_state_rdata(32'd0),";if(!s.includes('.audio_last_out('))pins+=".audio_last_out(16'd0),";s=s.replace(/savestates\s+dut\(/,'savestates dut('+pins);}
  s=s.replaceAll("mem[26][63:40]=24'h48430d;","mem[26][63:40]=24'h48430d;mem[32][39:32]=8'd1;mem[34][63:32]=0;");
  if(fam==='g10')s=s.replace('always@(posedge cpu_prepare)if(NATURAL_PHASE)begin','always@(posedge cpu_prepare)if(NATURAL_PHASE&&!warming)begin');
  if(name==='vdp_tb.sv'){const at=s.lastIndexOf('endmodule');s=s.slice(0,at)+miter()+shadowCPU(s,read(p.join(dst,'T80s_sim.vhd')))+s.slice(at);}
  s=s.replace(/force dut\.(\w+)=([^;]+);/g,(m,n,e)=>m+`force alias_ctl.${n}=${e};`).replace(/release dut\.(\w+);/g,(m,n)=>m+`release alias_ctl.${n};`);
  fs.writeFileSync(p.join(dst,name),s);
 }
 let c=read(p.join(dst,'compile.do'));c=c.replace('savestates_sim.sv','../../../rtl/opll_snapshot.sv savestates_sim.sv candidate_sim.sv');fs.writeFileSync(p.join(dst,'compile.do'),c);
 for(const name of cases){const from=p.join(src,name),to=p.join(dst,name);fs.mkdirSync(to,{recursive:true});for(const f of fs.readdirSync(from))if(f==='run.do'||/\.(dat|hex|bin)$/.test(f))fs.copyFileSync(p.join(from,f),p.join(to,f));manifest.push({family:fam,name,dir:p.relative(d,to),marker:'PASS V15 VDP'});}
}
fs.writeFileSync(p.join(d,'native_manifest.json'),JSON.stringify(manifest,null,2));
fs.writeFileSync(p.join(d,'miter_controller.svh'),miter());
console.log('Prepared isolated exact CPU-only candidate and '+manifest.length+' native real-T80/VDP miters; no production edits.');
module.exports={miter,shadowCPU,outputs,inputs};
