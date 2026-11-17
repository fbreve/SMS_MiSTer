const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,r=p.resolve(d,'../..'),{miter,shadowCPU}=require('./prepare');
const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n');
const mirror=s=>s.replace(/force dut\.(\w+)\s*=([^;]+);/g,(m,n,e)=>m+`force alias_ctl.${n}=${e};`).replace(/release dut\.(\w+);/g,(m,n)=>m+`release alias_ctl.${n};`);
function copy(src,dst){fs.mkdirSync(dst,{recursive:true});for(const f of fs.readdirSync(src))if(fs.statSync(p.join(src,f)).isFile()&&/\.(sv|vhd|v|svh|hex|do)$/.test(f))fs.copyFileSync(p.join(src,f),p.join(dst,f));}
{
 const src=p.join(r,'tests/savestate_g06_g10_fix/matrix_nmi'),dst=p.join(d,'native_nmi');copy(src,dst);
 fs.copyFileSync(p.join(d,'baseline_sim.sv'),p.join(dst,'savestates_integrated.sv'));fs.copyFileSync(p.join(d,'candidate_sim.sv'),p.join(dst,'candidate_sim.sv'));
 let s=read(p.join(dst,'fixed_tb.sv')).replaceAll("24'h48430e","24'h484313");
 s=s.replace('savestates dut(',"savestates dut(.fm_initialized(1'b1),.fm_state_rdata(32'd0),.audio_last_out(16'd0),.bg_out(139'd0),.bg2_out(139'd0),");
 const renamed=s.replace(/nmi_machine(\s*#\([\s\S]*?\))?\s+core\s*\(/,'T80s$1 cpu(');
 const names='wram_D cpu_reg nmi_snap nstate old_nmi nmi_replay ready gg_out io_out addr data di iset m1 mreq wr rd iq nmi_n restart_out'.split(' ');
 const shadow=shadowCPU(renamed,names.map(n=>n+':out std_logic;').join('\n')).replace(/T80s\s*#/,'nmi_machine #');
 const at=s.lastIndexOf('endmodule');s=s.slice(0,at)+miter()+shadow+s.slice(at);fs.writeFileSync(p.join(dst,'fixed_tb.sv'),mirror(s));
 let c=read(p.join(dst,'compile.do')).replace('savestates_integrated.sv','../../../rtl/opll_snapshot.sv savestates_integrated.sv candidate_sim.sv');fs.writeFileSync(p.join(dst,'compile.do'),c);
 const cases=JSON.parse(read(p.join(r,'tests/savestate_g01_cpu_restart_fix/nmi_final/cases.json')));
 for(const item of cases){const to=p.join(dst,item.name);fs.mkdirSync(to,{recursive:true});const args={SOURCE:item.source,PROGRAM:item.program,EDGE:item.edge,WIDTH:item.width,SECOND:item.second,HELD:item.held,SCHEDULE:item.schedule,FORMAT:item.format,RELEASE_SECOND:item.name==='both_released'?1:0};
 fs.writeFileSync(p.join(to,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -t 1ps final_work.fixed_tb -g/fixed_tb/dut/TB_FAST=1 ${Object.entries(args).map(([k,v])=>'-g'+k+'='+v).join(' ')}\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);}
 fs.writeFileSync(p.join(d,'nmi_cases.json'),JSON.stringify(cases,null,2));
}
{
 const src=p.join(r,'tests/savestate_f01_opll_fix/reg_g12'),dst=p.join(d,'native_pause');copy(src,dst);
 fs.copyFileSync(p.join(d,'baseline_sim.sv'),p.join(dst,'savestates_sim.sv'));fs.copyFileSync(p.join(d,'candidate_sim.sv'),p.join(dst,'candidate_sim.sv'));
 let s=read(p.join(dst,'audio_tb.sv')),h=read(p.join(dst,'pause_fixture.sv'));s=s.replace('savestates dut(',"savestates dut(.audio_last_out(16'd0),");
 // The fixture include is inside pause_tb. Attach the miter and real CPU there.
 const at=s.lastIndexOf('endmodule');assert(at>=0);s=s.slice(0,at)+miter()+shadowCPU(s+h,read(p.join(dst,'T80s_sim.vhd')))+s.slice(at);
 fs.writeFileSync(p.join(dst,'audio_tb.sv'),mirror(s));fs.writeFileSync(p.join(dst,'pause_fixture.sv'),mirror(h));
 fs.writeFileSync(p.join(dst,'compile.do'),read(p.join(dst,'compile.do')).replace('savestates_sim.sv','savestates_sim.sv candidate_sim.sv'));
 for(const saved of[0,1])for(const current of[0,1]){const name=`s${saved}_c${current}`,to=p.join(dst,name);fs.mkdirSync(to,{recursive:true});fs.copyFileSync(p.join(src,name,'run.do'),p.join(to,'run.do'));fs.copyFileSync(p.join(src,name,'rom.hex'),p.join(to,'rom.hex'));}
}
console.log('Prepared retained eight-triplet/GG NMI and four Pause combinations with real consumers and unchanged native oracles.');
