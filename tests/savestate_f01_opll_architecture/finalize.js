const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),semantic=s=>s.replace(/--[^\r\n]*/g,'').replace(/\s+/g,'');
const before=Object.fromEntries(fs.readdirSync(p.join(d,'sim_opll')).filter(f=>f.endsWith('.vhd')).map(f=>[f,sha(semantic(fs.readFileSync(p.join(d,'sim_opll',f),'latin1')))]));
const tb=sha(fs.readFileSync(p.join(d,'audio_tb.sv')));
cp.execFileSync(process.execPath,[p.join(d,'prepare.js')],{stdio:'inherit'});
assert.equal(sha(fs.readFileSync(p.join(d,'audio_tb.sv'))),tb,'Fixture regenerated differently');
for(const[f,h]of Object.entries(before))assert.equal(sha(semantic(fs.readFileSync(p.join(d,'sim_opll',f),'latin1'))),h,'Semantic source bridge '+f);
cp.execFileSync(process.execPath,[p.join(d,'search_prepare.js')],{stdio:'inherit'});
fs.writeFileSync(p.join(d,'source_identity.json'),JSON.stringify({note:'Final regeneration restores original license headers; all19 adapted VM2413 files have identical comment/whitespace-normalized source. Audio TB identical bytes. Audit package adds behavioral preservation hooks only; no production state interface.',semanticBeforeAndAfter:before,simulationFiles:Object.fromEntries(['audio_tb.sv','native_tb.sv','native_rom.hex','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','search_tb.vhd','audit_pkg.vhd',...fs.readdirSync(p.join(d,'sim_opll')).map(f=>'sim_opll/'+f),...fs.readdirSync(p.join(d,'search_opll')).map(f=>'search_opll/'+f)].map(f=>[f,sha(fs.readFileSync(p.join(d,f)))]))},null,2));
for(const f of ['README.md','architecture.md']){let s=fs.readFileSync(p.join(d,f),'utf8').replace('Seven synthetic','Eight synthetic');fs.writeFileSync(p.join(d,f),s);}
