const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
let s=fs.readFileSync(path.join(r,'rtl/savestates.sv'),'utf8');
for(const n of ['mapper_snap','evolution_snap']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),decl=s.match(re)[0];s=s.replace(re,'').replace('// NVRAM size calculation helpers',decl+'// NVRAM size calculation helpers');}
for(const f of ['savestate_hcounter','savestate_gg_io','savestate_md6','savestate_master_tap','savestate_paddle','savestate_eeprom','savestate_sc_ram','savestate_lightgun_fix'])fs.writeFileSync(path.join(r,'tests',f,'savestates_sim.sv'),s);
console.log('Refreshed eight regression controller models from current production RTL (declaration ordering only).');
