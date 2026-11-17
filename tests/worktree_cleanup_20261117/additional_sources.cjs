const fs=require('fs'),path=require('path'),crypto=require('crypto');
const root=path.resolve(__dirname,'../..'),before=require('./before.json'),published=new Set(require('./external_evidence_manifest.json').map(f=>f.path));
const sources=require('./files_before.json').filter(f=>!f.symlink&&!published.has(f.path)&&!before.repositories.some(r=>f.path.startsWith(r.relative+'/'))&&!/(^|\/)(tools|uv_cache|db|incremental_db|output_files|game_sources|obj_dir|native_obj|work|candidate_work|reference_work|test_work|fast_work)\//.test(f.path)&&!/fitted_atoms|netlist/i.test(path.basename(f.path))&&/\.(vhd|vhdl|v|sv|svh|vh|c|h|cpp|hpp|js|py|ps1|sh|tcl|do|patch|diff|md)$/i.test(f.path));
for(const f of sources)f.sha256=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,f.path))).digest('hex');
fs.writeFileSync(path.join(__dirname,'additional_sources_manifest.json'),JSON.stringify(sources,null,2));console.log(sources.length,sources.reduce((a,f)=>a+f.bytes,0));
