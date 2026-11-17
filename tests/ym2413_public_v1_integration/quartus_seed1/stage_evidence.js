const fs=require('fs'),p=require('path'),c=require('crypto'),assert=require('assert');
const [action,dir,stage]=process.argv.slice(2),sha=f=>c.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const marker=p.join(dir,stage+'.done');
const required=stage==='queries'?['expanded_settings.txt','declared_rtl.txt',...['setup','hold','fm_from','fm_to','phase_from','phase_to','snapshot_from','snapshot_to','ignored_sdc','unconstrained'].map(k=>'physical_'+k+'.rpt')]:['output_files/SMS.'+stage+'.rpt',...(stage==='asm'?['output_files/SMS.rbf']:['output_files/SMS.'+stage+'.summary'])];
if(action==='verify') {
 const saved=JSON.parse(fs.readFileSync(marker));for(const [f,h]of Object.entries(saved.hashes))assert.equal(sha(p.join(dir,f)),h,'Completed artifact changed '+f);
} else {
 for(const f of required)assert(fs.existsSync(p.join(dir,f))&&fs.statSync(p.join(dir,f)).size>0,'Missing stage artifact '+f);
 if(stage!=='queries') {
  const rpt=fs.readFileSync(p.join(dir,required[0]),'utf8');
  assert(/Info: Quartus Prime [^\r\n]* was successful\. 0 errors/i.test(rpt),'No successful tool completion in '+required[0]);
 }
 const hashes=Object.fromEntries(required.map(f=>[f,sha(p.join(dir,f))]));
 fs.writeFileSync(marker,JSON.stringify({completed:new Date().toISOString(),hashes},null,2)+'\n',{flag:'wx'});
}
