const fs=require('fs'),assert=require('assert');
let s=fs.readFileSync('ys_warm_tb.sv','utf8').replace('module ys_warm_tb;','module ys_reset_tb;');
const anchor='task wait_frames(input integer n);';assert(s.includes(anchor));
s=s.replace(anchor,`// Pinned master SMS.sv: raw_reset starts ram_clr_run; CPU/controller reset
// remains active until all16384 physical WRAM addresses have been cleared.
task native_reset;begin
 reset_n=0;$display("RESET_BEGIN cycle=%0d raw_hold=128 WRAM_clear_clocks=16384",cycles);
 ticks(128);
 for(integer n=0;n<16384;n++)begin
  @(posedge clk);if(n<8192)wram[n]<=8'd0;@(negedge clk);
 end
 for(integer n=0;n<8192;n++)if(wram[n]!==0)$fatal(1,"WRAM reset clear failed");
 reset_n=1;$display("RESET_RELEASE cycle=%0d visible_WRAM_zero=8192",cycles);
end endtask
${anchor}`);
assert(s.includes('reset_n=0;ticks(128);reset_n=1;wait_frames(8); // Native RAM retains contents across reset.'));
s=s.replace('reset_n=0;ticks(128);reset_n=1;wait_frames(8); // Native RAM retains contents across reset.',
            'native_reset;wait_frames(8);');
s=s.replace('for(integer step=0;step<4;step++)begin wait_frames(MOTION_STEP);','for(integer step=0;step<2;step++)begin wait_frames(MOTION_STEP);');
s=s.replace('for(integer step=0;step<8;step++)begin wait_frames(MOTION_STEP);','for(integer step=0;step<32;step++)begin wait_frames(MOTION_STEP);');
fs.writeFileSync('ys_reset_tb.sv',s);
fs.writeFileSync('compile_reset.do',`onerror {quit -code 1}\nvlog -sv -quiet ys_reset_tb.sv\nquit -code 0\n`);
let run=fs.readFileSync('warm.do','utf8').replace('work.ys_warm_tb','work.ys_reset_tb').replace('vsim -c -t','vsim -c -wlf $env(YS_OUT).wlf -t');
fs.writeFileSync('reset.do',run);
let runner=fs.readFileSync('run_map_variants.js','utf8');
runner=runner.replace("const plans=[", "const plans=[").replace("const rom=JSON.parse", "for(const q of plans)q.name='r_'+q.name;\nconst rom=JSON.parse");
runner=runner.replaceAll("'map_run_status.json'","'reset_run_status.json'").replace('active<3','active<5').replace("'-do','warm.do'","'-do','reset.do'");
fs.writeFileSync('run_reset_variants.js',runner);
console.log('Prepared exact reset clear and left8/right128-frame movie; all outputs use r_ prefix.');
