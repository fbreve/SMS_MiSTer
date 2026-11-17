const fs=require('fs'),path=require('path'),dir=__dirname,root=path.resolve(dir,'../..');const baseline=process.env.TAP_BASELINE==='1';
let s=fs.readFileSync(path.join(root,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module tap_integration;parameter STALL=0,ONLY=-1;');
s=s.replace(/reg (\[18:0\]\s*)tap_out = '0;/,'wire $1tap_out;').replace(/reg (\[45:0\]\s*)md_out = '0;/,'wire $1md_out;').replace(/reg (\[31:0\]\s*)io_out = '0;/,'wire $1io_out;').replace(/reg (\[127:0\]\s*)gg_out = '0;/,'wire $1gg_out;');
s=s.replace('always #5 clk=~clk;',"reg[15:0]lfsr=16'h1ace;always #5 clk=~clk;").replace('cycle=cycle+1;end',"cycle=cycle+1;lfsr={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?lfsr[3:0]<12:0);end");
if(baseline){s=s.replace(/\.tap_(?:out|in|set|valid)\(tap_(?:out|in|set|valid)\),?/g,'').replace("reg [18:0] tap_in = '0;","wire[18:0]tap_in=0;");}
const entity=fs.readFileSync(path.join(root,'rtl/io.vhd'),'utf8').split('architecture')[0],ports=[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)];
const ioports={clk:'clk',reset_n:'iorst',ce_cpu:"1'b1",wr_n:'wr',rd_n:'rd',a:'addr',d_in:'data',d_out:'guest',j1_th_out:'th',j2_th_out:'th2',j1_up:'padpins[3]',j1_down:'padpins[2]',j1_left:'padpins[1]',j1_right:'padpins[0]',j1_tl:'padpins[4]',j1_tr:'padpins[5]',io_state_out:'io_out',io_state_in:'io_in',io_state_set:'io_set',gg_state_out:'gg_out',gg_state_in:'gg_in',gg_state_set:'gg_set',ss_freeze:'ss_freeze'};
const io='io localio('+ports.map(m=>{const a=m[3].match(/\((\d+)\s+downto\s+(\d+)\)/i),w=a?+a[1]-a[2]+1:1;return '.'+m[1]+'('+(ioports[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':w+"'d0"))+')';}).join(',')+');';
s+=`reg iorst=0,padreset=1,refreset=1,holdref=0,wr=1,rd=1,en=1;reg[7:0]addr=8'h3f,data=8'hff;reg[31:0]players=32'h88442211;
wire th,th2;wire[7:0]guest,joya,joyb,refjoya,refjoyb;wire[18:0]refstate;wire[45:0]refmd;wire[5:0]padpins,pad2pins,refpins,ref2pins;
wire[1:0]kind=en?2'd0:2'd2;
${io}
`;
for(const ref of [false,true])s+=`tap_fixture local${ref?'ref':'dut'}(.clk_sys(clk),.reset_active(${ref?'refreset':'padreset'}),.ce_cpu(cpu_ce),.ss_freeze(${ref?"1'b0":'ss_freeze'}),.ss_set(${ref||baseline?"1'b0":'tap_set'}),.ss_valid(${ref||baseline?"1'b0":'tap_valid'}),.hold(${ref?'holdref':"1'b0"}),.th(th),.enabled(en),.raw_serial(1'b0),.ss_in(${ref?"19'd0":'tap_in'}),.players(players),.physical(7'h7f),.pause_combo(1'b0),.state(${ref?'refstate':'tap_out'}),.joya(${ref?'refjoya':'joya'}),.joyb(${ref?'refjoyb':'joyb'}),.joyser(),.USER_OUT());\n`;
for(const ref of [false,true])for(const port of [1,2])s+=`sega_controller md${port}${ref?'ref':''}(.clk(clk),.reset(${ref?'refreset':'padreset'}),.controller_type(kind),.sms_pins(${ref?'ref':''}joy${port===1?'a':'b'}[5:0]),.th(${port===1?'th':'th2'}),.md_a(1'b0),.md_start(1'b0),.md_x(1'b1),.md_y(1'b0),.md_z(1'b1),.md_mode(1'b0),.pins(${ref?(port===1?'refpins':'ref2pins'):(port===1?'padpins':'pad2pins')}),.ss_freeze(${ref?'holdref':'ss_freeze'}),.ss_set(${ref?"1'b0":'md_set'}),.ss_valid(md_valid),.ss_in(md_in[${port===1?'22:0':'45:23'}]),.ss_out(${ref?'refmd':'md_out'}[${port===1?'22:0':'45:23'}]));\n`;
s+=`integer k,j,phase,freeze_start,freeze_length,save_cycles,load_cycles,previous_reads;reg[18:0]saved;reg[31:0]savedio;reg[45:0]savedmd;reg[127:0]savedgg;
always @(posedge ss_freeze)begin #1;holdref=1;freeze_start=cycle;end
always @(negedge ss_freeze)begin freeze_length=cycle-freeze_start;if(!dut.do_save)holdref=0;end
task cpu_step;begin wait(cpu_ce);tick;end endtask
task put(input[7:0]v);begin addr=8'h3f;data=v;wr=0;tick;wr=1;repeat(3)tick;repeat(2)cpu_step;end endtask
task check;begin if(tap_out!==refstate||joya!==refjoya||joyb!==refjoyb||md_out!==refmd||padpins!==refpins||pad2pins!==ref2pins)$fatal(1,"Tap DDR k%0d tap%h/%h pins%h/%h MD%h/%h",k,tap_out,refstate,padpins,refpins,md_out,refmd);end endtask
initial begin
reset_n=0;repeat(4)tick;reset_n=1;iorst=1;padreset=0;refreset=0;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;video_state_out=22'h12345;vdp_regs={8'h5a,128'd0};
for(k=0;k<${baseline?3:21};k=k+1)begin
if(ONLY>=0&&ONLY!=k)continue;
holdref=0;en=k!=17;padreset=1;refreset=1;put(8'hff);put(8'h55);put(8'hff);padreset=0;refreset=0;
while(tap_out[15:0]<57001)cpu_step;
put(8'h55);put(8'hff);phase=k<3?k+1:2;repeat(phase)begin put(8'h55);put(8'hff);end
if(k==1)put(8'h55);else if(k==2)while(tap_out[15:0]<56999)cpu_step;else repeat(37)cpu_step;
if(k==18)begin
force dut.op_cooldown=0;ss_save=1;tick;ss_save=0;
wait(cpu_ce);addr=8'h3f;data=8'h55;wr=0;tick;wr=1;
wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
end else operation(1);
save_cycles=freeze_length;saved=${baseline?'refstate':'dut.tap_snap'};savedio=mem['h19][31:0];savedmd=mem['h1e][45:0];savedgg={mem['h1d],mem['h1c]};
${baseline?'':`if(mem['h26]!=={13'd0,saved,32'h4d544150}||mem['h1a][63:38]!=={24'h484307,2'd3})$fatal(1,"Tap payload format");
if(saved!==refstate)$fatal(1,"noncoherent Tap capture");
if(k==18 && saved[18]===th)$fatal(1,"pending TH edge not captured");
if(mem['h1e]!=={18'd0,savedmd}||mem['h25]!==64'h53435235||mem['h1f]!==64'h0000000145455058||mem['h1a][29:22]!=8'h5a)$fatal(1,"old field collision");
case(k)
20:mem['h1a][63:40]=24'h484306;
3:mem['h1a][63:22]=0;
4:mem['h1a][63:38]={24'h484301,2'd0};
5:mem['h1a][63:38]={24'h484302,2'd2};
6:mem['h1a][63:38]={24'h484303,2'd3};
7:mem['h1a][63:38]={24'h484304,2'd3};
8:mem['h1a][63:38]={24'h484305,2'd3};
9:mem['h1a][63:40]=24'h484308;
10:mem['h26][63]=1;
11:mem['h26][31:0]=0;
12:mem['h26][47:32]=57002;
13:mem['h1a][39:38]=2;
14:begin mem[0][63:32]=16382;mem['he][63]=0;end
15:mem['h1a][63:40]=24'h123456;
endcase`}
// Only DUT advances along discarded timeline; naturally held reference never receives restored fields.
repeat(5)begin put(8'h55);put(8'hff);end repeat(120)cpu_step;
operation(0);load_cycles=freeze_length;
if(load_cycles<855015)$fatal(1,"transport too short for production timeout");
${baseline?`if(joya===refjoya)$fatal(1,"expected production timing gap");$display("CONFIRMED F09 full DDR baseline case%0d saved%h live%h reference%h guest pins%h/%h saveClocks%0d loadClocks%0d",k,saved,tap_out,refstate,joya,refjoya,save_cycles,load_cycles);`:`if(k<3||k>=16)begin
check;for(j=0;j<12;j=j+1)begin players=players+32'h01030507;put(j%2?8'h55:8'hff);check;end
if(k==0||k==19)begin operation(1);repeat(5)put(8'h55);operation(0);check;end
// Guest reads through actual IO observe the reconstructed player pins.
addr=8'hdc;rd=0;repeat(3)tick;rd=1;if(guest[5:0]!=={refpins[5:4],refpins[0],refpins[1],refpins[2],refpins[3]})$fatal(1,"guest IO pin permutation %h/%h",guest,refpins);
end else begin
if(tap_valid||tap_out!=={th,2'd0,16'd57001})$fatal(1,"legacy normalization k%0d state%h valid%0d",k,tap_out,tap_valid);
put(8'hff);put(8'h55);if(tap_out[17:16]!=0)$fatal(1,"legacy first falling edge counted");put(8'hff);put(8'h55);if(tap_out[17:16]!=1)$fatal(1,"legacy second falling edge missed");
end
$display("PASS Tap DDR case%0d stalls%0d enabled%0d saved%h saveClocks%0d loadClocks%0d",k,STALL,en,saved,save_cycles,load_cycles);`}
end
$display("PASS ${baseline?'PRE-FIX production-timeout DDR':'Master Tap DDRAM COMPLETE'}");$finish;
end
initial begin #(64'd2000000000);$fatal(1,"watchdog k%0d state%0d tap%h",k,dut.state,tap_out);end
endmodule
`;
fs.writeFileSync(path.join(dir,baseline?'before_integration_tb.sv':'integration_tb.sv'),s);
let rtl=fs.readFileSync(path.join(root,baseline?'tests/savestate_master_tap/baseline/rtl/savestates.sv':'rtl/savestates.sv'),'utf8');for(const n of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=rtl.match(re)[0];rtl=rtl.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
fs.writeFileSync(path.join(dir,baseline?'before_savestates_sim.sv':'savestates_sim.sv'),rtl);
if(baseline)fs.writeFileSync(path.join(dir,'before_integration_fixture.sv'),fs.readFileSync(path.join(dir,'before_fixture.sv'),'utf8'));
const lib=baseline?'before_integration_work':'integration_work';
fs.writeFileSync(path.join(dir,baseline?'before_integration.do':'integration.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib ${lib}
vcom -work ${lib} -2008 -quiet ../../rtl/io.vhd
vlog -work ${lib} -sv -quiet ${baseline?'before_savestates_sim.sv before_integration_fixture.sv before_integration_tb.sv':'savestates_sim.sv tap_fixture.sv integration_tb.sv'} ../../rtl/sega_controller.sv
if {![info exists env(TAP_STALL)]} {set env(TAP_STALL) 0}
if {![info exists env(TAP_CASE)]} {set env(TAP_CASE) -1}
vsim -c -t 1ps -gSTALL=$env(TAP_STALL) -gONLY=$env(TAP_CASE) ${lib}.tap_integration
run -all
quit -code 0
`);
