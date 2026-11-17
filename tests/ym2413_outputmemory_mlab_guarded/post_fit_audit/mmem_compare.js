const {parse,sig,replicaInfo}=require('./mmem.js');const fs=require('fs');const path=require('path');
const base=path.resolve(__dirname,'..','..');
function outsig(atoms){const o={};for(const a of atoms.filter(x=>x.type==='LUTRAM'))o[a.name]=a.outs.map(x=>x.port+':'+x.type+':'+x.fan).join(',');return o;}
function counts(atoms){const c={};for(const a of atoms){c[a.type]=(c[a.type]||0)+1;}return c;}
function ffNames(atoms){return atoms.filter(a=>a.type==='FF').map(a=>a.name.replace(/^.*Mmem\|/,'')).sort();}
const lutNames=atoms=>atoms.filter(a=>a.type==='LCELL_COMB').map(a=>a.name.replace(/^.*Mmem\|/,'')).sort();
for(const s of [1,2,3]){
 const g=parse(path.join(__dirname,`mmem_seed${s}.tsv`)),u=parse(path.join(base,`ym2413_outputmemory_mlab/physical_seed${s}/fitted_atoms.tsv`));
 const sg=JSON.stringify(sig(g)),su=JSON.stringify(sig(u));
 // normalize fanout-agnostic: compare input signal names
 const norm=x=>JSON.parse(x);
 console.log(`seed ${s}: replica input-signature identical: ${sg===su}`);
 console.log('  atom type counts guarded',JSON.stringify(counts(g)),'unguarded',JSON.stringify(counts(u)));
 console.log('  FF identical:',JSON.stringify(ffNames(g))===JSON.stringify(ffNames(u)),ffNames(g).length,ffNames(u).length,' LCELL names identical:',JSON.stringify(lutNames(g))===JSON.stringify(lutNames(u)));
 const og=outsig(g),ou=outsig(u);const kg=Object.keys(og).sort(),ku=Object.keys(ou).sort();
 console.log('  LUTRAM atom names identical:',JSON.stringify(kg)===JSON.stringify(ku),'; output ports sample',og[kg[0]]);
 const pg=g.filter(a=>a.type==='LUTRAM').flatMap(a=>a.params).sort().join('/'),pu=u.filter(a=>a.type==='LUTRAM').flatMap(a=>a.params).sort().join('/');
 console.log('  LUTRAM PARAM dumps identical:',pg===pu,pg.slice(0,120));
 if(sg!==su){const a=norm(sg),b=norm(su);for(const rep of Object.keys(a))for(const k of Object.keys(a[rep].inputs)){const x=JSON.stringify(a[rep].inputs[k]),y=JSON.stringify((b[rep]||{inputs:{}}).inputs[k]);if(x!==y)console.log('   diff',rep,k,'\n    G',x.slice(0,300),'\n    U',(y||'').slice(0,300));}}
}
