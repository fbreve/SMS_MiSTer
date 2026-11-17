const fs=require('fs'),p=require('path'),assert=require('assert'),d=p.join(__dirname,'transport_equivalence'),adapter=require('./controller_adapter');
const current=p.resolve(__dirname,'../../rtl/savestates.sv');
fs.writeFileSync(p.join(d,'savestates_sim.sv'),adapter(current));
fs.writeFileSync(p.join(d,'golden.sv'),adapter(p.join(d,'before.sv')).replace('module savestates #','module savestates_golden #'));
let tb=fs.readFileSync(p.join(__dirname,'format/format_tb.sv'),'utf8');
const start=tb.indexOf('savestates dut('),end=tb.indexOf('\n\nalways #5',start),instance=tb.slice(start,end),connections={};
for(let i=instance.indexOf('(')+1;i<instance.length;){const m=instance.slice(i).match(/\.([A-Za-z0-9_]+)\(/);if(!m)break;const at=i+m.index+m[0].length;let level=1,j=at;for(;level&&j<instance.length;j++){if(instance[j]==='(')level++;if(instance[j]===')')level--;}connections[m[1]]=instance.slice(at,j-1);i=j;}
const source=fs.readFileSync(current,'utf8').replace(/\/\*[\s\S]*?\*\//g,'').replace(/\/\/[^\n]*/g,''),a=source.indexOf('module savestates ('),b=source.indexOf(');',a),ports=[];let dir='',range='';
for(const raw of source.slice(a+'module savestates ('.length,b).split(',')){
 let s=raw.trim(),m=s.match(/^(input|output|inout)\s+(?:(?:wire|reg|logic)\s+)?(\[[^\]]+\])?\s*(\w+)$/);
 if(m){dir=m[1];range=m[2]||'';ports.push({dir,range,name:m[3]});}
 else {assert(/^\w+$/.test(s)&&dir,'Port parse '+s);ports.push({dir,range,name:s});}
}
let decl='reg[4777:0]random_sprite1=0,random_sprite2=0;\n',nc=[],gc=[],checks=[];
for(const port of ports){const {name,range,dir}=port;let expr=connections[name];
 if(dir==='input'){assert(expr!==undefined&&expr!=='','Missing input '+name);if(name==='sprite_out')expr='random_sprite1';if(name==='sprite2_out')expr='random_sprite2';nc.push('.'+name+'('+expr+')');gc.push('.'+name+'('+expr+')');}
 else {decl+='wire '+range+' golden_'+name+';\n';if(expr===undefined||expr===''){expr='new_'+name;decl+='wire '+range+' '+expr+';\n';}nc.push('.'+name+'('+expr+')');gc.push('.'+name+'(golden_'+name+')');
  const guard=name==='sprite_in'?'vdp_regs_set':name==='sprite2_in'?'vdp2_regs_set':"1'b1";
  checks.push('if('+guard+' && ('+expr+' !== golden_'+name+'))$fatal(1,"transport output '+name+' mismatch state%0d golden%0d",dut.state,golden.state);');
 }
}
const inst=decl+'savestates #(.TB_FAST(1)) dut('+nc.join(',\n')+');\nsavestates_golden #(.TB_FAST(1)) golden('+gc.join(',\n')+');';
tb=tb.slice(0,start)+inst+tb.slice(end);
tb=tb.replace('force dut.op_cooldown=0;', 'force dut.op_cooldown=0;force golden.op_cooldown=0;').replace('release dut.op_cooldown;', 'release dut.op_cooldown;release golden.op_cooldown;');
tb=tb.replace('integer pending=0;', 'integer pending=0;').replace('pending<=3;readaddr<=DDRAM_ADDR;', 'pending<=extra_profiles?3+(rng[7:4]):3;readaddr<=DDRAM_ADDR;');
tb=tb.replace('reg[63:0]mem[0:12287];', 'reg extra_profiles=0;reg[31:0]rng=32\'h9e3779b9;\nreg[63:0]mem[0:12287];');
tb=tb.replace(' $display("PASS V14 FORMAT rejected%0d accepted%0d",rejections,accepted);$finish;', `
 $display("PASS V14 FORMAT rejected%0d accepted%0d",rejections,accepted);
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
  for(integer wordnum=0;wordnum<75;wordnum++)begin
   if(mem['h2901+wordnum]!==padded1[64*wordnum+:64]||mem['h294c+wordnum]!==padded2[64*wordnum+:64])$fatal(1,"full physical record writer profile%0d word%0d",profile,wordnum);
  end
  for(integer wordnum=0;wordnum<12288;wordnum++)saved_image[wordnum]=mem[wordnum];
  random_sprite1=~random_sprite1;random_sprite2=~random_sprite2;
  for(integer replaynum=0;replaynum<3;replaynum++)begin
   transfer(0);
   if(sprite_restored!==expected1||new_sprite2_in!==expected2)$fatal(1,"full physical record restore profile%0d replay%0d",profile,replaynum);
   for(integer wordnum=0;wordnum<12288;wordnum++)if(mem[wordnum]!==saved_image[wordnum])$fatal(1,"transport changed image");
  end
  $display("TRANSPORT_PROFILE PASS %0d systeme%b consumed%b",profile,systeme,!logical_pause);
 end
 $display("PASS TRANSPORT STREAM EQUIVALENCE outputs%0d format185 profiles16 loads48 physicalbits9556",${ports.filter(x=>x.dir==='output').length});$finish;
`);
tb=tb.replace(/\nendmodule\s*$/, `
reg[4777:0]expected1,expected2;wire[4799:0]padded1={22'd0,expected1},padded2={22'd0,expected2};reg[63:0]saved_image[0:12287];
always@(negedge clk)if(extra_profiles)begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};DDRAM_BUSY<=rng[2:0]==0;end
always@(negedge clk)if(reset_n)begin
 if(dut.state!==golden.state)$fatal(1,"transport FSM cycle differs %0d/%0d",dut.state,golden.state);
 ${checks.join('\n ')}
end
endmodule
`);
// Module variables must precede procedural use in the older simulator.
tb=tb.replace('reg[4777:0]expected1,expected2;wire[4799:0]padded1={22\'d0,expected1},padded2={22\'d0,expected2};reg[63:0]saved_image[0:12287];','');
tb=tb.replace('module vdp_tb;',"module vdp_tb;\nreg[4777:0]expected1,expected2;wire[4799:0]padded1={22'd0,expected1},padded2={22'd0,expected2};reg[63:0]saved_image[0:12287];");
fs.writeFileSync(p.join(d,'miter.sv'),tb);
fs.writeFileSync(p.join(d,'run.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib transport_work
vlog -work transport_work -sv -quiet golden.sv savestates_sim.sv miter.sv
vsim -c -t 1ps transport_work.vdp_tb
run -all
quit -code 0
`);
console.log('Prepared cycle-equivalence miter: '+ports.length+' ports, full physical dual records, inherited185 format checks');
