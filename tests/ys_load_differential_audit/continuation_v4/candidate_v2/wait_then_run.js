const fs=require('fs'),p=require('path'),cp=require('child_process');
const file=p.join(__dirname,'seed_cold_reference.log');
const timer=setInterval(()=>{
 const text=fs.existsSync(file)?fs.readFileSync(file,'utf8'):'';
 if(text.includes('SEED_READY')){
  clearInterval(timer);
  const child=cp.spawn(process.execPath,[p.join(__dirname,'run_map_variants.js')],{cwd:__dirname,stdio:'inherit',windowsHide:true});
  child.on('exit',code=>{process.exitCode=code||0;});
 }else if(/\*\* Fatal:|Errors: [1-9]/.test(text)){
  clearInterval(timer);console.error('Seed generation failed; graphical comparisons were not started.');process.exitCode=1;
 }
},1000);
console.log('Waiting for qualified native seed export; validation precedes all graphical comparisons.');
