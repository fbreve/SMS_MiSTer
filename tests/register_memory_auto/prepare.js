const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),out=__dirname,rev='8443a0d19a88aff7a5900011bccf386daf146945';
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:64*1024*1024});
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const write=(f,v)=>fs.writeFileSync(p.join(out,f),JSON.stringify(v,null,2)+'\n');
assert.equal(git('rev-parse','HEAD').toString().trim(),rev);
assert(!fs.existsSync(p.join(out,'baseline')),'Do not overwrite experiment builds');
const files=git('ls-tree','-r',rev).toString().trim().split('\n').map(s=>s.match(/^(\d+) (\w+) (\w+)\t(.+)$/)).filter(m=>m[2]==='blob');
const manifest={baseline:rev,seed:1,buildDate:'261014',inputs:{},difference:'Only ramstyle of regs_array removed in candidate',preflow:'Bypass date-generating preflow, execute original map/fit/asm/sta settings with fixed identical build_id.v'};
for(const m of files){const rel=m[4],bytes=git('cat-file','blob',m[3]);for(const variant of ['baseline','candidate']){const target=p.join(out,variant,rel);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,variant==='candidate'&&rel==='rtl/VM2413/registermemory.vhd'?Buffer.from(bytes.toString("latin1").replace(/^ +attribute ramstyle of regs_array : signal is "logic";\r?\n/m,''),'latin1'):bytes);}manifest.inputs[rel]={blob:m[3],baseline:hash(bytes),candidate:hash(fs.readFileSync(p.join(out,'candidate',rel)))};}
for(const variant of ['baseline','candidate']){fs.writeFileSync(p.join(out,variant,'build_id.v'),'`define BUILD_DATE "261014"\n');fs.copyFileSync(p.join(root,'tests/timing_history/builds/F/jtag.cdf'),p.join(out,variant,'jtag.cdf'));}
manifest.generated={build_id:hash(fs.readFileSync(p.join(out,'baseline/build_id.v'))),jtag:hash(fs.readFileSync(p.join(out,'baseline/jtag.cdf')))};
write('input_manifest.json',manifest);
const changed=Object.entries(manifest.inputs).filter(([k,v])=>v.baseline!==v.candidate).map(([k])=>k);assert.deepEqual(changed,['rtl/VM2413/registermemory.vhd']);
console.log(JSON.stringify({files:files.length,changed,refs:JSON.parse(fs.readFileSync(p.join(out,"preservation_before.json"))).refs}));
