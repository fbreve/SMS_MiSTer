const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const dst=p.join(d,'miter');fs.mkdirSync(dst,{recursive:true});
const source=fs.readFileSync(p.join(root,'rtl/savestates.sv'),'utf8').replace(/\/\*[\s\S]*?\*\//g,'').replace(/\/\/[^\n]*/g,'');
const a=source.indexOf('module savestates ('),b=source.indexOf(');',a),ports=[];let dir='',range='';
for(const raw of source.slice(a+19,b).split(',')){const s=raw.trim(),m=s.match(/^(input|output|inout)\s+(?:(?:wire|reg|logic)\s+)?(\[[^\]]+\])?\s*(\w+)$/);if(m){dir=m[1];range=m[2]||'';ports.push({dir,range,name:m[3]});}else{assert(/^\w+$/.test(s)&&dir,s);ports.push({dir,range,name:s});}}
let tb=fs.readFileSync(p.join(d,'imports/imports_tb.sv'),'utf8');tb=tb.slice(0,tb.indexOf('reg[63:0]image[0:12287]'));
const start=tb.indexOf('savestates dut('),end=tb.indexOf('\n\nalways #5',start),inst=tb.slice(start,end),con={};
for(let i=inst.indexOf('(')+1;i<inst.length;){const m=inst.slice(i).match(/\.(\w+)\(/);if(!m)break;const at=i+m.index+m[0].length;let level=1,j=at;for(;level&&j<inst.length;j++){if(inst[j]==='(')level++;if(inst[j]===')')level--;}con[m[1]]=inst.slice(at,j-1);i=j;}
let decl='',nc=[],gc=[],checks=[];
for(const {dir,range,name}of ports){let expr=con[name];if(dir==='input'){if(expr===undefined)expr="'0";nc.push('.'+name+'('+expr+')');gc.push('.'+name+'('+expr+')');}else{decl+='wire '+range+' golden_'+name+';\n';if(!expr){expr='new_'+name;decl+='wire '+range+' '+expr+';\n';}nc.push('.'+name+'('+expr+')');gc.push('.'+name+'(golden_'+name+')');checks.push(`if(${expr} !== golden_${name})$fatal(1,"output ${name} candidate%0d golden%0d",dut.state,golden.state);`);}}
tb=tb.slice(0,start)+decl+'savestates #(.TB_FAST(1)) dut('+nc.join(',\n')+');\nsavestates_golden #(.TB_FAST(1)) golden('+gc.join(',\n')+');'+tb.slice(end);
tb=tb.replaceAll('force dut.op_cooldown=0;','force dut.op_cooldown=0;force golden.op_cooldown=0;').replaceAll('release dut.op_cooldown;','release dut.op_cooldown;release golden.op_cooldown;');
if(!tb.includes('assign restart_out=0;'))tb=tb.replace('assign replay=0;','assign replay=0;assign restart_out=0;');
tb=tb.replace('module vdp_tb;','module vdp_tb;\nreg active=0;reg[31:0]rng=32\'h65ac5e01;integer profile=0,cycles=0;\n');
tb=tb.replace('pending<=3;readaddr<=DDRAM_ADDR;','pending<=3+(profile%3==0?0:rng[7:4]);readaddr<=DDRAM_ADDR;');
tb+=`always@(negedge clk)if(reset_n)begin
 cycles++;${checks.join('\n')}
 if(cycles%1000000==0)$display("MITER_PROGRESS clocks%0d profile%0d state%0d busy%b",cycles,profile,dut.state,ss_busy);
 if(dut.state!==golden.state)$fatal(1,"FSM mismatch");
 if(active)begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};DDRAM_BUSY<=profile%3==0?0:rng[2:0]==0;end
end
reg[63:0]image[0:12287];
initial begin
 for(integer w=0;w<12288;w++)mem[w]=0;
 repeat(4)tick;reset_n=1;active=1;
 for(profile=0;profile<16;profile++)begin
  systeme=(profile>>2)&1;logical_pause=(profile>>3)&1;
  case(profile%4)0:clkd=0;1:clkd=10;2:clkd=20;3:clkd=25;endcase
  bg_live=0;bg2_live=0;expect_background=1;
  for(integer b=0;b<139;b++)begin bg_live[b]=rng[0];bg2_live[b]=rng[1];tick;end
  bg_live[22:15]=profile*13;bg2_live[22:15]=239-profile*13;
  transfer(1);for(integer w=0;w<12288;w++)image[w]=mem[w];
  for(integer replaynum=0;replaynum<3;replaynum++)transfer(0);
  expect_background=0;mem['h1a][63:22]=0;mem['he][63:52]=0;mem[5][63:38]=0;mem['h32]='1;mem['h2997]='1;
  for(integer replaynum=0;replaynum<2;replaynum++)transfer(0);
  if(!systeme)begin mem[0][63:32]=32'h3ffe;mem[5][63:20]=0;for(integer replaynum=0;replaynum<2;replaynum++)transfer(0);end
  $display("PASS MITER profile%0d current3 public96x2 public64x%0d",profile,systeme?0:2);
 end
 $display("PASS MITER ALL outputs${checks.length} profiles16 clocks%0d",cycles);$finish;
end
initial begin #1000000000;$fatal(1,"watchdog");end
endmodule\n`;
fs.writeFileSync(p.join(dst,'miter.sv'),tb);fs.writeFileSync(p.join(dst,'candidate.sv'),adapter(p.join(root,'rtl/savestates.sv')));fs.writeFileSync(p.join(dst,'golden.sv'),fs.readFileSync(p.join(d,'format/savestates_sim.sv'),'utf8').replace('module savestates #','module savestates_golden #'));
fs.writeFileSync(p.join(dst,'run.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib miter_work\nvlog -work miter_work -sv -quiet ../../../rtl/opll_snapshot.sv golden.sv candidate.sv miter.sv\nvsim -t 1ps miter_work.vdp_tb\nrun 10 us\necho "FIRST_STATE [examine /vdp_tb/dut/state] clocks [examine /vdp_tb/cycles]"\nrun -all\nquit -code 0\n');
console.log({ports:ports.length,outputs:checks.length});
