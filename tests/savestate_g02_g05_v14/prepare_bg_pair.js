// Natural background-history pair: change only a past controller input, select
// legacy versus Mode4 over horizontal reset, then restore the same Mode4 state
// before the accepted blank-row capture. Future input is identical.
const fs=require('fs'),p=require('path'),d=p.join(__dirname,'bg_pair'),src=p.join(__dirname,'rich');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
fs.copyFileSync(p.resolve(__dirname,'../../rtl/vdp_background.vhd'),p.join(d,'rtl/vdp_background.vhd'));
let bg=fs.readFileSync(p.join(d,'rtl/vdp_background.vhd'),'utf8').replace(/port\s*\(/i,'port (\n audit_bg: out std_logic_vector(126 downto 0);').replace(/begin\s*\n/,'begin\n audit_bg <= tile_index & x & tile_y & palette & palette_shift & priority_latch & flip_x & datac & data0 & data1 & data2 & data3 & shift0 & shift1 & shift2 & shift3 & text_shift & text_tile_index & text_pattern & text_phase & text_column;\n');fs.writeFileSync(p.join(d,'rtl/vdp_background.vhd'),bg);
let main=fs.readFileSync(p.join(d,'rtl/vdp_main.vhd'),'utf8').replace(/port\s*\(/i,'port (\n audit_bg: out std_logic_vector(126 downto 0);').replace(/(vdp_bg_inst: entity work\.vdp_background[\s\S]*?port map\s*\()/,'$1\n audit_bg => audit_bg,');fs.writeFileSync(p.join(d,'rtl/vdp_main.vhd'),main);
let top=fs.readFileSync(p.join(d,'rtl/vdp.vhd'),'utf8').replace(/port\s*\(/i,'port (\n audit_bg: out std_logic_vector(126 downto 0);').replace(/(vdp_main_inst: entity work\.vdp_main[\s\S]*?port map\s*\()/,'$1\n audit_bg => audit_bg,');fs.writeFileSync(p.join(d,'rtl/vdp.vhd'),top);
let compile=fs.readFileSync(p.join(d,'compile.do'),'utf8').replace('../../../rtl/vdp_background.vhd','rtl/vdp_background.vhd');fs.writeFileSync(p.join(d,'compile.do'),compile);
let h=fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('ON_IO=0;','ON_IO=0,HISTORY=0;');fs.writeFileSync(p.join(d,'header.svh'),h);
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8').replace('next_frame=frame;','next_frame=frame+1;');
s=s.replace('reg hl=0;','reg hl=0;reg history_done=0;wire[126:0]bg_state;');
s=s.replace('.audit(audit),','.audit(audit),.audit_bg(bg_state),');
s=s.replace('.DI(!ciq?vd:',".DI(!ciq?(ca[7:0]==8'hdc ? ((!history_done&&HISTORY&&y==191&&x>=350)?8'd0:8'd4):vd):");
s=s.replace('$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);','$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);history_done=1;');
s=s.replace('ARM x%0d y%0d regs%h probe%h",x,y,vdp_regs,probe','ARM x%0d y%0d regs%h probe%h BG%h",x,y,vdp_regs,probe,bg_state');
s=s.replace('if(accepted_y!=REQUEST_Y)', 'if($isunknown(bg_state))$fatal(1,"unknown background history");\n if(accepted_y!=REQUEST_Y)');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
let rom=fs.readFileSync(p.join(__dirname,'fixture/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));const loop=0x8b,code=[0xdb,0xdc,0xd3,0xbf,0x3e,0x80,0xd3,0xbf,0xc3,loop&255,loop>>8];for(let i=0;i<code.length;i++)rom[loop+i]=code[i];
for(const hist of[0,1])for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+'h'+hist);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=64 -gGG=0 -gREQUEST_Y=192 -gREQUEST_X=120 -gWARMUP=1 -gEXT_REFERENCE=1 -gHISTORY=${hist} -gREFERENCE=${ref} -gSPRITES=0 -gSAMPLES=42000 -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('127-bit observed natural background-history pair prepared');
