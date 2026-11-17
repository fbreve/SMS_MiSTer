const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname;
const sources=[fs.readFileSync(p.join(d,'../../rtl/savestates.sv'),'utf8'),fs.readFileSync(p.join(d,'candidate/rtl/savestates.sv'),'utf8')];
const constants=Object.fromEntries([...sources[0].matchAll(/localparam \[23:0\] (\w+) = 24'h([0-9a-f]+)/g)].map(m=>[m[1],parseInt(m[2],16)]));
function compile(e){e=e.replace(/dout_latch\[63:40\]/g,'tag').replace(/dout_latch\[63:48\]/g,'prefix').replace(/dout_latch\[39:38\]/g,'subtype').replace(/\d+'([dhb])([0-9a-f]+)/gi,(_,b,v)=>parseInt(v,{d:10,h:16,b:2}[b.toLowerCase()]));return new Function('ctx','with(ctx){return +('+e+');}');}
function prepare(s,index){const wires=index?['current_format','modern_restart_tag','modern_nmi_tag','removed_development_tag','invalid_nmi_header']:['modern_restart_tag','modern_nmi_tag','load_ext_magic','invalid_nmi_header'];const w=wires.map(name=>{const m=s.match(new RegExp('wire (?:\\[[^\\]]+\\] )?'+name+' = ([\\s\\S]*?);'));assert(m,name);return{name,fn:compile(m[1])};});
 const block=s.slice(s.lastIndexOf('ST_LOAD_VIDEO: begin'),s.lastIndexOf('ST_LOAD_GG: begin'));
 const flags=[...block.matchAll(/(has_\w+)\s*<=\s*([^;]+);/g)].map(m=>({name:m[1],fn:compile(m[2])}));
 const conditions=[];for(const m of block.matchAll(/\bif\s*\(/g)){const start=m.index+m[0].length;let level=1,end=start;for(;level;end++){if(block[end]==='(')level++;if(block[end]===')')level--;assert(end<block.length);}const e=block.slice(start,end-1);if(/MAGIC|load_ext_magic|invalid_nmi_header|current_format/.test(e))conditions.push(compile(e));}
 assert.equal(conditions.length,4);return ctx=>{ctx={...ctx};for(const x of w)ctx[x.name]=x.fn(ctx);return [...flags.map(x=>[x.name,x.fn(ctx)]),...conditions.map((f,i)=>['condition'+i,f(ctx)])];};}
const functions=sources.map(prepare);let contexts=0,comparisons=0;
for(const tag of [0,0x484311])for(let subtype=0;subtype<4;subtype++)for(let mask=0;mask<32;mask++){
 const ctx={...constants,tag,prefix:tag>>>8,subtype,has_audio_ext:mask&1,restart_padding_ok:(mask>>1)&1,nmi_padding_ok:(mask>>2)&1,live_evolution:(mask>>3)&1,evolution_state:(mask>>4)&1};
 const a=functions[0](ctx),b=functions[1](ctx);assert.deepEqual(b,a,JSON.stringify(ctx));contexts++;comparisons+=a.length;
}
const result={passed:true,contexts,comparisons,domain:'currentFM17/public96 tag0; all4subtypes and all32combinations of audio presence, both padding predicates, live/saved Evolution flags; old64 bypass unchanged',sourceSHA:sources.map(s=>crypto.createHash('sha256').update(s).digest('hex'))};
fs.writeFileSync(p.join(d,'decode_equivalence.json'),JSON.stringify(result,null,2));console.log(result);
