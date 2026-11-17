const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..'),dest=path.join(d,'regressions');
const names=['savestate_hcounter','savestate_gg_io','savestate_md6','savestate_master_tap','savestate_paddle','savestate_eeprom','savestate_sc_ram','savestate_lightgun_fix','savestate_systeme_pause_fix','savestate_coverage','sram_architecture'];
fs.mkdirSync(path.join(d,'rtl'),{recursive:true});
for(const n of fs.readdirSync(path.join(r,'rtl')))if(n.endsWith('.mif'))fs.copyFileSync(path.join(r,'rtl',n),path.join(d,'rtl',n));
let ss=fs.readFileSync(path.join(d,'savestates_sim.sv'),'utf8'),manifest=[];
for(const name of names){
 const source=path.join(r,'tests',name),target=path.join(dest,name);fs.mkdirSync(target,{recursive:true});
 for(const ent of fs.readdirSync(source,{withFileTypes:true})){
  if(!ent.isFile()||!/\.(sv|vhd|v|do|mif)$/.test(ent.name))continue;
  let s=fs.readFileSync(path.join(source,ent.name),'utf8');
  // Advance only current writer expectations and future-version rejection.
  // The existing v1-v7 mutation vectors and all datapath assertions remain.
  if(/\.(sv|do)$/.test(ent.name))s=s.replaceAll('484309','48430a').replaceAll('484308','484309');
  if(ent.name==='savestates_sim.sv')s=ss;
  else if(/\.sv$/.test(ent.name))s=s.replace(/\bsavestates (\w+)\(/g,'savestates $1(.mapper_history_out(18\'h0ffff),.mapper_history_in(),');
  if(/\.do$/.test(ent.name))s=s.replaceAll('../../rtl','../../../../rtl');
  if(ent.name==='mapper_ctrl_sim.vhd')s=fs.readFileSync(path.join(d,'mapper_ctrl_sim.vhd'),'utf8');
  fs.writeFileSync(path.join(target,ent.name),s);manifest.push(name+'/'+ent.name);
 }
}
fs.copyFileSync(path.join(d,'banking.do'),path.join(d,'banking_current.do'));
fs.writeFileSync(path.join(d,'regression_sources.json'),JSON.stringify(manifest,null,2)+'\n');
console.log('Prepared isolated regression source copies; current v9 writer/future v10 expectations, unchanged datapath assertions.');
