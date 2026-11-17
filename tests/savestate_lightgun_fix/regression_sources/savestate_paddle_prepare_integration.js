const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
let s=fs.readFileSync(path.join(r,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module paddle_integration;parameter STALL=0,ONLY=-1;');
for(const n of ['paddle_out','tap_out','io_out','gg_out'])s=s.replace(new RegExp('reg (\\[[^\\]]+\\]\\s*)'+n+" = '0;"),'wire $1'+n+';');
s=s.replace('always #5 clk=~clk;',"reg[15:0]lfsr=16'h1ace;always #5 clk=~clk;").replace('cycle=cycle+1;end',"cycle=cycle+1;lfsr={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?lfsr[3:0]<12:0);end");
let routing=fs.readFileSync(path.join(r,'tests/savestate_master_tap/tap_fixture.sv'),'utf8').replace('module tap_fixture','module routing_fixture').replace('input pause_combo,output','input pause_combo,input[9:0]paddle_pins,input paddle_enabled,output').replace('paddle_en=0','paddle_en=paddle_enabled').replace('paddle_0_nib=0,paddle_1_nib=0','paddle_0_nib=paddle_pins[3:0],paddle_1_nib=paddle_pins[8:5]').replace('paddle_0_tr=0,paddle_1_tr=0','paddle_0_tr=paddle_pins[4],paddle_1_tr=paddle_pins[9]');
fs.writeFileSync(path.join(d,'routing_fixture.sv'),routing);
const entity=fs.readFileSync(path.join(r,'rtl/io.vhd'),'utf8').split('architecture')[0],ports=[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)];
for(const ref of [false,true]){
const p={clk:'clk',reset_n:'iorst',ce_cpu:"1'b1",wr_n:'wr',rd_n:'rd',a:'addr',d_in:'data',d_out:ref?'refguest':'guest',j1_th_out:ref?'refth':'th',j2_th_out:ref?'refth2':'th2',j1_up:(ref?'refroutea':'routea')+'[3]',j1_down:(ref?'refroutea':'routea')+'[2]',j1_left:(ref?'refroutea':'routea')+'[1]',j1_right:(ref?'refroutea':'routea')+'[0]',j1_tr:(ref?'refroutea':'routea')+'[5]',j1_tl:(ref?'refroutea':'routea')+'[4]',j2_up:(ref?'refrouteb':'routeb')+'[3]',j2_down:(ref?'refrouteb':'routeb')+'[2]',j2_left:(ref?'refrouteb':'routeb')+'[1]',j2_right:(ref?'refrouteb':'routeb')+'[0]',j2_tr:(ref?'refrouteb':'routeb')+'[5]',j2_tl:(ref?'refrouteb':'routeb')+'[4]',io_state_out:ref?'':'io_out',io_state_in:ref?'io_out':'io_in',io_state_set:ref?"1'b0":'io_set',gg_state_out:ref?'':'gg_out',gg_state_in:'gg_in',gg_state_set:ref?"1'b0":'gg_set',ss_freeze:ref?'holdref':'ss_freeze'};
s+='\n'+`io io${ref?'ref':'dut'}(`+ports.map(m=>{const a=m[3].match(/\((\d+)\s+downto\s+(\d+)\)/i),w=a?+a[1]-a[2]+1:1;return '.'+m[1]+'('+(p[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':w+"'d0"))+')';}).join(',')+');\n';
}
// Declarations must precede mixed-language instances for ModelSim's implicit-net rules.
const cut=s.indexOf('\nio iodut');
s=s.slice(0,cut)+`\nreg iorst=0,holdref=0,wr=1,rd=1,jp=0,joy=0,enabled=1,tap_enabled=0;reg[7:0]addr=8'h3f,data=8'hff,p0=8'ha3,p1=8'h5c,x0=8'h23,x1=8'hdc;
wire[18:0]reftap;wire[7:0]routea,routeb,refroutea,refrouteb;wire th,th2,refth,refth2;wire[7:0]guest,refguest;wire[9:0]pins,refpins;wire[31:0]refstate;\n`+s.slice(cut);
for(const ref of [false,true])s+=`paddle_fixture local${ref?'ref':'dut'}(clk,${ref?'holdref':"1'b0"},${ref?"1'b0":'ss_freeze'},${ref?"1'b0":'paddle_set'},${ref?"1'b0":'paddle_valid'},jp,joy,${ref?"32'd0":'paddle_in'},p0,p1,x0,x1,${ref?'refth,refth2':'th,th2'},${ref?'refstate,refpins':'paddle_out,pins'});\n`;
for(const ref of [false,true])s+=`routing_fixture route${ref?'ref':'dut'}(.clk_sys(clk),.reset_active(1'b0),.ce_cpu(cpu_ce),.ss_freeze(${ref?'holdref':'ss_freeze'}),.ss_set(${ref?"1'b0":'tap_set'}),.ss_valid(tap_valid),.hold(1'b0),.th(${ref?'refth':'th'}),.enabled(tap_enabled),.raw_serial(1'b0),.ss_in(tap_in),.players(tap_enabled?32'h77331100:32'd0),.physical(7'h7f),.pause_combo(1'b0),.paddle_pins(${ref?'refpins':'pins'}),.paddle_enabled(enabled),.joya(${ref?'refroutea':'routea'}),.joyb(${ref?'refrouteb':'routeb'}),.state(${ref?'reftap':'tap_out'}),.joyser(),.USER_OUT());\n`;
s+=`integer k,j,start,saveclocks,loadclocks;reg[31:0]saved;reg[63:0]oldvideo;reg exact;reg[11:0]normalize_counter;
always @(posedge ss_freeze)begin #1;holdref=1;start=cycle;end
always @(negedge ss_freeze)begin if(dut.do_save)saveclocks=cycle-start;else begin loadclocks=cycle-start;holdref=0;end end
task put(input[7:0]v);begin addr=8'h3f;data=v;wr=0;tick;wr=1;repeat(3)tick;if(tap_enabled)repeat(2)begin wait(cpu_ce);tick;end end endtask
task check;begin if(tap_out!==reftap||paddle_out!==refstate||pins!==refpins||guest!==refguest||th!==refth||th2!==refth2)$fatal(1,"DDR k%0d state%h/%h pins%h/%h guest%h/%h",k,paddle_out,refstate,pins,refpins,guest,refguest);end endtask
always @(posedge clk)if(paddle_set&&!paddle_valid)begin #1;if(paddle_out!=={12'd0,th2,th,2'd0,(joy?{~x1[7],x1[6:0]}:p1),(joy?{~x0[7],x0[6:0]}:p0)})$fatal(1,"legacy normalization at strobe k%0d %h",k,paddle_out);end
initial begin
reset_n=0;repeat(4)tick;reset_n=1;iorst=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;vdp_regs={8'h5a,128'd0};video_state_out=22'h12345;
for(k=0;k<(ONLY>=22?25:22);k=k+1)begin
if(ONLY>=0&&ONLY!=k)continue;
holdref=0;tap_enabled=k>=22;enabled=k!=21;
routedut.tmr=57001;routeref.tmr=57001;routedut.old_th=1;routeref.old_th=1;jp=0;joy=k%2;localdut.cnt_en16khz=17;localref.cnt_en16khz=17;
put(8'hff);put(8'h55);put(8'hff);put(8'h55);p0=8'ha3;p1=8'h5c;x0=8'h23;x1=8'hdc;
put(8'hff);put(8'h55);
jp=(k==1||k==2||k==19||k==23||k==24);if(jp)begin while(paddle_out[31:20]!=0)tick;tick;if(k==2||k==24)begin while(paddle_out[31:20]!=0)tick;tick;end end
repeat(139)tick;
if(k==20)begin force dut.op_cooldown=0;ss_save=1;tick;ss_save=0;wait(cpu_ce);addr=8'h3f;data=8'hff;wr=0;tick;wr=1;wait(ss_freeze);wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;end else operation(1);saved=dut.paddle_snap;oldvideo=mem['h1a];
if(k==20&&saved[18]===th)$fatal(1,"pending edge missing");
if(saved!==refstate||mem['h27]!=={saved,32'h50414437}||mem['h1a][63:38]!=={24'h484307,2'd3})$fatal(1,"capture/format mismatch");
// Existing slots are canaries, including v6 Master Tap and v3 MD6.
if(mem['h26]!=={13'd0,dut.tap_snap,32'h4d544150}||mem['h1e]!=={18'd0,md_out}||mem['h25]!==64'h53435235||mem['h1f]!==64'h0000000145455058)$fatal(1,"old payload moved");
exact=k<3||k==18||k==19||k==20||k==21||k>=22;
case(k)
3:mem['h1a][63:22]=0;
4:mem['h1a][63:38]={24'h484301,2'd0};
5:mem['h1a][63:38]={24'h484302,2'd2};
6:mem['h1a][63:38]={24'h484303,2'd3};
7:mem['h1a][63:38]={24'h484304,2'd3};
8:mem['h1a][63:38]={24'h484305,2'd3};
9:mem['h1a][63:38]={24'h484306,2'd3};
10:mem['h1a][63:40]=24'h484308;
11:mem['h1a][63:40]=24'h123456;
12:mem['h1a][39:38]=2;
13:mem['h27][31:0]=0;
14:mem['h27][63:52]=3356;
15:begin mem[0][63:32]=16382;mem['he][63]=0;end
16:mem['h1a][63:40]=24'h484300;
17:mem['h27][63:52]=4095;
endcase
// The reference remains held without loading paddle fields. Its IO writes are frozen too.
p0=8'h76;p1=8'h29;x0=8'hfa;x1=8'h03;repeat(8)begin put(8'hff);put(8'h55);end
repeat(8000)tick;p0=8'he1;p1=8'hb4;x0=8'h96;x1=8'h78;
operation(0);
if(loadclocks<900000)$fatal(1,"transport too short");
if(exact)begin
check;if(k==21&&routea!==8'hff)$fatal(1,"disabled routing altered ordinary pins");for(j=0;j<6800;j=j+1)begin if(j==0||j==1||j==3||j==45)put(j%2?8'hff:8'h55);addr=j%2?8'hdc:8'hdd;rd=0;tick;check;rd=1;end
if(k==18||k==19)begin operation(1);repeat(9)put(8'hff);operation(0);check;end
end else if(paddle_valid)$fatal(1,"invalid/legacy treated as exact k%0d",k);
if(k==21)begin iorst=0;repeat(5)tick;check;iorst=1;repeat(5)tick;check;enabled=1;repeat(5)tick;check;end
if(k>=22)$display("PASS combined Tap/Paddle case%0d JP%0d savedTap%h liveTap%h referenceTap%h",k,jp,dut.tap_snap,tap_out,reftap);
$display("PASS Paddle DDR case%0d stalls%0d JP%0d joystick%0d saved%h saveClocks%0d loadClocks%0d exact%0d",k,STALL,jp,joy,saved,saveclocks,loadclocks,exact);
end
$display("PASS Paddle DDRAM COMPLETE");$finish;
end
initial begin #(64'd2500000000);$fatal(1,"watchdog k%0d state%0d",k,dut.state);end
endmodule\n`;
fs.writeFileSync(path.join(d,'integration_tb.sv'),s);
fs.copyFileSync(path.join(r,'tests/savestate_hcounter/savestates_sim.sv'),path.join(d,'savestates_sim.sv'));
for(let stall=0;stall<3;stall++)fs.writeFileSync(path.join(d,`stalls${stall}.do`),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib ddr${stall}_work
vcom -work ddr${stall}_work -2008 -quiet ../../rtl/io.vhd
vlog -work ddr${stall}_work -sv -quiet savestates_sim.sv paddle_fixture.sv routing_fixture.sv integration_tb.sv
if {![info exists env(PADDLE_CASE)]} {set env(PADDLE_CASE) -1}
vsim -c -t 1ps -gONLY=$env(PADDLE_CASE) -gSTALL=${stall} ddr${stall}_work.paddle_integration
run -all
quit -code 0
`);
