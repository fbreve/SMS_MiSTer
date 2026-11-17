const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert'),d=__dirname,repo=p.resolve(d,'../..'),w=p.join(d,'worktree'),phys=p.join(d,'synthesis'),ref=p.resolve(d,'../ym2413_v19_fullstate/physical_seed2');
const sha=b=>c.createHash('sha256').update(b).digest('hex'),norm=b=>b.toString('latin1').replace(/\r\n/g,'\n');
assert(JSON.parse(fs.readFileSync(p.join(d,'functional_results.json'))).PASS,'Functional gate');assert(JSON.parse(fs.readFileSync(p.join(d,'regression_results.json'))).PASS,'Transport/regression gate');
cp.execFileSync('node',[p.join(d,'verify.js')],{stdio:'inherit'});assert(!fs.existsSync(phys),'Refuse synthesis overwrite');
const m=JSON.parse(fs.readFileSync(p.join(ref,'inputs.json'))),r=JSON.parse(fs.readFileSync(p.join(ref,'results.json'))).builds.candidate;
for(const [f,h]of Object.entries(r.reportHashes))assert.equal(sha(fs.readFileSync(p.join(ref,'candidate/output_files',f))),h);
for(const [name,h]of Object.entries(m.toolHashes))assert.equal(sha(fs.readFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/'+name+'.exe')),h);
fs.mkdirSync(phys);const inputs={};for(const [f,v]of Object.entries(m.builds.candidate.inputs)){
 let bytes=fs.readFileSync(p.join(ref,'candidate',f));assert.equal(sha(bytes),v.SHA256);
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f))assert.equal(norm(bytes),norm(cp.execFileSync('git',['show','9873761503510e4b2c7e06600bf5515344235c2f:'+f],{cwd:w})),f);
 if(f==='rtl/VM2413/outputmemory.vhd')bytes=Buffer.from(bytes.toString('latin1').replace('attribute ramstyle of data_array : signal is "logic";','attribute ramstyle of data_array : signal is "MLAB";'),'latin1');
 if(/^(rtl\/|sys\/|SMS\.sv$|files\.qip$)/.test(f))assert.equal(norm(bytes),norm(fs.readFileSync(p.join(w,f))));
 const dest=p.join(phys,'candidate',f);fs.mkdirSync(p.dirname(dest),{recursive:true});fs.writeFileSync(dest,bytes);inputs[f]={...v,SHA256:sha(bytes)};
}
const manifest={...m,baseline:'9873761503510e4b2c7e06600bf5515344235c2f',candidate:{branch:'experiment/ym2413-outputmemory-mlab',HEAD:'9873761503510e4b2c7e06600bf5515344235c2f',uncommitted:true},builds:{candidate:{inputs}},sourceHash:sha(Buffer.from(Object.entries(inputs).sort().map(([f,v])=>f+' '+v.SHA256).join('\n'))),scope:'Analysis & Synthesis only; no fitter, assembler, RBF or physical timing measurement authorized',reference:{directory:ref},sourceDifferences:['rtl/VM2413/outputmemory.vhd'],functionalSHA256:sha(fs.readFileSync(p.join(d,'functional_results.json'))),regressionSHA256:sha(fs.readFileSync(p.join(d,'regression_results.json')))};
fs.writeFileSync(p.join(phys,'inputs.json'),JSON.stringify(manifest,null,2)+'\n');fs.copyFileSync(p.join(d,'production.diff'),p.join(phys,'production.diff'));
const helpers=p.resolve(d,'../ym2413_registermemory_mlab/physical_seed2');for(const f of ['map.ps1','check_inputs.js'])fs.copyFileSync(p.join(helpers,f),p.join(phys,f));console.log('PASS full functional gate, pinned production-only synthesis inputs; no fitter script created');
