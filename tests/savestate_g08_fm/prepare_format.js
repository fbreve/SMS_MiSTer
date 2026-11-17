const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,adapter=require('../savestate_g06_g10_fix/controller_adapter');
for(const kind of ['format','imports']){
 const src=p.join(d,'../savestate_f06_sega_sram_fix',kind),dst=p.join(d,kind);fs.mkdirSync(dst,{recursive:true});
 for(const f of fs.readdirSync(src))if(/\.(sv|do)$/.test(f))fs.copyFileSync(p.join(src,f),p.join(dst,f));
 fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter('rtl/savestates.sv'));
 const file=p.join(dst,kind==='format'?'format_tb.sv':'imports_tb.sv');let s=fs.readFileSync(file,'utf8').replaceAll("24'h484312","24'h484313");
 s=s.replace('module vdp_tb;',"module vdp_tb;reg[15:0]history_source=16'h5aa5;wire[15:0]history_restored;wire history_valid;reg want_history=1;");
 s=s.replace('savestates dut(', 'savestates dut(.audio_last_out(history_source),.audio_last_in(history_restored),.audio_last_valid(history_valid),');
 s=s.replace(/\nendmodule\s*$/,`
always@(posedge clk)if(loading&&audio_phase_set)begin
 if(history_valid!==want_history)$fatal(1,"history version validity");
 if(want_history&&history_restored!==history_source)$fatal(1,"history payload roundtrip");
end
endmodule
`);
 if(kind==='format'){
  s=s.replace('// Every FM descriptor/padding bit',`// New history field and its explicit version gate.
for(integer b=0;b<16;b++)begin history_source=16'd1<<b;transfer(1);transfer(0);if(!guest_writes)$fatal(1,"history onehot");accepted++;end
history_source=0;transfer(1);transfer(0);accepted++;
history_source=16'hffff;transfer(1);transfer(0);accepted++;
history_source=16'h5aa5;transfer(1);
for(integer b=48;b<64;b++)reject_bit('h22,b);
begin reg[63:0]v,h;v=mem['h20];h=mem['h22];mem['h20][39:32]=1;mem['h22][63:32]=0;
 transfer(0);if(guest_writes)$fatal(1,"v19 accepted missing history");rejections++;mem['h20]=v;mem['h22]=h;end
begin reg[63:0]v;v=mem['h1a];mem['h1a][63:40]=24'h484312;
 transfer(0);if(guest_writes)$fatal(1,"v18 reinterpreted v2 history");rejections++;mem['h1a]=v;end
// Every FM descriptor/padding bit`);
  s=s.replace("oldtag=mem['h1a];expect_background=0;","oldtag=mem['h1a];expect_background=0;want_history=0;mem['h20][39:32]=1;mem['h22][63:32]=0;");
  s=s.replace("expect_background=1;mem['h1a]=oldtag;mem['h2f][3]=0;",`for(integer version=17;version<=18;version++)begin
 mem['h1a][63:40]=24'h484300+version;transfer(0);if(!guest_writes)$fatal(1,"v17/v18 import");accepted++;
 if(version==18)for(integer b=32;b<64;b++)reject_bit('h22,b);
end
expect_background=1;want_history=1;mem['h20][39:32]=2;mem['h22][47:32]=history_source;mem['h1a]=oldtag;mem['h2f][3]=0;`);
  s=s.replace('transfer(0);if(!guest_writes||!bg_valid)$fatal(1,"dual v15 rejected");accepted++;','transfer(0);if(!guest_writes||!bg_valid)$fatal(1,"dual v15 rejected");accepted++;\nfor(integer b=32;b<64;b++)reject_bit(\'h24,b);');
  s=s.replace('systeme=0;expect_background=0;mem[0]', 'systeme=0;expect_background=0;want_history=0;mem[0]');
  s=s.replace('expect_background=1;transfer(1);transfer(0);','expect_background=1;want_history=1;transfer(1);transfer(0);');
  s=s.replace('PASS V17 FORMAT','PASS V19 FORMAT');
 }else{
  s=s.replace('version<=16','version<=18');
  s=s.replace("mem['h1a][63:40]=24'h484300+version;", "want_history=0;mem['h20][39:32]=1;mem['h22][63:32]=0;mem['h1a][63:40]=24'h484300+version;");
  s=s.replace("mem['h2997]='1;expect_background=version>=15;", "if(version<17)mem['h2997]='1;expect_background=version>=15;");
  s=s.replace('fm_resets!=1||fm_writes!=28','fm_resets!=(version>=17?0:1)||fm_writes!=(version>=17?104:28)');
  s=s.replace('audio_phase_in!==(version==16)','audio_phase_in!==(version>=16)');
  s=s.replace("mem['h1a][63:22]=0;", "want_history=0;mem['h1a][63:22]=0;");
  s=s.replace('expect_background=1;transfer(1);','expect_background=1;want_history=1;transfer(1);');
  s=s.replace('loads20 tagged1to16','loads22 tagged1to18');
 }
 assert(s.includes('.audio_last_out'));fs.writeFileSync(file,s);
}
console.log('Prepared v19 format padding/version/history checks and22 current/legacy imports.');
