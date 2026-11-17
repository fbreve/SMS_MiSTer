const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'_archive/prepare.js'),'utf8');
s=s.replace("d=__dirname;","root=p.resolve(__dirname,'../..'),d=p.resolve(process.argv[2]);\nfs.mkdirSync(d,{recursive:true});");
s=s.replace("cp.execFileSync('git',['show','ab09fdf:rtl/savestates.sv'],{encoding:'utf8'})","cp.execFileSync('git',['show','ab09fdf41221c9e3e77eee87264a125ba43021fe:rtl/savestates.sv'],{cwd:root,encoding:'utf8'})");
s=s.replace("fs.readFileSync('rtl/savestates.sv','utf8')","cp.execFileSync('git',['show','28ead01f7f8709ddda5dc4a63206b9921cb757e0:rtl/savestates.sv'],{cwd:root,encoding:'utf8'})");
s=s.replace("fs.readFileSync('tests/feedback_memory_auto/savestate_tb.sv','utf8')","fs.readFileSync(p.join(__dirname,'fixtures/regression_tb.sv'),'utf8').replace(/^\\uFEFF/,'')");
s=s.replace(/tb=tb\.replace[^\n]+\n/,'');
s=s.slice(0,s.indexOf("fs.writeFileSync(p.join(d,'run.do')"));
fs.writeFileSync(p.join(d,'prepare.js'),s);
for(const name of ['prepare_focused.js','prepare_targeted.js']){
 let s=fs.readFileSync(p.join(d,name),'utf8').replace('d=__dirname;','d=p.resolve(process.argv[2]);');
 s=s.replace("s=s.replace('transitions<100','transitions<100');",'');
 if(name==='prepare_targeted.js')s=s.replace(" $display(\"PASS focused`);"," $display(\"PASS targeted`);");
 fs.writeFileSync(p.join(d,name),s);
}
