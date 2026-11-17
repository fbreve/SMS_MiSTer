const fs=require('fs'),p=require('path'),assert=require('assert');const d=p.join(__dirname,'candidate_v2');
let probe=fs.readFileSync(p.join(d,'vdp.vhd'),'utf8');
probe=probe.replace(/entity vdp is/i,'entity vdp_probe is').replace(/end vdp;/i,'end vdp_probe;').replace(/architecture Behavioral of vdp is/i,'architecture Behavioral of vdp_probe is');
assert(/entity vdp_probe is/i.test(probe)&&/of vdp_probe is/i.test(probe),'VDP entity anchors');
probe=probe.replace('TestWE : out std_logic;', 'TestCPUState : out std_logic_vector(35 downto 0); TestWE : out std_logic;');
probe=probe.replace('TestWE<=vram_portA_wren;', 'TestCPUState <= xram_cpu_A_incr & xram_cpu_read & address_ff & old_WR_n & old_RD_n & data_write & cpu_write_data & vram_cpu_D_outl & xram_cpu_A;\n TestWE<=vram_portA_wren;');
fs.writeFileSync(p.join(d,'vdp_probe.vhd'),probe);
let s=fs.readFileSync(p.join(d,'ys_map_tb.sv'),'utf8').replace('module ys_map_tb;','module ys_warm_tb;');
function change(a,b){assert(s.includes(a),'missing '+a.slice(0,60));s=s.replace(a,b);}
change('wire vram_we;', 'wire[35:0] cpu_vdp_probe; reg[35:0] previous_vdp_probe=0; reg[63:0] previous_mapper=0;\nwire vram_we;');
change('vdp #(.MAX_SPPL(7))','vdp_probe #(.MAX_SPPL(7))');
change('.TestWE(vram_we)', '.TestCPUState(cpu_vdp_probe),.TestWE(vram_we)');
change(' prev_wr<=wr_n;previous_rd<=rd_n;',` if(tracing&&cpu_vdp_probe!==previous_vdp_probe)$fdisplay(trace_fd,"T %0d %h",cycles-release_cycle,cpu_vdp_probe);
 if(tracing&&mapper_word!==previous_mapper)$fdisplay(trace_fd,"M %0d %h %h",cycles-release_cycle,mapper_word,cpu_regs[79:64]);
 previous_mapper<=mapper_word;previous_vdp_probe<=cpu_vdp_probe;
 prev_wr<=wr_n;previous_rd<=rd_n;`);
change('task operation(input bit saving);begin',`task operation(input bit saving);begin
 wait(controller.state==0 && controller.op_cooldown==0);
 $display("OP_READY saving=%b cycle=%0d frame=%0d",saving,cycles,frame);`);
change('$display("SAVE_METADATA word5=%h mapper=%h payload_words=%0d context=%0d",ddr[5],ddr[15],save_sram_words,controller.restart_snap);',
`$display("SAVE_METADATA word5=%h mapper=%h payload_words=%0d context=%0d",ddr[5],ddr[15],save_sram_words,controller.restart_snap);
 $writememh({out_prefix,"_saved_slot.hex"},ddr);`);
change('PC=%h IR=%h CTX=%h MAP=%h",stage,controller.do_save,cycles,frame,x,y,addr,ir,restart_ctx,mapper_word);',
       'PC=%h IR=%h CTX=%h MAP=%h MC=%h TS=%h",stage,controller.do_save,cycles,frame,x,y,addr,ir,restart_ctx,mapper_word,mc,ts);');
change('stage=4;wait_frames(5);joy_n[2]=0;',
       'stage=4;wait_frames(1);checkpoint("first_frame");image("first_frame");wait_frames(4);checkpoint("neutral5");image("neutral5");joy_n[2]=0;');
change('MAP=%h VDP=%h CPU=%h",label,cycles,frame,hv,hw,hs,mapper_word,vdp_regs,cpu_regs);',
       'MAP=%h VDP=%h CPU=%h CRAM=%h IO=%h VIDEO=%h PROBE=%h",label,cycles,frame,hv,hw,hs,mapper_word,vdp_regs,cpu_regs,cram,io_word,video_word,cpu_vdp_probe);');
fs.writeFileSync(p.join(d,'ys_warm_tb.sv'),s);
fs.writeFileSync(p.join(d,'compile_warm.do'),`onerror {quit -code 1}\nvcom -2008 -quiet vdp_probe.vhd\nvlog -sv -quiet ys_warm_tb.sv\nquit -code 0\n`);
fs.writeFileSync(p.join(d,'warm.do'),`onerror {quit -code 1}
vsim -c -t 1ps work.ys_warm_tb -gSEED_IMPORT=1 -gCANDIDATE=$env(YS_CANDIDATE) -gREFERENCE=$env(YS_REFERENCE) -gSHAM_SRAM=$env(YS_SHAM) -gMOTION_STEP=4 +ROM=$env(YS_ROM) +OUT=$env(YS_OUT) +SEED_SLOT=$env(YS_SLOT) +SEED_SRAM=$env(YS_SRAM)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
console.log('Warm fixture retains production cooldown and reset RAM contents; own independently saved slot exported.');
