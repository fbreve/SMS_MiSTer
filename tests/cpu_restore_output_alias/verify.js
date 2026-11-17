const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=a=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:root,stdio:['ignore','pipe','pipe']}).toString().trim();
const baseline=require('../savestates_internal_cost_audit/baseline.json');
assert.equal(git(['rev-parse','HEAD']),baseline.head);assert.equal(git(['branch','--show-current']),baseline.branch);
assert.equal(git(['diff','--stat']),'');assert.equal(git(['diff','--cached','--stat']),'');
for(const row of [...baseline.tracked,...baseline.evidence])assert.equal(sha(fs.readFileSync(p.join(root,row.file))),row.sha256,row.file);
for(const row of baseline.inputs)assert.equal(sha(fs.readFileSync(p.join(root,'tests/savestate_g08_fm/quartus_early',row.file))),row.sha256,row.file);
// Read all audit machine evidence, including all declarations and physical rows.
const evidence={};for(const f of fs.readdirSync(p.join(root,'tests/savestates_internal_cost_audit'))){const q=p.join(root,'tests/savestates_internal_cost_audit',f);if(fs.statSync(q).isFile())evidence[f]=sha(fs.readFileSync(q));}
const inv=require('../savestates_internal_cost_audit/inventory.json');
console.log('Inventory top-level sections: '+Object.keys(inv).join(', '));
const own=require('../savestates_internal_cost_audit/provenance_check.json');assert(own.passed);assert.deepEqual(own.global,{needed:37117,placed:38599,registers:48880,M10K:488,setup:0.104,hold:0.239});
const out={head:baseline.head,branch:baseline.branch,tracked:baseline.tracked,inputs:baseline.inputs,evidence,baseline:baseline.metrics,global:own.global,status:git(['status','--short']),passed:true};
const target=p.join(d,'provenance.json');if(fs.existsSync(target)){const old=require(target);assert.deepEqual(out,old);}else fs.writeFileSync(target,JSON.stringify(out,null,2)+'\n');
console.log('PASS all 204 tracked files, 137 retained build inputs, prior reports and complete audit evidence unchanged; HEAD/branch/index clean.');
