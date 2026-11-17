const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),old=p.join(root,'tests/savestate_g08_release');
const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n'),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const head=cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim();
if(head!=='f205b05dc058fc5f7f2432779b61e8f3b0e22519')throw Error('Unexpected baseline');
if(!fs.existsSync(p.join(d,'baseline.json'))){const files=cp.execFileSync('git',['ls-files'],{cwd:root,encoding:'utf8'}).trim().split('\n').filter(f=>fs.existsSync(p.join(root,f))&&fs.statSync(p.join(root,f)).isFile());fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head,files:Object.fromEntries(files.map(f=>[f,hash(fs.readFileSync(p.join(root,f)))]))},null,2));}
const controller=require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv'));
function phaseFix(s){return s.replace('bg_snap<=bg_out;', 'audio_phase_snap<=audio_phase_out; // post-T next channel, not transport phase\n            bg_snap<=bg_out;').replace('                audio_phase_snap <= audio_phase_out;','                // Audio phase was captured at ARM, before transport advanced.').replace('if (!do_save && has_audio_ext) begin','if (do_save || has_audio_ext) begin');}
for(const kind of ['baseline','prototype']){
const dst=p.join(d,kind);fs.mkdirSync(dst,{recursive:true});
for(const f of ['T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','rom.hex','audio_tb.sv'])fs.copyFileSync(p.join(old,f),p.join(dst,f));
fs.writeFileSync(p.join(dst,'savestates_sim.sv'),kind==='prototype'?phaseFix(controller):controller);
let c=read(p.join(old,'compile.do')).replaceAll('../../rtl','../../../rtl');fs.writeFileSync(p.join(dst,'compile.do'),c);
fs.writeFileSync(p.join(dst,'run.do'),read(p.join(old,'run.do')));
}
fs.writeFileSync(p.join(d,'phase_fix.js'),'module.exports='+phaseFix.toString()+';\n');
console.log('Prepared untouched baseline and phase-only test prototype. No production edits.');
