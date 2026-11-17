const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'prototype'),dst=p.join(d,'protocol');
fs.mkdirSync(dst,{recursive:true});
for(const f of ['audio_tb.sv','pin_model.sv','sdram.v','savestates_sim.sv','mapper_ctrl_sim.vhd','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','jt89.v','rom.hex','compile.do'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
s=s.replace('reg load_started=0;','reg load_started=0,load_released=0;integer release_cycle=0;');
s=s.replace('load_started=1;request(0);wait(ss_freeze);wait(!ss_freeze);','load_started=1;request(0);wait(ss_freeze);wait(!ss_freeze);load_released=1;release_cycle=cycle;');
s=s.replaceAll('(load_started&&!ss_freeze&&cycle%2==0)','(load_released&&!ss_freeze&&cycle<release_cycle+32)');
s=s.replace('if(load_started&&!ss_freeze&&cpu_ce&&!paused)begin','if(load_released&&!ss_freeze&&cpu_ce&&!paused)begin');
s=s.replace('if(z80_reg!==rr||ca!==ra)begin architectural_differences++','if($isunknown({z80_reg,rr,signature,ref_signature})||z80_reg!==rr||ca!==ra||signature!==ref_signature||{cm1,cmreq,ciq,crd,cwr}!=={rm1,rmreq,riq,rrd,rwr})begin architectural_differences++');
s=s.replace(/\nendmodule\s*$/,`
reg prep_previous=0,track_reissue=0;integer reissue_accepts=0,reissue_returns=0,reissue_checks=0,last_return_cycle=0;
reg[24:0]last_return_address=0;reg[15:0]last_return_word=0;
always@(posedge clk)begin
 if(cpu_prepare&&!prep_previous)begin
  track_reissue=1;reissue_accepts=0;reissue_returns=0;
  $display("REISSUE_BEGIN cycle%0d oldrd%b oldAddress%h oldWord%h lastReturn%0d lastAddress%h lastWord%h",cycle,live.access_manager.old_rd,{live.bank,live.a},live.sd_dat,last_return_cycle,last_return_address,last_return_word);
 end
 if(track_reissue&&live.mode==0&&live.q==0&&!live.access_manager.old_rd&&rd)begin
  reissue_accepts++;$display("REISSUE_ACCEPT id%0d cycle%0d address%h",dram_accepts,cycle,phys);
 end
 if(live.mode==0&&live.q==6&&live.ram_req&&!live.wr)begin
  if(track_reissue)begin reissue_returns++;$display("REISSUE_RETURN cycle%0d address%h",cycle,{live.bank,live.a});end
  last_return_cycle=cycle;last_return_address={live.bank,live.a};
 end
 if(track_reissue&&cpu.MCycle==1&&cpu.TState==2&&
    (((cpu_prepare&&replay)&&ce_cpu)||(!ss_freeze&&!paused&&cpu_ce)))begin
  if(rd)begin
   if(reissue_accepts!=1||reissue_returns!=1||!ready||{live.bank,live.a}!==phys||sd!==chip.byte_at(phys))
    $fatal(1,"restored request contract accepts%0d returns%0d ready%b A%h latched%h data%h expected%h",reissue_accepts,reissue_returns,ready,phys,{live.bank,live.a},sd,chip.byte_at(phys));
   reissue_checks++;$display("PASS_REISSUE id%0d cycle%0d address%h byte%h accepts%0d returns%0d",dram_accepts,cycle,phys,sd,reissue_accepts,reissue_returns);
  end else if(reissue_accepts||reissue_returns)$fatal(1,"ROM transaction for non-ROM requester");
  track_reissue=0;
 end
 prep_previous<=cpu_prepare;
end
always@(negedge clk)last_return_word=live.sd_dat;
final begin if(reissue_checks!=1)$error("missing restored request proof checks%0d",reissue_checks);end
endmodule
`);
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
console.log('Prepared quiet, freshness/exactly-once instrumented prototype.');
