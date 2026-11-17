// Builds the isolated verification harness: <task>/verification/{rtl,tests/ym2413_fullstate}, tools junction at <task>/tools.
const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert');
const task=__dirname,wt=p.join(task,'worktree'),vr=p.join(task,'verification'),td=p.join(vr,'tests/ym2413_fullstate'),src=p.resolve(task,'../ym2413_selfhealing_combined/worktree/tests/ym2413_fullstate');
assert(!fs.existsSync(vr),'Refuse overwriting verification');
fs.mkdirSync(td,{recursive:true});
fs.cpSync(p.join(wt,'rtl'),p.join(vr,'rtl'),{recursive:true});
const skip=/^(combined_(audio|trace)_.*|combined_results\.json|partial_.*|reproduction_results\.json|cross_engine\.json|manifest\.json|campaign_source_manifest\.json|combined_source_manifest\.json|artifacts_sha256\.json|source_identity\.json|production\.diff|preservation_final\.log|combined_collect\.log|COMBINED_EXPERIMENT\.md|.*\.(log|wlf|csv|bin))$/;
for(const e of fs.readdirSync(src,{withFileTypes:true})){if(!e.isFile()||skip.test(e.name))continue;fs.copyFileSync(p.join(src,e.name),p.join(td,e.name));}
const tools=p.join(task,'tools');
if(!fs.existsSync(tools))cp.execFileSync('cmd.exe',['/c','mklink','/J',tools,p.resolve(task,'../ym2413_selfhealing_combined/tools')],{stdio:'inherit'});
console.log(fs.readdirSync(td).length,'harness files copied');
