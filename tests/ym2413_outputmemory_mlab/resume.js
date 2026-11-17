const fs=require('fs'),p=require('path'),c=require('crypto'),assert=require('assert'),d=__dirname,logs=p.join(d,'worktree/tests/ym2413_fullstate/logs'),archive=p.join(d,'suspend_interruption_36_39');
if(fs.existsSync(archive))assert(fs.readdirSync(archive).every(f=>f==='windows_events.json'));else fs.mkdirSync(archive);const records={reason:'Windows System Kernel-Power confirms suspend/resume; four wall-clock timeouts, no RTL assertion failure. Archive incomplete attempts and retry unchanged stimuli.',files:{}};
for(let shift=36;shift<=39;shift++){
 assert(!fs.existsSync(p.join(logs,'phase_'+shift+'.exitcode')));
 const errorBytes=fs.readFileSync(p.join(d,'phase'+shift+'.launch.error.log')),error=errorBytes.toString(errorBytes[0]===255&&errorBytes[1]===254?'utf16le':'utf8');assert(error.includes('GHDL process timeout'));
 for(const ext of ['stdout.log','stderr.log','priority.log']){const f=p.join(logs,'phase_'+shift+'.'+ext),b=fs.readFileSync(f);assert(!/assertion (failure|error)/.test(b.toString()));records.files[p.basename(f)]=c.createHash('sha256').update(b).digest('hex');fs.renameSync(f,p.join(archive,p.basename(f)));}
 for(const ext of ['launch.log','launch.error.log']){const f=p.join(d,'phase'+shift+'.'+ext);fs.renameSync(f,p.join(archive,p.basename(f)));}
}
fs.copyFileSync(p.join(d,'run_ghdl.ps1'),p.join(archive,'original_wall_watchdog.ps1'));
fs.writeFileSync(p.join(archive,'reason.json'),JSON.stringify(records,null,2)+'\n');
let launcher=fs.readFileSync(p.join(d,'run_ghdl.ps1'),'utf8');
launcher=launcher.replace("$ErrorActionPreference='Stop'",`$ErrorActionPreference='Stop'
if(!('OutputActiveClock' -as [type])){Add-Type -TypeDefinition @'
using System;using System.Runtime.InteropServices;
public static class OutputActiveClock {
 [DllImport("kernel32.dll")] static extern bool QueryUnbiasedInterruptTime(out ulong t);
 public static double Seconds(){ulong t;if(!QueryUnbiasedInterruptTime(out t))throw new Exception("Active clock unavailable");return t/10000000.0;}
}
'@}
$taskActiveStart=[OutputActiveClock]::Seconds()`);
launcher=launcher.replace('$taskWatch.Elapsed.TotalSeconds -gt $TimeoutSeconds','([OutputActiveClock]::Seconds()-$taskActiveStart) -gt $TimeoutSeconds');
fs.writeFileSync(p.join(d,'run_ghdl.ps1'),launcher);
let campaign=fs.readFileSync(p.join(d,'campaign.ps1'),'utf8').replace('$taskNext=0;$taskRunning=@();$taskDone=0;','$taskNext=36;$taskRunning=@();$taskDone=36;');
fs.writeFileSync(p.join(d,'campaign_resume.ps1'),campaign);console.log('PASS incomplete suspend attempts retained; unchanged test resumed at phase36, bounded watchdog excludes S3 sleep');
