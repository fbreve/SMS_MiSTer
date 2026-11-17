const fs=require('fs'),path=require('path'),dir=__dirname,root=path.resolve(dir,'../..');
const before=process.env.SC_BEFORE==='1';
let s=fs.readFileSync(path.join(root,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module sc_integration;parameter STALL=0;');
s=s.replace("reg [7:0] nvram_D = '0;",'wire[7:0]nvram_D;');
s=s.replace('always #5 clk=~clk;',"reg[15:0]lfsr=16'h1ace;always #5 clk=~clk;");
s=s.replace('cycle=cycle+1;end',"cycle=cycle+1;lfsr={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?lfsr[3:0]<12:0);end");
s+=`reg sc=1;reg[1:0]cfg=1;reg[15:0]a=0;reg[7:0]di=0;reg wr=1,mreq=1;wire we;wire[7:0]q;
wire[14:0]pa=cfg==1?{4'd0,a[10:0]}:cfg==2?{1'b0,a[13:0]}:a[14:0];
memory_bus bus(.A(a),.sc3000_en(sc),.sc_cart_ram(cfg),.mapper_castle(1'b0),.sc_multicart_en(1'b0),.WR_n(wr),.RD_n(1'b0),.MREQ_n(mreq),.ss_freeze(ss_freeze),.mapper_eeprom(1'b0),.nvram_e(1'b0),.nvram_ex(1'b0),.nvram_cme(1'b0),.dahjee_cart_access(1'b0),.eeprom_bus_active(1'b0),.eeprom_D_out(8'd0),.nvram_D_out(nvram_D),.ram_D_out(8'h66),.irom_D_out(8'h99),.ram_WR(),.rom_RD(),.nvram_WR(we),.memory_D_out(q));
dpram #(.widthad_a(15),.init_file("UNUSED")) ram(.clock_a(clk),.address_a(ss_freeze?(nvram_WE?nvram_WA:nvram_A):pa),.data_a(ss_freeze?nvram_WD:di),.wren_a(ss_freeze?nvram_WE:we),.q_a(nvram_D),.clock_b(clk),.address_b(15'd0),.data_b(8'd0),.wren_b(1'b0),.q_b());
integer size,k,i,mode,variant;reg[7:0]expectation[0:32767];integer payload_writes=0,payload_reads=0;reg counting=0;
always @(posedge clk)if(counting&&DDRAM_ADDR>=29'h07c00d01&&DDRAM_ADDR<=29'h07c01d00&&!DDRAM_BUSY)begin if(DDRAM_WE)payload_writes=payload_writes+1;if(DDRAM_RD)payload_reads=payload_reads+1;end
function[7:0]pattern(input integer ix,input integer seed);pattern=seed==0?((ix*73)^(ix>>5)^8'h35):seed==1?(ix%2?8'haa:8'h55):((ix*1103515245+12345)>>(ix%17))^ix;endfunction
task put(input integer ix,input[7:0]v);begin a=16'h8000+ix;di=v;mreq=0;wr=0;repeat(2)tick;wr=1;mreq=1;tick;end endtask
task fill(input bit perturb);begin for(i=0;i<size;i=i+1)put(i,perturb?~expectation[i]:expectation[i]);end endtask
task scan(input bit saved);begin for(i=0;i<size;i=i+1)begin a=16'h8000+i;mreq=0;repeat(3)tick;if(q!==(saved?expectation[i]:~expectation[i]))$fatal(1,"SC cfg%0d case%0d byte%0d got%h expected%h",cfg,k,i,q,saved?expectation[i]:~expectation[i]);end mreq=1;end endtask
initial begin
reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;
for(mode=1;mode<=3;mode=mode+1)begin cfg=mode;size=mode==1?2048:mode==2?16384:32768;
${before?'':'sc_ram_size=cfg;'}
for(k=0;k<${before?1:19};k=k+1)begin
for(i=0;i<size;i=i+1)expectation[i]=pattern(i,k%3);
fill(0);payload_writes=0;payload_reads=0;counting=1;fork operation(1);begin wait(ss_freeze);if(k==0)begin wr=0;mreq=0;repeat(100)begin tick;if(we)$fatal(1,"CPU write during freeze");end wr=1;mreq=1;end end join counting=0;
${before?'if(payload_writes!=0)$fatal(1,"unexpected baseline SC payload");':`if(payload_writes!=size/8)$fatal(1,"SC word count %0d != %0d",payload_writes,size/8);
if(mem['h25]!=={30'd0,cfg,32'h53435235})$fatal(1,"SC descriptor");
for(i=0;i<size;i=i+1)if(mem['hd01+i/8][(i%8)*8+:8]!==expectation[i])$fatal(1,"serialized byte%0d",i);
case(k)
17:mem['h1a][63:38]={24'h484305,2'd3};
18:mem['h1a][63:38]={24'h484306,2'd3};
3:mem['h1a][63:22]=0;
4:mem['h1a][63:38]={24'h484301,2'd0};
5:mem['h1a][63:38]={24'h484302,2'd2};
6:mem['h1a][63:38]={24'h484303,2'd3};
7:mem['h1a][63:38]={24'h484304,2'd3};
8:mem['h1a][63:40]=24'h484308;
9:mem['h25][63]=1;
10:mem['h25][31:0]=0;
11:mem['h25][33:32]=0;
12:sc_ram_size=cfg==3?1:3;
13:mem['h1a][39:38]=2;
14:begin mem[0][63:32]=16382;mem['he][63]=0;end
endcase`}
fill(1);counting=1;operation(0);counting=0;
${before?`scan(0);$display("PASS PRE-FIX F05 cfg%0d bytes%0d endpoints/middle/full image retain perturbed B; zero payload words",cfg,size);`:`scan(k<3||k>=15);
if(payload_reads!==((k<3||k>=15)?size/8:0))$fatal(1,"load word count k%0d %0d",k,payload_reads);
sc_ram_size=cfg;
if(k==0)begin operation(0);scan(1);put(size-1,8'h7d);expectation[size-1]=8'h7d;operation(1);fill(1);operation(0);scan(1);end
if(k==15)begin reset_n=0;repeat(3)tick;reset_n=1;repeat(3)tick;scan(1);end
if(k==16)begin cfg=0;repeat(3)tick;cfg=mode;repeat(3)tick;scan(1);end
$display("PASS F05 fullDDR cfg%0d case%0d bytes%0d stall%0d",cfg,k,size,STALL);`}
end end
$display("PASS SC COMPLETE");$finish;
end
initial begin #(64'd3000000000);$fatal(1,"watchdog state%0d",dut.state);end
endmodule
`;
fs.writeFileSync(path.join(dir,before?'before_tb.sv':'integration_tb.sv'),s);
fs.copyFileSync(path.join(root,'tests/savestate_hcounter/savestates_sim.sv'),path.join(dir,before?'before_savestates.sv':'savestates_sim.sv'));
fs.writeFileSync(path.join(dir,before?'before.do':'integration.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib ${before?'before_work':'work'}
vcom -work ${before?'before_work':'work'} -2008 -quiet ../../rtl/dpram.vhd ../../rtl/memory_bus.vhd
vlog -work ${before?'before_work':'work'} -sv -quiet ${before?'before_savestates.sv before_tb.sv':'savestates_sim.sv integration_tb.sv'}
if {![info exists env(SC_STALL)]} {set env(SC_STALL) 0}
vsim -c -t 1ps -L altera_mf -gSTALL=$env(SC_STALL) ${before?'before_work':'work'}.sc_integration
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
`);
