const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
assert(['FITS COMFORTABLY','FITS BUT REQUIRES CAUTION'].includes(require('./early_results.json').classification));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),rows=[];
function copyTop(src,dst){fs.mkdirSync(dst,{recursive:true});for(const f of fs.readdirSync(src)){const q=p.join(src,f);if(fs.statSync(q).isFile()&&/\.(sv|svh|vhd|v|do|json)$/.test(f))fs.copyFileSync(q,p.join(dst,f));}if(fs.existsSync(p.join(src,'rtl')))fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});}
function endpoint(s){return s.replace(/savestates\s+dut\s*\(/,"savestates dut(.fm_initialized(1'b1),.fm_state_rdata(32'd0),");}
function finish(dst,controller='savestates_sim.sv',fast=true){
 let ctrl=adapter(p.join(root,'rtl/savestates.sv'),fast);if(!fast)ctrl=ctrl.replace("20'd900000;","20'd0;");fs.writeFileSync(p.join(dst,controller),ctrl);
 for(const f of fs.readdirSync(dst).filter(x=>/\.(sv|svh)$/.test(x)&&x!==controller)){const q=p.join(dst,f);fs.writeFileSync(q,endpoint(fs.readFileSync(q,'utf8')));}
 let compile=fs.readFileSync(p.join(dst,'compile.do'),'utf8');compile=compile.replace(controller,'../../../rtl/opll_snapshot.sv '+controller);fs.writeFileSync(p.join(dst,'compile.do'),compile);
}
for(const [family,source,cases]of[
 ['reg_g05','g05_targeted',['dut_h0']],
 ['reg_sprites','sprites',['dut_collision','dut_overflow9']],
 ['reg_g10','phases',['dut_phases','dut_deterministic','dut_full_flush']],
 ['reg_dual','dual',['dut_collision']],
 ['reg_g04','g04',['dut_pending']]
]){
 const src=p.join(d,'../savestate_sprite_resource_optimization',source),dst=p.join(d,family);copyTop(src,dst);finish(dst);
 for(const name of cases){const sd=p.join(src,name),cd=p.join(dst,name);fs.mkdirSync(cd,{recursive:true});const fixtures=[];
  for(const f of fs.readdirSync(sd))if(f==='run.do'||/\.(dat|hex|bin)$/.test(f)){fs.copyFileSync(p.join(sd,f),p.join(cd,f));fixtures.push({file:f,sha256:sha(fs.readFileSync(p.join(sd,f)))});}
  const marker=family==='reg_sprites'?'DONE VDP':family==='reg_g05'?'PASS RICH V15 VDP':'PASS V15 VDP';rows.push({family,name,library:'vdp_work',marker,fixtures});
 }
}
// Existing ten-program registered-ROM CPU restart suite.
{
 const family='reg_g01',src=p.join(d,'../savestate_g12_sdram_fix/g01'),dst=p.join(d,family);copyTop(src,dst);finish(dst,'savestates_integrated.sv',false);
 const file=p.join(dst,'trace_tb.sv');fs.writeFileSync(file,fs.readFileSync(file,'utf8').replaceAll("24'h484310","24'h484311"));
 for(const c of JSON.parse(fs.readFileSync(p.join(src,'cases.json')))){
  const name='p'+c.args.PROGRAM,cd=p.join(dst,name);fs.mkdirSync(cd,{recursive:true});
  fs.writeFileSync(p.join(cd,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -t 1ps trace_work.fixed_tb ${Object.entries(c.args).map(([k,v])=>'-g'+k+'='+v).join(' ')}\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);
  rows.push({family,name,library:'trace_work',marker:'PASS G01 TRACE'});
 }
}
// G12 exactly-once physical request/pin protocol, with real Pause gate.
{
 const family='reg_g12',src=p.join(d,'../savestate_g12_sdram_fix/final_protocol'),dst=p.join(d,family);copyTop(src,dst);finish(dst);
 for(const saved of [0,1])for(const current of [0,1]){
  const name=`s${saved}_c${current}`,cd=p.join(dst,name);fs.mkdirSync(cd,{recursive:true});fs.copyFileSync(p.join(src,'rom.hex'),p.join(cd,'rom.hex'));
  fs.writeFileSync(p.join(cd,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -t 1ps -L altera_mf pause_work.pause_tb -gDUAL=0 -gBOOT=1200 -gTAIL_DELAY=8 -gSAVED_PAUSED=${saved} -gCURRENT_PAUSED=${current} -gTAC=1 -g/pause_tb/dut/TB_FAST=1\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);
  rows.push({family,name,library:'pause_work',marker:'PASS G12 LOAD_RUNNING',also:'PASS_REISSUE',covers:['G12','F12']});
 }
}
fs.writeFileSync(p.join(d,'regression_manifest.json'),JSON.stringify(rows,null,2));console.log('Prepared '+rows.length+' targeted cases; prior fixtures and oracles copied unchanged.');
