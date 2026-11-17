const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname,adapter=require('../savestate_g06_g10_fix/controller_adapter');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),manifest=[];
for(const name of ['matrix','modes']){
 const orig=p.join(d,'../savestate_g08_release_fix',name),from=p.join(d,'../savestate_f06_sega_sram_fix','reg_audio_'+name),dst=p.join(d,'release_'+name);fs.mkdirSync(dst,{recursive:true});
 for(const f of fs.readdirSync(from))if(fs.statSync(p.join(from,f)).isFile()&&/\.(sv|vhd|v|do|hex)$/.test(f))fs.copyFileSync(p.join(from,f),p.join(dst,f));
 let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
 s=s.replace('wire[15:0]al,ar,rl,rr_audio;','wire[15:0]rl,rr_audio;').replace('module pause_tb;','module pause_tb;wire[15:0]al,ar,last_sample_in;wire last_sample_valid;');
 s=s.replace(/savestates\s+dut\s*\(/,'savestates dut(.audio_last_out(audio_phase_out?al:ar),.audio_last_in(last_sample_in),.audio_last_valid(last_sample_valid),');
 s=s.replace('AudioMix mix(.clk','AudioMix mix(.ss_last_sample(last_sample_in),.ss_last_valid(last_sample_valid),.clk');
 assert(s.includes('.audio_last_out'));fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter('rtl/savestates.sv'));
 const rows=[...JSON.parse(fs.readFileSync(p.join(orig,'cases.json'))),...(name==='modes'?JSON.parse(fs.readFileSync(p.join(orig,'boundary_cases.json'))):[])];
 for(const row of rows){
  const child=p.join(dst,row.id);fs.mkdirSync(child,{recursive:true});const files={};
  for(const f of ['reference.dat','rom.hex','replay.do']){let src=p.join(orig,row.id,f);assert(fs.existsSync(src),'missing independent release fixture '+src);const b=fs.readFileSync(src);fs.writeFileSync(p.join(child,f),b);files[f]=sha(b);}
  manifest.push({family:'release_'+name,id:row.id,args:row.args,fullFlush:!!row.fullFlush,files});
 }
}
fs.writeFileSync(p.join(d,'release_manifest.json'),JSON.stringify(manifest,null,2));
const out=p.join(d,'psg');fs.mkdirSync(out,{recursive:true});for(const f of ['psg_replay_tb.sv','psg.do'])fs.copyFileSync(p.join(d,'../savestate_f06_sega_sram_fix/psg',f),p.join(out,f));
console.log('Prepared complete retained release matrix: '+manifest.length+' cases; original ROM/oracle/run scripts unchanged.');
