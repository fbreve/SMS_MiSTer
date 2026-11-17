const fs=require('fs'),assert=require('assert');
let s=fs.readFileSync('ys_reset_tb.sv','utf8').replace('module ys_reset_tb;','module ys_environment_load_tb;');
const old="joy_n[3]=0;wait_frames(180);joy_n=6'b111111;wait_frames(40);";
assert(s.includes(old));
s=s.replace(old,`// Qualified natural history: through the north gate, then settle outdoors.
  joy_n[0]=0;wait_frames(112);joy_n=6'b111111;wait_frames(40);
  begin: qualify_history
   integer changed;
   changed=0;for(integer n='h400;n<'h800;n++)if(sram[n]!==saved_sram[n])changed++;
   $display("ENV_HISTORY cache_differences=%0d display=%b mapper=%h",changed,vdp_regs[7],mapper_word);
   image("changed_environment");checkpoint("changed_environment");
   if(changed==0||!vdp_regs[7])$fatal(1,"environment history did not qualify; no causal LOAD trial");
  end`);
s=s.replace('for(integer step=0;step<32;step++)begin wait_frames(MOTION_STEP);',
            'for(integer step=0;step<20;step++)begin wait_frames(MOTION_STEP);');
const end=' joy_n=6\'b111111;checkpoint("end");';assert(s.includes(end));
s=s.replace(end,` // Additional path clears the tree that blocks the initial rightward movie.
 joy_n=6'b111111;joy_n[1]=0;
 for(integer step=0;step<4;step++)begin wait_frames(MOTION_STEP);image($sformatf("down%0d",(step+1)*MOTION_STEP));checkpoint($sformatf("down%0d",(step+1)*MOTION_STEP));end
 joy_n=6'b111111;joy_n[3]=0;
 for(integer step=0;step<16;step++)begin wait_frames(MOTION_STEP);image($sformatf("clear_right%0d",(step+1)*MOTION_STEP));checkpoint($sformatf("clear_right%0d",(step+1)*MOTION_STEP));end
 joy_n=6'b111111;checkpoint("end");`);
s=s.replace('integer nv_events=0,wr_events=0,', 'integer map_mutations=0;\ninteger nv_events=0,wr_events=0,');
const monitor=' if(ss_nvram_WE)dma_sram_bytes++;';assert(s.includes(monitor));
s=s.replace(monitor,` if(tracing&&vram_we&&!ss_ss_freeze&&vram_wa>=15'h3800&&vram_wa<15'h3d00&&vram_trace[vram_wa]!==vram_wd)map_mutations++;
${monitor}`);
s=s.replace('joy_n=6\'b111111;checkpoint("end");$display(', 'joy_n=6\'b111111;checkpoint("end");$display("MAP_QUALIFICATION effective_map_name_writes=%0d",map_mutations);$display(');
fs.writeFileSync('ys_environment_load_tb.sv',s);
fs.writeFileSync('compile_environment_case.do',`onerror {quit -code 1}\nvlog -sv -quiet ys_environment_load_tb.sv\nquit -code 0\n`);
let run=fs.readFileSync('reset.do','utf8').replace('work.ys_reset_tb','work.ys_environment_load_tb').replace('-gSEED_IMPORT=1','-gSEED_IMPORT=1 -gACTION=0');
fs.writeFileSync('environment_case.do',run);
let runner=fs.readFileSync('run_map_variants.js','utf8');
runner=runner.replace('const rom=JSON.parse',"for(const q of plans)q.name='e_'+q.name;\nconst rom=JSON.parse");
runner=runner.replaceAll("'map_run_status.json'","'environment_run_status.json'").replace('active<3','active<5').replace("'-do','warm.do'","'-do','environment_case.do'");
fs.writeFileSync('run_environment_variants.js',runner);
console.log('Environment-history candidate set prepared; UP112/neutral40 before LOAD, then left8/right80/down16/right64.');
