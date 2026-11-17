const fs=require('fs'),p=require('path'),d=__dirname,src=p.resolve(d,'../savestate_g12_sdram'),dst=p.join(d,'matrix');
fs.mkdirSync(dst,{recursive:true});
for(const f of ['audio_tb.sv','pin_model.sv','sdram.v','savestates_sim.sv','mapper_ctrl_sim.vhd','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','jt89.v','rom.hex','compile.do'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
const start=s.indexOf('sdram live('),end=s.indexOf('\n',start),line=s.slice(start,end);
if(!line.includes('.clkref(cpu_ce)'))throw Error('missing reference');
s=s.slice(0,start)+line.replace('.clkref(cpu_ce)','.clkref(cpu_prepare ? ce_cpu : cpu_ce)')+s.slice(end);
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
fs.writeFileSync(p.join(dst,'compile.do'),fs.readFileSync(p.join(dst,'compile.do'),'utf8').replaceAll('../../rtl/','../../../rtl/'));
// Focus on ROM timing, repeated replay, legal arrival timing, stalls, and the
// natural same-complete-image/different-controller-history pair. The full shared
// transfer campaign remains closed and is deliberately not repeated.
let cases=JSON.parse(fs.readFileSync(p.join(src,'cases.json'),'utf8')).filter(c=>!c.id.startsWith('transfer_'));
cases=cases.filter(c=>!c.args.TRANSFER);
cases.push(...JSON.parse(fs.readFileSync(p.join(src,'sanity_cases.json'),'utf8')));
fs.writeFileSync(p.join(dst,'cases.json'),JSON.stringify(cases,null,2));
fs.copyFileSync(p.join(src,'matrix.ps1'),p.join(d,'matrix.ps1'));
console.log('Prepared '+cases.length+' prototype integration cases.');
