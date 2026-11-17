const fs=require('fs'),p=require('path'),here=__dirname,d=p.join(here,'format');fs.mkdirSync(d,{recursive:true});
const put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
let h=fs.readFileSync(p.join(here,'candidate/header.svh'),'utf8').replace(/\r\n/g,'\n');
put('format_tb.sv',h+`
always #5 clk=~clk;
assign vblank=1;assign x=0;assign z80_reg=0;assign z80_m1_n=0;assign z80_mreq_n=0;assign z80_iset=0;
assign cpu_ce=1;assign vdp_ce=0;assign pix_ce=0;assign sp_ce=0;
assign vdp_regs=0;assign cram_out=0;assign vram_D=0;assign wram_D=0;
assign psg_out=0;assign psg2_out=0;assign psg_ext_out=0;assign psg2_ext_out=0;assign psg_div_out=0;assign audio_quiescent=1;
assign vdp2_regs=0;assign video_state_out=0;assign g06_live=0;assign replay=0;
always@(negedge clk)phase_ready<=phase_set;
reg[63:0]mem[0:12287];integer pending=0;reg[28:0]readaddr;
always@(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b++)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending)$fatal(1,"overlapping read");pending<=3;readaddr<=DDRAM_ADDR;end
end
task tick;begin @(negedge clk);#1;end endtask
integer guest_writes=0,rejections=0,accepted=0;reg loading=0;
always@(posedge clk)if(loading&&(wram_WE||vram_WE||nvram_WE||vram2_WE||z80_set||mapper_set||evolution_set||gg_set||io_set||eeprom_set||gun_set||paddle_set||tap_set||vdp_regs_set||vdp2_regs_set||psg_set||psg2_set||cram_wr||cram2_wr||video_state_set||audio_ext_set||audio_phase_set))guest_writes++;
task transfer(input bit saveop);begin
 wait(!ss_busy);force dut.op_cooldown=0;tick;guest_writes=0;loading=!saveop;
 ss_save=saveop;ss_load=!saveop;tick;ss_save=0;ss_load=0;
 wait(ss_busy);wait(!ss_busy);loading=0;release dut.op_cooldown;tick;
end endtask
task reject_bit(input integer wordaddr,bitnum);reg[63:0]oldword;begin
 oldword=mem[wordaddr];mem[wordaddr]=oldword^(64'd1<<bitnum);
 transfer(0);if(guest_writes)$fatal(1,"malformed image wrote guest state word%h bit%0d",wordaddr,bitnum);
 mem[wordaddr]=oldword;rejections++;$display("REJECT word%h bit%0d",wordaddr,bitnum);
end endtask
reg[63:0]oldtag;
initial begin
 for(integer i=0;i<12288;i++)mem[i]=0;
 repeat(4)tick;reset_n=1;transfer(1);
 if(mem['h1a][63:40]!==24'h48430e||mem['h2e]!==64'h12aa0e0047365231||mem['h2f]!==8)$fatal(1,"v14 format writer");
 transfer(0);if(!guest_writes||!sprite_valid)$fatal(1,"valid v14 rejected");accepted++;
 for(integer b=0;b<64;b++)reject_bit('h2e,b);
 for(integer b=4;b<64;b++)reject_bit('h2f,b);
 reject_bit('h2f,2);
 for(integer b=42;b<64;b++)begin reject_bit('h294b,b);reject_bit('h2996,b);end
 reject_bit('h294c,0);
 // Every inherited tagged format retains its prior normalization policy.
 oldtag=mem['h1a];
 for(integer version=1;version<=13;version++)begin
  mem['h1a][63:40]=24'h484300+version;mem['h1a][39:38]=version==1?0:version==2?2:3;
  transfer(0);if(!guest_writes||sprite_valid||sprite_restored!==0)$fatal(1,"legacy normalization version%0d",version);
  accepted++;$display("LEGACY_ACCEPT version%0d",version);
 end
 mem['h1a]=oldtag;mem['h2f][3]=0;
 transfer(0);if(!guest_writes||replay_t2!==0)$fatal(1,"stopped capture flag rejected");accepted++;
 $display("PASS V14 FORMAT rejected%0d accepted%0d",rejections,accepted);$finish;
end
initial begin #100000000;$fatal(1,"format watchdog");end
endmodule
`);
let c=fs.readFileSync(p.join(here,'candidate/savestates_sim.sv'),'utf8');put('savestates_sim.sv',c);
put('run.do',`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib format_work\nvlog -work format_work -sv -quiet savestates_sim.sv format_tb.sv\nvsim -c format_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1\nrun -all\nquit -code 0\n`);
console.log('v14 format mutation and legacy checks prepared.');
