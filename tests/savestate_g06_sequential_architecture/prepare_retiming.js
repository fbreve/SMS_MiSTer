const fs=require('fs'),p=require('path'),d=__dirname,out=p.join(d,'read_retiming');
for(const f of ['vdp_sprite_shifter','vdp_sprites']){
 let s=fs.readFileSync(p.join(out,'distributed/rtl',f+'.vhd'),'utf8').replace(/\bvdp_sprites\b/g,'sprite_read_reference').replace(/\bvpd_sprite_shifter\b/g,'shifter_read_reference');fs.writeFileSync(p.join(out,f+'_reference.vhd'),s);
}
let s=fs.readFileSync(p.join(d,'local_tb.sv'),'utf8').replace('module local_tb;','module retime_tb;');
s=s.replace('vdp_sprites_reference #(.MAX_SPPL(63))','sprite_read_reference #(.MAX_SPPL(63),.SS_SEQUENTIAL(1))');
s=s.replace('.ss_sprite_out(refrecord),.ss_sprite_in(saved),',`.ss_state_addr(sa),.ss_state_read(sr),.ss_state_write(sw),.ss_state_wdata(sd),.ss_state_rdata(sq_ref),.ss_sprite_out(refrecord),.ss_sprite_in(saved),`);
s=s.replace('wire[31:0]sq;',`wire[31:0]sq,sq_ref;reg[31:0]root_response=0,old_collision_response=0;reg[13:0]collision_value=14'h3fc0;reg check_read=0;
wire[31:0]collision_word=!sr?32'd0:sa==148?{collision_value[3:0],28'd0}:sa==149?{22'd0,collision_value[13:4]}:32'd0;
integer read_checks=0;
always@(posedge clk)begin
 root_response<=sq|collision_word;old_collision_response<=collision_word;
 #1;if(check_read)begin
  if(root_response!==(sq_ref|old_collision_response))$fatal(1,"read register relocation mismatch address%0d",sa);
  read_checks++;
 end
end`);
s=s.replace('repeat(3)tick;','repeat(3)tick;check_read=1;');
s=s.replace('vram=random32();','vram=random32();sr=k%64==0;sa=random32()%150;collision_value=random32();');
s=s.replace('PASS LOCAL ALL trials16 checks%0d','PASS RETIMING ALL trials16 guest_checks%0d').replace('comparisons);$finish;','comparisons);$display("PASS READ RETIMING clocks%0d",read_checks);$finish;');
fs.writeFileSync(p.join(out,'retime_tb.sv'),s);
fs.writeFileSync(p.join(out,'run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib retime_work
vcom -work retime_work -2008 ../candidate_A/rtl/sprite_state_pkg.vhd ../candidate_A/rtl/vdp_sprite_shifter.vhd ../candidate_A/rtl/vdp_sprites.vhd vdp_sprite_shifter_reference.vhd vdp_sprites_reference.vhd
vlog -work retime_work -sv retime_tb.sv
vsim -t 1ps -voptargs=+acc retime_work.retime_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
console.log('Prepared exact distributed-register versus root-register read miter.');
