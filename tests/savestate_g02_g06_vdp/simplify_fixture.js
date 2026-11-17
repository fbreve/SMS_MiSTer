// One-time fixture migration: avoid Starter's >10k statement slowdown by
// recording a separate, uninterrupted simulation instead of a second core.
const fs=require('fs'),p=require('path');const file=p.join(__dirname,'vdp_tb.sv');
let s=fs.readFileSync(file,'utf8').replace(/\r\n/g,'\n');
s=s.split('\n').filter(l=>!l.startsWith('video videoref(')&&!l.startsWith('T80s #(.T2Write(0)) rcpu(')&&!l.startsWith('vdp refvdp1(')).join('\n');
s=s.replace('integer cycle=0;',"wire frozen=ss_freeze&&!REFERENCE;reg hl=0;\ninteger cycle=0;");
s=s.replaceAll('!ss_freeze','!frozen').replace('wire frozen=ss_freeze&&!REFERENCE','wire frozen=ss_freeze&&!REFERENCE');
s=s.replaceAll(".HL(1'b0)",'.HL(hl)');
s=s.replace('wait(ss_freeze);wait(!frozen);#1;', 'if(REFERENCE)begin wait(dut.state==41);tick;end else begin wait(ss_freeze);wait(!frozen);end #1;');
s=s.replace('if(video_state_out[21:4]', 'if(!REFERENCE&&video_state_out[21:4]');
s=s.replace('init_cwe=0;setup=0;', 'init_cwe=0;hl=1;tick;hl=0;tick;setup=0;');
const start=s.indexOf(' // Independent uninterrupted reference:'),end=s.indexOf(' f=$fopen("image.hex"',start);
if(start<0||end<0)throw Error('migration anchors');
s=s.slice(0,start)+` // Reference and DUT execute identical P in independent simulations.
 if(REFERENCE)f=$fopen("reference.dat","w");else begin
  f=$fopen("reference.dat","r");if(!f)$fatal(1,"missing uninterrupted reference");
  for(j=0;j<1000;j=j+1)begin n=$fscanf(f,"%h %h %h %h %h\\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j]);if(n!=5)$fatal(1,"short reference");end $fclose(f);
 end
 for(j=0;j<1000;j=j+1)begin
  do tick;while(!ce_pix);@(posedge clk);#1;
  if($isunknown({vdp_regs,color,irq}))$fatal(1,"unknown initialized oracle x%0d y%0d regs%h color%h",x,y,vdp_regs,color);
  if(REFERENCE)$fdisplay(f,"%h %h %h %h %h",x,y,vdp_regs,color,vd);
  else begin
   if({x,y}!=={tx[j],ty[j]})$fatal(1,"save-only beam misalignment");
   if(vdp_regs!==trace[j]||color!==pixels[j])$fatal(1,"SAVE-only reference mismatch x%0d y%0d dut%h ref%h",x,y,vdp_regs,trace[j]);
  end
  savechecks++;
 end
 if(REFERENCE)begin $fclose(f);$display("PASS UNINTERRUPTED REFERENCE samples%0d",savechecks);$finish;end
`+s.slice(end);
fs.writeFileSync(file,s);
