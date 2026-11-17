const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const manifest=JSON.parse(fs.readFileSync(p.join(d,'input_manifest.json'))),changed=[];
for(const [file,m] of Object.entries(manifest.inputs)){
 for(const v of ['baseline','candidate'])assert.equal(sha(fs.readFileSync(p.join(d,v,file))),m[v],v+'/'+file);
 if(m.baseline!==m.candidate)changed.push(file);
}
assert.deepEqual(changed,['rtl/VM2413/registermemory.vhd']);
const f='rtl/VM2413/registermemory.vhd',a=fs.readFileSync(p.join(d,'baseline',f),'latin1'),b=fs.readFileSync(p.join(d,'candidate',f),'latin1');
assert.equal(a.replace(/^ +attribute ramstyle of regs_array : signal is "logic";\r?\n/m,''),b);
assert.equal(fs.readFileSync(p.join(d,'worktree',f),'latin1').replaceAll('\r\n','\n'),b.replaceAll('\r\n','\n'));
assert.equal(cp.execFileSync('git',['diff','--name-only'],{cwd:p.join(d,'worktree'),encoding:'utf8'}).trim(),f);
const previous=JSON.parse(fs.readFileSync(p.join(root,'tests/phase_memory_auto/tools.json'))),binaries={};
for(const [tool,h] of Object.entries(previous.binaries)){binaries[tool]=sha(fs.readFileSync(`C:/intelFPGA_lite/17.0/quartus/bin64/${tool}.exe`));assert.equal(binaries[tool],h,tool);}
const tools={quartus:cp.execFileSync('C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe',['--version'],{encoding:'utf8'}),modelsim:cp.execFileSync('C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe',['-version'],{encoding:'utf8'}),binaries};
fs.writeFileSync(p.join(d,'tools.json'),JSON.stringify(tools,null,2)+'\n');
const before=JSON.parse(fs.readFileSync(p.join(d,'preservation_before.json')));
for(const [f,h] of Object.entries(before.files))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,f);
for(const [r,h] of Object.entries(before.refs))assert.equal(cp.execFileSync('git',['rev-parse',r],{cwd:root,encoding:'utf8'}).trim(),h,r);
const result={trackedInputs:Object.keys(manifest.inputs).length,changed,phaseMemoryUnchangedInBothBuilds:true,originalPhaseWorktreePreserved:true,protectedFiles:Object.keys(before.files).length,protectedRefs:Object.keys(before.refs).length,toolHashesMatchPhaseExperiment:true};
fs.writeFileSync(p.join(d,'input_validation.json'),JSON.stringify(result,null,2)+'\n');console.log(result);
