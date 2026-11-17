const fs=require('fs'),p=require('path');const d=__dirname;
for(const v of ['A','B','C']){
 const target=p.join(d,`strong_${v}`);fs.mkdirSync(target,{recursive:true});
 for(const f of ['jt89.v','jt89_tone.v','jt89_noise.v','jt89_vol.v','jt89_mixer.v','psg_replay_tb.sv','replay.do'])fs.copyFileSync(p.join(d,`sim_${v}`,f),p.join(target,f));
 let t=fs.readFileSync(p.join(target,'psg_replay_tb.sv'),'utf8');
 // Existing fixture warms for only ~29 generator ticks. Reset counters first
 // wrap after 1024 tone / 2048 noise ticks; that fixture can miss output changes.
 t=t.replace('i<3200;i=i+1) begin ce=(i%7==0)','i<40000;i=i+1) begin ce=1');
 if(v!=='A')t=t.replace('$display("PASS reduced PSG contract:', 'if(mismatches==0||late==0||cases_different!=128)$fatal(1,"strengthened stimulus did not distinguish history");\n$display("PASS reduced PSG contract:');
 fs.writeFileSync(p.join(target,'psg_replay_tb.sv'),t);
}
