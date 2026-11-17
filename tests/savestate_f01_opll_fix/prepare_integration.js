const fs=require('fs'),p=require('path'),d=__dirname,root=p.resolve(d,'../..'),src=p.join(d,'../savestate_f01_opll_architecture');
for(const f of ['pause_fixture.sv','rom.hex','T80_sim.vhd','T80s_sim.vhd'])fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.writeFileSync(p.join(d,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')));
let s=fs.readFileSync(p.join(src,'audio_tb.sv'),'utf8');
s=s.replace('parameter FMCASE=0,','parameter FM_SUPPRESS=0,CONVERGE=0,FMCASE=0,');
s=s.replaceAll("{fmout[12:0],3'b0}","(FM_SUPPRESS?16'd0:{fmout[12:0],3'b0})").replaceAll("{rfmout[12:0],3'b0}","(FM_SUPPRESS?16'd0:{rfmout[12:0],3'b0})");
s=s.replace("repeat(50000)tick; fmwrite(8'h10,8'h91);", "repeat(50000)tick; fmwrite(8'h10,8'h91); if(CONVERGE)begin fmwrite(8'h20,8'h09);fmwrite(8'h20,8'h19);repeat(6000)tick;end");
const wires=`wire[7:0]fm_state_addr;wire fm_state_read,fm_state_write,fm_initialized,fm_legacy_reset,fm_initialization_run;wire[31:0]fm_state_wdata,fm_state_rdata,fm_opll_rdata;reg[31:0]fm_wrapper_rdata=0;`;
s=s.replace('wire ss_freeze;',wires+'\nwire ss_freeze;');
s=s.replace(/savestates\s+dut\s*\(/,`savestates dut (
 .fm_state_addr(fm_state_addr),.fm_state_read(fm_state_read),.fm_state_write(fm_state_write),
 .fm_state_wdata(fm_state_wdata),.fm_state_rdata(fm_state_rdata),.fm_initialized(fm_initialized),
 .fm_legacy_reset(fm_legacy_reset),.fm_initialization_run(fm_initialization_run),`);
if(!s.includes('.fm_initialized(fm_initialized)'))throw Error('controller instance');
s=s.replace('if(!reset_n)begin fm_a<=0;', 'if(!reset_n||fm_legacy_reset)begin fm_a<=0;');
s=s.replace('else begin if(!ss_freeze&&fwr)',`else begin if(ss_freeze&&fm_state_write&&fm_state_addr==8'h4c)begin fm_a<=fm_state_wdata[0];fm_d<=fm_state_wdata[8:1];end else if(!ss_freeze&&fwr)`);
s=s.replace('opll fm(.xin',`assign fm_state_rdata=fm_opll_rdata|fm_wrapper_rdata;
always@(posedge clk)begin fm_wrapper_rdata<=0;if(ss_freeze&&fm_state_read&&fm_state_addr==8'h4c)fm_wrapper_rdata<={23'd0,fm_d,fm_a};end
opll fm(.ss_hold(ss_freeze&&!fm_initialization_run),.ss_addr(fm_state_addr),.ss_read(fm_state_read),.ss_write(fm_state_write),.ss_wdata(fm_state_wdata),.ss_rdata(fm_opll_rdata),.ss_initialized(fm_initialized),.xin`);
s=s.replace('.ic_n(reset_n),.mixout(fmout)', '.ic_n(reset_n&&!fm_legacy_reset),.mixout(fmout)');
s=s.replace(/opll rfm\([^;]+;/,m=>`generate if(REF)begin ${m} end else begin assign rfmout=14'd0;end endgenerate`);
s=s.replace('if(raw_errors)$fatal', 'if(fmerrors)$fatal(1,"F01 raw FM suffix mismatch");\nif(raw_errors)$fatal');
s=s.replace('if(fmerrors)$fatal', 'if(FM_SUPPRESS&&errors)$fatal(1,"G08.release isolation mismatch");\nif(fmerrors)$fatal');
s=s.replace('PASS CHARACTERIZED FMCASE','PASS F01 FMCASE');
fs.writeFileSync(p.join(d,'audio_tb.sv'),s);
let compile=fs.readFileSync(p.join(src,'compile.do'),'utf8').replace('savestates_sim.sv pause_fixture.sv audio_tb.sv','../../rtl/opll_snapshot.sv savestates_sim.sv pause_fixture.sv audio_tb.sv').replaceAll('work_fast','work_v17');
fs.writeFileSync(p.join(d,'compile.do'),compile);
fs.writeFileSync(p.join(d,'run.do'),fs.readFileSync(p.join(src,'run.do'),'utf8').replaceAll('work_fast','work_v17'));
fs.appendFileSync(p.join(d,'.gitignore'),'original_work/\nwork_fast/\nmemory_gate/db/\nmemory_gate/incremental_db/\nmemory_gate/output_files/\n');
