const fs=require('fs'),p=require('path'),assert=require('assert');const d=__dirname,out=p.join(d,'candidate_v2');
let s=fs.readFileSync(p.join(d,'discovery_source.sv'),'utf8');
function change(a,b){assert(s.includes(a),'missing anchor '+a.slice(0,60));s=s.replace(a,b);}
change('module ys_full_tb;','module ys_map_tb;');
change('parameter CANDIDATE=0,BOOT_FRAMES=200,STOP_FRAME=240,ACTION=-1,CYCLE_LIMIT=0,MOTION_STEP=30;',
`parameter CANDIDATE=0,BOOT_FRAMES=150,STOP_FRAME=240,ACTION=1,CYCLE_LIMIT=0,MOTION_STEP=4;
parameter SEED_EXPORT=0,SEED_IMPORT=0,SHAM_SRAM=0,REFERENCE=0;
integer stage=0;
wire full_sram_allowed=1'b1; // This fixture is ordinary Sega SRAM, not SC/SystemE/EEPROM.
reg[31:0] game_id=32'h811c9dc5;
string seed_slot_path,seed_sram_path;`);
change('if(ss_nvram_WE)begin sram[ss_nvram_WA]<=ss_nvram_WD;sram_q<=ss_nvram_WD;end',
`if(ss_nvram_WE)begin
   if(!(SHAM_SRAM&&stage==3))begin sram[ss_nvram_WA]<=ss_nvram_WD;sram_q<=ss_nvram_WD;end
  end`);
change('integer frame=0,stage=0,trace_fd,cpu_events=0,vram_events=0,io_events=0,unknown_writes=0;',
`integer frame=0,trace_fd,cpu_events=0,vram_events=0,io_events=0,unknown_writes=0;
integer nv_events=0,wr_events=0,dma_sram_bytes=0,save_sram_words=0,load_sram_words=0;
reg previous_rd=1;
wire cpu_sram_selected=(addr[15:14]==2&&nv_e)||(addr[15:14]==3&&nv_ex)||(addr[15:13]==5&&nv_cme);`);
change('if(tracing&&cpu_ce_live&&cpu_events<20000)begin',
       'if(tracing&&cpu_ce_live&&(cpu_events<20000||(mc==1&&(ts==1||ts==2))))begin');
change(' prev_wr<=wr_n;',` if(tracing&&cpu_ce_live&&!mreq_n&&cpu_sram_selected&&(!rd_n||!wr_n))begin
  $fdisplay(trace_fd,"N %0d %h %h %h %h %h %h %h %b%b %h",cycles-release_cycle,cpu_regs[79:64],addr,nv_addr,cpu_di,cpu_do,mc,ts,rd_n,wr_n,mapper_word);nv_events++;
 end
 if(tracing&&wram_wr&&prev_wr)begin
  $fdisplay(trace_fd,"W %0d %h %h %h",cycles-release_cycle,cpu_regs[79:64],addr,cpu_do);wr_events++;
 end
 if(ss_nvram_WE)dma_sram_bytes++;
 if(ss_DDRAM_WE&&ss_DDRAM_ADDR>=29'h7c00d01&&ss_DDRAM_ADDR<=29'h7c01d00)save_sram_words++;
 if(ss_DDRAM_RD&&ss_DDRAM_ADDR>=29'h7c00d01&&ss_DDRAM_ADDR<=29'h7c01d00)load_sram_words++;
 prev_wr<=wr_n;previous_rd<=rd_n;`);
change('$display("LOAD_CHECK VRAM_vs_slot=%0d WRAM_vs_slot=%0d SRAM_vs_saved_complete=%0d",vd,wd,sd);',
       '$display("LOAD_CHECK VRAM_vs_slot=%0d WRAM_vs_slot=%0d SRAM_vs_saved_complete=%0d DMA_SRAM_WE=%0d SAVE_SRAM_WORDS=%0d LOAD_SRAM_WORDS=%0d metadata=%h",vd,wd,sd,dma_sram_bytes,save_sram_words,load_sram_words,ddr[5]);');
