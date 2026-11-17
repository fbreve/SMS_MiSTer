const fs=require('fs'),p=require('path');const d=__dirname,dir=p.join(d,'native');fs.mkdirSync(dir,{recursive:true});
const put=(f,s)=>fs.writeFileSync(p.join(dir,f),s);
for(const v of ['A','B','C']){
 for(const name of ['jt89','jt89_tone','jt89_noise','jt89_vol','jt89_mixer'])put(`${v}_${name}.v`,fs.readFileSync(p.join(d,`sim_${v}/${name}.v`),'utf8').replace(/\bjt89\w*\b/g,s=>v+'_'+s));
 put(`${v}_controls.vhd`,fs.readFileSync(p.join(d,`sim_${v}/controls.vhd`),'utf8').replace(/\bcontrols\b/g,v+'_controls'));
 put(`${v}_AudioMix.vhd`,fs.readFileSync(p.join(d,`sim_${v}/AudioMix.vhd`),'utf8').replace(/\bAudioMix\b/g,v+'_AudioMix'));
}
let tb=`\`timescale 1ns/1ps
module native_tb;
reg clk=0;always #5 clk=~clk;reg rst=1,ce=0,freeze=0,wr1=1,wr2=1,detwr=1,balwr=1;reg[7:0]din=0;
reg [31:0]rng=32'h187cda39;integer cycles=0,checks=0,nonzero=0,stereo=0,control_changes=0,reset_cases=0;reg[10:0]prevcontrols=0;
`;
for(const v of ['A','B','C']){
tb+=`wire[10:0] ${v}_control;wire[55:0]${v}_cfg1,${v}_cfg2;wire signed[10:0]${v}_l1,${v}_r1,${v}_l2,${v}_r2;wire signed[15:0]${v}_al,${v}_ar;\n`;
for(const chip of [1,2])tb+=`${v}_jt89 ${v}${chip}(.clk(clk),.rst(rst),.clk_en(ce&&!freeze),.wr_n(wr${chip}),.din(din),.mux(${chip===1?v+'_control[7:0]':"8'hff"}),.soundL(${v}_l${chip}),.soundR(${v}_r${chip}),.ready(),.ss_out(${v}_cfg${chip}),.ss_in(56'd0),.ss_set(1'b0)${v==='A'?',.ss_ext_in(96\'d0),.ss_ext_set(1\'b0),.ss_div_in(4\'d0),.ss_ext_out(),.ss_div_out(),.ss_quiescent()':''});\n`;
tb+=`${v}_controls ${v}ctl(.clk_sys(clk),.RESET_n(!rst),.ss_freeze(freeze),.psg_set(1'b0),.audio_ext_set(1'b0),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(11'd0),.audio_control_out(${v}_control));\n`;
tb+=`${v}_AudioMix ${v}mix(.clk(clk),.audio_in_l1({${v}_l1,5'd0}),.audio_in_r1({${v}_r1,5'd0}),.audio_in_l2({${v}_l2,5'd0}),.audio_in_r2({${v}_r2,5'd0}),.audio_l(${v}_al),.audio_r(${v}_ar)${v==='A'?',.ss_phase_out(),.ss_phase_in(1\'b0),.ss_phase_set(1\'b0)':''});\n`;
}
tb+=`task tick;begin @(negedge clk);#1;cycles=cycles+1;end endtask
task put(input integer chip,input[7:0]b);begin din=b;wr1=chip==1?0:1;wr2=chip==2?0:1;repeat(2)tick;wr1=1;wr2=1;repeat(2)tick;end endtask
always @(posedge clk)begin #1;
 if(!rst&&cycles>10)begin
 if({A_cfg1,A_cfg2,A_control,A_l1,A_r1,A_l2,A_r2,A_al,A_ar}!=={B_cfg1,B_cfg2,B_control,B_l1,B_r1,B_l2,B_r2,B_al,B_ar})$fatal(1,"B native operation mismatch cycle=%0d",cycles);
 if({A_cfg1,A_cfg2,A_control,A_l1,A_r1,A_l2,A_r2,A_al,A_ar}!=={C_cfg1,C_cfg2,C_control,C_l1,C_r1,C_l2,C_r2,C_al,C_ar})$fatal(1,"C native operation mismatch cycle=%0d",cycles);
 if(^({A_l1,A_r1,A_l2,A_r2,A_al,A_ar})===1'bx)$fatal(1,"unknown audio");
 checks=checks+1;if(A_al!=0||A_ar!=0)nonzero=nonzero+1;if(A_al!=A_ar)stereo=stereo+1;if(A_control!=prevcontrols)control_changes=control_changes+1;prevcontrols=A_control;
 end
end
initial begin
 repeat(5)tick;rst=0;ce=1;
 // Tone periods include the sample-playback boundary and the largest reload.
 for(integer tone=0;tone<9;tone=tone+1)begin
  put(1,8'h80|(tone==8?15:tone));put(1,tone==8?8'h3f:0);put(1,8'h91);put(1,8'he0|(tone%8));put(1,8'hf2);
  put(2,8'haf);put(2,8'h17);put(2,8'hb3);put(2,8'he0|(tone%8));put(2,8'hf1);
  repeat(22000)begin
   rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};ce=cycles%3==0;freeze=cycles%997<37;
   if(cycles%131==0)begin din=rng[7:0];detwr=0;end else detwr=1;
   if(cycles%137==0)begin din=rng[15:8];balwr=0;end else balwr=1;
   tick;
  end
  freeze=0;detwr=1;balwr=1;rst=1;repeat(3)tick;rst=0;reset_cases=reset_cases+1;
 end
 if(checks<190000||nonzero<1000||stereo<1000||control_changes<100)$fatal(1,"native coverage");
 $display("PASS native A/B/C: cycles=%0d checks=%0d nonzero=%0d stereo=%0d control_changes=%0d resets=%0d dual_PSG exact config/sample/mixer/control equivalence",cycles,checks,nonzero,stereo,control_changes,reset_cases);$finish;
end
endmodule
`;
put('native_tb.sv',tb);
put('run.do',`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib work\n${['A','B','C'].map(v=>`vlog -suppress 2388 -quiet ${['jt89_vol','jt89_tone','jt89_noise','jt89_mixer','jt89'].map(x=>`${v}_${x}.v`).join(' ')}\nvcom -2008 -quiet ${v}_controls.vhd ${v}_AudioMix.vhd`).join('\n')}\nvlog -sv -quiet native_tb.sv\nvsim -c -t 1ps -voptargs=+acc work.native_tb\n${['A','B','C'].map(v=>`force -deposit /native_tb/${v}mix/toggle 0 0`).join('\n')}\nrun -all\nquit -code 0\n`);
