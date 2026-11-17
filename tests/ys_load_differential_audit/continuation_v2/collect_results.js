const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');const d=__dirname,root=p.resolve(d,'../../..');
const read=f=>fs.readFileSync(p.join(d,f),'utf8'),hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const cpu=JSON.parse(read('matrix_results.json')).results,vdp=JSON.parse(read('vdp_matrix_results.json')).results,format=JSON.parse(read('format_results.json'));
const preload=JSON.parse(read('preload_results.json')).results;assert.equal(preload.length,24);
for(const r of preload)assert.equal(r.equal,r.mode!==0||r.program===0,'unexpected preload verdict '+r.log);
assert.equal(cpu.length,98);assert.equal(vdp.length,32);
for(const r of cpu){const expected=r.mode===2||(r.mode===1&&![2,3].includes(r.intCase))||([0,3].includes(r.mode)&&r.program===0);assert.equal(r.equal,expected,'unexpected CPU verdict '+r.log);assert.equal(r.checks,701);}
for(const r of vdp){const expected=[1,2].includes(r.mode)||r.program===0;assert.equal(r.equal,expected,'unexpected VDP verdict '+r.log);}
const roms=JSON.parse(read('local_rom_identity.json')).roms,ys=[];
for(const name of ['standard','japan'])for(const mode of [0,1]){
 const log=`ys_${name}_${mode===0?'current':'context'}_sram.log`,file=p.join(d,log);
 if(!fs.existsSync(file)){ys.push({name,mode,status:'not run',log});continue;}
 const s=read(log),m=s.match(/RESULT failed=(\d+) arch_first=(-?\d+) bus_first=(-?\d+)/),m2=s.match(/YS_MEMORY WRAM_different_bytes=(\d+) SRAM_different_bytes=(\d+) mapper_equal=(\d+)/);
 if(m&&s.includes('COMPLETE')&&!/\*\* (Error|Fatal)/.test(s))ys.push({name,mode,status:'complete',log,equal:m[1]==='0',archFirst:+m[2],busFirst:+m[3],WRAMDifferences:+m2[1],SRAMDifferences:+m2[2],mapperEqual:m2[3]==='1',accept:s.match(/YS_ACCEPT[^\r\n]+/)[0],first:s.match(/FIRST[^\r\n]+/)?.[0]??null});
 else ys.push({name,mode,status:s.includes('capture not reached')?'no qualified capture in bounded run':'incomplete bounded probe',log});
}
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'utf8'}).trim();
assert.equal(git('status','--porcelain','--untracked-files=no'),'');
assert.equal(git('rev-parse','master'),'66f16d5c656fd8906d62570da4d258875bcee684');assert.equal(git('rev-parse','HEAD'),'8cd53ccc954c24970372ea6d8a3fb2336a14c46f');assert.equal(git('rev-parse','investigate/cram-memory-inference'),'1b2a52d87d2659c908d4f9f846416d14bfd85bea');
const logs=[...cpu,...vdp,...preload,...ys.filter(x=>fs.existsSync(p.join(d,x.log)))].map(x=>x.log);
const result={status:'Focused regression verdicts validated; Ys map causality remains unproven',cpuCases:cpu.length,vdpCases:vdp.length,codec:format,ys,roms:roms.map(({path,...r})=>r),logSHA256:Object.fromEntries(logs.map(f=>[f,hash(p.join(d,f))])),sourceSHA256:Object.fromEntries(fs.readdirSync(d).filter(f=>/\.(js|sv|vhd|do)$/.test(f)).map(f=>[f,hash(p.join(d,f))])),protectedEarlierAuditSHA256:{REPORT:hash(p.join(d,'../REPORT.md')),sourceIdentity:hash(p.join(d,'../source_identity.json')),simulationLog:hash(p.join(d,'../simulation.log'))},refs:{master:git('rev-parse','master'),HEAD:git('rev-parse','HEAD'),history:git('rev-parse','investigate/cram-memory-inference')},trackedStatus:git('status','--porcelain','--untracked-files=no'),recommendation:'NO-GO production; GO isolated DDR/phase integration and map-scene causality test'};
fs.writeFileSync(p.join(d,'ys_results.json'),JSON.stringify({ys},null,2)+'\n');fs.writeFileSync(p.join(d,'final_results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({status:result.status,cpuCases:cpu.length,vdpCases:vdp.length,ys,trackedStatus:result.trackedStatus},null,2));
