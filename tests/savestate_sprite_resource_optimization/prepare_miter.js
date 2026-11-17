const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,adapter=require('../savestate_g06_g10_fix/controller_adapter');
const variant=process.argv[2]||'A',focused=process.argv.includes('--focused'),dst=p.join(d,(focused?'focused_':'miter_')+variant);fs.mkdirSync(dst,{recursive:true});
fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(p.join(d,'candidate_'+variant+'.sv')));
fs.writeFileSync(p.join(dst,'golden.sv'),adapter(p.join(d,'baseline.sv')).replace('module savestates #','module savestates_golden #'));
let tb=fs.readFileSync(p.join(d,'../savestate_g08_release_fix/format/format_tb.sv'),'utf8');
const start=tb.indexOf('savestates dut('),end=tb.indexOf('\n\nalways #5',start);assert(start>=0&&end>start);const inst=tb.slice(start,end),con={};
for(let i=inst.indexOf('(')+1;i<inst.length;){const m=inst.slice(i).match(/\.(\w+)\(/);if(!m)break;const at=i+m.index+m[0].length;let level=1,j=at;for(;level&&j<inst.length;j++){if(inst[j]==='(')level++;if(inst[j]===')')level--;}con[m[1]]=inst.slice(at,j-1);i=j;}
const source=fs.readFileSync(p.join(d,'baseline.sv'),'utf8').replace(/\/\*[\s\S]*?\*\//g,'').replace(/\/\/[^\n]*/g,''),a=source.indexOf('module savestates ('),b=source.indexOf(');',a),ports=[];let dir='',range='';
for(const raw of source.slice(a+19,b).split(',')){const s=raw.trim(),m=s.match(/^(input|output|inout)\s+(?:(?:wire|reg|logic)\s+)?(\[[^\]]+\])?\s*(\w+)$/);if(m){dir=m[1];range=m[2]||'';ports.push({dir,range,name:m[3]});}else{assert(/^\w+$/.test(s)&&dir,'port '+s);ports.push({dir,range,name:s});}}
let decl='reg [4777:0] random_sprite1=0,random_sprite2=0;\n',nc=[],gc=[],checks=[];
for(const {dir,range,name}of ports){let expr=con[name];if(dir==='input'){assert(expr!==undefined&&expr!=='','input '+name);if(name==='sprite_out')expr='random_sprite1';if(name==='sprite2_out')expr='random_sprite2';nc.push('.'+name+'('+expr+')');gc.push('.'+name+'('+expr+')');}
else{decl+='wire '+range+' golden_'+name+';\n';if(expr===undefined||expr===''){expr='new_'+name;decl+='wire '+range+' '+expr+';\n';}nc.push('.'+name+'('+expr+')');gc.push('.'+name+'(golden_'+name+')');checks.push(`if(${expr} !== golden_${name}) $fatal(1,"Miter output ${name} state%0d golden%0d",dut.state,golden.state);`);}}
tb=tb.slice(0,start)+decl+'savestates #(.TB_FAST(1)) dut('+nc.join(',\n')+');\nsavestates_golden #(.TB_FAST(1)) golden('+gc.join(',\n')+');'+tb.slice(end);
tb=tb.replaceAll('force dut.op_cooldown=0;','force dut.op_cooldown=0;force golden.op_cooldown=0;').replaceAll('release dut.op_cooldown;','release dut.op_cooldown;release golden.op_cooldown;');
tb=tb.replace('$display("PASS V16 FORMAT rejected%0d accepted%0d two139bitRecords onehots139 positions240 inherited1to14 old64",rejections,accepted);$finish;',`$display("PASS V16 FORMAT rejected%0d accepted%0d",rejections,accepted);
 extra_profiles=1;
 for(integer profile=0;profile<16;profile++)begin
  systeme=(profile>>2)&1;logical_pause=(profile>>3)&1;
  case(profile%4)0:clkd=0;1:clkd=10;2:clkd=20;3:clkd=25;endcase
  for(integer bitnum=0;bitnum<4778;bitnum++)begin
   rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};random_sprite1[bitnum]=rng[0];
   rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};random_sprite2[bitnum]=rng[0];
  end
  expected1=random_sprite1;expected2=systeme?random_sprite2:4778'd0;
  transfer(1);
  for(integer w=0;w<75;w++)if(mem['h2901+w]!==padded1[64*w+:64]||mem['h294c+w]!==padded2[64*w+:64])$fatal(1,"packed sprite word profile%0d word%0d",profile,w);
  for(integer w=0;w<12288;w++)image_copy[w]=mem[w];
  random_sprite1=~random_sprite1;random_sprite2=~random_sprite2;
  for(integer replaynum=0;replaynum<3;replaynum++)begin
   transfer(0);if(sprite_restored!==expected1||new_sprite2_in!==expected2)$fatal(1,"sprite replay profile%0d replay%0d",profile,replaynum);
   for(integer w=0;w<12288;w++)if(mem[w]!==image_copy[w])$fatal(1,"image modified");
  end
  $display("MATRIX PASS profile%0d",profile);
 end
 $display("PASS EXACT CONTROLLER MITER outputs${checks.length} format%0d profiles16 loads48 cycles%0d",rejections+accepted,compared_cycles);$finish;`);
const vars="reg extra_profiles=0;reg[31:0]rng=32'h9e3779b9;reg[4777:0]expected1,expected2;wire[4799:0]padded1={22'd0,expected1},padded2={22'd0,expected2};reg[63:0]image_copy[0:12287];integer compared_cycles=0;\n";
tb=tb.replace('module vdp_tb;','module vdp_tb;\n'+vars);
if(focused){tb=tb.replace('bitindex<139','bitindex<0').replace('pos<240','pos<0');}
tb=tb.replace('pending<=3;readaddr<=DDRAM_ADDR;','pending<=extra_profiles?3+rng[7:4]:3;readaddr<=DDRAM_ADDR;');
tb=tb.replace(/\nendmodule\s*$/,`\nalways@(negedge clk)if(extra_profiles)begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};DDRAM_BUSY<=rng[2:0]==0;end
always@(negedge clk)if(reset_n)begin
 compared_cycles++;
 if(dut.state!==golden.state || dut.sprite_snap!==golden.sprite_snap || dut.sprite2_snap!==golden.sprite2_snap)$fatal(1,"Miter state/bank state%0d",dut.state);
 ${checks.join('\n ')}
end
endmodule\n`);
fs.writeFileSync(p.join(dst,'miter.sv'),tb);fs.writeFileSync(p.join(dst,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib miter_work\nvlog -work miter_work -sv -quiet golden.sv savestates_sim.sv miter.sv\nvsim -c -t 1ps miter_work.vdp_tb\nrun -all\nquit -code 0\n`);
console.log('Prepared exact all-clock/all-output miter variant'+variant+' ports'+ports.length+' outputs'+checks.length);
