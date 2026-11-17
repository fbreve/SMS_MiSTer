const fs=require('fs'),p=require('path'),here=__dirname,src=p.join(here,'candidate'),d=p.join(here,'psg');
fs.mkdirSync(d,{recursive:true});
for(const f of fs.readdirSync(src))if(/\.(sv|svh|vhd|do|ps1|hex|json)$/.test(f)&&fs.statSync(p.join(src,f)).isFile())fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
const put=(f,s)=>fs.writeFileSync(p.join(d,f),s),read=f=>fs.readFileSync(p.join(src,f),'utf8').replace(/\r\n/g,'\n');
let h=read('header.svh').replace('NATURAL_PHASE=0;', 'NATURAL_PHASE=0,SYSTEM_E=1;').replace("reg systeme = '0;", 'wire systeme=SYSTEM_E!=0;');put('header.svh',h);
let controller=read('savestates_sim.sv');
if(!controller.includes('parameter TB_FAST'))controller=controller.replace('module savestates (','module savestates #(parameter TB_FAST=0) (').replace("20'd900000;", "(TB_FAST?20'd0:20'd900000);");
put('savestates_sim.sv',controller);
let s=read('vdp_tb.sv');
s=s.replace('wire cpu_tick=TURBO?ce_pix:ce_cpu;', 'wire cpu_tick=(TURBO||SYSTEM_E)?ce_pix:ce_cpu;');
s=s.replaceAll('ram[0:8191]','ram[0:16383]').replaceAll('n<8192','n<16384').replaceAll('wram_A[12:0]','wram_A[13:0]').replaceAll('wram_WA[12:0]','wram_WA[13:0]').replaceAll('ca[12:0]','ca[13:0]');
s=s.replace('assign psg_out=0;assign psg2_out=0;assign psg_ext_out=0;assign psg2_ext_out=0;assign psg_div_out=0;assign audio_quiescent=1;', `
wire quiet1,quiet2;wire[3:0]div2;reg pgwr=1;reg[7:0]pgd1=0,pgd2=0;
wire pgce=ce_cpu&&!frozen&&!logical_pause;
assign audio_quiescent=quiet1&&(!systeme||quiet2);
jt89 pg1(.clk(clk),.clk_en(pgce),.rst(!reset_n),.wr_n(pgwr),.din(pgd1),.mux(8'hff),.soundL(),.soundR(),.ready(),.ss_out(psg_out),.ss_set(psg_set),.ss_in(psg_in),.ss_ext_out(psg_ext_out),.ss_ext_in(psg_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(psg_div_out),.ss_div_in(psg_div_in),.ss_quiescent(quiet1));
jt89 pg2(.clk(clk),.clk_en(pgce),.rst(!reset_n),.wr_n(pgwr),.din(pgd2),.mux(8'hff),.soundL(),.soundR(),.ready(),.ss_out(psg2_out),.ss_set(psg2_set),.ss_in(psg2_in),.ss_ext_out(psg2_ext_out),.ss_ext_in(psg2_ext_in),.ss_ext_set(audio_ext_set&&systeme),.ss_div_out(div2),.ss_div_in(psg_div_in),.ss_quiescent(quiet2));
task pgput(input[7:0]a,b);begin pgd1=a;pgd2=b;pgwr=0;repeat(31)tick;pgwr=1;repeat(31)tick;end endtask
wire[155:0]pgstate1={psg_out,psg_ext_out,psg_div_out},pgstate2={psg2_out,psg2_ext_out,div2};
reg[155:0]pgref1[0:9999],pgref2[0:9999];reg[3:0]ceref[0:9999];reg pgloaded=0,pgdone=0;
task pgscore;integer f,k,n;begin
 pgdone=0;
 if(REFERENCE)f=$fopen("psg_reference.dat","w");
 else if(!pgloaded)begin
  f=$fopen("psg_reference.dat","r");if(!f)$fatal(1,"missing PSG reference");
  for(k=0;k<10000;k++)begin n=$fscanf(f,"%h %h %h\\n",ceref[k],pgref1[k],pgref2[k]);if(n!=3)$fatal(1,"short PSG reference");end
  $fclose(f);pgloaded=1;
 end
 for(k=0;k<10000;k++)begin @(posedge clk);#1;
  if(REFERENCE)$fdisplay(f,"%h %h %h",{ce_cpu,ce_vdp,ce_pix,ce_sp},pgstate1,pgstate2);
  else begin
   if({ce_cpu,ce_vdp,ce_pix,ce_sp}!==ceref[k])$fatal(1,"first-enable order mismatch clock%0d",k);
   if(pgstate1!==pgref1[k]||(systeme&&pgstate2!==pgref2[k]))$fatal(1,"PSG logical-state mismatch clock%0d DUT%h ref%h",k,pgstate1,pgref1[k]);
  end
 end
 if(REFERENCE)$fclose(f);pgdone=1;$display("PSG_TRACE PASS systeme%0d hostclocks10000",SYSTEM_E);
end endtask
reg[311:0]pgheld;reg pgpreparing=0;
always@(posedge clk)begin
 if(cpu_prepare&&!pgpreparing)pgheld={pgstate1,pgstate2};
 if(cpu_prepare&&(pgce||{pgstate1,pgstate2}!==pgheld))$fatal(1,"PSGs advanced during CPU-only preparation");
 pgpreparing<=cpu_prepare;
end
`);
s=s.replace('reset_n=1;init_we=1;', "reset_n=1;pgput(8'h8d,8'h85);pgput(8'h02,8'h03);pgput(8'h91,8'h94);pgput(8'he7,8'he5);pgput(8'hf3,8'hf6);init_we=1;");
s=s.replace('$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);', '$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);fork pgscore;join_none');
s=s.replace(' if(REFERENCE)begin $fclose(f);', ' wait(pgdone);\n if(REFERENCE)begin $fclose(f);');
s=s.replace('  request(0);divs=0;', '  request(0);fork pgscore;join_none divs=0;');
s=s.replace('  $display("RESULT pass', '  wait(pgdone);\n  $display("RESULT pass');put('vdp_tb.sv',s);
let run=read('run.ps1').replace("[string]$Label='case'", "[int]$Sys=1,[string]$Label='case'")
 .replace('$env:PROTOCOL_PAUSE=$PauseCapture;', '$env:PROTOCOL_SYSE=$Sys;$env:PROTOCOL_PAUSE=$PauseCapture;')
 .replace(';Copy-Item -LiteralPath (Join-Path $ref', ';$ref=Join-Path $PSScriptRoot "reference_s${Sys}_t${Turbo}";Copy-Item -LiteralPath (Join-Path $ref')
 .replace(' -Destination $case}', ' -Destination $case;Copy-Item -LiteralPath (Join-Path $ref "psg_reference.dat") -Destination $case}');
put('run.ps1',run);put('run.do',read('run.do').replace(' -gREFERENCE=', ' -gSYSTEM_E=$env(PROTOCOL_SYSE) -gREFERENCE='));
put('compile.do',read('compile.do').replace('vlog -work vdp_work -sv', 'vlog -work vdp_work -suppress 2388 -quiet ../../../rtl/jt89/jt89_vol.v ../../../rtl/jt89/jt89_tone.v ../../../rtl/jt89/jt89_noise.v ../../../rtl/jt89/jt89_mixer.v ../../../rtl/jt89/jt89.v\nvlog -work vdp_work -sv'));
console.log('Real dual-PSG integration and first-enable oracle prepared.');
