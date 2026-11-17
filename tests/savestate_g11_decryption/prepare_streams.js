const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'streams');fs.mkdirSync(dst,{recursive:true});
for(const f of fs.readdirSync(p.join(d,'campaign'))){if(/\.(v|sv|vhd|hex|svh|do)$/.test(f))fs.copyFileSync(p.join(d,'campaign',f),p.join(dst,f));}
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
function replace(a,b){if(!s.includes(a))throw Error('missing source bridge '+a);s=s.replace(a,b);}
replace('reg[250:0]cpu_oracle[0:N-1];','reg[41:0]rom_event,ref_rom_event,event_oracle[0:N-1];reg[7:0]ram_oracle[0:16383];\nreg[250:0]cpu_oracle[0:N-1];');
replace('$fdisplay(fd,"%h %h %b %h %h",{rl,rr_audio},rraw,refphase,cpu_ref,ref_signature);','$fdisplay(fd,"%h %h %b %h %h %h",{rl,rr_audio},rraw,refphase,cpu_ref,ref_signature,ref_rom_event);');
replace('$fclose(fd);$display("PASS MATRIX REFERENCE','$fclose(fd);$writememh("reference_ram.hex",ref_bytes);$display("PASS MATRIX REFERENCE');
replace('$fscanf(fd,"%h %h %b %h %h",oracle[k],raw_oracle[k],phase_oracle[k],cpu_oracle[k],sig_oracle[k]);if(scan!=5)','$fscanf(fd,"%h %h %b %h %h %h",oracle[k],raw_oracle[k],phase_oracle[k],cpu_oracle[k],sig_oracle[k],event_oracle[k]);if(scan!=6)');
replace('end $fclose(fd);\nwait(!ss_freeze);','end $fclose(fd);$readmemh("reference_ram.hex",ram_oracle);\nwait(!ss_freeze);');
replace('if(raw!==raw_oracle[k])','if(rom_event!==event_oracle[k])$fatal(1,"G11/G12 STREAM pass%0d k%0d actual%h expected%h CPU%h",pass,k,rom_event,event_oracle[k],cpu_actual);\nif(raw!==raw_oracle[k])');
replace('$display("PASS SUFFIX pass%0d samples%0d progressCPU%0d PSG%0d paused%b",pass,N,progress_cpu,progress_psg,paused);','for(j=0;j<16384;j++)if(ram_bytes[j]!==ram_oracle[j])$fatal(1,"full WRAM divergence pass%0d address%h actual%h expected%h",pass,j,ram_bytes[j],ram_oracle[j]);\n$display("PASS ROM_STREAM_WRAM pass%0d samples%0d WRAM16384",pass,N);\n$display("PASS SUFFIX pass%0d samples%0d progressCPU%0d PSG%0d paused%b",pass,N,progress_cpu,progress_psg,paused);');
const observer=`
always@(posedge clk)begin
 rom_event<=0;ref_rom_event<=0;
 if(reset_n&&!ss_freeze&&cpu_ce&&(!paused||ss_capture_progress)&&cpu.TState==2&&!crd&&!cmreq&&ca<16'hc000)
  rom_event<={1'b1,phys,sd,decoded};
 if(reset_n&&((DUAL==3||DUAL==5)?rce_cpu:rce_pix)&&!holdref&&(!rpaused||ref_progress)&&rcpu.TState==2&&!rrd&&!rmreq&&ra<16'hc000)
  ref_rom_event<={1'b1,rphys,rchip.byte_at(rphys),rchip.plain_byte(ra,rphys,!rm1)};
end
reg raw_prep_old=0,raw_tracking=0;integer raw_accepts=0,raw_returns=0,raw_reissues=0;
always@(posedge clk)begin
 if(cpu_prepare&&!raw_prep_old)begin raw_tracking=1;raw_accepts=0;raw_returns=0;end
 if(raw_tracking&&live.mode==0&&live.q==0&&!live.access_manager.old_rd&&rd)begin raw_accepts++;$display("G11_RAW_ACCEPT cycle%0d physical%h",cycle,phys);end
 if(raw_tracking&&live.mode==0&&live.q==6&&live.ram_req&&!live.wr)begin raw_returns++;$display("G11_RAW_RETURN cycle%0d physical%h",cycle,{live.bank,live.a});end
 if(raw_tracking&&cpu.MCycle==1&&cpu.TState==2&&((cpu_prepare&&replay&&ce_cpu)||(!ss_freeze&&!paused&&cpu_ce)))begin
  if(rd)begin
   if(raw_accepts!=1||raw_returns!=1||{live.bank,live.a}!==phys||sd!==chip.byte_at(phys))$fatal(1,"CONTRADICTORY_G12 restored request accepts%0d returns%0d",raw_accepts,raw_returns);
   raw_reissues++;$display("PASS G11_RAW_REISSUE cycle%0d physical%h raw%h decode%h",cycle,phys,sd,decoded);
  end
  raw_tracking=0;
 end
 raw_prep_old<=cpu_prepare;
end
final $display("G11_RAW_REISSUES %0d",raw_reissues);
`;
s=s.replace(/endmodule\s*$/,observer+'\nendmodule\n');
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
console.log('Prepared per-clock physical/raw/decrypted stream oracle and full final WRAM equality.');
