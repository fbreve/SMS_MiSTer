const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert'),d=__dirname,repo=p.resolve(d,'../..'),out=p.join(d,'fault'),old=p.join(repo,'tests/ym2413_collision_reachability');fs.mkdirSync(out,{recursive:true});
for(const f of ['make_tb.js','check_process_tree.ps1'])fs.copyFileSync(p.join(old,f),p.join(out,f));
let s=fs.readFileSync(p.join(old,'prepare.js'),'utf8').replace("root=p.resolve(d,'../..')",'root='+JSON.stringify(repo));
s=s.replace("adapt(git('show',base+':rtl/VM2413/'+n+'.vhd'))",`adapt(lib==='candidate'&&n==='outputmemory'?fs.readFileSync(${JSON.stringify(p.join(d,'worktree/rtl/VM2413/outputmemory.vhd'))},'latin1'):git('show',base+':rtl/VM2413/'+n+'.vhd'))`);
fs.writeFileSync(p.join(out,'prepare.js'),s);
s=fs.readFileSync(p.join(old,'run.ps1'),'utf8');const exe=p.join(repo,'tests/ym2413_selfhealing_combined/tools/ghdl6/bin/ghdl.exe').replaceAll('\\','/');s=s.replace("$taskExe=(Resolve-Path '../ym2413_selfhealing_combined/tools/ghdl6/bin/ghdl.exe').Path",`$taskExe='${exe}'`);fs.writeFileSync(p.join(out,'run.ps1'),s);
cp.execFileSync('node',['prepare.js'],{cwd:out,stdio:'inherit'});cp.execFileSync('node',['make_tb.js'],{cwd:out,stdio:'inherit'});
assert(fs.readFileSync(p.join(out,'candidate/outputmemory.vhd'),'latin1').includes('signal is "MLAB"'));assert(fs.readFileSync(p.join(out,'reference/outputmemory.vhd'),'latin1').includes('signal is "logic"'));
console.log('PASS independent pinned logic/MLAB libraries and test-only adversarial collisions prepared outside worktree');
