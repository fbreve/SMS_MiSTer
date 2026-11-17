const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const gate=JSON.parse(fs.readFileSync(p.join(d,'pre_edit_gate.json'),'utf8'));assert(gate.pass);
const top=fs.readFileSync(p.join(root,'SMS.sv'),'utf8');
const expression=top.match(/\.clkref\((\(ss_cpu_prepare[^\n]+)\),/)[1];
assert.equal(expression,'(ss_cpu_prepare || !(systeme || turbo)) ? ce_cpu : ce_pix');
const actual=expression.replaceAll('ss_cpu_prepare','cpu_prepare').replaceAll('turbo','(DUAL==4)');
for(const [source,name]of [['protocol','final_protocol'],['matrix','final_matrix']]){
 const src=p.join(d,source),dst=p.join(d,name);fs.mkdirSync(dst,{recursive:true});
 for(const f of ['audio_tb.sv','pin_model.sv','sdram.v','savestates_sim.sv','mapper_ctrl_sim.vhd','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','jt89.v','rom.hex','compile.do'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
 let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');assert(s.includes('.clkref(cpu_prepare ? ce_cpu : cpu_ce)'));
 s=s.replace('.clkref(cpu_prepare ? ce_cpu : cpu_ce)',`.clkref(${actual})`);fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
 if(name==='final_matrix'){
  const cases=[...JSON.parse(fs.readFileSync(p.join(src,'cases.json'))),...JSON.parse(fs.readFileSync(p.join(src,'additional_cases.json')))];fs.writeFileSync(p.join(dst,'cases.json'),JSON.stringify(cases,null,2));
 }
}
fs.writeFileSync(p.join(d,'final_source_bridge.json'),JSON.stringify({topSha256:crypto.createHash('sha256').update(top).digest('hex'),productionExpression:expression,simulationExpression:actual,modeMap:{SystemE:0,SMS:3,GGturbo:4,GGnormal:5},note:'Literal current top-level expression; known mode decode matches the fixture effective CPU clock.'},null,2));
console.log('Prepared fresh final-source protocol and 49-case integration fixtures.');
