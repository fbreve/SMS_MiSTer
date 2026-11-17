const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const cases=require('./sprite_cases.json').map(x=>({...x,source:'distributed response, exact synchronous bridge to selected boundary response'}));
const old=require('./related_cases.json');
for(const [family,name,original]of [['background','dut_h0','dut_h0'],['dual','dut_collision','dut_collision'],['phases','dut_phases_root','dut_phases'],['phases','dut_deterministic','dut_deterministic'],['phases','dut_full_flush','dut_full_flush'],['phases','dut_lfsr','dut_phases'],['pending','dut_pending64','dut_pending']]){
 const x=old.find(y=>y.family===family&&y.name===original);assert(x);
 cases.push({family,name,inputs:x.inputs,source:family==='background'?'distributed response, exact synchronous bridge':'selected boundary response',customRun:name==='dut_phases_root'||name==='dut_lfsr'||name==='dut_pending64'});
}
const results=[];
for(const x of cases){const base=p.join(d,x.family,x.name),file=p.join(base,'simulation.log'),s=read(file);
 assert(/PASS (?:RICH |V15 |G04_NATIVE)|DONE VDP/.test(s),x.name+' terminal pass');
 assert(/Errors: 0/.test(s)&&!/\*\* (?:Error|Fatal|Failure):|Errors: [1-9]|Failed to open readmem|Failed to open file/.test(s),x.name+' no errors');
 const verified={},generated={};for(const[f,h]of Object.entries(x.inputs)){
  if(f==='image.hex'){generated[f]=sha(fs.readFileSync(p.join(base,f)));continue;}
  const actual=sha(fs.readFileSync(p.join(base,f)));
  if(!(f==='run.do'&&x.customRun))assert.equal(actual,h,x.name+' unchanged oracle/input '+f);
  verified[f]=actual;
 }
 results.push({family:x.family,name:x.name,source:x.source,passed:true,logSHA256:sha(fs.readFileSync(file)),verifiedInputs:verified,generatedImages:generated,markers:s.split(/\r?\n/).filter(l=>/PASS |DONE VDP|DUAL_INDEPENDENT_IRQ|AUDIT_COUNTS|End time:|Errors:/.test(l))});
}
const iso=p.join(d,'fm_isolation/isolation'),is=read(p.join(iso,'simulation.log'));assert(is.includes('PASS F01 FMCASE0 HISTORY0')&&is.includes('Errors: 0')&&!/\*\* (Error|Fatal|Failure):/.test(is));
for(const f of ['rom.hex','reference.dat'])assert.equal(sha(fs.readFileSync(p.join(iso,f))),sha(fs.readFileSync(p.join(d,'../savestate_f01_opll_fix/isolation',f))));
const gate=require('./functional_gate.json');for(const e of gate.evidence){assert.equal(sha(fs.readFileSync(p.join(d,e.file))),e.sha256,'immutable pre-build gate evidence '+e.file);}
const w=read(p.join(d,'pending/dut_pending64/image.hex')).trim().split(/\s+/),last=BigInt('0x'+w[0x294b]);
const pendingDelay=Number((last>>28n)&16383n);assert(pendingDelay!==0);
const out={passed:true,nativeCases:results.length,results,preBuildGateEvidenceUnchanged:true,F01Isolation:{passed:true,rawFMAndPSGExact:true,FMContributionSuppressed:true,logSHA256:sha(fs.readFileSync(p.join(iso,'simulation.log'))),note:'One retained isolation witness, SAVE and three LOADs; not a new G08.FM investigation or full F01 recertification.'},pendingDelay:{decimal:pendingDelay,hex:'0x'+pendingDelay.toString(16),lastPayloadWord:w[0x294b],portRows:[148,149]},scope:'Original component/memory/protocol/format/read-retiming gate plus 21 actual-VDP scenarios. Reduced-slot integration is explicitly separated from full64-slot packing and exact local-state proof.'};
fs.writeFileSync(p.join(d,'functional_results.json'),JSON.stringify(out,null,2)+'\n');console.log({passed:true,nativeCases:results.length,pendingDelay,F01Isolation:true});
