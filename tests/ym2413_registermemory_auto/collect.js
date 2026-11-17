const fs=require('fs'),p=require('path'),cp=require('child_process'),c=require('crypto'),assert=require('assert'),d=__dirname,td=p.join(d,'worktree/tests/ym2413_fullstate'),logs=p.join(td,'logs');
const hash=b=>c.createHash('sha256').update(b).digest('hex');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
cp.execFileSync('node',[p.join(d,'verify.js')],{stdio:'inherit'});
const phases=[];let pending=0,rawChecks=0;const egstates=new Set();
for(let i=0;i<72;i++){
 const n='phase_'+i,s=read(p.join(logs,n+'.stdout.log')),priority=read(p.join(logs,n+'.priority.log'));
 assert.equal(read(p.join(logs,n+'.exitcode')).trim(),'0',n+' exit');assert(s.includes('PASS AUTO ALL loads=2 shift='+i+' raw_checks='),n+' completion');assert(!/assertion (failure|error)/.test(s));
 const follow=[...s.matchAll(/PASS EXACT LOAD shift=(\d+) pass=(\d+) follow_ns=(\d+) checks=(\d+)/g)];assert.equal(follow.length,2,n+' LOAD count');for(const m of follow)assert(+m[3]>=115000000,n+' follow-up');
 for(const [j,m]of follow.entries()){assert.equal(+m[1],i,'follow phase');assert.equal(+m[2],j,'follow pass');}
 const saved=[...s.matchAll(/PASS SAVE shift=(\d+) pass=(\d+) pending='([01])' envelope=(\d+)/g)];assert.equal(saved.length,2);for(const [j,m]of saved.entries()){assert.equal(+m[1],i,'saved phase');assert.equal(+m[2],j,'saved pass');pending+=+m[3];egstates.add(+m[4]);}
 assert(/Priority=Idle ParentPriority=Idle/.test(priority)&&/VerifiedIdleSamples=[1-9]\d*/.test(priority),n+' priority');
 const checks=+s.match(/raw_checks=(\d+)/)[1];rawChecks+=checks;
 phases.push({shift:i,LOADs:2,followup_ns:follow.map(m=>+m[3]),rawChecks:checks,priority:'Idle',stdoutSHA256:hash(fs.readFileSync(p.join(logs,n+'.stdout.log')))});
}
assert(pending>0,'No pending-write snapshots');
const regressions={};
for(const [name,pass]of [['independent_map','PASS independent pattern ALL'],['protocol','PASS protocol ALL'],['nonfm','PASS nonFM ALL'],['phases','PASS PHASE SWEEP ALL'],...Array.from({length:7},(_,i)=>['fullstate_mode'+i,'PASS fullstate'])]){
 const text=read(p.join(logs,name+'.log'));assert.equal(+read(p.join(logs,name+'.exitcode')).trim(),0,name+' exit');assert(text.includes(pass),name+' PASS');assert(!/\*\* (Fatal|Error|Failure):/.test(text),name+' failure');
 regressions[name]={PASS:true,summary:text.split(/\r?\n/).filter(x=>x.includes(pass)),logSHA256:hash(fs.readFileSync(p.join(logs,name+'.log')))};
}
const bank=read(p.join(logs,'bank.stdout.log'));assert(bank.includes('PASS BANK ALL'));assert.equal(+read(p.join(logs,'bank.exitcode')).trim(),0);
const priorityLogs=fs.readdirSync(logs).filter(f=>f.endsWith('.priority.log'));for(const f of priorityLogs){const s=read(p.join(logs,f));assert(s.includes('Priority=Idle ParentPriority=Idle')&&/VerifiedIdleSamples=[1-9]\d*/.test(s),'Priority proof '+f);}
const artifactFiles=fs.readdirSync(d).filter(f=>/\.(js|ps1|vhd|diff|json)$/.test(f)&&f!=='results.json'&&f!=='artifacts_sha256.json');
const results={PASS:true,baseline:'9873761503510e4b2c7e06600bf5515344235c2f',productionChange:'registermemory.vhd ramstyle logic -> AUTO only',ghdl:{path:p.resolve(d,'../ym2413_selfhealing_combined/tools/ghdl6/bin/ghdl.exe'),SHA256:hash(fs.readFileSync(p.resolve(d,'../ym2413_selfhealing_combined/tools/ghdl6/bin/ghdl.exe'))),verifiedPriorityLogs:priorityLogs.length,maxConcurrentSimulations:4},phases,LOADs:144,rawStateAndAudioChecks:rawChecks,pendingWriteSnapshots:pending,envelopeStates:[...egstates].sort(),bank:{PASS:true,summary:bank.match(/PASS BANK ALL[^\r\n]+/)[0]},regressions,synthesis:'NOT RUN; RAM inference and hardware collision semantics remain unproven',preservation:'PASS exact production scope, master, sys, all prior worktrees, empty index',artifacts:Object.fromEntries(artifactFiles.map(f=>[f,hash(fs.readFileSync(p.join(d,f)))]))};
fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log(JSON.stringify({PASS:true,LOADs:results.LOADs,rawChecks,pending,egstates:results.envelopeStates,priorityLogs:priorityLogs.length,bank:results.bank,regressions:Object.keys(regressions)},null,2));
