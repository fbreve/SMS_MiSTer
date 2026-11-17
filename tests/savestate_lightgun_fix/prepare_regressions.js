const fs=require('fs'),path=require('path'),cp=require('child_process'),r=path.resolve(__dirname,'../..');
function make(dir,name,source,lib){
 let s=fs.readFileSync(path.join(r,'tests',dir,source),'utf8');
 const old=s.match(/^vlib (\w+)/m)[1];
 s=s.replace(/^vlib \w+/m,'vlib '+lib).replace(/^(vcom|vlog)(.*)$/gm,(_,cmd,args)=>cmd+' -work '+lib+args.replace(/ -work \w+/g,''));
 s=s.replace(new RegExp('\\b'+old+'\\.','g'),lib+'.');
 fs.writeFileSync(path.join(r,'tests',dir,name+'.do'),s);
}
for(let i=0;i<3;i++)for(const dir of ['savestate_eeprom','savestate_sc_ram','savestate_master_tap'])make(dir,'f11_final'+i,'integration.do','f11_final'+i+'_work');
make('savestate_paddle','f11_final','stalls0.do','f11_final_work');
make('savestate_md6','f11_final','integration.do','f11_final_work');
for(const name of ['controller','integration'])make('savestate_hcounter','f11_'+name,name+'.do','f11_'+name+'_work');
for(let i=0;i<2;i++){
 cp.execFileSync(process.execPath,['tests/savestate_gg_io/prepare_integration.js'],{cwd:r,env:{...process.env,DDRAM_STALLS:String(i)}});
 const dir=path.join(r,'tests/savestate_gg_io');fs.copyFileSync(path.join(dir,'integration_tb.sv'),path.join(dir,'f11_integration'+i+'.sv'));
 make('savestate_gg_io','f11_final'+i,'integration.do','f11_final'+i+'_work');
 const p=path.join(dir,'f11_final'+i+'.do');fs.writeFileSync(p,fs.readFileSync(p,'utf8').replace('integration_tb.sv','f11_integration'+i+'.sv'));
}
