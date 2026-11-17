const fs=require('fs'),path=require('path'),d=__dirname;
let generator=fs.readFileSync(path.join(d,'baseline/prepare.js'),'utf8').replace("path.join(d,'scenario.sv.in')","path.join(d,'fixed_scenario.sv.in')");
generator=generator.replace("path.join(r,'tests/savestate_hcounter/controller_tb.sv')","path.join(d,'baseline/controller_tb.sv')");
generator=generator.replace("sms.indexOf('always @(posedge clk_sys) begin\\n\\tjoy8_r')","sms.lastIndexOf('always @(posedge clk_sys) begin',sms.indexOf('joy8_r   <='))");
new Function('require','__dirname',generator)(require,d);
let s=fs.readFileSync(path.join(d,'pause_tb.sv'),'utf8');
s=s.replace('CASE=0,KEEP=0,FULL=0','CASE=0,KEEP=0,FULL=0,STALL=0,OFFSET=0,DELAY=6');
s=s.replace('wire ss_freeze;','wire ss_freeze;wire ss_capture_progress;');
s=s.replace('.ss_freeze(ss_freeze),','.ss_freeze(ss_freeze),.ss_capture_progress(ss_capture_progress),');
s=s.replace("joy,rvb,1'b0,1'b0,rpaused","joy,rvb,ss_freeze,1'b0,rpaused");
s=s.replace('.CEN((ce_pix&&!ss_freeze&&!paused))','.CEN((ce_pix&&!ss_freeze&&(!paused||ss_capture_progress)))');
s=s.replaceAll('.clk_en(ce_cpu&&!ss_freeze&&!paused)','.clk_en(ce_cpu&&!ss_freeze&&(!paused||ss_capture_progress))');
s=s.replace('.CEN((ce_pix&&!holdref&&!rpaused))','.CEN((ce_pix&&!holdref&&(!rpaused||ref_progress)))');
s=s.replace('.clk_en(ce_cpu&&!holdref&&!rpaused)','.clk_en(ce_cpu&&!holdref&&(!rpaused||ref_progress))');
s=s.replace('wire[1:0]riset;',`wire[1:0]riset;reg ref_request=0;
wire ref_progress=systeme&&ref_request&&!holdref&&!storage_busy&&rvb&&rx<256&&(rm1||rmreq||riset!=0);
always@(posedge clk)begin
 if(!reset_n)ref_request<=0;
 else if(ss_save||ss_load)ref_request<=1;
 else if(dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&!storage_busy)ref_request<=0;
end
reg[15:0]stall_rng=16'h1ace;
always@(negedge clk)begin #0.001;
 stall_rng={stall_rng[14:0],stall_rng[15]^stall_rng[13]^stall_rng[12]^stall_rng[10]};
 DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?stall_rng[3:0]<12:STALL==3?cycle%2048<2020:0);
end
`);
s=s.replace('module pause_tb;', 'module pause_tb;wire[135:0]refvdp_regs,refvdp2_regs;');
for(const i of [1,2]){
 const m=s.match(new RegExp('vdp vdp'+i+'\\([^;]+;'));
 let ref=m[0].replace('vdp vdp'+i,'vdp refvdp'+i).replaceAll('!ss_freeze','!holdref').replace('.x(x)','.x(rx)').replace('.y(y)','.y(ry)');
 const base=i===1?'vdp':'vdp2',out=i===1?'refvdp_regs':'refvdp2_regs';
 ref=ref.replace('.ss_regs_out('+base+'_regs)','.ss_regs_out('+out+')').replace('.ss_regs_in('+base+'_regs_in)',".ss_regs_in(136'd0)").replace('.ss_regs_set('+base+'_regs_set)',".ss_regs_set(1'b0)");
 s=s.replace(m[0],m[0]+'\n'+ref);
}
fs.writeFileSync(path.join(d,'fixed_tb.sv'),s);
let run=fs.readFileSync(path.join(d,'run.do'),'utf8').replace('pause_tb.sv','fixed_tb.sv');
run=run.replace('-gFULL=$env(PAUSE_FULL)','-gFULL=$env(PAUSE_FULL) -gSTALL=$env(PAUSE_STALL) -gOFFSET=$env(PAUSE_OFFSET) -gDELAY=$env(PAUSE_DELAY)');
fs.writeFileSync(path.join(d,'fixed.do'),run);
