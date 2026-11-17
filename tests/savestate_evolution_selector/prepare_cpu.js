const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
for(const n of ['T80','T80s'])fs.writeFileSync(path.join(d,n+'_sim.vhd'),fs.readFileSync(path.join(r,'rtl/T80',n+'.vhd'),'utf8').replace(/:\s*work\.(T80\w*)/g,': entity work.$1'));
let s=fs.readFileSync(path.join(d,'evolution_tb.sv'),'utf8').split('reg mrst=')[0].replace('module evolution_tb;','module cpu_tb;');
for(const n of ['z80_reg','z80_iset','vblank','x','video_state_out'])s=s.replace(new RegExp('reg (\\[[^\\]]+\\]\\s*)?'+n+" = '0;"),'wire $1'+n+';');
// CPU owns the bus. The operation task no longer drives synthetic bus signals.
s=s.replace('boundary;','');
let bytes=[];const emit=(...b)=>bytes.push(...b),out=(port,v)=>emit(0x3e,v,0xd3,port),sw=()=>{emit(0x3e,0x87,0x32,0xfe,0x3f);const target=bytes.length+3;emit(0xc3,target&255,target>>8);};
out(0x61,0);out(0x62,0x28);sw();out(0x61,0);out(0x62,0x48);sw();
const loop=bytes.length;emit(0x3a,0x23,0x81,0xd3,0x20,0xc3,loop&255,loop>>8);
fs.writeFileSync(path.join(d,'guest_bytes.json'),JSON.stringify(bytes));
s+=`reg mrst=0;wire[15:0]addr;wire[7:0]data,di;wire wr,mreq,iq,rd;
wire[159:0]extra;wire[23:0]physical;wire[15:0]game,previous;wire[7:0]mode;wire launch;
assign evolution_out=extra[95:0];assign z80_mreq_n=mreq;
evolution_machine mapped(.clk(clk),.reset_n(mrst),.a(addr),.d(data),.mreq(mreq),.iorq(iq),.rd(rd),.wr(wr),.m1(z80_m1_n),.set(evolution_set),.ein(evolution_in),.min(mapper_in),.extra(extra),.mapped(mapper_out),.physical(physical),.game(game),.previous(previous),.mode(mode),.launch(launch));
function[7:0]rom(input[23:0]a);case(a[15:0])
${bytes.map((b,i)=>`${i}:rom=8'h${b.toString(16)};`).join('\n')}
default:rom=a[23:16];endcase endfunction
assign di=rom(physical);
wire pix=cycle%10==0;wire[8:0]y;
video beam(.clk(clk),.ce_pix(pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(),.vblank(vblank));
`;
const entity=fs.readFileSync(path.join(r,'rtl/T80/T80s.vhd'),'utf8').split('end T80s')[0];
const o={reset_n:'mrst',clk:'clk',cen:'(cpu_ce&&!ss_freeze)',wait_n:"1'b1",int_n:"1'b1",nmi_n:"1'b1",busrq_n:"1'b1",m1_n:'z80_m1_n',mreq_n:'mreq',iorq_n:'iq',rd_n:'rd',wr_n:'wr',a:'addr',di:'di',do:'data',reg:'z80_reg',dirset:'z80_set',dir:'z80_dir',iset_out:'z80_iset'};
s+='T80s #(.T2Write(0)) cpu('+[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(std_logic(?:_vector\s*\([^)]*\))?)/gi)].map(m=>'.'+m[1]+'('+(o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':m[3].toLowerCase().includes('vector')?"230'd0":"1'b0"))+')').join(',')+');\n';
s+=`integer accepts=0,guest_reads=0;reg[7:0]guest_data=0;integer stage=0;reg first_before=0,first_after=0;
always @(posedge clk)begin
 if(dut.state==37&&cpu_ce&&!z80_m1_n&&!z80_mreq_n&&z80_iset==0&&vblank&&x<256)accepts=accepts+1;
 if(!iq&&!wr&&addr[7:0]==8'h20&&!ss_freeze)begin
 guest_data<=data;guest_reads=guest_reads+1;
 if((stage<2&&data!==8'h28)||(stage>=2&&data!==8'h48))$fatal(1,"unexpected CPU data stage%0d data%h",stage,data);
 end
 if(!mreq&&!rd&&addr==16'h8123&&!ss_freeze)begin
  if(stage==0&&!first_before)begin first_before=1;$display("CPU READ before cycle%0d addr=%h Flash=%h DI=%h",cycle,addr,physical,di);end
  if(stage==2&&!first_after)begin first_after=1;$display("CPU READ restored cycle%0d addr=%h Flash=%h DI=%h",cycle,addr,physical,di);end
 end
end
initial begin
 repeat(4)tick;reset_n=1;audio_quiescent=1;ss_game_id='hf1400080;
 while(!(vblank&&x<64))tick;mrst=1;wait(guest_data==8'h28);repeat(100)tick;
 operation(1);if(guest_data!==8'h28||previous!==16'h2800)$fatal(1,"save changed history");
 $display("CPU SAVE_ONLY PASS accepted=%0d game=%h prev=%h guestOUT=%h",accepts,game,previous,guest_data);
 stage=1;repeat(300)tick;operation(0);stage=2;wait(guest_data==8'h48);repeat(100)tick;
 if(previous!==0||game!==16'h4800||accepts!=2)$fatal(1,"wrong restored CPU mapping");
 $display("PASS F14 real T80/video accepted=%0d actual OUT20 data before28 restored48 reads=%0d mapper=%h previous=%h",accepts,guest_reads,mapper_out,previous);$finish;
end
initial begin repeat(6000000)tick;$fatal(1,"CPU watchdog");end
endmodule
`;
fs.writeFileSync(path.join(d,'cpu_tb.sv'),s);
fs.writeFileSync(path.join(d,'cpu.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib cpu_work
vcom -work cpu_work -2008 -quiet ../../rtl/video.vhd ../../rtl/evolution_mapper.vhd ../../rtl/evolution_rom_address.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd
vlog -work cpu_work -sv -quiet savestates_sim.sv evolution_machine.sv cpu_tb.sv
vsim -c -t 1ps -voptargs=+acc cpu_work.cpu_tb
set NumericStdNoWarnings 1
run -all
quit -code 0
`);
