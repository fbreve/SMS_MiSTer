const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,process.argv[2]||'campaign');fs.mkdirSync(dst,{recursive:true});
for(const f of fs.readdirSync(p.join(d,'matrix'))){if(/\.(v|sv|vhd|hex|svh|do)$/.test(f))fs.copyFileSync(p.join(d,'matrix',f),p.join(dst,f));}
for(const f of ['crypto_functions.svh','decrypt_path.sv'])fs.copyFileSync(p.join(d,f),p.join(dst,f));
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
s=s.replace('parameter MODE=','parameter RESAVE=0,MODE=');
s=s.replace('integer baseline_consumptions=', 'initial begin #1;if(cpu.u0.Mode!=0||rcpu.u0.Mode!=0)$fatal(1,"G11 requires production Z80 CPU mode");end\ninteger baseline_consumptions=');
s=s.replace('$display("PASS SUFFIX pass%0d samples%0d progressCPU%0d PSG%0d paused%b",pass,N,progress_cpu,progress_psg,paused);',`$display("PASS SUFFIX pass%0d samples%0d progressCPU%0d PSG%0d paused%b",pass,N,progress_cpu,progress_psg,paused);
if(RESAVE&&pass==REPLAYS)begin
 request(1);wait(ss_freeze);wait(!ss_freeze);
 for(j=0;j<12288;j++)if($isunknown(mem[j]))$fatal(1,"unknown resaved complete image");
 $writememh("image_resave.hex",mem);
 $display("RESAVE_COMPLETE phase%b madr%h decode%h keyD%h mc%h",crypt.segapipe.phase,crypt.segapipe.madr,decoded,crypt.kd,crypt.mc);
 begin integer future_file;future_file=$fopen("future_resave.dat","w");
 for(integer future_index=0;future_index<N;future_index++)begin
  @(posedge clk);#1;
  if($isunknown({cpu_actual,signature}))$fatal(1,"unknown phase-pair future");
  $fdisplay(future_file,"%h %h",cpu_actual,signature);future(future_index,0);
 end
 $fclose(future_file);end
 $display("PASS MATRIX resave N%0d",N);$finish;
end`);
s=s.replace('$display("Q pass%0d raw%h outputs%h/%h CPU%h dramAddr%h dramData%h",pass,raw,al,ar,z80_reg,live.a,live.sd_dat);',`$display("Q pass%0d raw%h outputs%h/%h CPU%h dramAddr%h dramData%h phase%b madr%h decode%h xd%h swp%h keyA%h keyD%h mc%h",pass,raw,al,ar,z80_reg,live.a,live.sd_dat,crypt.segapipe.phase,crypt.segapipe.madr,decoded,crypt.segapipe.xd,crypt.segapipe.sd,crypt.ka,crypt.kd,crypt.mc);`);
s=s.replace('if(reset_n&&!crd&&!cmreq&&ca<16\'hc000)begin',`if(reset_n&&!crd&&!cmreq&&ca<16'hc000&&cpu.TState==2)begin`);
s=s.replace('if(cpu_prepare)trace_left=36;','if(cpu_prepare)trace_left=36;\n if(cycle%200000==0)$display("G11_PROGRESS cycle%0d CPU%h A%h state%0d",cycle,z80_reg,ca,dut.state);');
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
fs.writeFileSync(p.join(dst,'pin_model.sv'),fs.readFileSync(p.join(dst,'pin_model.sv'),'utf8').replace('if(CACHEHISTORY)begin opmask','#0;if(CACHEHISTORY)begin opmask'));
console.log('Prepared isolated corrected campaign, Q-history logging and accepted resave collision probe.');
