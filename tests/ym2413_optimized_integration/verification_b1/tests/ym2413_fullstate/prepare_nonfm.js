const fs=require('fs'),p=require('path'),d=__dirname;
const source=fs.readFileSync(p.join(d,'savestates_sim.sv'),'utf8');
const ports=[];for(const m of source.split(');')[0].replace(/\/\/[^\n]*/g,'').matchAll(/\b(input|output)\s+(?:reg\s+)?(\[[^\]]+\]\s*)?([\s\S]*?)(?=\binput\b|\boutput\b|$)/g))for(const n of m[3].split(',').map(x=>x.trim()).filter(Boolean))ports.push({kind:m[1],w:m[2]||'',n});
const ins=ports.filter(x=>x.kind==='input'&&!x.n.startsWith('fm_')&&!['DDRAM_DOUT','DDRAM_DOUT_READY'].includes(x.n));
const outs=ports.filter(x=>x.kind==='output'&&!x.n.startsWith('fm_'));
const decl=ins.map(x=>`reg ${x.w}${x.n}='0;`).join('\n');
let s=`\`timescale 1ns/1ps
module nonfm_tb;
${decl}
reg [63:0] DDRAM_DOUT_a=0,DDRAM_DOUT_b=0;reg DDRAM_DOUT_READY_a=0,DDRAM_DOUT_READY_b=0;
${outs.map(x=>`wire ${x.w}${x.n}_a,${x.n}_b;`).join('\n')}
wire [7:0] fm_addr;wire fm_read,fm_write,fm_init_run,fm_reset;wire [31:0] fm_wdata;
reg [31:0] fm_rdata=0;
always @(posedge clk)fm_rdata<=fm_read&&fm_addr==78?32'h000000c7:0;
master_savestates a(${ports.filter(x=>!x.n.startsWith('fm_')).map(x=>'.'+x.n+'('+x.n+(x.kind==='output'||['DDRAM_DOUT','DDRAM_DOUT_READY'].includes(x.n)?'_a':'')+')').join(',')});
savestates b(${ports.filter(x=>!x.n.startsWith('fm_')).map(x=>'.'+x.n+'('+x.n+(x.kind==='output'||['DDRAM_DOUT','DDRAM_DOUT_READY'].includes(x.n)?'_b':'')+')').join(',')},
 .fm_state_addr(fm_addr),.fm_state_read(fm_read),.fm_state_write(fm_write),.fm_state_wdata(fm_wdata),.fm_state_rdata(fm_rdata),.fm_initialized(1'b1),.fm_initialization_run(fm_init_run),.fm_legacy_reset(fm_reset));
always #5 clk=~clk;
integer cycles=0;reg stalls=0;
reg [63:0] mem_a[0:98303],mem_b[0:98303];integer pa=0,pb=0;reg [28:0] ra,rb;
integer restored_a=0,restored_b=0;
always @(negedge clk)begin cycles++;cpu_ce=cycles%15==0;pix_ce=cycles%10==0;vdp_ce=cycles%5==0;sp_ce=cycles%2;DDRAM_BUSY=stalls&&(cycles%79<7);end
always @(posedge clk)begin
 DDRAM_DOUT_READY_a<=0;DDRAM_DOUT_READY_b<=0;
 if(pa>0)begin pa<=pa-1;if(pa==1)begin DDRAM_DOUT_a<=mem_a[ra-29'h07c00000];DDRAM_DOUT_READY_a<=1;end end
 if(pb>0)begin pb<=pb-1;if(pb==1)begin DDRAM_DOUT_b<=mem_b[rb-29'h07c00000];DDRAM_DOUT_READY_b<=1;end end
 if(DDRAM_RD_a&&!DDRAM_BUSY)begin if(pa!=0)$fatal(1,"master overlapping reads");pa<=3+cycles%5;ra<=DDRAM_ADDR_a;end
 if(DDRAM_RD_b&&!DDRAM_BUSY)begin if(pb!=0)$fatal(1,"candidate overlapping reads");pb<=3+cycles%5;rb<=DDRAM_ADDR_b;end
 if(DDRAM_WE_a&&!DDRAM_BUSY)for(integer i=0;i<8;i++)if(DDRAM_BE_a[i])mem_a[DDRAM_ADDR_a-29'h07c00000][i*8+:8]<=DDRAM_DIN_a[i*8+:8];
 if(DDRAM_WE_b&&!DDRAM_BUSY)for(integer i=0;i<8;i++)if(DDRAM_BE_b[i])mem_b[DDRAM_ADDR_b-29'h07c00000][i*8+:8]<=DDRAM_DIN_b[i*8+:8];
 if(z80_set_a)begin restored_a++;if(z80_dir_a!==z80_reg)$fatal(1,"master CPU restore");end
 if(z80_set_b)begin restored_b++;if(z80_dir_b!==z80_reg)$fatal(1,"candidate CPU restore");end
end
task tick;begin @(negedge clk);#2;end endtask
task operation(input bit saving);begin
 force a.op_cooldown=0;force b.op_cooldown=0;
 ss_save=saving;ss_load=!saving;tick;ss_save=0;ss_load=0;
 wait(ss_freeze_a&&ss_freeze_b);wait(!ss_freeze_a&&!ss_freeze_b);repeat(12)tick;
 release a.op_cooldown;release b.op_cooldown;
end endtask
initial begin
 for(integer i=0;i<98304;i++)begin mem_a[i]=0;mem_b[i]=0;end
 repeat(6)tick;reset_n=1;vblank=1;audio_quiescent=1;ss_game_id=32'h12345678;
 z80_reg=230'h123456789abcdef;vdp_regs=128'h987654321;psg_out=56'h123456;psg2_out=56'h654321;psg_ext_out=96'h789abcdef;psg2_ext_out=96'h987654321;
 io_out=32'h12345678;video_state_out=22'h12345;cram_out={384{1'b1}};cram2_out={384{1'b1}};
 for(integer c=0;c<8;c++)begin
  systeme=c%2;ss_bios_mode=(c/2)%2;ss_slot=c%4;stalls=c>=4;mapper_out=systeme?64'h60:64'h1000000000000;
  operation(1);
  for(integer i=0;i<98304;i++)begin
   if(i%12288=='h1a)begin if(mem_a[i][21:0]!==mem_b[i][21:0])$fatal(1,"video payload regression");end
   else if(i%12288<'h2997 || i%12288>'h29c9)if(mem_a[i]!==mem_b[i])$fatal(1,"non-FM DDR payload regression case=%0d word=%h",c,i);
  end
  operation(0);
${outs.filter(x=>!x.n.startsWith('DDRAM_')&&!x.n.endsWith('_set')&&!x.n.endsWith('_WE')&&!['ss_freeze','cram_wr','cram2_wr','vram_en','vram2_en','eeprom_set','evolution_set','cram_A','cram_D','cram2_A','cram2_D','vram_A','vram_WA','vram_WD','vram2_A','vram2_WA','vram2_WD','wram_A','wram_WA','wram_WD','nvram_A','nvram_WA','nvram_WD'].includes(x.n)).map(x=>`  if(${x.n}_a!==${x.n}_b)$fatal(1,"non-FM output regression ${x.n}");`).join('\n')}
  $display("PASS nonFM case=%0d SystemE=%b BIOS=%b slot=%0d stalls=%b",c,systeme,ss_bios_mode,ss_slot,stalls);
 end
 if(restored_a!=8||restored_b!=8)$fatal(1,"incomplete nonFM restores");
 $display("PASS nonFM ALL restores=8 per controller payloads all slots cycles=%0d",cycles);$finish;
end
initial begin #200000000;$fatal(1,"nonFM TIMEOUT states=%0d,%0d",a.state,b.state);end
endmodule
`;
fs.writeFileSync(p.join(d,'nonfm_tb.sv'),s);
fs.writeFileSync(p.join(d,'nonfm.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -quiet -work test_work nonfm_tb.sv
vsim -t 1ps test_work.nonfm_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
