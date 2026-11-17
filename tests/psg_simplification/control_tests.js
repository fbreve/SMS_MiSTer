const fs=require('fs'),p=require('path'),assert=require('assert');const d=__dirname,dir=p.join(d,'native');
const sys=fs.readFileSync(p.join(d,'C/rtl/system.vhd'),'utf8');const a=sys.indexOf('FM_gated <='),b=sys.indexOf('-- The old code shifts FM',a);assert(a>0&&b>a);const routing=sys.slice(a,b);
fs.writeFileSync(p.join(dir,'routing.vhd'),`library ieee;use ieee.std_logic_1164.all;entity routing is port(fm_ena,mapper_evolution,systeme,gg:in std_logic;det_D:in std_logic_vector(2 downto 0);psg_enables:in std_logic_vector(1 downto 0);PSG_outL,PSG_outR,PSG2_outL,PSG2_outR:in std_logic_vector(10 downto 0);FM_out:in std_logic_vector(13 downto 0);FM_gated,mix_inL,mix_inR,mix2_inL,mix2_inR:out std_logic_vector(12 downto 0);PSG_disable:out std_logic);end;architecture extracted of routing is alias FM_sign:std_logic is FM_out(13);alias FM_adj:std_logic is FM_out(12);begin\n${routing}\nend;\n`);
let tb=`\`timescale 1ns/1ps\nmodule restore_controls_tb;
reg clk=0;always #5 clk=~clk;reg reset_n=0,freeze=0,restore=0,detwr=1,balwr=1,gg=0,systeme=0;reg[7:0]din=0;reg[10:0]saved;
integer persistent=0,fm_differences=0,stereo_differences=0,checks=0;
`;
for(const v of ['A','B','C']){
tb+=`wire[10:0]${v}ctl;wire signed[10:0]${v}l,${v}r;wire[12:0]${v}fm,${v}ml,${v}mr,${v}m2l,${v}m2r;wire ${v}disable;\n`;
tb+=`${v}_controls ${v}control(.clk_sys(clk),.RESET_n(reset_n),.ss_freeze(freeze),.psg_set(restore),.audio_ext_set(restore),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(saved),.audio_control_out(${v}ctl));\n`;
// Configuration-only restoration suffices to establish a constant tone below6.
tb+=`${v}_jt89 ${v}psg(.clk(clk),.clk_en(1'b1),.rst(!reset_n),.wr_n(1'b1),.din(8'd0),.mux(${v}ctl[7:0]),.soundL(${v}l),.soundR(${v}r),.ready(),.ss_out(),.ss_in({4'd0,3'd0,3'd4,4'd15,4'd15,4'd15,4'd1,10'd0,10'd0,10'd1}),.ss_set(restore)${v==='A'?',.ss_ext_in(96\'d0),.ss_ext_set(1\'b0),.ss_div_in(4\'d0),.ss_ext_out(),.ss_div_out(),.ss_quiescent()':''});\n`;
tb+=`routing ${v}route(.fm_ena(1'b1),.mapper_evolution(1'b0),.systeme(systeme),.gg(gg),.det_D(${v}ctl[10:8]),.psg_enables(2'd0),.PSG_outL(${v}l),.PSG_outR(${v}r),.PSG2_outL(11'd111),.PSG2_outR(11'd222),.FM_out(14'd321),.FM_gated(${v}fm),.mix_inL(${v}ml),.mix_inR(${v}mr),.mix2_inL(${v}m2l),.mix2_inR(${v}m2r),.PSG_disable(${v}disable));\n`;
}
tb+=`task tick;begin @(negedge clk);#1;end endtask
task write_controls(input[10:0]v);begin din={5'd0,v[10:8]};detwr=0;tick;detwr=1;din=v[7:0];balwr=0;tick;balwr=1;tick;end endtask
initial begin
 repeat(5)tick;reset_n=1;tick;
 for(integer mode=0;mode<8;mode=mode+1)begin
  saved={3'(mode),8'h01};write_controls({3'(mode^7),8'h10});
  freeze=1;restore=1;tick;restore=0;freeze=0;repeat(50)tick;
  for(integer i=0;i<2000;i=i+1)begin
   gg=mode%2;systeme=(mode/2)%2;tick;
   if({Actl,Afm,Aml,Amr,Am2l,Am2r,Adisable}!=={Cctl,Cfm,Cml,Cmr,Cm2l,Cm2r,Cdisable})$fatal(1,"C control/routing restore");
   if(Bctl===Actl)$fatal(1,"missing intentional B control loss");persistent=persistent+1;
   if(Bfm!==Afm)fm_differences=fm_differences+1;
   if({Bl,Br}!=={Al,Ar})stereo_differences=stereo_differences+1;
   if(Al!==0||Ar!==203||Bl!==203||Br!==0)$fatal(1,"GG stereo side assignment");
   checks=checks+1;
  end
 end
 if(persistent!=16000||fm_differences!=16000||stereo_differences!=16000)$fatal(1,"control coverage");
 $display("PASS control consumers: checks=%0d C_matches_master=%0d B_persistent_control=%0d B_FM_gate=%0d B_swapped_stereo=%0d SMS/GG/SystemE det_values0..7",checks,checks,persistent,fm_differences,stereo_differences);$finish;
end
endmodule
`;
fs.writeFileSync(p.join(dir,'restore_controls_tb.sv'),tb);
fs.writeFileSync(p.join(dir,'controls.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvcom -2008 -quiet routing.vhd\nvlog -sv -quiet restore_controls_tb.sv\nvsim -c -t 1ps work.restore_controls_tb\nrun -all\nquit -code 0\n`);
