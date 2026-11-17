const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');const src=p.dirname(__dirname),hashes={};
const selected=process.argv.includes('--reference-only')?['e_reference']:process.argv.includes('--baseline-only')?['e_baseline']:['e_baseline','e_reference'];
for(const name of selected){
 const log=fs.readFileSync(p.join(src,name+'_map.log'),'utf8');assert(log.includes('COMPLETE movement sequence')&&!/\*\* (Fatal|Error)/.test(log),'control incomplete: '+name);
 for(const file of fs.readdirSync(src).filter(f=>f.startsWith(name+'_')&&/\.(log|mem|ppm)$/.test(f))){const dest=p.join(__dirname,file);assert(!fs.existsSync(dest),'control already imported: '+file);fs.copyFileSync(p.join(src,file),dest);hashes[file]=crypto.createHash('sha256').update(fs.readFileSync(dest)).digest('hex');}
}
fs.writeFileSync(p.join(__dirname,selected.length===2?'control_import_manifest.json':selected[0]+'_import_manifest.json'),JSON.stringify({source:src,sourceRevision:'8cd53ccc954c24970372ea6d8a3fb2336a14c46f',scope:'Completed actual-controller control(s); source baseline unchanged by correction',hashes},null,2),{flag:'wx'});console.log('Imported completed controls without modifying original evidence:',selected.join(','));
