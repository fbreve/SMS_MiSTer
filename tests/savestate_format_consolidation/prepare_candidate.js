const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const original=fs.readFileSync(p.join(root,'rtl/savestates.sv'),'utf8').replace(/\r\n/g,'\n');
assert.equal(sha(fs.readFileSync(p.join(root,'rtl/savestates.sv'))),require('./baseline.json').hashes['rtl/savestates.sv']);
let s=original;
// Isolated experiment: current v17 and both public untagged formats only.
// Remove the v12+ -> v11 tag alias before removing intermediate comparisons.
s=s.replace(/wire modern_restart_tag = .*?;\nwire modern_nmi_tag = .*?;\nwire \[23:0\] load_ext_magic = .*?;/,
 `wire current_format = dout_latch[63:40] == FM_MAGIC;
wire modern_restart_tag = current_format;
wire modern_nmi_tag = current_format;
wire removed_development_tag = dout_latch[63:48] == 16'h4843 && !current_format;`);
let alias=0,removed=0;
s=s.replace(/load_ext_magic\s*(==|!=)\s*(\w+MAGIC)/g,(all,op,tag)=>{if(tag==='EVOLUTION_PENDING_MAGIC'){alias++;return op==='=='?'current_format':'!current_format';}removed++;return op==='=='?"1'b0":"1'b1";});
const oldNames=[...original.matchAll(/localparam \[23:0\] (\w+) = 24'h4843(\w\w)/g)].filter(m=>m[2]!=='11').map(m=>m[1]);
for(const tag of oldNames){s=s.replace(new RegExp('dout_latch\\[63:40\\]\\s*(==|!=)\\s*'+tag,'g'),(all,op)=>{removed++;return op==='=='?"1'b0":"1'b1";});s=s.replace(new RegExp('^localparam \\[23:0\\] '+tag+' = .*?;[^\\n]*\\n','m'),'');}
s=s.replace('wire invalid_nmi_header = ', 'wire invalid_nmi_header = removed_development_tag || ');
assert(!s.includes('load_ext_magic'));for(const t of oldNames)assert(!new RegExp('\\b'+t+'\\b').test(s),t);
assert.equal((s.match(/removed_development_tag/g)||[]).length,2);
const dst=p.join(d,'candidate/rtl');fs.mkdirSync(dst,{recursive:true});fs.writeFileSync(p.join(dst,'savestates.sv'),s);
fs.writeFileSync(p.join(d,'candidate_manifest.json'),JSON.stringify({productionChanged:false,currentVersion:17,public:['untagged64','untagged96'],rejected:'HC prefix other than current tag',removedComparisons:removed,currentAliasComparisons:alias,originalSHA:sha(Buffer.from(original)),candidateSHA:sha(Buffer.from(s)),onlyFile:'rtl/savestates.sv'},null,2));
console.log({removed,alias,oldTags:oldNames.length});
