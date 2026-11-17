const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const decision=require('./early_results.json');assert(['FITS COMFORTABLY','FITS BUT REQUIRES CAUTION'].includes(decision.classification),'resource gate blocks broadening');
let s=fs.readFileSync(p.join(d,'audio_tb.sv'),'utf8').replace('module pause_tb;','module random_tb;').replace('parameter FM_SUPPRESS=0,','parameter RANDOMSEED=1,FM_SUPPRESS=0,').replace('N=20000','N=48000').replaceAll('[0:20000]','[0:47999]');
s=s.replace('opll rfm(', 'opll_reference rfm(');
s=s.replace('assign cpu_ce=ce_pix;',"wire random_normal_cpu=(RANDOMSEED%5!=0)&&(RANDOMSEED&1);wire guest_cpu_ce=random_normal_cpu?ce_cpu:ce_pix;\nassign cpu_ce=guest_cpu_ce;");
s=s.replace('(ce_pix&&!ss_freeze&&','(guest_cpu_ce&&!ss_freeze&&').replace('(rce_pix&&!holdref&&','((random_normal_cpu?rce_cpu:rce_pix)&&!holdref&&');
s=s.replace('systeme=0;', 'systeme=(RANDOMSEED%5==0);');
s=s.replaceAll("{fmout[12:0],3'b0}","{((fmout[13]==fmout[12])?fmout[12:0]:{fmout[13],{12{fmout[12]}}}),3'b0}").replaceAll("{rfmout[12:0],3'b0}","{((rfmout[13]==rfmout[12])?rfmout[12:0]:{rfmout[13],{12{rfmout[12]}}}),3'b0}");
s=s.replace('fmsetup; repeat(SEED)tick;', 'fmsetup; randomsetup; repeat(SEED)tick;');
s=s.replaceAll("(FM_SUPPRESS?16'd0:{((fmout[13]==fmout[12])?fmout[12:0]:{fmout[13],{12{fmout[12]}}}),3'b0})", "(systeme?{audio2[10],audio2,4'b0}:(FM_SUPPRESS?16'd0:{((fmout[13]==fmout[12])?fmout[12:0]:{fmout[13],{12{fmout[12]}}}),3'b0}))");
s=s.replaceAll("(FM_SUPPRESS?16'd0:{((rfmout[13]==rfmout[12])?rfmout[12:0]:{rfmout[13],{12{rfmout[12]}}}),3'b0})", "(systeme?{raudio[10],raudio,4'b0}:(FM_SUPPRESS?16'd0:{((rfmout[13]==rfmout[12])?rfmout[12:0]:{rfmout[13],{12{rfmout[12]}}}),3'b0}))");
s=s.replace(".audio_in_r2((systeme?{audio2[10],audio2,4'b0}",".audio_in_r2((systeme?{a2r[10],a2r,4'b0}").replace(".audio_in_r2((systeme?{raudio[10],raudio,4'b0}",".audio_in_r2((systeme?{rar[10],rar,4'b0}");
s=s.replace('if(FM_SUPPRESS&&errors)$fatal', 'if((FM_SUPPRESS||systeme)&&errors)$fatal');
s=s.replace('if(fmout!==ofm[k])',"if(systeme&&{psg2_out,psg2_ext_out,div2,audio2,a2r}!=={ocfg[k],oext[k],odiv[k],osnd[k]})$fatal(1,\"System E PSG2 isolation\");\nif(fmout!==ofm[k])");
s=s.replace("qmode=1; fmwrite(8'h30,8'hf0);", "qmode=1; fmwrite(8'hf0,0);fmwrite(0,8'h61^(RANDOMSEED+pass));fmwrite(3,(RANDOMSEED*7+pass)&31);fmwrite(8'h0e,((RANDOMSEED+pass)&1)?8'h3f:0);fmwrite(8'h20,8'h09);fmwrite(8'h30,8'hf0);");
s=s.replace("fmwrite(8'h10,8'h37+pass)","fmwrite(8'h10,(8'h37+pass+RANDOMSEED*13)&255)");
s=s.replace(/\nendmodule\s*$/,`
integer random_state;integer rv,chan,voices;
function automatic integer next_random;begin random_state=random_state^(random_state<<13);random_state=random_state^(random_state>>17);random_state=random_state^(random_state<<5);next_random=random_state&32'h7fffffff;end endfunction
task randomsetup;begin
 random_state=RANDOMSEED*32'h19e3779;
 rv=next_random();fmwrite(0,(rv&1)?8'he1:8'h61);rv=next_random();fmwrite(1,(rv&1)?8'he1:8'h61);
 rv=next_random();fmwrite(2,rv&63);fmwrite(3,(RANDOMSEED&7)|((RANDOMSEED&3)<<3));
 rv=next_random();fmwrite(4,((8+(rv&7))<<4)|((rv>>3)&15));rv=next_random();fmwrite(5,((8+(rv&7))<<4)|((rv>>3)&15));
 rv=next_random();fmwrite(6,((rv%13)<<4)|(1+((rv>>4)%15)));rv=next_random();fmwrite(7,((rv%13)<<4)|(1+((rv>>4)%15)));
 voices=2+(RANDOMSEED%8);
 for(chan=0;chan<voices;chan++)begin
  rv=next_random();fmwrite(8'h30+chan,chan==0?(rv&3):(rv&255));
  rv=next_random();fmwrite(8'h10+chan,64+(rv%192));
 rv=next_random();fmwrite(8'h20+chan,(chan==0?8'h10:((rv>>4)&8'h30))|((3+(rv%4))<<1)|((rv>>9)&1));
 end
 if(RANDOMSEED%3==0)begin fmwrite(8'h36,8'h10);fmwrite(8'h37,8'h10);fmwrite(8'h38,8'h10);fmwrite(8'h0e,8'h3f);end
 if(RANDOMSEED%4==0)fmwrite(8'hf0,8'h80);
 rv=next_random();repeat(1000+(rv%18000))tick;
 $display("RANDOM_CONFIG seed%0d channels%0d feedback%0d",RANDOMSEED,voices,RANDOMSEED&7);
end endtask
endmodule
`);
fs.writeFileSync(p.join(d,'random_tb.sv'),s);
let ref=fs.readFileSync(p.join(d,'../savestate_f01_opll_architecture/sim_opll/opll.vhd'),'latin1').replace(/entity\s+opll\s+is/i,'entity opll_reference is').replace(/end\s+opll\s*;/i,'end opll_reference;').replace(/architecture\s+rtl\s+of\s+opll\s+is/i,'architecture rtl of opll_reference is');
fs.writeFileSync(p.join(d,'opll_reference.vhd'),ref,'latin1');
let compile=fs.readFileSync(p.join(d,'compile.do'),'utf8').replaceAll('work_v17','work_random').replace('audio_tb.sv','random_tb.sv').replace('quit -code 0','vcom -work original_work -2008 opll_reference.vhd\nquit -code 0');fs.writeFileSync(p.join(d,'random_compile.do'),compile);
fs.writeFileSync(p.join(d,'random_run.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -L work_random -L original_work -t 1ps -voptargs=+acc work_random.random_tb -gRANDOMSEED=$env(RANDOMSEED) -gREF=$env(REF) -gSTALL=$env(STALL) -g/random_tb/dut/TB_FAST=1\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n');
