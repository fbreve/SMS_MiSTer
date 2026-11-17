const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname,sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const a=require('./build_experiment_inputs.json'),b=require('./build_confirmation_inputs.json');
const changed=Object.keys(a.inputs).filter(f=>a.inputs[f]!==b.inputs[f]);assert.deepEqual(changed,['SMS.qsf']);assert.equal(a.buildIdSHA,b.buildIdSHA);assert.equal(a.seed,1);assert.equal(b.seed,2);
const qa=fs.readFileSync(p.join(d,'quartus_experiment/SMS.qsf'),'utf8'),qb=fs.readFileSync(p.join(d,'quartus_confirmation/SMS.qsf'),'utf8');assert.equal(qb.replace(/set_global_assignment -name SEED 2\b/,'set_global_assignment -name SEED 1'),qa);
for(const [name,m]of [['experiment',a],['confirmation',b]])for(const[f,h]of Object.entries(m.inputs))assert.equal(sha(fs.readFileSync(p.join(d,'quartus_'+name,f))),h,name+' '+f);
const out={passed:true,baselineSeed:1,primarySeed:1,confirmationSeed:2,primarySourceInputs:Object.keys(a.inputs).length,identicalAcrossExperiments:136,changed,rtlIdentical:true,fixedBuildIdIdentical:true,qsfOtherSettingsIdentical:true,pairedSeed2Baseline:false,interpretation:'Primary seed1 delta is paired. Seed2 is one sensitivity confirmation; cross-seed differences are not a causal area/cost estimate.'};
fs.writeFileSync(p.join(d,'confirmation_controls.json'),JSON.stringify(out,null,2));console.log(out);
