const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),src=p.join(root,'tests/savestate_g12_sdram');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
if(cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim())throw Error('Pre-edit proof requires unchanged production');
const files=cp.execFileSync('git',['ls-files'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/).filter(f=>fs.statSync(p.join(root,f)).isFile());
fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),files:Object.fromEntries(files.map(f=>[f,sha(fs.readFileSync(p.join(root,f)))]))},null,2));
for(const kind of ['baseline','prototype']){
 const dst=p.join(d,kind);fs.mkdirSync(dst,{recursive:true});
 for(const f of ['audio_tb.sv','pin_model.sv','sdram.v','savestates_sim.sv','mapper_ctrl_sim.vhd','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','jt89.v','rom.hex','compile.do'])fs.copyFileSync(p.join(src,'running',f),p.join(dst,f));
 let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
 s=s.replace('parameter TAIL_DELAY=0,','parameter SAVED_PAUSED=1,CURRENT_PAUSED=0,TAIL_DELAY=0,');
 s=s.replace('while(!(vb&&x==200))tick;button;wait(paused);repeat(64)tick;','if(SAVED_PAUSED)begin while(!(vb&&x==200))tick;button;wait(paused);repeat(64)tick;end');
 s=s.replace("if(mem['h2f][3]!==0)$fatal(1,\"not a suppressed-T capture\");","if(mem['h2f][3]!==!SAVED_PAUSED)$fatal(1,\"wrong capture consumption\");");
 s=s.replace('button;wait(!paused);repeat(2000)tick;','if(SAVED_PAUSED)begin button;wait(!paused);end repeat(2000)tick;\n if(CURRENT_PAUSED)begin button;wait(paused);repeat(64)tick;end');
 s=s.replace('repeat(1000)tick;\n if(wrong_fetches', 'if(CURRENT_PAUSED)begin repeat(100)tick;button;wait(!paused);end\n repeat(1000)tick;\n if(wrong_fetches');
 // Gate consumers by the actual architectural enable; raw CPU cadence continues in Pause.
 s=s.replace('if(load_started&&!ss_freeze&&cpu_ce)begin','if(load_started&&!ss_freeze&&cpu_ce&&!paused)begin');
 s=s.replace('phase%0d A%h rd%b q%0d', 'phase%0d A%h rd%b q%0d');
 s=s.replace(/\nendmodule\s*$/,`\nalways@(posedge clk)if(cpu_prepare||audio_phase_set||(load_started&&!ss_freeze&&cycle%2==0))$display("G12_CAUSAL cycle%0d paused%b MC%0d TS%0d PC%h A%h MREQ%b RD%b romRD%b q%0d pending%b ready%b raw%h freeze%b state%0d replay%b",cycle,paused,cpu.MCycle,cpu.TState,z80_reg[79:64],ca,cmreq,crd,rd,live.q,live.ram_req,ready,sd,ss_freeze,dut.state,replay);\nendmodule\n`);
 // integration.svh was inlined by the original generator. Change only the DUT reference clock.
 if(kind==='prototype'){
  const before='sdram live(',start=s.indexOf(before),end=s.indexOf('\n',start);
  const line=s.slice(start,end);if(!line.includes('.clkref(cpu_ce)'))throw Error('DUT reference not found');
  s=s.slice(0,start)+line.replace('.clkref(cpu_ce)','.clkref(cpu_prepare ? ce_cpu : cpu_ce)')+s.slice(end);
 }
 fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
}
console.log('Prepared independent baseline and clock-coupled prototype; production unchanged.');
