const fs=require('fs'),path=require('path'),dir=__dirname,root=path.resolve(dir,'../..');
let s=fs.readFileSync(path.join(root,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module md_integration;');
s=s.replace(/reg (\[45:0\]\s*)md_out = '0;/,'wire $1md_out;').replace(/reg (\[31:0\]\s*)io_out = '0;/,'wire $1io_out;').replace(/reg (\[127:0\]\s*)gg_out = '0;/,'wire $1gg_out;');
s=s.replace('cycle=cycle+1;end','cycle=cycle+1;DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(cycle%13<3);end');
const entity=fs.readFileSync(path.join(root,'rtl/io.vhd'),'utf8').split('architecture')[0];
const ports=[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)];
function io(){const o={clk:'clk',reset_n:'iorst',ce_cpu:"1'b1",wr_n:'wr',rd_n:"1'b1",a:'addr',d_in:'data',j1_th_out:'th1',j2_th_out:'th2',region:"1'b0",io_state_out:'io_out',io_state_in:'io_in',io_state_set:'io_set',ss_freeze:'ss_freeze',gg_state_out:'gg_out',gg_state_in:'gg_in',gg_state_set:'gg_set'};
return 'io localio('+ports.map(m=>{const r=m[3].match(/\((\d+)\s+downto\s+(\d+)\)/i),w=r?Number(r[1])-Number(r[2])+1:1;return '.'+m[1]+'('+(o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':w+"'b0"))+')';}).join(',')+');';}
s+=`reg iorst=0,padreset=1,refreset=1,holdref=0,wr=1;reg [7:0]addr=8'h3f,data=0;
wire th1,th2;wire [45:0] refstate;wire [5:0] pins1,pins2,refpins1,refpins2;reg [1:0]kind1=2,kind2=2;reg [3:0] buttons=15;
${io()}
`;
for(let i=1;i<=2;i++)for(const ref of [false,true])s+=`sega_controller pad${i}${ref?'ref':''}(.clk(clk),.reset(${ref?'refreset':'padreset'}),.controller_type(kind${i}),.sms_pins(6'h3f),.th(th${i}),.md_a(1'b0),.md_start(1'b0),.md_x(buttons[1]),.md_y(buttons[2]),.md_z(buttons[3]),.md_mode(buttons[0]),.pins(${ref?'refpins':'pins'}${i}),.ss_freeze(${ref?'holdref':'ss_freeze'}),.ss_set(${ref?"1'b0":'md_set'}),.ss_valid(md_valid),.ss_in(md_in[${i===1?'22:0':'45:23'}]),.ss_out(${ref?'refstate':'md_out'}[${i===1?'22:0':'45:23'}]));\n`;
s+=`task put(input [7:0]d);begin data=d;wr=0;tick;wr=1;repeat(2)tick;end endtask
task check;begin if(md_out!==refstate||pins1!==refpins1||pins2!==refpins2)$fatal(1,"integrated replay k=%0d state=%h/%h pins=%b/%b %b/%b",k,md_out,refstate,pins1,refpins1,pins2,refpins2);end endtask
reg [45:0]saved;reg [127:0]savedgg;integer k,j,freeze_start,freeze_length;reg [45:0]frozen;
// Observe the actual freeze boundary, including its final active clock.
always @(posedge ss_freeze)begin #1;holdref=1;freeze_start=cycle;end
always @(negedge ss_freeze)begin freeze_length=cycle-freeze_start;end
always @(negedge ss_freeze)if(!dut.do_save)holdref=0;
initial begin
reset_n=0;repeat(4)tick;reset_n=1;iorst=1;padreset=0;refreset=0;
vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;video_state_out=22'h12345;
vdp_regs={8'h5a,128'd0};vdp2_regs={8'ha5,128'd0};
for(k=0;k<13;k=k+1)begin
 buttons=15;
 holdref=0;padreset=1;refreset=1;put(8'hff);padreset=0;refreset=0;
 // Set P1 to third rise, P2 to second rise; settle real IO TH outputs.
 repeat(3)begin put(8'h55);put(8'h77);end
 put(8'h55);put(8'hff); // P1 fourth, P2 first: reset and rebuild distinct phases below
 padreset=1;refreset=1;tick;padreset=0;refreset=0;put(8'h55);
 repeat(2)begin put(8'hff);put(8'h55);end
 put(8'h77); // P1 third rise high, P2 second-rise low
 repeat(37)tick;
 operation(1);saved=dut.md_snap;savedgg={mem['h1d],mem['h1c]};
 if(md_out[22:17]!==saved[22:17]||md_out[45:40]!==saved[45:40])$fatal(1,"save transport consumed phase");
 $display("SAVE case%0d frozen=%0d clocks captured P1=%h P2=%h",k,freeze_length,saved[22:0],saved[45:23]);
 if(mem['h1a][63:38]!=={24'h484307,2'd3}||mem['h1e]!=={18'd0,saved})$fatal(1,"v3 storage");
 if(saved[19:17]!=3||saved[42:40]!=2||saved[16:0]==0||saved[39:23]==0)$fatal(1,"nontrivial setup %h",saved);
 if(savedgg!==gg_out)$fatal(1,"GG words changed");
 // Reference reached the same state through actual TH edges and was held at
 // the freeze boundary. It never loads any DUT snapshot or restored payload.
 if(refstate!==saved)$fatal(1,"natural reference capture mismatch");
 case(k)
 1:mem['h1a][63:22]=0;
 2:mem['h1a][63:38]={24'h484301,2'd0};
 3:mem['h1a][63:38]={24'h484302,2'd2};
 4:mem['h1a][63:38]={24'h484308,2'd3};
 5:mem['h1a][39:38]=2;
 6:mem['h1e][63]=1;
 7:mem['h1e][16:0]=80540;
 8:mem['h1e][19:17]=5;
 9:begin mem[0][63:32]=16382;mem['he][63]=0;end
 12:mem['h1a][63:38]={24'h484303,2'd3}; // F08 v3
 10:mem['h1a][63:40]=24'h123456;
 endcase
 put(8'h55);repeat(80545)tick;put(8'hff);
 operation(0);
 if(freeze_length<=80540)$fatal(1,"real freeze not longer than timeout");
 // operation includes ten active tail clocks; account for them equally on reference.
 if(k==0||k==11||k==12)begin
 if(!md_valid)$fatal(1,"valid v3 rejected");
 if(md_out[19:17]!=3||md_out[42:40]!=2||pins1[3:0]!=0)$fatal(1,"saved phases collapsed %h",md_out);
 if(md_out[22:17]!==saved[22:17]||md_out[45:40]!==saved[45:40])$fatal(1,"port histories");
 // The independently held reference resumes on the same release clock.
 check;
 holdref=0;
 for(j=0;j<80548;j=j+1)begin buttons=j%16;tick;check;end
 end else begin
 if(md_valid)$fatal(1,"legacy/invalid state accepted");
 if(md_out[19:17]!=0||md_out[42:40]!=0||md_out[20]!==th1||md_out[43]!==th2)$fatal(1,"legacy phase/history");
 end
 if(k==0||k==3||k==11||k==12)if(gg_out!==savedgg)$fatal(1,"GG preservation");
 $display("PASS MD DDRAM case%0d freeze=%0d cycles P1=%h P2=%h",k,freeze_length,md_out[22:0],md_out[45:23]);
end
$display("PASS MD DDRAM both real-timeout pads / stalls / untagged / v1 / v2 / invalid / oldest64");$finish;
end
initial begin #500000000;$fatal(1,"watchdog");end
endmodule
`;
fs.writeFileSync(path.join(dir,'integration_tb.sv'),s);
fs.copyFileSync(path.join(root,'tests/savestate_hcounter/savestates_sim.sv'),path.join(dir,'savestates_sim.sv'));
fs.writeFileSync(path.join(dir,'integration.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../rtl/io.vhd
vlog -sv -quiet savestates_sim.sv ../../rtl/sega_controller.sv integration_tb.sv
vsim -c -t 1ps work.md_integration
run -all
quit -code 0
`);

