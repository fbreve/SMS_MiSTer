const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
const read=f=>fs.readFileSync(path.join(r,f),'utf8').replace(/\r\n/g,'\n');
let ss=read('rtl/savestates.sv');for(const n of ['mapper_snap','evolution_snap']){let re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\n','m'),a=ss.match(re)[0];ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',a+'// NVRAM size calculation helpers');}fs.writeFileSync(path.join(d,'savestates_sim.sv'),ss);
let gun=read('rtl/lightgun.sv').replace('module lightgun','module gun_fixture').replace('input        CLK,','input CLK, input hold,').replace('always @(posedge CLK) begin','always @(posedge CLK) begin : beam').replace('\nend\n\nendmodule','\nend\nend\n\nendmodule');gun=gun.replace('output       SENSOR','output reg   SENSOR').replace('output       TRIGGER','output reg   TRIGGER').replace('assign TARGET  = ~offscreen & draw;','').replace('\tTRIGGER <=','\tif (!hold) begin\n\tTRIGGER <=').replace('\nendmodule','\nassign TARGET = ~offscreen & draw;\nendmodule');fs.writeFileSync(path.join(d,'gun_fixture.sv'),gun);
let prefix=read('tests/savestate_hcounter/controller_tb.sv').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module boundary_tb;parameter STALL=0,PAL=0,PORT=0,BORDER=0,REGION=0,ALLOW_EQUAL=0;');
for(const n of ['x','vblank','video_state_out','vdp_regs','io_out','gg_out','cpu_ce','vdp_ce','pix_ce','sp_ce'])prefix=prefix.replace(new RegExp('reg (\\[[^\\]]+\\]\\s*)?'+n+" = '0;"),'wire $1'+n+';');
prefix=prefix.replace('always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;end',`reg[4:0]clkd=0;reg ce_cpu=0,ce_vdp=0,ce_pix=0,ce_sp=0;reg[15:0]lfsr=16'h1ace;
assign cpu_ce=ce_cpu;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
always @(negedge clk)begin cycle=cycle+1;ce_sp<=clkd[0];ce_cpu<=0;ce_vdp<=0;ce_pix<=0;clkd<=clkd+1'b1;
if(clkd==29)begin clkd<=0;ce_vdp<=1;ce_pix<=1;end
else if(clkd==24)begin ce_cpu<=1;ce_vdp<=1;end
else if(clkd==19)begin ce_vdp<=1;ce_pix<=1;end
else if(clkd==14)ce_vdp<=1;
else if(clkd==9)begin ce_cpu<=1;ce_vdp<=1;ce_pix<=1;end
else if(clkd==4)ce_vdp<=1;
lfsr<={lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};
DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?lfsr[3:0]<12:STALL==3?cycle%2048<1900:0);
end`);
prefix=prefix.replace('task operation(input bit saving);begin','task operation(input bit saving);begin\n tick;');
prefix+=`reg holdref=0,iorst=0,wr=1,rd=1;reg[7:0]addr=8'h3f,data=8'hff;reg[7:0]jx=8'h7f,jy=8'h7c;reg[24:0]mouse=0;reg mousexy=0;
wire[8:0]y,rx,ry;wire hb,vb,rhb,rvb;wire[21:0]refvideo;wire sensor,refsensor,target,reftarget,trigger,reftrigger,hl,refhl;
wire[7:0]guest,refguest,hval,refhval;wire nmi,refnmi;reg th1,th2,rth1,rth2;
always@(posedge clk)begin th1<=PORT?1'b1:!sensor;th2<=PORT?!sensor:1'b1;rth1<=PORT?1'b1:!refsensor;rth2<=PORT?!refsensor:1'b1;end
assign vblank=vb;
`;
function entity(file,name,inst,over){let p=[...read(file).split('architecture')[0].matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)];return name+' '+inst+'('+p.map(m=>{let range=m[3].match(/\((\d+)\s+downto\s+(\d+)\)/i),w=range?+range[1]-range[2]+1:1;return '.'+m[1]+'('+(over[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':w+"'d0"))+')';}).join(',')+');\n';}
for(const ref of [false,true]){
prefix+=entity('rtl/video.vhd','video',ref?'reference_video':'live_video',{clk:'clk',ce_pix:ref?'(ce_pix&&!holdref)':'ce_pix',pal:'PAL[0]',border:'BORDER[0]',smode_m4:"1'b1",video_state_out:ref?'refvideo':'video_state_out',video_state_in:'video_state_in',video_state_set:ref?"1'b0":'video_state_set',x:ref?'rx':'x',y:ref?'ry':'y',hblank:ref?'rhb':'hb',vblank:ref?'rvb':'vb'});
prefix+=`gun_fixture ${ref?'reference_gun':'live_gun'}(.CLK(clk),.hold(${ref?'holdref':"1'b0"}),.RESET(!reset_n),.MOUSE(mouse),.MOUSE_XY(mousexy),.JOY_X(jx),.JOY_Y(jy),.JOY(12'd0),.HDE(!${ref?'rhb':'hb'}),.VDE(!${ref?'rvb':'vb'}),.CE_PIX(ce_pix&&!${ref?'holdref':'ss_freeze'}),.BTN_MODE(1'b0),.SIZE(2'd0),.SENSOR_DELAY(8'd34),.TARGET(${ref?'reftarget':'target'}),.SENSOR(${ref?'refsensor':'sensor'}),.TRIGGER(${ref?'reftrigger':'trigger'}));\n`;
prefix+=entity('rtl/io.vhd','io',ref?'reference_io':'live_io',{clk:'clk',reset_n:'iorst',ce_cpu:'ce_cpu',wr_n:'wr',rd_n:'rd',a:'addr',d_in:'data',d_out:ref?'refguest':'guest',j1_th:ref?'rth1':'th1',j2_th:ref?'rth2':'th2',j1_tl:ref?'(PORT?1\'b1:!reftrigger)':'(PORT?1\'b1:!trigger)',j2_tl:ref?'(PORT?!reftrigger:1\'b1)':'(PORT?!trigger:1\'b1)',hl_out:ref?'refhl':'hl',io_state_out:ref?'':'io_out',io_state_in:'io_in',io_state_set:ref?"1'b0":'io_set',gg_state_out:ref?'':'gg_out',gg_state_in:'gg_in',gg_state_set:ref?"1'b0":'gg_set',region:'REGION[0]',pal:'PAL[0]',ss_freeze:ref?'holdref':'ss_freeze',gg_link_nmi_n:ref?'refnmi':'nmi'});
}
// Exact production VDP HCounter restore/edge block, with unused VDP fields tied zero.
prefix+=`reg oldhl=0,refoldhl=0;reg[7:0]latched,ref_latched;
assign vdp_regs={latched,128'd0};assign hval=latched;assign refhval=ref_latched;
always @(posedge clk)begin
if(!reset_n)begin oldhl<=0;refoldhl<=0;end else begin
if(vdp_regs_set)begin latched<=vdp_regs_in[135:128];oldhl<=hl;end
oldhl<=hl;if(!vdp_regs_set&&!oldhl&&hl)latched<=x[8:1];
if(!holdref)begin refoldhl<=refhl;if(!refoldhl&&refhl)ref_latched<=rx[8:1];end
end end
`;
fs.writeFileSync(path.join(d,'prefix.sv'),prefix);
fs.writeFileSync(path.join(d,'boundary_tb.sv'),prefix+fs.readFileSync(path.join(d,'scenario.sv.in'),'utf8'));
for(let i=0;i<4;i++)fs.writeFileSync(path.join(d,`stalls${i}.do`),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib boundary${i}_work
vcom -work boundary${i}_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd
vlog -work boundary${i}_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=${i} boundary${i}_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
