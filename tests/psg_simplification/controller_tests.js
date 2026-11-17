const fs=require('fs'),p=require('path');const d=__dirname;
for(const v of ['B','C']){
const source=fs.readFileSync(p.join(d,`sim_${v}/controller.sv`),'utf8');
const ports=[...source.split(');')[0].replace(/\/\/[^\n]*/g,'').matchAll(/\b(input|output)\s+(?:reg\s+)?(\[[^\]]+\]\s*)?(\w+)\s*(?:,|$)/gm)];
const dynamic=['psg_out','psg2_out','audio_control_out'];
const decl=ports.map(([,kind,w,n])=>`${kind==='output'||dynamic.includes(n)?'wire':'reg'} ${w||''}${n}${kind==='input'&&!dynamic.includes(n)?"='0":''};`).join('\n');
let tb=`\`timescale 1ns/1ps
module controller_tb;
${decl}
${v==='B'?'wire [10:0] audio_control_out;reg [10:0] audio_control_in=0;':''}
savestates dut(${ports.map(x=>`.${x[3]}(${x[3]})`).join(',')});
always #5 clk=~clk;
reg wr1=1,wr2=1;reg [7:0] din=0;reg detwr=1,balwr=1;
wire signed [10:0] l,r,l2,r2;
jt89 p1(.clk(clk),.clk_en(cpu_ce&&!ss_freeze),.rst(!reset_n),.wr_n(wr1),.din(din),.mux(audio_control_out[7:0]),.soundL(l),.soundR(r),.ready(),.ss_out(psg_out),.ss_in(psg_in),.ss_set(psg_set));
jt89 p2(.clk(clk),.clk_en(cpu_ce&&!ss_freeze),.rst(!reset_n),.wr_n(wr2),.din(din),.mux(8'hff),.soundL(l2),.soundR(r2),.ready(),.ss_out(psg2_out),.ss_in(psg2_in),.ss_set(psg2_set));
controls ctl(.clk_sys(clk),.RESET_n(reset_n),.ss_freeze(ss_freeze),.psg_set(psg_set),.audio_ext_set(1'b0),.det_WR_n(detwr),.bal_WR_n(balwr),.D_in(din),.audio_control_in(audio_control_in),.audio_control_out(audio_control_out));
wire signed[15:0] al,ar;
AudioMix mix(.clk(clk),.audio_in_l1({l,5'd0}),.audio_in_r1({r,5'd0}),.audio_in_l2(systeme?{l2,5'd0}:16'd0),.audio_in_r2(systeme?{r2,5'd0}:16'd0),.audio_l(al),.audio_r(ar));
reg [63:0] memory[0:98303];integer cycles=0,pending=0,writes=0,reads=0,loads=0,loads2=0,ops=0,stalled=0,rejected=0;
reg [28:0] ra;reg stalls=0;reg [31:0] rng=32'h7a9d321b;
reg[229:0] saved_cpu;reg[127:0] saved_vdp;reg[55:0] saved_psg,saved_psg2;reg[10:0] saved_controls,changed_controls;
integer cram_writes=0,ram_writes=0,restores=0,last_accept=0;
reg[28:0] held_addr;reg[63:0]held_data;reg[7:0]held_be;reg held_rd,held_we,holding=0;
always @(negedge clk)begin
 cycles=cycles+1;cpu_ce=cycles%15==0;vdp_ce=cycles%10==0;pix_ce=cycles%10==0;sp_ce=cycles%5==0;
 rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};DDRAM_BUSY=stalls&&(rng[3:0]<4);if(DDRAM_BUSY)stalled=stalled+1;
end
always @(posedge clk)begin
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=memory[ra-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(holding && {DDRAM_RD,DDRAM_WE,DDRAM_ADDR,DDRAM_DIN,DDRAM_BE} !== {held_rd,held_we,held_addr,held_data,held_be})$fatal(1,"stalled request changed");
 holding=(DDRAM_RD||DDRAM_WE)&&DDRAM_BUSY;held_rd=DDRAM_RD;held_we=DDRAM_WE;held_addr=DDRAM_ADDR;held_data=DDRAM_DIN;held_be=DDRAM_BE;
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  if(DDRAM_ADDR<29'h07c00000||DDRAM_ADDR>=29'h07c18000)$fatal(1,"write out of slot range");
  for(integer b=0;b<8;b=b+1)if(DDRAM_BE[b])memory[DDRAM_ADDR-29'h07c00000][8*b+:8]<=DDRAM_DIN[8*b+:8];writes=writes+1;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending!=0)$fatal(1,"overlap");pending<=2+(rng[7:4]%5);ra<=DDRAM_ADDR;reads=reads+1;end
 if(z80_set)begin if(z80_dir!==saved_cpu)$fatal(1,"CPU roundtrip");loads=loads+1;end
 if(vdp_regs_set&&vdp_regs_in!==saved_vdp)$fatal(1,"VDP roundtrip");
 if(psg_set&&psg_in!==saved_psg)$fatal(1,"PSG1 payload");
 if(psg2_set)begin if(psg2_in!==saved_psg2)$fatal(1,"PSG2 payload");loads2=loads2+1;end
 if(cram_wr||cram2_wr)cram_writes=cram_writes+1;
 if(vram_WE||vram2_WE||wram_WE||nvram_WE)ram_writes=ram_writes+1;
 if(z80_set||vdp_regs_set||psg_set||mapper_set||io_set||eeprom_set||evolution_set||video_state_set||psg2_set||vdp2_regs_set)restores=restores+1;
 if(vram_WE&&vram_WD!==8'ha1)$fatal(1,"VRAM data");
 if(vram2_WE&&vram2_WD!==8'ha3)$fatal(1,"VRAM2 data");
 if(wram_WE&&wram_WD!==8'hb2)$fatal(1,"WRAM data");
 if(nvram_WE&&nvram_WD!==8'hc3)$fatal(1,"NVRAM data");
end
task tick;begin @(negedge clk);#2;end endtask
task put(input integer chip,input[7:0]b);begin din=b;wr1=chip==1?0:1;wr2=chip==2?0:1;repeat(2)tick;wr1=1;wr2=1;repeat(3)tick;end endtask
task controls_write(input[10:0]c);begin din={5'd0,c[10:8]};detwr=0;tick;detwr=1;din=c[7:0];balwr=0;tick;balwr=1;tick;end endtask
task operation(input bit saving);integer start_cycle;begin
 force dut.op_cooldown=0;start_cycle=cycles;
 if(saving)ss_save=1;else ss_load=1;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);wait(dut.state==0);repeat(4)tick;release dut.op_cooldown;ops=ops+1;
 $display("operation=%0d saving=%0d mode=%0d bios=%0d slot=%0d cycles=%0d",ops,saving,systeme,ss_bios_mode,ss_slot,cycles-start_cycle);
end endtask
integer base,prior_loads,prior_restores,prior_ram,prior_cram;reg[63:0]oldword;
task reject(input integer offset,input[63:0]bad);begin
 oldword=memory[base+offset];memory[base+offset]=bad;prior_loads=loads;prior_restores=restores;prior_ram=ram_writes;prior_cram=cram_writes;
 operation(0);
 if(loads!=prior_loads||restores!=prior_restores||ram_writes!=prior_ram||cram_writes!=prior_cram)$fatal(1,"rejected image modified live state");
 memory[base+offset]=oldword;rejected=rejected+1;
end endtask
initial begin
 for(integer i=0;i<98304;i=i+1)memory[i]=64'hdeadbeefdeadbeef;
 repeat(6)tick;reset_n=1;vblank=1;x=0;ss_game_id=32'h12345678;
 vram_D=8'ha1;vram2_D=8'ha3;wram_D=8'hb2;nvram_D=8'hc3;cram_out='1;cram2_out=0;
 for(integer t=0;t<8;t=t+1)begin
  systeme=t%2;ss_bios_mode=(t/2)%2;ss_slot=t%4;stalls=t>=4;
  mapper_out=systeme?64'h60:64'h1000000000000;
  saved_cpu={102'h1923,128'h0123456789abcdef0011223344556677}^t;saved_vdp=128'hfedcba98765432100123456789abcdef^t;
  z80_reg=saved_cpu;vdp_regs=saved_vdp;vdp2_regs=~saved_vdp;video_state_out=22'h12345;
  put(1,8'h8d);put(1,8'h02);put(1,8'h91);put(1,8'he0|t);put(1,8'hf2);
  put(2,8'haf);put(2,8'h0b);put(2,8'hb3);put(2,8'he7);put(2,8'hf1);
  saved_controls={3'(t),8'ha5^8'(t)};controls_write(saved_controls);repeat(7)tick;
  saved_psg=psg_out;saved_psg2=psg2_out;operation(1);
  base=(ss_bios_mode?16'hc000:0)+ss_slot*16'h3000;
  if(memory[base][63:32]!=24574)$fatal(1,"size header");
  if(memory[base+1][31:0]!== (ss_bios_mode?32'h5342${v==='B'?'42':'43'}01:32'h534d${v==='B'?'42':'43'}01))$fatal(1,"version");
  if(memory[base+32]!==64'hdeadbeefdeadbeef)$fatal(1,"obsolete extension written");
  changed_controls=~saved_controls;controls_write(changed_controls);put(1,8'h9f);put(2,8'hbf);repeat(113)tick;
  operation(0);if(psg_out!==saved_psg||systeme&&psg2_out!==saved_psg2)$fatal(1,"actual JT89 configuration restore");
  if(audio_control_out!==${v==='C'?'saved_controls':'changed_controls'})$fatal(1,"architectural control contract");
  // Repeat loading the same image after a new history and control write.
  controls_write(changed_controls);repeat(47)tick;operation(0);
  if(audio_control_out!==${v==='C'?'saved_controls':'changed_controls'})$fatal(1,"repeated controls");
 end
 // Reject before any live state writes: size, production, cross-candidate,
 // future version, wrong game, wrong mode, and (B) reserved PSG bits.
 reject(0,{32'd16382,memory[base][31:0]});reject(0,{32'd24575,memory[base][31:0]});
 reject(1,{ss_game_id,32'h534d5331});reject(1,{ss_game_id,32'h5342${v==='B'?'43':'42'}01});reject(1,{ss_game_id,32'h5342${v==='B'?'42':'43'}02});
 reject(1,{32'h87654321,memory[base+1][31:0]});
 reject(14,memory[base+14]^(64'd1<<${v==='B'?52:63}));
 ${v==='B'?'reject(14,memory[base+14]^(64\'d1<<63));':''}
 if(loads!=16||loads2!=8||stalled==0||writes<1000||reads<1000)$fatal(1,"coverage");
 $display("PASS controller ${v}: cycles=%0d ops=%0d loads=%0d PSG2=%0d safe_rejections=%0d reads=%0d writes=%0d busy=%0d controls=${v==='C'?'restored':'intentionally_not_restored'}",cycles,ops,loads,loads2,rejected,reads,writes,stalled);$finish;
end
initial begin #500000000;$fatal(1,"timeout state=%0d ops=%0d",dut.state,ops);end
endmodule
`;
fs.writeFileSync(p.join(d,`sim_${v}/controller_tb.sv`),tb);
fs.writeFileSync(p.join(d,`sim_${v}/controller.do`),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvcom -2008 -quiet controls.vhd AudioMix.vhd\nvlog -sv -quiet controller.sv controller_tb.sv\nvsim -c -t 1ps -voptargs=+acc work.controller_tb\nforce -deposit /controller_tb/mix/toggle 0 0\nrun -all\nquit -code 0\n`);
}
