const fs=require('fs'),path=require('path'),dir=__dirname,root=path.resolve(dir,'../..');
let s=fs.readFileSync(path.join(root,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module ee_integration;\nparameter STALL=0,CASE_ONLY=-1;');
for(const [n,w]of [['eeprom_out',63],['eeprom_ext_out',127],['nvram_D',7]])s=s.replace(new RegExp(`reg (\\[${w}:0\\]\\s*)${n} = '0;`),'wire $1'+n+';');
s=s.replace('cycle=cycle+1;end',"cycle=cycle+1;lfsr={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?(cycle%31<13):STALL==2?(lfsr[3:0]<12):0);end").replace('cpu_ce=cycle%15==0','cpu_ce=fast_boundary||cycle%15==0');
s=s.replace('always #5 clk=~clk;','reg fast_boundary=0;reg [15:0]lfsr=16\'h1ace;\nalways #5 clk=~clk;');
s+=`reg rst1=0,rst2=0,holdref=0,wr=1;reg[15:0]addr=16'h8000;reg[7:0]data=0;
wire[6:0]a1,a2;wire[7:0]wd1,wd2,pins1,pins2,qref;wire we1,we2,active1,active2;
wire[63:0]refstate;wire[127:0]refext;
reg sdwe=0;reg[14:0]sda=0;reg[7:0]sdd=0;wire[7:0]sdq1,sdq2;
wire[14:0]ramA=ss_freeze?(nvram_WE?nvram_WA:(nvram_refill?{8'd0,a1}:nvram_A)):{8'd0,a1};
wire[7:0]ramdata=ss_freeze?nvram_WD:wd1;
wire ramwe=ss_freeze?nvram_WE:we1;
cart_eeprom local1(.clk_sys(clk),.ce_cpu(1'b1),.reset_n(rst1),.soft_reset(1'b0),.A(addr),.D_in(data),.D_out(pins1),.WR_n(wr),.MREQ_n(1'b0),.enabled(eeprom_present),.mapper_eeprom(eeprom_present),.bus_active(active1),.nvram_a(a1),.nvram_di(wd1),.nvram_do(nvram_D),.nvram_we(we1),.ss_out(eeprom_out),.ss_in(eeprom_in),.ss_set(eeprom_set),.ss_ext_out(eeprom_ext_out),.ss_ext_in(eeprom_ext_in),.ss_full(eeprom_full),.ss_freeze(ss_freeze));
cart_eeprom local2(.clk_sys(clk),.ce_cpu(1'b1),.reset_n(rst2),.soft_reset(1'b0),.A(addr),.D_in(data),.D_out(pins2),.WR_n(wr),.MREQ_n(1'b0),.enabled(eeprom_present),.mapper_eeprom(eeprom_present),.bus_active(active2),.nvram_a(a2),.nvram_di(wd2),.nvram_do(qref),.nvram_we(we2),.ss_out(refstate),.ss_in(64'd0),.ss_set(1'b0),.ss_ext_out(refext),.ss_ext_in(128'd0),.ss_full(1'b0),.ss_freeze(holdref));
dpram #(.widthad_a(15),.init_file("UNUSED")) ram1(.clock_a(clk),.address_a(ramA),.data_a(ramdata),.wren_a(ramwe),.q_a(nvram_D),.clock_b(clk),.address_b(sda),.data_b(sdd),.wren_b(sdwe),.q_b(sdq1));
dpram #(.widthad_a(15),.init_file("UNUSED")) ram2(.clock_a(clk),.address_a({8'd0,a2}),.data_a(wd2),.wren_a(we2&&!holdref),.q_a(qref),.clock_b(clk),.address_b(sda),.data_b(sdd),.wren_b(sdwe&&!perturb),.q_b(sdq2));
reg perturb=0;integer k,j,size,run;reg[63:0]saved;reg[127:0]savedext;reg[7:0]expected[0:16383];
always @(posedge ss_freeze)begin #1;holdref=1;end
always @(negedge ss_freeze)if(!dut.do_save && eeprom_full)holdref=0;
task put(input[7:0]v);begin data=v;wr=0;tick;wr=1;repeat(2)tick;end endtask
task bitin(input bit b);begin put(4|b);put(6|b);put(4|b);end endtask
task cmd(input[7:0]v);begin put(0);bitin(1);for(integer b=7;b>=0;b=b-1)bitin(v[b]);end endtask
task check;begin if(eeprom_out!==refstate||eeprom_ext_out!==refext||pins1!==pins2||active1!==active2)$fatal(1,"full replay k%0d state%h/%h ext%h/%h pins%h/%h",k,eeprom_out,refstate,eeprom_ext_out,refext,pins1,pins2);end endtask
task scan(input bit pair,input bit original);begin
 for(integer b=0;b<size;b=b+1)begin sda=b;repeat(2)tick;
 if(pair)begin if(sdq1!==sdq2)$fatal(1,"RAM replay byte%0d %h/%h k%0d",b,sdq1,sdq2,k);end
 else if(sdq1!==(original?expected[b]:~expected[b]))$fatal(1,"RAM restore byte%0d k%0d got%h expected%h",b,k,sdq1,(original?expected[b]:~expected[b]));
 end
end endtask
initial begin
reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;
ss_game_id=32'h12345678;video_state_out=22'h12345;vdp_regs={8'h5a,128'd0};vdp2_regs={8'ha5,128'd0};
gg_out=128'h00001fe00003f8000000ffa07fff00ff;md_out={2'd2,1'b0,3'd2,17'd123,2'd2,1'b1,3'd3,17'd456};
for(run=0;run<23;run=run+1)begin
 k=run<4?run:run<10?run+13:run-6; // exact replays precede intentionally lossy legacy loads
 if(CASE_ONLY>=0 && CASE_ONLY!=k)continue;
 systeme=k==16||k==19;eeprom_present=k<14||k>=17;mapper_out=k==15?64'h4000000000000:64'd0;size=k==15?16384:128;
 holdref=0;rst1=0;rst2=0;wr=1;perturb=0;repeat(3)tick;
 sdwe=1;for(j=0;j<size;j=j+1)begin expected[j]=k==18?(j%2?8'haa:8'h55):((j*73)^(k%2?8'h55:8'ha5));sda=j;sdd=expected[j];tick;end sdwe=0;
 rst1=1;rst2=1;repeat(3)tick;
 if(eeprom_present)begin
 cmd(8'h80);repeat(6)tick;put(0);cmd(8'h30);put(0);
 case(k)
 0:begin cmd(0);put(0);bitin(1);bitin(0);bitin(0);bitin(1);bitin(1);end
 1:begin cmd(8'h10);end // WRAL is still active at accepted boundary
 2:begin
 put(0);bitin(1);for(j=7;j>=1;j=j-1)bitin((8'hbf>>j)&1);put(5);
 // Accept M1 while the guest's final opcode edge reaches the engine.
 fast_boundary=1;force dut.op_cooldown=0;ss_save=1;data=7;wr=0;tick;ss_save=0;wr=1;
 wait(ss_freeze);fast_boundary=0;wait(!ss_freeze);repeat(10)tick;release dut.op_cooldown;
 end
 3:begin cmd(8'h7f);repeat(7)bitin(1);end
 default:put(0);
 endcase
 end
 if(k==17)addr=0; // EEPROM exists but no current access/window
 if(k!=2)operation(1);saved=dut.eeprom_snap;savedext=dut.eeprom_ext_snap;
 if(k==2&&savedext[3:0]!=5)$fatal(1,"READ latch phase not captured: %0d",savedext[3:0]);
 if(mem['h1a][63:38]!=={24'h484307,2'd3})$fatal(1,"v4 tag");
 if(mem['h1e]!=={18'd0,md_out}||{mem['h1d],mem['h1c]}!==gg_out)$fatal(1,"F02/F08 positions");
 if(eeprom_present)begin
 if(mem['h1f]!=={15'd0,5'd16,3'd2,1'b1,8'd1,32'h45455058}||{mem['h31],mem['h30]}!==savedext||mem['h1b]!==saved)$fatal(1,"EEPROM descriptor/protocol");
 if((k<4||k>=17)&&(refstate!==saved||refext!==savedext))$fatal(1,"capture not coherent with natural reference");
 if(k==1&&(!savedext[52]||savedext[51:50]==0))$fatal(1,"write-all completed before capture");
 // Compare every serialized backing byte against frozen reference RAM.
 for(j=0;j<128;j=j+1)begin sda=j;repeat(2)tick;if(mem['h40+j/8][(j%8)*8+:8]!==sdq2)$fatal(1,"torn snapshot byte%0d k%0d",j,k);end
 end
 case(k)
 4:mem['h1a][63:22]=0;
 5:mem['h1a][63:38]={24'h484301,2'd0};
 6:mem['h1a][63:38]={24'h484302,2'd2};
 7:mem['h1a][63:38]={24'h484303,2'd3};
 8:mem['h1a][63:40]=24'h484308;
 9:mem['h1a][39:38]=2;
 10:mem['h1f][63]=1;
 11:mem['h31][63]=1;
 12:mem['h30][3:0]=15;
 20:mem['h1a][63:40]=24'h484304;
 21:mem['h1a][63:40]=24'h484305;
22:mem['h1a][63:40]=24'h484306;
 13:begin mem[0][63:32]=16382;mem['he][63]=0;end
 endcase
 // Only the DUT moves to a discarded timeline; mutate backing via RAM port B.
 perturb=1;rst1=0;repeat(3)tick;rst1=1;addr=16'h8000;
 sdwe=1;for(j=0;j<size;j=j+1)begin sda=j;sdd=~expected[j];tick;end sdwe=0;
 operation(0);
 if(k<4||k>=17)begin
 if(!eeprom_full)$fatal(1,"valid full EEPROM rejected");check;
 case(k)
 0:repeat(4)bitin(0);
 3:repeat(9)bitin(0);
 default:repeat(40)bitin(0);
 endcase
 repeat(140)begin tick;check;end
 scan(1,1);
 // Subsequent write and erase remain functional after restoration.
 cmd(8'h30);cmd(8'h7f);for(j=15;j>=0;j=j-1)bitin((16'h5aa5>>j)&1);repeat(5)tick;check;
 cmd(8'hff);repeat(5)tick;check;
 if(k==18)begin
 operation(1);rst1=0;repeat(3)tick;rst1=1;
 sdwe=1;for(j=0;j<128;j=j+1)begin sda=j;sdd=j;tick;end sdwe=0;
 operation(0);check;scan(1,1);
 end
 end else begin
 if(eeprom_full)$fatal(1,"legacy/invalid/nonEEP consumed full state");
 scan(0,k==15);
 if(eeprom_present&&(eeprom_ext_out[3:0]!=1||eeprom_ext_out[51:50]!=0||eeprom_ext_out[34]!=0))$fatal(1,"legacy protocol not normalized");
 if(k==13&&eeprom_out!==64'd1)$fatal(1,"old64 missing word must normalize to deterministic ready state");
 end
 if(k==7||k==10||k==11||k==12||k<4||k>=17)begin if(md_in!==md_out||gg_in!==gg_out)$fatal(1,"other extensions damaged");end
 $display("PASS EEPROM DDRAM case%0d stalls%0d full%0d size%0d",k,STALL,eeprom_full,size);
end
if(CASE_ONLY<0)$display("PASS EEPROM DDRAM: 23 cases, full protocol/backing, coherent natural reference, legacy v0-v3, invalid, SRAM, SystemE");
else $display("PASS EEPROM DDRAM targeted case%0d",CASE_ONLY);
$finish;
end
initial begin #600000000;$fatal(1,"watchdog");end
endmodule
`;
// ModelSim requires module-level references to be declared before instances.
s=s.replace('reg perturb=0;','').replace('wire[6:0]a1,a2;','reg perturb=0;wire[6:0]a1,a2;');
fs.writeFileSync(path.join(dir,'integration_tb.sv'),s);
fs.copyFileSync(path.join(root,'tests/savestate_hcounter/savestates_sim.sv'),path.join(dir,'savestates_sim.sv'));
fs.writeFileSync(path.join(dir,'integration.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../rtl/dpram.vhd ../../rtl/eeprom_93c46.vhd ../../rtl/cart_eeprom.vhd
vlog -sv -quiet savestates_sim.sv integration_tb.sv
if {![info exists env(EEPROM_STALL)]} {set env(EEPROM_STALL) 0}
if {![info exists env(EEPROM_CASE)]} {set env(EEPROM_CASE) -1}
vsim -c -t 1ps -L altera_mf -gSTALL=$env(EEPROM_STALL) -gCASE_ONLY=$env(EEPROM_CASE) work.ee_integration
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
`);
