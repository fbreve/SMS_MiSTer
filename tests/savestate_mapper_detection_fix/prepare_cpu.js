const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
for(const n of ['T80','T80s'])fs.writeFileSync(path.join(d,n+'_sim.vhd'),fs.readFileSync(path.join(r,'rtl/T80',n+'.vhd'),'utf8').replace(/:\s*work\.(T80\w*)/g,': entity work.$1'));
let s=fs.readFileSync(path.join(d,'history_tb.sv'),'utf8').split('reg mrst=')[0].replace('module history_tb;','module cpu_reach_tb;\nparameter EARLY=0;');
for(const n of ['z80_reg','z80_m1_n','z80_mreq_n','z80_iset','vblank','x','video_state_out'])s=s.replace(new RegExp('reg (\\[[^\\]]+\\]\\s*)?'+n+" = '0;"),'wire $1'+n+';');
s+=`reg mrst=0,boot=0,romclk=0,romen=0;reg[24:0]ra=0;reg[7:0]rd=0;
wire[15:0]addr;wire[7:0]data,di;wire wr,mreq,iq,readn;wire[21:0]physical;wire dh,sega;wire[7:0]unusedq;
machine mapped(.clk_sys(clk),.ROMCL(romclk),.ROMAD(ra),.ROMDT(rd),.ROMEN(romen),.RESET_n(mrst),.ss_freeze(ss_freeze),.bootloader_n(boot),.A(addr),.D_in(data),.WR_n(wr),.MREQ_n(mreq),.mapper_set(mapper_set),.mapper_in(mapper_in),.state_out(mapper_out),.rom_address(physical),.dahjee(dh),.sega_seen(sega),.read_data(unusedq));
function[7:0]rom(input[21:0]a);case(a)
0:rom=8'h41;1:rom=8'h42;2:rom=8'h3e;3:rom=0;4:rom=8'h32;5:rom=8'hfd;6:rom=8'hff;
7:rom=8'h3e;8:rom=3;9:rom=8'h32;10:rom=0;11:rom=8'ha0;12:rom=8'hc3;13:rom=12;14:rom=0;default:rom=0;endcase endfunction
assign di=rom(physical);assign z80_mreq_n=mreq;
wire pix=cycle%10==0;wire[8:0]y;
video beam(.clk(clk),.ce_pix(pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(),.vblank(vblank));
`;
const entity=fs.readFileSync(path.join(r,'rtl/T80/T80s.vhd'),'utf8').split('end T80s')[0];
const o={reset_n:'mrst',clk:'clk',cen:'(cpu_ce&&!ss_freeze)',wait_n:"1'b1",int_n:"1'b1",nmi_n:"1'b1",busrq_n:"1'b1",m1_n:'z80_m1_n',mreq_n:'mreq',iorq_n:'iq',rd_n:'readn',wr_n:'wr',a:'addr',di:'di',do:'data',reg:'z80_reg',dirset:"1'b0",iset_out:'z80_iset'};
s+='T80s #(.T2Write(0)) cpu('+[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(std_logic(?:_vector\s*\([^)]*\))?)/gi)].map(m=>'.'+m[1]+'('+(o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':m[3].toLowerCase().includes('vector')?"230'd0":"1'b0"))+')').join(',')+');\n';
s+=`integer handoff,accepts=0;
always @(posedge clk)if(dut.state==37&&cpu_ce&&!z80_m1_n&&!z80_mreq_n&&z80_iset==0&&vblank&&x<256)accepts=accepts+1;
initial begin
 reset_n=0;repeat(4)tick;reset_n=1;audio_quiescent=1;ss_game_id=32'hf1300003;
 romen=1;for(integer i=0;i<131072;i=i+1)begin ra=i;rd=rom(i);romclk=0;#1;romclk=1;#1;end romen=0;romclk=0;
 while(!(vblank&&x<64))tick;
 boot=1;mrst=1;handoff=cycle;
 wait(sega&&mapper_out[23:16]==3);repeat(100)tick;
 if(!EARLY)repeat(66000)tick;
 ss_save=1;tick;ss_save=0;wait(ss_freeze);tick;
 if(!sega||mapper_out[23:16]!=3)$fatal(1,"CPU prefix not accumulated");
 if(!vblank||x>=256||accepts!=1)$fatal(1,"invalid real CPU capture");
 $display("PASS F13 real T80/video accepted EARLY%0d clock%0d handoff_age%0d xy%0d/%0d mapper%h sega%0d A%h REG%h",EARLY,cycle,cycle-handoff,x,y,mapper_out,sega,addr,z80_reg);$finish;
end
initial begin repeat(2500000)tick;$fatal(1,"CPU reachability watchdog");end
endmodule
`;
fs.writeFileSync(path.join(d,'cpu_reach_tb.sv'),s);
fs.writeFileSync(path.join(d,'cpu.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib cpu_work\nvcom -work cpu_work -2008 -quiet ../../rtl/video.vhd ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd\nvlog -work cpu_work -sv -quiet savestates_sim.sv machine.sv cpu_reach_tb.sv\nvsim -c -t 1ps -voptargs=+acc cpu_work.cpu_reach_tb -gEARLY=$env(F13_EARLY)\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);
