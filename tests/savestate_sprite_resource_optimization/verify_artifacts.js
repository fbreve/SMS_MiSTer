const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),baseline=JSON.parse(fs.readFileSync(p.join(d,'baseline.json'))),rows=JSON.parse(fs.readFileSync(p.join(d,'regression_manifest.json'))),retained=process.argv.includes('--retained');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),git=(...a)=>cp.execFileSync('git',a,{cwd:root}).toString().trim(),norm=b=>b.toString().replace(/\r\n/g,'\n').split('\n').map(x=>x.trimEnd()).join('\n'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const changes=[];for(const[f,h]of Object.entries(baseline.files))if(sha(fs.readFileSync(p.join(root,f)))!==h)changes.push(f);
if(retained){assert.deepEqual(changes,['rtl/savestates.sv']);assert.equal(norm(fs.readFileSync(p.join(root,'rtl/savestates.sv'))),norm(fs.readFileSync(p.join(d,'candidate_A.sv'))));}else assert.deepEqual(changes,[]);
assert.equal(git('rev-parse','HEAD'),baseline.head);assert.equal(git('diff','--cached','--stat'),'');
for(const[r,h]of Object.entries(baseline.reports))assert.equal(sha(fs.readFileSync(p.join(root,'tests',r,'review.md'))),h,'Prerequisite report changed '+r);
assert.equal(git('diff','f205b05','HEAD','--','rtl/vdp.vhd','rtl/vdp_main.vhd','rtl/vdp_background.vhd','rtl/vdp_sprites.vhd','rtl/vdp_sprite_shifter.vhd','rtl/T80'),'','Fixture receiver baseline drift');
const expected=adapter(p.join(d,'candidate_A.sv')),families=[...new Set(rows.filter(r=>!r.reference).map(r=>r.family))],sources={},consumedInputs=[];
for(const family of families){const dir=p.join(d,family);assert.equal(fs.readFileSync(p.join(dir,'savestates_sim.sv'),'utf8'),expected,'Controller source '+family);for(const f of ['savestates_sim.sv','header.svh','vdp_tb.sv','T80_sim.vhd','T80s_sim.vhd'])if(fs.existsSync(p.join(dir,f)))sources[family+'/'+f]=sha(fs.readFileSync(p.join(dir,f)));for(const f of fs.readdirSync(p.join(dir,'rtl')))if(/\.vhd$/.test(f))sources[family+'/rtl/'+f]=sha(fs.readFileSync(p.join(dir,'rtl',f)));}
for(const r of rows.filter(r=>!r.reference)){const text=fs.readFileSync(p.join(d,r.family,'vdp_tb.sv'),'utf8'),names=new Set([...text.matchAll(/\$readmemh\("([^"]+)"/g)].map(x=>x[1]));for(const m of text.matchAll(/\$fopen\("([^"]+)"\s*,\s*([^;\n]*?)\)/g))if(/"r"/.test(m[2]))names.add(m[1]);
 for(const file of names){const local=p.join(d,r.family,r.name,file);assert(fs.existsSync(local),'Missing consumed file '+local);let original;
  if(r.family==='sprites')original=p.join(d,'../savestate_g06_g10_fix/sprites',file==='reference.dat'?'reference_'+r.name.slice(4):r.name,file);
  else {const expected=r.fixtures.find(f=>f.file===file);assert(expected,'Missing consumed input manifest '+r.family+'/'+file);assert.equal(sha(fs.readFileSync(local)),expected.sha256,'Consumed input mutated '+local);}
  if(original)assert.equal(sha(fs.readFileSync(local)),sha(fs.readFileSync(original)),'Original sprite oracle/ROM changed '+local);
  consumedInputs.push({family:r.family,case:r.name,file,sha256:sha(fs.readFileSync(local))});
 }
}
fs.writeFileSync(p.join(d,'source_identity.json'),JSON.stringify({controllerAdapter:'two forward declarations relocated; TB_FAST only flush interval',sources,consumedInputs,receiversUnchangedSinceG05:true},null,2));
const result={pass:true,head:baseline.head,branch:git('branch','--show-current'),retained,trackedRegularFiles:Object.keys(baseline.files).length,changedFiles:changes,prerequisiteReportsUnchanged:true,consumedInputsVerified:consumedInputs.length,diffStat:git('diff','--stat'),status:git('status','--short'),staged:git('diff','--cached','--stat')};fs.writeFileSync(p.join(d,'integrity.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result,null,2));
