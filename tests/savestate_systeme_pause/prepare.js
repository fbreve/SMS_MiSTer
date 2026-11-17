const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
// Reuse the existing production-controller transport harness, not its test scenarios.
let s=fs.readFileSync(path.join(r,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module pause_tb;parameter CASE=0,KEEP=0,FULL=0;');
for(const n of ['vblank','x','z80_reg','z80_m1_n','z80_mreq_n','z80_iset','vdp_regs','vdp2_regs','video_state_out','psg_out','psg2_out','psg_ext_out','psg2_ext_out','psg_div_out','audio_quiescent','cpu_ce','vdp_ce','pix_ce','sp_ce'])s=s.replace(new RegExp('reg (\\[[^\\]]+\\]\\s*)?'+n+" = '0;"),'wire $1'+n+';');
s=s.replace('always @(negedge clk) begin cpu_ce=cycle%15==0;cycle=cycle+1;end',`reg[4:0]clkd=0;reg ce_cpu=0,ce_pix=0,ce_vdp=0,ce_sp=0;
assign cpu_ce=ce_pix;assign vdp_ce=ce_vdp;assign pix_ce=ce_pix;assign sp_ce=ce_sp;
always@(negedge clk)begin cycle=cycle+1;ce_cpu<=0;ce_pix<=0;ce_vdp<=0;ce_sp<=clkd[0];clkd<=clkd+1;
case(clkd)4:ce_vdp<=1;9:begin ce_cpu<=1;ce_pix<=1;ce_vdp<=1;end 14:ce_vdp<=1;19:begin ce_pix<=1;ce_vdp<=1;end 24:begin ce_cpu<=1;ce_vdp<=1;end 29:begin ce_pix<=1;ce_vdp<=1;clkd<=0;end endcase end`);
// Production System E uses raw ce_pix as controller cpu_ce and actual T80 CEN.
const sms=fs.readFileSync(path.join(r,'SMS.sv'),'utf8').replaceAll('\r','');
let block=sms.slice(sms.indexOf('always @(posedge clk_sys) begin\n\tjoy8_r'),sms.indexOf('assign HDMI_BOB_DEINT'));
if(!block)throw Error('pause block not found');
block=block.replaceAll('clk_sys','clk').replaceAll('raw_reset','!reset_n');
fs.writeFileSync(path.join(d,'pause_fixture.sv'),`module pause_fixture(input clk,reset_n,systeme,joy8_sig,VBlank,ss_freeze,input preserve,output reg se_paused,output reg se_pause_pending,output reg se_unpause_pending);reg joy8_r,VBlank_r,ss_freeze_r;wire ss_unfreeze=ss_freeze_r&~ss_freeze;always@(posedge clk)ss_freeze_r<=ss_freeze;\n${block.replace('ss_freeze | ss_unfreeze','((ss_freeze | ss_unfreeze) & ~preserve)')}endmodule\n`);
let sim=fs.readFileSync(path.join(r,'rtl/savestates.sv'),'utf8');
for(const name of ['mapper_snap','evolution_snap']){let re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+name+';\\r?\\n','m'),decl=sim.match(re)[0];sim=sim.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
fs.writeFileSync(path.join(d,'savestates_sim.sv'),sim);
for(const name of ['T80','T80s'])fs.writeFileSync(path.join(d,name+'_sim.vhd'),fs.readFileSync(path.join(r,'rtl/T80/'+name+'.vhd'),'utf8').replace(/:\s*work\.(T80\w*)/g,': entity work.$1'));
s+=`reg joy=0,holdref=0;wire paused,pp,up,rpaused,rpp,rup;wire[8:0]y,rx,ry;wire vb,hb,rvb,rhb;wire[21:0]rvideo;
pause_fixture p(clk,reset_n,systeme,joy,vb,ss_freeze,KEEP!=0,paused,pp,up);
pause_fixture rp(clk,reset_n,systeme,joy,rvb,1'b0,1'b0,rpaused,rpp,rup);
assign vblank=vb;
video video1(.clk(clk),.ce_pix(ce_pix),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(video_state_out),.video_state_in(video_state_in),.video_state_set(video_state_set),.x(x),.y(y),.vcounter_cpu(),.hsync(),.vsync(),.hblank(hb),.vblank(vb));
video videoref(.clk(clk),.ce_pix(ce_pix&&!holdref),.pal(1'b0),.border(1'b0),.ggres(1'b0),.mask_column(1'b0),.cut_mask(1'b0),.smode_M1(1'b0),.smode_M2(1'b0),.smode_M3(1'b0),.smode_M4(1'b1),.video_state_out(rvideo),.video_state_in(22'd0),.video_state_set(1'b0),.x(rx),.y(ry),.vcounter_cpu(),.hsync(),.vsync(),.hblank(rhb),.vblank(rvb));
wire[15:0]ca,ra;wire[7:0]co,ro;wire cm1,cmreq,rm1,rmreq,ciq,riq,crd,cwr,rrd,rwr;wire[229:0]rr;wire[1:0]riset;
// A increments once per loop. No forced CPU/bus or pause states.
function[7:0]rom(input[15:0]a);case(a)0:rom=8'h3c;1:rom=8'hc3;2:rom=0;3:rom=0;default:rom=0;endcase endfunction
assign z80_m1_n=cm1;assign z80_mreq_n=cmreq;
`;
const entity=fs.readFileSync(path.join(r,'rtl/T80/T80s.vhd'),'utf8').split('end T80s')[0];
for(const ref of [false,true]){const o={reset_n:'reset_n',clk:'clk',cen:ref?'(ce_pix&&!holdref&&!rpaused)':'(ce_pix&&!ss_freeze&&!paused)',wait_n:"1'b1",int_n:"1'b1",nmi_n:"1'b1",busrq_n:"1'b1",m1_n:ref?'rm1':'cm1',mreq_n:ref?'rmreq':'cmreq',iorq_n:ref?'riq':'ciq',rd_n:ref?'rrd':'crd',wr_n:ref?'rwr':'cwr',a:ref?'ra':'ca',di:ref?'rom(ra)':'rom(ca)',do:ref?'ro':'co',reg:ref?'rr':'z80_reg',dirset:ref?"1'b0":'z80_set',dir:ref?"230'd0":'z80_dir',iset_out:ref?'riset':'z80_iset'};
s+='T80s #(.T2Write(0)) '+(ref?'rcpu':'cpu')+'('+[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(std_logic(?:_vector\s*\([^)]*\))?)/gi)].map(m=>'.'+m[1]+'('+(o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':"1'b0"))+')').join(',')+');\n';}
const ve=fs.readFileSync(path.join(r,'rtl/vdp.vhd'),'utf8').split('architecture')[0];
s+='generate if(FULL)begin:fullvdps\n';
for(const i of [1,2]){const o={clk_sys:'clk',reset_n:'reset_n',ce_vdp:'(ce_vdp&&!ss_freeze)',ce_pix:'(ce_pix&&!ss_freeze)',ce_sp:'(ce_sp&&!ss_freeze)',hl:"1'b0",x:'x',y:'y',rd_n:"1'b1",wr_n:"1'b1",a:"8'h00",ss_regs_out:i===1?'vdp_regs':'vdp2_regs',ss_regs_in:i===1?'vdp_regs_in':'vdp2_regs_in',ss_regs_set:i===1?'vdp_regs_set':'vdp2_regs_set',se_bank:i===1?"1'b0":"1'b1",systeme:"1'b1"};
s+='vdp vdp'+i+'('+[...ve.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)].map(m=>{let range=m[3].match(/\((\d+)\s+downto\s+(\d+)\)/i),w=range?+range[1]-+range[2]+1:1;return '.'+m[1]+'('+(o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':w+"'b0"))+')';}).join(',')+');\n';}
s+='end else begin:lightvdps assign vdp_regs=0;assign vdp2_regs=0;end endgenerate\n';
s+=`wire pq1,pq2;wire[3:0]div2;wire signed[10:0]audio1,audio2;reg pwr=1;reg[7:0]pd=0;
assign audio_quiescent=pq1&&pq2;
jt89 psg1(.clk(clk),.clk_en(ce_pix&&!ss_freeze),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(audio1),.soundR(),.ready(),.ss_out(psg_out),.ss_set(psg_set),.ss_in(psg_in),.ss_ext_out(psg_ext_out),.ss_ext_in(psg_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(psg_div_out),.ss_div_in(psg_div_in),.ss_quiescent(pq1));
jt89 psg2(.clk(clk),.clk_en(ce_pix&&!ss_freeze),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(audio2),.soundR(),.ready(),.ss_out(psg2_out),.ss_set(psg2_set),.ss_in(psg2_in),.ss_ext_out(psg2_ext_out),.ss_ext_in(psg2_ext_in),.ss_ext_set(audio_ext_set),.ss_div_out(div2),.ss_div_in(psg_div_in),.ss_quiescent(pq2));
`;
s=s.replaceAll('.clk_en(ce_pix&&!ss_freeze)','.clk_en(ce_cpu&&!ss_freeze&&!paused)');
s+=`wire[95:0]rpsgext;wire[55:0]rpsgcfg;wire[3:0]rpsgdiv;wire signed[10:0]raudio;
jt89 rpsg(.clk(clk),.clk_en(ce_cpu&&!holdref&&!rpaused),.rst(!reset_n),.wr_n(pwr),.din(pd),.mux(8'hff),.soundL(raudio),.soundR(),.ready(),.ss_out(rpsgcfg),.ss_set(1'b0),.ss_in(56'd0),.ss_ext_out(rpsgext),.ss_ext_in(96'd0),.ss_ext_set(1'b0),.ss_div_out(rpsgdiv),.ss_div_in(4'd0),.ss_quiescent());\n`;
s+=fs.readFileSync(path.join(d,'scenario.sv.in'),'utf8');fs.writeFileSync(path.join(d,'pause_tb.sv'),s);
fs.writeFileSync(path.join(d,'run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib pause_work
vcom -work pause_work -2008 -quiet ../../rtl/video.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd ../../rtl/dpram.vhd ../../rtl/vdp_cram.vhd ../../rtl/vdp_background.vhd ../../rtl/vdp_sprite_shifter.vhd ../../rtl/vdp_sprites.vhd ../../rtl/vdp_main.vhd ../../rtl/vdp.vhd
vlog -work pause_work -suppress 2388 -quiet ../../rtl/jt89/jt89_vol.v ../../rtl/jt89/jt89_tone.v ../../rtl/jt89/jt89_noise.v ../../rtl/jt89/jt89_mixer.v ../../rtl/jt89/jt89.v
vlog -work pause_work -sv -quiet savestates_sim.sv pause_fixture.sv pause_tb.sv
vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gCASE=$env(PAUSE_CASE) -gKEEP=$env(PAUSE_KEEP) -gFULL=$env(PAUSE_FULL)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);

