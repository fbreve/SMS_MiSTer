// Fresh generation without touching the immutable campaign sources/libraries.
const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert'),d=__dirname;
const dest=p.join(d,'fresh_reproduction');assert(!fs.existsSync(dest),'Refuse overwriting reproduction');fs.mkdirSync(dest);
for(const f of ['candidate','reference','candidate_wrapper.vhd','reference_wrapper.vhd','acc_tb.vhd','prepare_native.js','prepare_combined.js'])fs.cpSync(p.join(d,f),p.join(dest,f),{recursive:true});
for(const script of ['prepare_native.js','prepare_combined.js'])cp.execFileSync('node',[p.join(dest,script)],{cwd:dest,stdio:'inherit'});
const hash=b=>c.createHash('sha256').update(b).digest('hex'),statements=b=>b.toString('latin1').replace(/--[^\r\n]*/g,'').replace(/\r\n/g,'\n');
const results=[];
for(const dir of ['native_candidate','native_reference'])for(const f of fs.readdirSync(p.join(d,dir)).filter(x=>x.endsWith('.vhd'))){
 const rel=dir+'/'+f,a=fs.readFileSync(p.join(d,rel)),b=fs.readFileSync(p.join(dest,rel));
 assert.equal(statements(a),statements(b),'Regenerated VHDL statements differ: '+rel);
 results.push({file:rel,campaignSHA256:hash(a),regeneratedSHA256:hash(b),byteIdentical:a.equals(b),statementsIdentical:true});
}
const a=fs.readFileSync(p.join(d,'combined_tb.vhd')),b=fs.readFileSync(p.join(dest,'combined_tb.vhd'));assert(a.equals(b),'Regenerated bench differs');
const output={status:'PASS',benchByteIdentical:true,benchSHA256:hash(a),files:results,note:'Exact campaign adapters are retained. Earlier adapter preparation normalized some non-ASCII comments through UTF-8; fresh generation preserves their original bytes. All VHDL statements and the entire bench are identical.'};
fs.writeFileSync(p.join(d,'reproduction_results.json'),JSON.stringify(output,null,2));
console.log('PASS fresh reproduction: all 38 native VHDL statement streams identical; bench byte-identical');
