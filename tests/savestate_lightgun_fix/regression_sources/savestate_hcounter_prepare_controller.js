const fs=require('fs'),path=require('path');const dir=__dirname,root=path.resolve(dir,'../..');
const s=fs.readFileSync(path.join(root,'rtl/savestates.sv'),'utf8').split(');')[0].replace(/\/\/[^\n]*/g,'');
const ports=[...s.matchAll(/\b(input|output)\s+(?:reg\s+)?(\[[^\]]+\]\s*)?(\w+)\s*(?:,|$)/gm)];
// ModelSim 10.5b rejects two existing forward references (Quartus accepts them).
// Move declarations only, leaving every expression, process and interface intact.
let sim=fs.readFileSync(path.join(root,'rtl/savestates.sv'),'utf8');
for(const name of ['mapper_snap','evolution_snap']){
 const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+name+';\\r?\\n','m');
 const decl=sim.match(re)[0];sim=sim.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');
}
fs.writeFileSync(path.join(dir,'savestates_sim.sv'),sim);
const declarations=ports.map(([,d,w,n])=>`${d==='input'?'reg':'wire'} ${w||''}${n}${d==='input'?" = '0":''};`).join('\n');
fs.writeFileSync(path.join(dir,'controller_tb.sv'),`\`timescale 1ns/1ps
module controller_tb;
${declarations}
savestates dut(${ports.map(p=>`.${p[3]}(${p[3]})`).join(',')});
always #5 clk=~clk;
reg [63:0] mem[0:12287]; integer cycle=0, pending=0; reg [28:0] readaddr;
integer writes=0,reads=0; reg restored=0; reg [135:0] seen1,seen2;
always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;end
always @(posedge clk) begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=mem[readaddr-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])mem[DDRAM_ADDR-29'h07c00000][b*8+:8]<=DDRAM_DIN[b*8+:8];writes<=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap read");pending<=3;readaddr<=DDRAM_ADDR;reads<=reads+1;end
 if(vdp_regs_set)begin seen1<=vdp_regs_in;restored<=1;end
 if(vdp2_regs_set)seen2<=vdp2_regs_in;
end
task tick;begin @(negedge clk);#1;end endtask
task operation(input bit saving);begin
 force dut.op_cooldown=0; // UI cooldown only; all transfer/restore FSM stages run normally
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end endtask
reg [63:0] video_saved; integer testno;
initial begin
 reset_n=0;repeat(4)tick;reset_n=1;
 vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;
 ss_game_id=32'h12345678;mapper_out=64'h60; // nonzero distinct System E physical VRAM bank bits, no NVRAM
 video_state_out=22'h12345;
 for(testno=0;testno<10;testno=testno+1)begin
  systeme=testno!=0&&testno!=6; // oldest pre-#192 format is the SMS compatibility path
  vdp_regs={8'h5a,128'h0123456789abcdef0011223344556677};
  vdp2_regs={8'ha5,128'hfedcba98765432108877665544332211};
  operation(1);
  video_saved=mem['h1a];
  if(video_saved!=={24'h484307,2'b11,(systeme?8'ha5:8'h00),8'h5a,22'h12345})$fatal(1,"stored extension mismatch");
  // Previous 96K, random old padding, future version, bad reserved, oldest64K.
  case(testno)
   2:mem['h1a]={42'd0,22'h12345};
   3:mem['h1a]={42'h2abcdef1234,22'h12345};
   4:mem['h1a]={24'h484308,2'b00,8'hfa,8'hfb,22'h12345};
   5:mem['h1a]={24'h484301,2'b01,8'hfa,8'hfb,22'h12345};
   6:begin mem[0][63:32]=32'd16382;mem['he][63]=0;end
   9:mem['h1a]={24'h484303,2'b11,8'ha5,8'h5a,22'h12345}; // committed F08
   8:mem['h1a]={24'h484302,2'b10,8'ha5,8'h5a,22'h12345}; // committed F02 v2
   7:mem['h1a]={24'h484301,2'b00,8'ha5,8'h5a,22'h12345}; // committed F07 v1
  endcase
  vdp_regs='1;vdp2_regs='1;restored=0;seen1='x;seen2='x;
  operation(0);
  if(!restored)$fatal(1,"legacy/new load not accepted case %0d",testno);
  if(seen1[127:0]!==128'h0123456789abcdef0011223344556677)$fatal(1,"VDP1 old fields changed");
  if(systeme&&seen2[127:0]!==128'hfedcba98765432108877665544332211)$fatal(1,"VDP2 old fields changed");
  if(seen1[135:128]!==((testno<2||testno==7||testno==8||testno==9)?8'h5a:8'h00))$fatal(1,"VDP1 latch case %0d value %h",testno,seen1[135:128]);
  if(systeme&&seen2[135:128]!==((testno<2||testno==7||testno==8||testno==9)?8'ha5:8'h00))$fatal(1,"VDP2 latch case %0d",testno);
  $display("PASS controller case %0d SystemE=%0d H1=%h H2=%h writes=%0d reads=%0d",testno,systeme,seen1[135:128],seen2[135:128],writes,reads);
 end
 $display("PASS controller: modern SMS/System E plus previous96K, random padding, unknown version, invalid reserved, old64K");$finish;
end
initial begin #300000000;$fatal(1,"watchdog");end
endmodule
`);
fs.writeFileSync(path.join(dir,'controller.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vlog -sv -quiet savestates_sim.sv controller_tb.sv
vsim -c -t 1ps work.controller_tb
run -all
quit -code 0
`);
