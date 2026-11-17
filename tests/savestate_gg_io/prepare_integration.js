const fs=require('fs'),path=require('path');const dir=__dirname,root=path.resolve(dir,'../..');
const inv=JSON.parse(fs.readFileSync(path.join(dir,'inventory.json')));
// Reuse the established full-controller DDRAM model and unshortened flush.
let s=fs.readFileSync(path.join(dir,'controller_model.sv.in'),'utf8');
s=s.slice(0,s.indexOf('reg [63:0] video_saved;')).replace('module controller_tb;','module gg_integration_tb;');
if(process.env.DDRAM_STALLS!=='0')s=s.replace('always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;end','always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(cycle%13<3);end');
s=s.replace(/reg (\[127:0\]\s*)gg_out = '0;/,'wire $1gg_out;').replace(/reg (\[31:0\]\s*)io_out = '0;/,'wire $1io_out;');
const entity=fs.readFileSync(path.join(root,'rtl/io.vhd'),'utf8').split('architecture')[0];
const ports=[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)];
function io(n){const o={clk:'clk',reset_n:'rst'+n,ce_cpu:'protocol_run && !ss_freeze && cpu_ce',wr_n:'wr'+n,rd_n:'io_rd',a:'io_addr',d_in:'io_din',d_out:'data'+n,gg:'gg_mode',gg_link_en:"1'b1",gg_link_in:'link',gg_link_out:'pins'+n,gg_link_nmi_n:'nmi'+n,gg_state_out:n===1?'gg_out':'refgg',gg_state_in:'gg_in',gg_state_set:n===1?'gg_set':"1'b0",io_state_out:n===1?'io_out':'refio',io_state_in:'io_in',io_state_set:n===1?'io_set':"1'b0",ss_freeze:n===1?'ss_freeze':'refhold || ss_freeze',systeme:'systeme',palettemode:'sg_mode',sc3000_en:'sc_mode',sk1100_en:'sc_mode',sc_multicart_en:'sc_mode',sk1100_row_data:"12'habc",se_mapper_in:'mapper_in[7:0]',se_mapper_set:n===1?'mapper_set':"1'b0"};
return 'io local'+n+'('+ports.map(m=>{const r=m[3].match(/\((\d+)\s+downto\s+(\d+)\)/i),width=r?Number(r[1])-Number(r[2])+1:1;return '.'+m[1]+'('+(o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':width+"'b0"))+')';}).join(',')+');';}
s+=`reg rst1=0,rst2=0,gg_mode=1,sg_mode=0,sc_mode=0,protocol_run=0,refhold=0;
reg wr1=1,wr2=1,io_rd=1;reg [7:0]io_addr=0,io_din=0;reg [6:0]link=7'h7f;
wire [7:0]data1,data2;wire [6:0]pins1,pins2;wire nmi1,nmi2;wire [127:0]refgg;wire [31:0]refio;
${io(1)}
${io(2)}
task put(input [7:0]a,d,input bit both);begin io_addr=a;io_din=d;wr1=0;if(both)wr2=0;tick;wr1=1;wr2=1;tick;end endtask
task get(input [7:0]a);begin io_addr=a;io_rd=0;repeat(2)tick;if(data1!==data2)$fatal(1,"guest read mismatch port%h %h %h",a,data1,data2);io_rd=1;tick;end endtask
localparam [127:0] GG_RESET=128'h${inv.reset128};
reg [127:0]savedgg;reg [31:0]savedio;integer k;
initial begin
reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;
ss_game_id=32'h12345678;video_state_out=22'h12345;vdp_regs={8'h5a,128'd0};vdp2_regs={8'ha5,128'd0};
for(k=0;k<14;k=k+1)begin
 systeme=k==9;gg_mode=k<8||k>=12;sg_mode=k==10;sc_mode=k==11;
 protocol_run=0;refhold=0;rst1=0;rst2=0;io_rd=1;link=7'h7f;tick;rst1=1;rst2=1;tick;
 if(gg_mode)begin put(2,0,1);put(1,8'h35,1);put(2,8'h40,1);put(5,8'h38,1);put(3,8'ha6,1);put(3,8'h93,1);link=7'h1f;protocol_run=1;repeat(13000)tick;protocol_run=0;tick;end
 else if(sc_mode)begin put(8'hc2,8'h05,1);put(8'he0,8'h42,1);end
 else put(8'h3f,8'hf3,1);
 savedgg=gg_out;savedio=io_out;
 if(k==0&&(!savedgg[38]||!savedgg[66]||savedgg[83:82]==0||savedgg[31:24]!=8'h35||savedgg[7:0]!=8'h40))$fatal(1,"Nontrivial serial setup not reached");
 refhold=1;operation(1);
 if(mem['h1a][63:38]!=={24'h484308,2'd3}||{mem['h1d],mem['h1c]}!==savedgg)$fatal(1,"extension save mismatch");
 case(k)
  1:mem['h1a][63:38]={24'h484301,2'd0}; // F07 v1
  2:mem['h1a][63:22]=0;
  3:mem['h1a][63:40]=24'h123456;
  4:mem['h1a][63:40]=24'h484309;
  5:mem['h1a][39:38]=1;
  6:mem['h1d][63]=1; // reserved padding invalid
  13:mem['h1a][63:38]={24'h484303,2'd3}; // F08
  12:mem['h1a][63:38]={24'h484302,2'd2}; // F02 v2 retains GG
  7:begin mem[0][63:32]=32'd16382;mem['he][63]=0;end
 endcase
 rst1=0;tick;rst1=1;tick;
 if(gg_mode)begin put(2,0,0);put(1,8'h6a,0);put(2,8'hff,0);put(3,8'h55,0);end
 else if(sc_mode)begin put(8'hc2,8'h01,0);put(8'he0,8'h11,0);end
 else put(8'h3f,0,0);
 operation(0);
 if(gg_out!==((k>=1&&k<=7)?GG_RESET:savedgg))$fatal(1,"GG restore case%0d actual%h expected%h",k,gg_out,((k>=1&&k<=7)?GG_RESET:savedgg));
 if(k!=7&&io_out[26:0]!==savedio[26:0])$fatal(1,"ordinary IO fields changed case%0d",k);
 if(k==0)begin
  refhold=0;get(1);get(2);get(3);get(5);get(4);
  protocol_run=1;
  repeat(250000)begin tick;if(gg_out!==refgg||pins1!==pins2||nmi1!==nmi2)$fatal(1,"integrated replay mismatch");end
  protocol_run=0;
 end
 if(!gg_mode&&(pins1!==7'h7f||nmi1!==1'b1))$fatal(1,"inactive GG affects non-GG outputs");
 $display("PASS integrated GG case%0d gg=%0d SystemE=%0d SG=%0d SC=%0d",k,gg_mode,systeme,sg_mode,sc_mode);
end
$display("PASS F02 DDRAM integration: 14 modern/legacy/invalid/non-GG cases plus mid-transfer replay");$finish;
end
initial begin #400000000;$fatal(1,"watchdog");end
endmodule
`;
fs.writeFileSync(path.join(dir,'integration_tb.sv'),s);
let sim=fs.readFileSync(path.join(root,'rtl/savestates.sv'),'utf8');
for(const name of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+name+';\\r?\\n','m'),d=sim.match(re)[0];sim=sim.replace(re,'').replace('// NVRAM size calculation helpers',d+'// NVRAM size calculation helpers');}
fs.writeFileSync(path.join(dir,'savestates_sim.sv'),sim);
fs.writeFileSync(path.join(dir,'integration.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../rtl/io.vhd
vlog -sv -quiet savestates_sim.sv integration_tb.sv
vsim -c -t 1ps work.gg_integration_tb
run -all
quit -code 0
`);
