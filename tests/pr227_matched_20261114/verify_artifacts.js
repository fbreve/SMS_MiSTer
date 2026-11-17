const fs=require('fs'),path=require('path'),crypto=require('crypto');const out=__dirname;
const manifest=JSON.parse(fs.readFileSync(path.join(out,'artifact_manifest.json')));
for(const [p,h]of Object.entries(manifest)){const b=fs.readFileSync(path.join(out,p));if(crypto.createHash('sha256').update(b).digest('hex')!==h)throw Error('Artifact hash mismatch: '+p);}
console.log('Verified SHA-256 of '+Object.keys(manifest).length+' original output artifacts.');
