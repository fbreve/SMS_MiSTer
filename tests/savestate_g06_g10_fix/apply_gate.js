const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const here=__dirname,root=p.resolve(here,'../..');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'utf8'}).trim();
if(git('rev-parse','HEAD')!=='8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a')throw Error('Wrong baseline');
if(git('branch','--show-current')!=='fix/savestate-g06-g10-restart')throw Error('Wrong branch');
if(git('diff','--name-only')||git('diff','--cached','--name-only'))throw Error('Production/staged tree already changed');
const logs=['protocol/sync_phase12_turbo/simulation.log','protocol/sync_phase12_normal/simulation.log','protocol/canonical_overflow/simulation.log','protocol_g01/ldir.log','protocol_nmi/sms_edge0.log','candidate/integrated_symbolic_turbo/simulation.log','candidate/integrated_symbolic_normal/simulation.log','candidate/paused_turbo/simulation.log'];
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
for(const f of logs){const s=fs.readFileSync(p.join(here,f),'utf8');if(!/Errors: 0,/.test(s)||/\*\* (Fatal|Error|Failure)/.test(s)||!/(DONE VDP|PASS (G01|F16|PROTOTYPE))/.test(s))throw Error('Gate failed: '+f);}
const files=['SMS.sv','rtl/T80/T80s.vhd','rtl/system.vhd','rtl/savestates.sv','rtl/vdp.vhd','rtl/vdp_main.vhd','rtl/vdp_sprites.vhd','rtl/vdp_sprite_shifter.vhd'];
const manifest=git('ls-files').split(/\r?\n/).map(f=>fs.statSync(p.join(root,f)).isFile()?{file:f,sha256:hash(p.join(root,f))}:{file:f,gitlink:git('rev-parse','HEAD:'+f)});
const gate={time:new Date().toISOString(),head:git('rev-parse','HEAD'),branch:git('branch','--show-current'),trackedDiff:git('diff','--stat'),staged:git('diff','--cached','--stat'),logs:logs.map(f=>({file:f,sha256:hash(p.join(here,f))})),documents:['contract.md','state_inventory.md','design_pre_edit.md'].map(f=>({file:f,sha256:hash(p.join(here,f))})),manifest,files};
fs.writeFileSync(p.join(here,'pre_edit_gate.json'),JSON.stringify(gate,null,2));
if(process.argv.includes('--apply'))for(const f of files)fs.copyFileSync(p.join(here,'candidate',f),p.join(root,f));
console.log('Pre-edit gate recorded: '+manifest.length+' tracked inputs; '+(process.argv.includes('--apply')?'eight production files applied.':'no production edit.'));
