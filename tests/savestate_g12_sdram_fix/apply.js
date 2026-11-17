const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const gate=JSON.parse(fs.readFileSync(p.join(d,'pre_edit_gate.json'),'utf8'));assert(gate.pass&&gate.productionUnchanged);
const file=p.join(root,'SMS.sv');let s=fs.readFileSync(file,'utf8');const old='\t.clkref(systeme ? ce_pix : turbo ? ce_pix : ce_cpu),';
assert.equal(s.split(old).length,2);
const eol=s.includes('\r\n')?'\r\n':'\n';
s=s.replace(old,['\t// Private CPU replay uses /15 even in System E/turbo. Align the ROM',
'\t// acceptance slot with its T1 so the restored read completes before T2.',
'\t.clkref((ss_cpu_prepare || !(systeme || turbo)) ? ce_cpu : ce_pix),'].join(eol));
fs.writeFileSync(file,s);console.log('Applied proven G12 reference-clock selection only; v16 unchanged.');
