const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const baseline=require('./baseline.json');for(const[f,h]of Object.entries(baseline.hashes))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'production '+f);
for(const[name,folder,manifest]of [['retainedF01','../savestate_f01_opll_fix/quartus_final',require('../savestate_f01_opll_fix/build_final_inputs.json')],['experiment','quartus_experiment',require('./build_experiment_inputs.json')],['confirmation','quartus_confirmation',require('./build_confirmation_inputs.json')]]){
 for(const[f,h]of Object.entries(manifest.inputs))assert.equal(sha(fs.readFileSync(p.join(d,folder,f))),h,name+' '+f);
 assert.equal(sha(fs.readFileSync(p.join(d,folder,'build_id.v'))),manifest.buildIdSHA,name+' fixed date');
}
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),baseline.head);
assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');
console.log('PASS all204tracked files, three137-input source sets, fixed build IDs, HEAD and empty index');
