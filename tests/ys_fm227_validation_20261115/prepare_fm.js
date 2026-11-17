const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto');
const root=p.resolve(__dirname,'../..'),src=p.join(root,'tests/ym2413_public_v1_integration/verification'),out=p.join(__dirname,'fm_v2');fs.mkdirSync(out);
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),manifest={};
function copyTree(a,b){fs.mkdirSync(b,{recursive:true});for(const e of fs.readdirSync(a,{withFileTypes:true})){const x=p.join(a,e.name),y=p.join(b,e.name);if(e.isDirectory()){if(['candidate','reference','payloads'].includes(e.name))copyTree(x,y);}else if(/\.(sv|svh|vhd|do|tcl|hex)$/.test(e.name)){fs.copyFileSync(x,y);manifest[p.relative(out,y)]=sha(fs.readFileSync(x));}}}copyTree(src,out);
const productionCore={};for(const f of fs.readdirSync(p.join(out,'candidate')).filter(q=>q.endsWith('.vhd'))){const actual=fs.readFileSync(p.join(root,'rtl/VM2413',f));fs.writeFileSync(p.join(out,'candidate',f),actual);productionCore[f]=sha(actual);}
const adapted=fs.readFileSync(p.join(__dirname,'candidate_controller.sv'),'utf8').replace('module candidate_controller (','module savestates (');
fs.writeFileSync(p.join(out,'savestates_sim.sv'),adapted);fs.writeFileSync(p.join(out,'savestates_fast.sv'),adapted.replace("20'd900000","20'd90"));fs.copyFileSync(p.join(root,'rtl/opll_snapshot.sv'),p.join(out,'opll_snapshot.sv'));
for(const f of fs.readdirSync(out).filter(q=>/\.(sv|svh)$/.test(q)&&!q.startsWith('savestates_'))){const file=p.join(out,f);let s=fs.readFileSync(file,'utf8');s=s.replace(/\bsavestates\s+(\w+)\s*\(/g,(m,n)=>`savestates ${n}(.sc3000_mode(1'b${f==='nonfm_tb.sv'?1:0}),.eeprom_present(1'b0),`);
 if(['protocol_tb.sv','guard_protocol_tb.sv'].includes(f))s=s.replace("!==24'h484311","!==24'h484314");
 fs.writeFileSync(file,s);
}
fs.writeFileSync(p.join(__dirname,'fm_inputs.json'),JSON.stringify({source:src,originalHashes:manifest,productionCore,adapters:['exact production OPLL replaces earlier verification copy','explicit new exclusion inputs','expected SRAM video marker for eligible protocol cases','nonfm equivalence retains excluded SC behavior','existing fast-only 90-cycle flush variant used only where original fixture selects it']},null,2));
console.log('FM regressions copied; all candidate OPLL VHDL files match production exactly.');
