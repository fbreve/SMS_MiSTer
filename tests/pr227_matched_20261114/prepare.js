const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto');
const root=process.cwd(), out=__dirname;
for(const p of ['seed1','baseline.tar','candidate.tar','preservation_before.json'])if(fs.existsSync(path.join(out,p)))throw Error('Refusing to overwrite existing preparation/evidence: '+p+'; reproduce in a fresh comparison directory');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:100*1024*1024});
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const revisions={baseline:'66f16d5c656fd8906d62570da4d258875bcee684',candidate:'8cd53ccc954c24970372ea6d8a3fb2336a14c46f'};
const dep=git('rev-parse',revisions.baseline+':mist/mist-modules').toString().trim();
if(git('rev-parse',revisions.candidate+':mist/mist-modules').toString().trim()!==dep)throw Error('Submodule revisions do not match');
const protection={};
for(const p of git('ls-files','-z').toString().split('\0').filter(Boolean)) {if(fs.existsSync(p)&&fs.statSync(p).isFile())protection[p]=hash(fs.readFileSync(p));}
for(const p of fs.readdirSync(root).filter(p=>p.endsWith('.rbf')))protection[p]=hash(fs.readFileSync(p));
fs.writeFileSync(path.join(out,'preservation_before.json'),JSON.stringify(protection,null,2));
for(const [label,rev] of Object.entries(revisions)){
 const dir=path.join(out,'seed1',label);fs.mkdirSync(dir,{recursive:true});
 const archive=path.join(out,label+'.tar');git('archive','--format=tar','--output='+archive,rev);
 cp.execFileSync('tar',['-xf',archive,'-C',dir]);
 const depdir=path.join(dir,'mist/mist-modules');fs.mkdirSync(depdir,{recursive:true});
 const deptar=path.join(out,'dependency_'+label+'.tar');cp.execFileSync('git',['archive','--format=tar','--output='+deptar,dep],{cwd:path.join(root,'mist/mist-modules')});cp.execFileSync('tar',['-xf',deptar,'-C',depdir]);
 // Only the isolated top-level build settings change; all sys/ files remain exact.
 const qsf=path.join(dir,'SMS.qsf'),original=fs.readFileSync(qsf);
 fs.writeFileSync(path.join(out,label+'_original.qsf'),original);
 fs.appendFileSync(qsf,'\n# Matched comparison harness: fixed build date; source sys/ untouched.\nset_global_assignment -name PRE_FLOW_SCRIPT_FILE "quartus_sh:fixed_build_id.tcl"\n');
 fs.writeFileSync(path.join(dir,'fixed_build_id.tcl'),'set f [open "build_id.v" w]\nputs -nonewline $f {`define BUILD_DATE "261114"}\nclose $f\n');
 const files={};function walk(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,e.name);if(e.isDirectory())walk(p);else files[path.relative(dir,p).replaceAll('\\','/')]=hash(fs.readFileSync(p));}}walk(dir);
 fs.writeFileSync(path.join(out,label+'_inputs.json'),JSON.stringify({revision:rev,dependency:dep,seed:1,buildDate:'261114',originalQsfSHA256:hash(original),files},null,2));
}
fs.writeFileSync(path.join(out,'provenance.json'),JSON.stringify({revisions,dependency:dep,version:cp.execFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe',['--version']).toString(),device:'5CSEBA6U23I7',fixedBuildDate:'261114',seed:1,command:'quartus_sh --flow compile SMS',existingBuildDecision:'No exact-revision matched pair with fully verified inputs found. Historical v19 and pre-cleanup candidates excluded.'},null,2));
