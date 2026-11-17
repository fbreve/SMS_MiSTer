const fs=require('fs'),p=require('path');const d=__dirname;
// Diagnose retained replay stimulus separately; never modify its original file.
for(const v of ['A','B']){
 const target=p.join(d,`diagnose_${v}`);fs.mkdirSync(target,{recursive:true});
 for(const f of ['jt89.v','jt89_tone.v','jt89_noise.v','jt89_vol.v','jt89_mixer.v','psg_replay_tb.sv','replay.do'])fs.copyFileSync(p.join(d,`sim_${v}`,f),p.join(target,f));
 let t=fs.readFileSync(p.join(target,'psg_replay_tb.sv'),'utf8').replace('mode<8','mode<1').replace('phase<16','phase<1');
 t=t.replace('saved_cfg=cfg;saved_ext=ext;saved_div=div;','saved_cfg=cfg;saved_ext=ext;saved_div=div;$display("CAPTURE cfg=%h ext=%h l=%d r=%d cnt=%d phase=%b",cfg,ext,l,r,dut.u_tone0.cnt,dut.u_tone0.out);');
 t=t.replace('load=1;tick;load=0;repeat(4) tick;','$display("PERTURBED ext=%h ref=%h l=%d ref_l=%d cnt=%d",ext,rext,l,rl,dut.u_tone0.cnt);load=1;tick;load=0;repeat(4) tick;');
 t=t.replace('ce=(i%7==0);tick;\n  if(cfg', 'ce=(i%7==0);tick;if(i%5000==0)$display("REPLAY i=%d ext=%h ref=%h l=%d ref_l=%d ce=%b cen=%b",i,ext,rext,l,rl,ce,dut.cen_16);\n  if(cfg');
 fs.writeFileSync(p.join(target,'psg_replay_tb.sv'),t);
}