change('trace_fd=$fopen({out_prefix,"_events.log"},"w");',`for(integer n=0;n<262144;n++)game_id={game_id[30:0],game_id[31]} ^ {24'd0,cart[n]} ^ {29'd0,n[0],n[8],n[16]};
 if(game_id!==32'ha458e3d4)$fatal(1,"this qualified fixture requires the standard ROM");
 trace_fd=$fopen({out_prefix,"_events.log"},"w");`);
change(' // Deterministic discovery movie: short button-1 presses, neutral between presses.',
` if(SEED_IMPORT)begin
  if(!$value$plusargs("SEED_SLOT=%s",seed_slot_path)||!$value$plusargs("SEED_SRAM=%s",seed_sram_path))$fatal(1,"seed paths required");
  $readmemh(seed_slot_path,ddr);
  if(ddr[1][63:32]!==game_id||ddr[5][63:38]!==0)$fatal(1,"seed ownership/legacy context mismatch");
  stage=-1;
  @(negedge clk);load_req=1;@(negedge clk);load_req=0;
  wait(ss_ss_freeze);
  // Explicit initial fixture memory, NOT an interpretation of the unmarked slot tail.
  $readmemh(seed_sram_path,sram);
  wait(!ss_ss_freeze);ticks(1);wait_frames(5);
  checkpoint("qualified_start");image("qualified_start");stage=0;
 end
 // Deterministic discovery movie: short button-1 presses, neutral between presses.`);
change('while(frame<BOOT_FRAMES)begin','while(!SEED_IMPORT&&frame<BOOT_FRAMES)begin');
change('stage=1;operation(1);checkpoint("saved");image("saved");',
`stage=1;save_sram_words=0;load_sram_words=0;dma_sram_bytes=0;
 operation(1);checkpoint("saved");image("saved");
 $display("SAVE_METADATA word5=%h mapper=%h payload_words=%0d context=%0d",ddr[5],ddr[15],save_sram_words,controller.restart_snap);
 if(SEED_EXPORT)begin
  if(CANDIDATE!=0||controller.restart_snap!=0||!vdp_regs[7])$fatal(1,"seed requires legacy ordinary-context displayed scene");
  $writememh({out_prefix,"_slot.hex"},ddr);
  $writememh({out_prefix,"_sram.hex"},sram);
  $display("SEED_READY actual master controller slot plus explicitly separate complete physical SRAM fixture; not an expanded savestate");
  if(!REFERENCE)begin $fclose(trace_fd);$finish;end
 end
 if(REFERENCE)begin
  release_cycle=cycles;tracing=1;stage=4;
 end`);
change(' stage=2;\n if(ACTION==1)begin', ' if(!REFERENCE)begin\n stage=2;\n if(ACTION==1)begin');
change("reset_n=0;for(integer n=0;n<8192;n++)wram[n]=0;ticks(128);reset_n=1;wait_frames(8);",
       'reset_n=0;ticks(128);reset_n=1;wait_frames(8); // Native RAM retains contents across reset.');
change('check_load;checkpoint("loaded");image("loaded");',
       'check_load;checkpoint("loaded");image("loaded");\n end');
fs.writeFileSync(p.join(out,'ys_map_tb.sv'),s);
let inc=fs.readFileSync(p.join(out,'controller.svh'),'utf8');
inc=inc.replace("assign ss_ss_game_id=32'hf1e2d3c4;",'assign ss_ss_game_id=game_id;');
// Protocol fixture uses its own constant game_id alias, so both fixtures share this include.
fs.writeFileSync(p.join(out,'map_controller.svh'),inc);
s=s.replace('`include "controller.svh"','`include "map_controller.svh"');fs.writeFileSync(p.join(out,'ys_map_tb.sv'),s);
let compile=fs.readFileSync(p.join(d,'compile.do'),'utf8').replace('ys_full_tb.sv','ys_map_tb.sv');fs.writeFileSync(p.join(out,'compile_map.do'),compile);
fs.writeFileSync(p.join(out,'seed.do'),`onerror {quit -code 1}
vsim -c -t 1ps work.ys_map_tb -gCANDIDATE=0 -gSEED_EXPORT=1 -gREFERENCE=1 -gBOOT_FRAMES=150 +ROM=$env(YS_ROM) +OUT=seed
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
console.log('Prepared native cold seed export and explicitly separate shared fixture bootstrap.');
