const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),up='8443a0d19a88aff7a5900011bccf386daf146945',build='tests/savestate_hcounter/baseline';
const git=a=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:root,maxBuffer:64*1024*1024}).toString().trim();
const read=f=>fs.readFileSync(p.join(root,f),'utf8'),hash=f=>crypto.createHash('sha256').update(fs.readFileSync(p.join(root,f))).digest('hex');
const output=(f,o)=>fs.writeFileSync(p.join(__dirname,f),JSON.stringify(o,null,2)+'\n');
const previous=JSON.parse(read('tests/fpga_resource_optimization_summary/preservation_after.json'));
for(const[f,h]of Object.entries(previous.hashes))assert.equal(hash(f),h,f);
const hashes={...previous.hashes};
function freeze(dir){for(const e of fs.readdirSync(p.join(root,dir),{withFileTypes:true})){const f=dir+'/'+e.name;if(e.isDirectory())freeze(f);else if(e.isFile())hashes[f]=hash(f);}}
freeze(build);freeze('tests/fpga_resource_optimization_summary');
const oldProof=JSON.parse(read('tests/savestate_resource_growth/source_verification.json')).find(r=>r.checkpoint==='historical');
const source=[];for(const f of oldProof.verified){const blob=cp.execFileSync('git',['show',up+':'+f],{cwd:root,maxBuffer:32*1024*1024});const a=read(build+'/'+f).replaceAll('\r\n','\n');assert.equal(a,blob.toString().replaceAll('\r\n','\n'),f);source.push({file:f,buildSha256:hash(build+'/'+f),gitBlob:git(['rev-parse',up+':'+f]),normalizedMatch:true});}
const manifest=JSON.parse(read('tests/savestate_g12_sdram_fix/build_inputs.json')).inputs.candidate;
const extras=Object.keys(manifest).filter(f=>!oldProof.verified.includes(f));
const metrics=require('../cpu_restore_output_alias/measure')(p.join(root,build));
const fit=read(build+'/output_files/SMS.fit.rpt');
const hierarchy=[];for(const line of fit.split(/\r?\n/)){const c=line.split(';').map(x=>x.trim());if(c.length===19&&c[15].startsWith('|sys_top'))hierarchy.push({path:c[15],entity:c[16],needed:c[2],placed:c[3],recoverable:c[4],unavailable:c[5],logicALUT:c[7],dedicatedFF:c[8],memoryBits:c[10],M10K:c[11]});}
const controller=hierarchy.find(r=>r.path==='|sys_top|emu:emu|savestates:savestates_inst'),ui=hierarchy.find(r=>r.path.endsWith('|savestate_ui:savestate_ui_inst'));assert(controller&&ui);
const raw=read(build+'/rtl/savestates.sv'),clean=raw.replace(/\/\*[\s\S]*?\*\//g,'').replace(/\/\/[^\r\n]*/g,'');const declarations=[];
for(const m of clean.matchAll(/\b(output\s+reg|reg)\s*(?:\[\s*(\d+)\s*:\s*(\d+)\s*\])?\s*([^;\n]+)[;,]/g)){const width=m[2]?Math.abs(+m[2]- +m[3])+1:1;for(const name of m[4].split(',').map(x=>x.trim()))if(/^\w+$/.test(name))declarations.push({name,width,kind:m[1],line:raw.slice(0,raw.indexOf(name,Math.max(0,raw.indexOf(m[0])))).split('\n').length});}
const diffs=git(['diff','--name-status',up,previous.head]).split('\n');
const configs=['SMS.qsf','SMS.qpf','files.qip'];const configComparison=configs.map(f=>({file:f,upstreamBlob:git(['rev-parse',up+':'+f]),v19Blob:git(['rev-parse',previous.head+':'+f])}));
output('source_verification.json',{upstream:up,build,sourceCount:source.length,source,extraManifestFiles:extras,oldProofMissing:oldProof.missing,oldProofMismatches:oldProof.mismatches,oldProofEnvironmentDifferences:oldProof.environmentDifferences,configComparison,differencesFromV19:diffs});
output('measurements.json',{upstream:up,build,metrics,controller,ui,hierarchyRows:hierarchy.length,interconnect:fit.split(/\r?\n/).filter(l=>/Average interconnect usage|Peak interconnect usage/.test(l)),buildId:read(build+'/build_id.v').trim(),settings:read(build+'/SMS.qsf').split(/\r?\n/).filter(l=>/DEVICE |SEED |MISTER_FB|OPTIMIZATION|PACKING|FITTER_EFFORT|PLACEMENT_EFFORT/.test(l))});
output('hierarchy.json',hierarchy);output('declarations.json',declarations);
output('preservation_before.json',{head:git(['rev-parse','HEAD']),branch:git(['branch','--show-current']),status:git(['status','--short']),diff:git(['diff','--stat']),stagedDiff:git(['diff','--cached','--stat']),refs:git(['show-ref']),hashes});
console.log(JSON.stringify({sourceCount:source.length,extras,controller,ui,whole:{needed:metrics.needed,placed:metrics.placed,logic:metrics.logicALUT,route:metrics.routingALUT,fitFF:metrics.registers,mapFF:metrics.synthesisRegisters,M10K:metrics.M10K,setup:metrics.setup,hold:metrics.hold},frozenFiles:Object.keys(hashes).length},null,2));
