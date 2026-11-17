const fs=require('fs'),path=require('path'),cp=require('child_process');const root=path.resolve(__dirname,'../..');
const read=f=>fs.readFileSync(path.join(root,f),'utf8');const s=read('rtl/vdp.vhd');
const old=fs.existsSync(path.join(__dirname,'baseline/rtl/vdp.vhd'))?read('tests/savestate_hcounter/baseline/rtl/vdp.vhd'):cp.execFileSync('git',['show','8443a0d:rtl/vdp.vhd'],{cwd:root,encoding:'utf8'});
const fields=[...s.matchAll(/ss_regs_out\(([^)]+)\)\s*<=\s*(\w+)\s*;/g)];
for(const [,bits,name]of fields){const escaped=bits.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');if(!new RegExp('\\b'+name+'\\s*<=\\s*ss_regs_in\\('+escaped+'\\)').test(s))throw Error('asymmetric '+name);}
const oldfields=[...old.matchAll(/ss_regs_out\(([^)]+)\)\s*<=\s*([^;]+);/g)].map(m=>m[1]+'='+m[2].trim());
const newfields=[...s.matchAll(/ss_regs_out\(([^)]+)\)\s*<=\s*([^;]+);/g)].filter(m=>m[1]!=='135 downto 128').map(m=>m[1]+'='+m[2].trim());
if(JSON.stringify(oldfields)!==JSON.stringify(newfields))throw Error('old fields changed');
// Run original audit checks into a throwaway directory, preserving original audit evidence/hashes.
let auditResult='Shared audit script absent; focused packing checks pass.';
if(fs.existsSync(path.join(root,'tests/savestate_coverage/build_audit.js'))){
 let audit=read('tests/savestate_coverage/build_audit.js');
 const tmp=path.join(__dirname,'static_current');fs.mkdirSync(tmp,{recursive:true});
 audit=audit.replace('const dir=__dirname,root=path.resolve(dir,\'../..\');',`const dir=${JSON.stringify(tmp)},root=${JSON.stringify(root)};`);
 cp.execFileSync(process.execPath,['-e',audit],{cwd:root});
 auditResult='Original audit static checks pass.';
}
const result=`PASS ${fields.length} direct VDP fields symmetric; all original 128-bit field expressions unchanged; ${auditResult}\n`;
fs.writeFileSync(path.join(__dirname,'static.log'),result);console.log(result);
