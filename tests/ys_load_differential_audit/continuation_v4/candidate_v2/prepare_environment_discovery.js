const fs=require('fs'),assert=require('assert');
let s=fs.readFileSync('ys_warm_tb.sv','utf8').replace('module ys_warm_tb;','module ys_environment_tb;');
const start=s.indexOf(" joy_n=6'b111111;\n if(ACTION<0)"),end=s.indexOf('\nend\ninitial begin #(64\'d20000000000)');assert(start>0&&end>start);
s=s.slice(0,start)+`
 joy_n=6'b111111;stage=10;
 for(integer n=0;n<32768;n++)saved_sram[n]=sram[n];
 begin: environment_movie
  integer elapsed,diff,bright;bit changed;
  elapsed=0;changed=0;
  while(elapsed<232)begin
   joy_n=6'b111111;if(!changed&&elapsed<112)joy_n[0]=0;
   wait_frames(8);elapsed+=8;
   diff=0;for(integer n='h400;n<'h800;n++)if(sram[n]!==saved_sram[n])diff++;
   if(diff)changed=1;
   image($sformatf("up%0d",elapsed));checkpoint($sformatf("up%0d",elapsed));
   bright=0;for(integer n=0;n<40960;n++)if(pixels[n]!==0)bright++;
   $display("ENV_PROGRESS elapsed=%0d cache_differences=%0d display=%b bright_map_pixels=%0d",elapsed,diff,vdp_regs[7],bright);
   if(changed&&vdp_regs[7]&&bright>4096)begin
    joy_n=6'b111111;wait_frames(8);
    diff=0;for(integer n='h400;n<'h800;n++)if(sram[n]!==saved_sram[n])diff++;
    bright=0;for(integer n=0;n<40960;n++)if(pixels[n]!==0)bright++;
    if(diff&&vdp_regs[7]&&bright>4096)begin
     image("new_environment");checkpoint("new_environment");
     $display("ENVIRONMENT_WITNESS elapsed=%0d plus8neutral cache_differences=%0d; visual qualification still required",elapsed,diff);
     $fclose(trace_fd);$finish;
    end
   end
   if(elapsed>=144&&!changed)begin $display("INCONCLUSIVE north-gate movie did not change cache; no causal LOAD experiment attempted");$fclose(trace_fd);$finish;end
  end
  $display("INCONCLUSIVE environment transition did not settle within bounded movie");$fclose(trace_fd);$finish;
 end
`+s.slice(end);
fs.writeFileSync('ys_environment_tb.sv',s);
fs.writeFileSync('environment_discovery.do',`onerror {quit -code 1}
vlog -sv -quiet ys_environment_tb.sv
vsim -c -wlf environment.wlf -t 1ps work.ys_environment_tb -gSEED_IMPORT=1 -gCANDIDATE=0 +ROM=$env(YS_ROM) +OUT=environment +SEED_SLOT=$env(YS_SLOT) +SEED_SRAM=$env(YS_SRAM)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
