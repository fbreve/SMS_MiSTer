const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
for(const name of ['T80','T80s'])fs.writeFileSync(path.join(d,name+'_sim.vhd'),fs.readFileSync(path.join(r,'rtl/T80/'+name+'.vhd'),'utf8').replace(/:\s*work\.(T80\w*)/g,': entity work.$1'));
let s=fs.readFileSync(path.join(d,'prefix.sv'),'utf8').replace('module boundary_tb;','module cpu_replay;');
for(const n of ['z80_reg','z80_m1_n','z80_mreq_n','z80_iset'])s=s.replace(new RegExp('reg (\\[[^\\]]+\\]\\s*)?'+n+" = '0;"),'wire $1'+n+';');
s=s.replace("jx=8'h7f","jx=8'h7d");
const declarations=`wire[15:0]ca,ra;wire[7:0]cdo,rdo,cdi,rdi;wire crd,cwr,ciq,rrd,rwr,riq,rm1,rmreq;wire[229:0]rreg;wire[1:0]riset;
function[7:0]rom(input[15:0]a);case(a)0:rom=8'h3e;1:rom=8'hff;2:rom=8'hd3;3:rom=8'h3f;4:rom=8'hdb;5:rom=8'hdd;6:rom=8'hc3;7:rom=8'h04;8:rom=0;default:rom=0;endcase endfunction
assign cdi=!ciq?guest:rom(ca);assign rdi=!riq?refguest:rom(ra);
`;
s=s.replace('video live_video(',declarations+'video live_video(');
s=s.replace(/io live_io\([^;]+;/,m=>m.replace('.WR_n(wr)','.WR_n(cwr|ciq)').replace('.RD_n(rd)','.RD_n(crd|ciq)').replace('.A(addr)','.A(ca[7:0])').replace('.D_in(data)','.D_in(cdo)'));
s=s.replace(/io reference_io\([^;]+;/,m=>m.replace('.WR_n(wr)','.WR_n(rwr|riq)').replace('.RD_n(rd)','.RD_n(rrd|riq)').replace('.A(addr)','.A(ra[7:0])').replace('.D_in(data)','.D_in(rdo)'));
const entity=fs.readFileSync(path.join(r,'rtl/T80/T80s.vhd'),'utf8').split('end T80s')[0];
for(const ref of [false,true]){
const o={reset_n:'reset_n',clk:'clk',cen:ref?'(ce_cpu&&!holdref)':'(ce_cpu&&!ss_freeze)',wait_n:"1'b1",int_n:"1'b1",nmi_n:ref?'refnmi':'nmi',busrq_n:"1'b1",m1_n:ref?'rm1':'z80_m1_n',mreq_n:ref?'rmreq':'z80_mreq_n',iorq_n:ref?'riq':'ciq',rd_n:ref?'rrd':'crd',wr_n:ref?'rwr':'cwr',a:ref?'ra':'ca',di:ref?'rdi':'cdi',do:ref?'rdo':'cdo',reg:ref?'rreg':'z80_reg',dirset:"1'b0",iset_out:ref?'riset':'z80_iset'};
s+='T80s #(.T2Write(0)) '+(ref?'reference_cpu':'live_cpu')+'('+[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(std_logic(?:_vector\s*\([^)]*\))?)/gi)].map(m=>'.'+m[1]+'('+(o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':m[3].toLowerCase().includes('vector')?"230'd0":"1'b0"))+')').join(',')+');\n';
}
s+=`integer frame=0,start,elapsed,ioreads=0,differences=0,accepts=0,after_release=0,freeze_seen=0;reg[7:0]previous_c,previous_r;
always@(posedge vb)if(!ss_freeze)begin frame=frame+1;$display("FRAME%0d xy%0d/%0d",frame,x,y);end
always@(posedge ss_freeze)begin #1;holdref=1;freeze_seen=1;start=cycle;if(z80_reg!==rreg)$fatal(1,"CPU paths unequal at freeze");$display("CPU CAPTURE xy%0d/%0d M1%b MREQ%b sensor%b/%b pending%b time%0d localHV%0d/%0d CPU%h",x,y,z80_m1_n,z80_mreq_n,sensor,refsensor,live_gun.beam.sensor_pend,live_gun.beam.sensor_time,live_gun.beam.hcnt,live_gun.beam.vcnt,z80_reg);end
always@(negedge ss_freeze)if(freeze_seen)begin elapsed=cycle-start;holdref=0;after_release=1;end
always@(posedge clk)begin
if(dut.state==37&&cpu_ce&&!z80_m1_n&&!z80_mreq_n&&z80_iset==0&&vb&&x<256)begin accepts=accepts+1;$display("CPU ACCEPT xy%0d/%0d",x,y);end
if(after_release&&ce_cpu&&!ss_freeze&&!ciq&&!crd&&ca[7:0]==8'hdd)begin
 ioreads=ioreads+1;if(cdi!==rdi)begin differences=differences+1;$display("CPU GUEST DIVERGENCE read%0d postClocks%0d xy%0d/%0d bus=%h/%h sensor=%b/%b A=%h/%h HL=%b/%b",ioreads,cycle-start-elapsed,x,y,cdi,rdi,sensor,refsensor,z80_reg[7:0],rreg[7:0],hl,refhl);end
end
end
initial begin
reset_n=0;repeat(6)tick;iorst=1;reset_n=1;audio_quiescent=1;ss_game_id=32'h12345678;
// Queue a real save one host clock before a naturally occurring M1 read at x254.
while(!(frame>=3&&vb&&y==192&&x==254&&clkd==24&&!z80_m1_n&&!z80_mreq_n&&z80_iset==0))tick;
ss_save=1;tick;ss_save=0;wait(ss_freeze);wait(!ss_freeze);#1;
if(video_state_out!==refvideo||z80_reg!==rreg)$fatal(1,"CPU/beam release mismatch");
$display("CPU RELEASE beam%h/%h sensor%b/%b pending%b/%b time%0d/%0d transport%0d",video_state_out,refvideo,sensor,refsensor,live_gun.beam.sensor_pend,reference_gun.beam.sensor_pend,live_gun.beam.sensor_time,reference_gun.beam.sensor_time,elapsed);
repeat(1800)tick;
if(!differences)$fatal(1,"no real CPU-visible divergence");
$display("CONFIRMED F11 real T80 save-only CPU divergence accepts%0d IN ioreads%0d differences%0d",accepts,ioreads,differences);$finish;
end
initial begin #250000000;$fatal(1,"CPU watchdog frame%0d xy%0d/%0d",frame,x,y);end
endmodule
`;
fs.writeFileSync(path.join(d,'cpu_tb.sv'),s);
fs.writeFileSync(path.join(d,'cpu.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib cpu_work
vcom -work cpu_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd
vlog -work cpu_work -sv -quiet savestates_sim.sv gun_fixture.sv cpu_tb.sv
vsim -c -t 1ps cpu_work.cpu_replay
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
