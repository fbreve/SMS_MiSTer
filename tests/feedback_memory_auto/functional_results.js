const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const simulations={};
for(const name of ['bank','gate','fm','fm_gate','savestate','savestate_gate_reference','savestate_gate']){
 const b=fs.readFileSync(p.join(d,name+'.log')),s=b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');
 const pass=s.includes('PASS ')&&!/\*\* (?:Fatal|Error):|# Errors: [1-9]|is not bound/.test(s);
 simulations[name]={pass,passLine:s.split(/\r?\n/).filter(l=>l.includes('PASS ')||l.includes('Nonzero audio checks')),sha256:crypto.createHash('sha256').update(b).digest('hex')};
 assert(pass,name+' did not qualify');
}
fs.writeFileSync(p.join(d,'functional_results.json'),JSON.stringify({simulations},null,2)+'\n');console.log(JSON.stringify(simulations,null,2));
