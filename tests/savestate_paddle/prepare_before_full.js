const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'integration_tb.sv'),'utf8').replace('module paddle_integration','module before_full');
s=s.replace(/\.paddle_(out|in|set|valid)\(paddle_(out|in|set|valid)\),?/g,'').replaceAll('dut.paddle_snap','refstate').replace('k<(ONLY>=22?25:22)','k<3');
s=s.replace(/if\(k==20&&saved\[18\][\s\S]*?\/\/ The reference remains held/,'// The reference remains held');
const a=s.indexOf('if(exact)begin\ncheck;'),b=s.indexOf('$display("PASS Paddle DDR case',a);
s=s.slice(0,a)+`addr=8'hdc;rd=0;repeat(3)tick;rd=1;
if(guest===refguest)$fatal(1,"expected baseline observable divergence k%0d",k);
$display("CONFIRMED F10 full DDR k%0d saved%h live%h ref%h guest%h/%h saveClocks%0d loadClocks%0d",k,saved,paddle_out,refstate,guest,refguest,saveclocks,loadclocks);
`+s.slice(b);
s=s.replace('PASS Paddle DDRAM COMPLETE','PASS PRE-FIX F10 full DDRAM COMPLETE');
fs.writeFileSync(path.join(d,'before_full.sv'),s);
let rtl=fs.readFileSync(path.join(d,'baseline/rtl/savestates.sv'),'utf8');
for(const n of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=rtl.match(re)[0];rtl=rtl.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
fs.writeFileSync(path.join(d,'before_savestates_sim.sv'),rtl);
s=fs.readFileSync(path.join(d,'routed0.do'),'utf8').replaceAll('routed0_work','before_full_work').replace('savestates_sim.sv paddle_fixture.sv routing_fixture.sv integration_tb.sv','before_savestates_sim.sv before_fixture.sv routing_fixture.sv before_full.sv').replace('before_full_work.paddle_integration','before_full_work.before_full');
fs.writeFileSync(path.join(d,'before_full.do'),s);
