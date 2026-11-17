const fs=require('fs'),p=require('path'),crypto=require('crypto'),adapter=require('./controller_adapter'),d=__dirname,source=p.resolve(d,'../../rtl/savestates.sv');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex'),recordOnly=process.argv.includes('--record-only'),records={};
const families={matrix_g01:['savestates_integrated.sv','short'],matrix_nmi:['savestates_integrated.sv','short'],pause_known:['savestates_sim.sv','parameter'],candidate_g01:['savestates_integrated.sv','full'],candidate_nmi:['savestates_integrated.sv','full'],distinct_q:['savestates_sim.sv','parameter'],systeme:['savestates_sim.sv','parameter'],stalls:['savestates_sim.sv','parameter'],format:['savestates_sim.sv','parameter']};
for(const [family,[name,mode]]of Object.entries(families)){
 if(recordOnly){records[family]={file:family+'/'+name,sha256:hash(p.join(d,family,name))};continue;}
 const folder=p.join(d,family),archive=p.join(folder,'before_ring_logs');fs.mkdirSync(archive,{recursive:true});
 for(const f of fs.readdirSync(folder))if(f.endsWith('.log')&&fs.statSync(p.join(folder,f)).isFile()&&!fs.existsSync(p.join(archive,f)))fs.copyFileSync(p.join(folder,f),p.join(archive,f));
 for(const sub of ['dut','dual_systeme_64_running','overflow_stall1','overflow_stall2'])if(fs.existsSync(p.join(folder,sub,'simulation.log'))){const target=p.join(archive,sub);fs.mkdirSync(target,{recursive:true});for(const f of ['simulation.log','image.hex'])if(fs.existsSync(p.join(folder,sub,f))&&!fs.existsSync(p.join(target,f)))fs.copyFileSync(p.join(folder,sub,f),p.join(target,f));}
 let s=adapter(source,mode==='parameter');if(mode==='short')s=s.replace("FLUSH_MAX       = 20'd900000","FLUSH_MAX       = 20'd0");fs.writeFileSync(p.join(folder,name),s);
 records[family]={file:family+'/'+name,sha256:hash(p.join(folder,name))};
}
fs.writeFileSync(p.join(d,'ring_regression_sources.json'),JSON.stringify({productionSHA256:hash(source),families:records},null,2)+'\n');
console.log('Refreshed nine controller fixture families; prior logs archived. No production source edited.');
