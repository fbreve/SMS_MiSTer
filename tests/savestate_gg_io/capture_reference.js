// Preserve the successful F07 build evidence; never synthesize a guessed baseline.
const fs=require('fs'),path=require('path'),crypto=require('crypto');const dir=__dirname,root=path.resolve(dir,'../..');
const source=path.join(root,'tests/savestate_hcounter');
const old=JSON.parse(fs.readFileSync(path.join(source,'results.json'),'utf8'));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const sources={};
for(const f of ['SMS.sv','rtl/io.vhd','rtl/savestates.sv','rtl/system.vhd','rtl/vdp.vhd','SMS.qsf','files.qip']){
 const compiled=fs.readFileSync(path.join(source,'candidate',f));
 if(!compiled.equals(fs.readFileSync(path.join(dir,'baseline',f))))throw Error('Not the committed F07 input: '+f);
 sources[f]=sha(compiled);
}
const b=fs.readFileSync(path.join(source,'candidate/compile.log'));
const log=b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8');
const warnings=[...new Set(log.split(/\r?\n/).filter(l=>/^\s*(Critical )?Warning \(\d+\):/.test(l)).map(l=>l.trim().replace(/ File:.*$/,'').replace(/ at [^(\s]+\(\d+\)/g,' at SOURCE(LINE)').replace(/Z:\/tests\/savestate_(?:hcounter|gg_io)\/candidate\//gi,'BUILD/')))];
fs.writeFileSync(path.join(dir,'F07_reference.json'),JSON.stringify({commit:'60c6552',sources,build:old.build.candidate,warnings,buildID:fs.readFileSync(path.join(source,'candidate/build_id.v'),'utf8')},null,2));
for(const type of ['fit','sta'])fs.copyFileSync(path.join(source,'candidate/output_files/SMS.'+type+'.summary'),path.join(dir,'F07_'+type+'.summary'));
console.log('Captured verified F07 reference.');
