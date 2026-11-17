const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
if(process.argv[2]==='check'){
 const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),manifest=require('./build_early_inputs.json');
 const raw=fs.readFileSync(p.join(root,'SMS.qsf')),expanded=fs.readFileSync(p.join(d,'quartus_early/SMS.qsf'));
 assert.equal(sha(raw),manifest.inputs['SMS.qsf'],'original QSF source unchanged');
 assert(expanded.toString().replace(/\r\n/g,'\n').startsWith(raw.toString().replace(/\r\n/g,'\n').trimEnd()),'only exported suffix allowed');
 const values=f=>fs.readFileSync(p.join(d,f),'utf8').trim().split(/\r?\n/).sort();
 const a=values('settings_raw_assignments.txt'),b=values('settings_expanded_assignments.txt');assert(a.length>2000);assert.deepEqual(a,b,'effective Quartus assignments changed');
 fs.writeFileSync(p.join(d,'qsf_export_verification.json'),JSON.stringify({pass:true,assignmentRows:a.length,originalSHA:sha(raw),expandedSHA:sha(expanded),sortedAssignmentsSHA:sha(a.join('\n')),source:'Quartus project API get_all_global_assignments/get_all_instance_assignments; includes location, wildcard IO, family/device, seed, all performance/packing settings and SDC/IP/source references.',difference:'Quartus auto-exported the already imported assignments. Effective assignments are identical. No source setting was changed.'},null,2));
 console.log('PASS '+a.length+' effective assignments identical; only copied QSF auto-export changed.');process.exit(0);
}
const m=require('./build_early_inputs.json'),dst=p.join(d,'settings_raw'),src=p.join(d,'quartus_early');fs.mkdirSync(dst,{recursive:true});
for(const f of Object.keys(m.inputs)){const out=p.join(dst,f);fs.mkdirSync(p.dirname(out),{recursive:true});fs.copyFileSync(f==='SMS.qsf'?p.join(root,f):p.join(src,f),out);}
fs.copyFileSync(p.join(src,'build_id.v'),p.join(dst,'build_id.v'));
console.log('Prepared original unexpanded QSF copy for effective-assignment comparison.');
